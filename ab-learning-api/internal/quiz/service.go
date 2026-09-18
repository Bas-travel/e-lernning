package quiz

import (
	"context"
	"errors"
	"math"
	"strconv"
	"strings"
	"time"

	"github.com/ablearning/ab-learning-api/internal/platform"
)

// Store is the persistence contract the grading rules need.
type Store interface {
	FindQuizByID(ctx context.Context, id int64) (Quiz, error)
	FindQuizByCourse(ctx context.Context, courseID int64) (Quiz, error)
	ListQuestions(ctx context.Context, quizID int64) ([]Question, error)
	SaveAttempt(ctx context.Context, quizID, userID int64, answers map[string]string, scorePct float64, passed bool, breakdown map[string]float64) (int64, error)
	ListAttempts(ctx context.Context, quizID, userID int64) ([]Attempt, error)
	FindBestAttempt(ctx context.Context, quizID, userID int64) (Attempt, error)
}

// EnrollmentChecker gates quiz-taking on owning the course. The learning
// domain implements it; nil means "don't gate" (used by unit tests).
type EnrollmentChecker interface {
	IsEnrolled(ctx context.Context, userID, courseID int64) (bool, error)
}

// Service grades quiz submissions and keeps the attempt history.
type Service struct {
	store       Store
	enrollments EnrollmentChecker
}

func NewService(store Store, enrollments EnrollmentChecker) *Service {
	return &Service{store: store, enrollments: enrollments}
}

// GetQuiz implements GET /quizzes/{id}. The returned questions carry no
// correct answers — grading happens server-side in Submit.
func (s *Service) GetQuiz(ctx context.Context, quizID int64) (QuizResponse, error) {
	quiz, questions, err := s.loadQuiz(ctx, quizID)
	if err != nil {
		return QuizResponse{}, err
	}
	return toQuizResponse(quiz, questions), nil
}

// GetCourseQuiz implements GET /courses/{id}/quiz — the course detail
// screen's entry point into practice.
func (s *Service) GetCourseQuiz(ctx context.Context, courseID int64) (QuizResponse, error) {
	quiz, err := s.store.FindQuizByCourse(ctx, courseID)
	if errors.Is(err, ErrQuizNotFound) {
		return QuizResponse{}, platform.ErrNotFound("This course has no quiz yet.")
	}
	if err != nil {
		return QuizResponse{}, err
	}

	questions, err := s.store.ListQuestions(ctx, quiz.ID)
	if err != nil {
		return QuizResponse{}, err
	}
	return toQuizResponse(quiz, questions), nil
}

// Submit implements POST /quizzes/{id}/submit. It grades against the stored
// answers, records the attempt, and returns both the score and the
// per-question corrections the result screen renders.
func (s *Service) Submit(ctx context.Context, userID, quizID int64, answers map[string]string) (AttemptResultResponse, error) {
	if len(answers) == 0 {
		return AttemptResultResponse{}, platform.ErrValidation("answers are required")
	}

	quiz, questions, err := s.loadQuiz(ctx, quizID)
	if err != nil {
		return AttemptResultResponse{}, err
	}
	if len(questions) == 0 {
		return AttemptResultResponse{}, platform.ErrValidation("This quiz has no questions yet.")
	}

	if s.enrollments != nil {
		enrolled, err := s.enrollments.IsEnrolled(ctx, userID, quiz.CourseID)
		if err != nil {
			return AttemptResultResponse{}, err
		}
		if !enrolled {
			return AttemptResultResponse{}, platform.ErrForbidden("Enroll in this course before taking its quiz.")
		}
	}

	results := make([]QuestionResult, 0, len(questions))
	skillHits := map[string]int{}
	skillTotals := map[string]int{}
	score := 0

	for _, question := range questions {
		chosen := resolveChoice(question, answers[strconv.FormatInt(question.ID, 10)])
		correct := chosen != "" && chosen == question.CorrectChoice
		if correct {
			score++
		}

		tag := question.SkillTag
		if tag == "" {
			tag = GeneralSkillTag
		}
		skillTotals[tag]++
		if correct {
			skillHits[tag]++
		}

		results = append(results, QuestionResult{
			QuestionID:    question.ID,
			Chosen:        chosen,
			CorrectChoice: question.CorrectChoice,
			Correct:       correct,
			SkillTag:      question.SkillTag,
		})
	}

	scorePct := round2(float64(score) / float64(len(questions)) * 100)
	passed := scorePct >= quiz.PassScorePct

	breakdown := make(map[string]float64, len(skillTotals))
	for tag, total := range skillTotals {
		breakdown[tag] = round2(float64(skillHits[tag]) / float64(total) * 100)
	}

	attemptID, err := s.store.SaveAttempt(ctx, quiz.ID, userID, answers, scorePct, passed, breakdown)
	if err != nil {
		return AttemptResultResponse{}, err
	}

	return AttemptResultResponse{
		AttemptID:      attemptID,
		QuizID:         quiz.ID,
		Title:          quiz.Title,
		Score:          score,
		Total:          len(questions),
		ScorePct:       scorePct,
		PassScorePct:   quiz.PassScorePct,
		Passed:         passed,
		SkillBreakdown: breakdown,
		Results:        results,
		AttemptedAt:    time.Now().Format(time.RFC3339),
	}, nil
}

// History implements GET /quizzes/{id}/attempts — the learner's own past
// scores, newest first.
func (s *Service) History(ctx context.Context, userID, quizID int64) ([]Attempt, error) {
	if _, err := s.store.FindQuizByID(ctx, quizID); err != nil {
		if errors.Is(err, ErrQuizNotFound) {
			return nil, platform.ErrNotFound("Quiz could not be found.")
		}
		return nil, err
	}
	return s.store.ListAttempts(ctx, quizID, userID)
}

func (s *Service) loadQuiz(ctx context.Context, quizID int64) (Quiz, []Question, error) {
	quiz, err := s.store.FindQuizByID(ctx, quizID)
	if errors.Is(err, ErrQuizNotFound) {
		return Quiz{}, nil, platform.ErrNotFound("Quiz could not be found.")
	}
	if err != nil {
		return Quiz{}, nil, err
	}

	questions, err := s.store.ListQuestions(ctx, quizID)
	if err != nil {
		return Quiz{}, nil, err
	}
	return quiz, questions, nil
}

// resolveChoice maps whatever the client sent back onto a choice ID. It
// accepts the choice's ID or its exact text (case-insensitive), because the
// quiz screen renders text and older builds echoed it straight back.
func resolveChoice(q Question, raw string) string {
	trimmed := strings.TrimSpace(raw)
	if trimmed == "" {
		return ""
	}
	for _, choice := range q.Choices {
		if choice.ID == trimmed {
			return choice.ID
		}
	}
	for _, choice := range q.Choices {
		if strings.EqualFold(strings.TrimSpace(choice.Text), trimmed) {
			return choice.ID
		}
	}
	// Unknown value: return it unchanged so it simply fails to match the
	// correct answer rather than being silently treated as unanswered.
	return trimmed
}

func round2(v float64) float64 {
	return math.Round(v*100) / 100
}

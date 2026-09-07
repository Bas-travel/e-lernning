package quiz

import (
	"errors"
	"fmt"
)

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) GetQuiz(id string) (Quiz, error) {
	if id == "" {
		return Quiz{}, errors.New("quiz id is required")
	}

	quiz, ok := s.repo.GetQuiz(id)
	if !ok {
		return Quiz{}, fmt.Errorf("quiz %s not found", id)
	}
	return quiz, nil
}

func (s *Service) SubmitQuiz(quizID string, answers map[string]string) (QuizAttempt, error) {
	if quizID == "" {
		return QuizAttempt{}, errors.New("quiz id is required")
	}

	quiz, err := s.GetQuiz(quizID)
	if err != nil {
		return QuizAttempt{}, err
	}

	if len(answers) == 0 {
		return QuizAttempt{}, errors.New("answers are required")
	}

	score := 0
	for _, q := range quiz.Questions {
		if answers[q.ID] == q.Correct {
			score++
		}
	}

	percentage := float64(score) / float64(len(quiz.Questions)) * 100
	attempt := QuizAttempt{
		ID:         fmt.Sprintf("attempt-%s", quizID),
		QuizID:     quizID,
		UserID:     "user-demo",
		Score:      score,
		Total:      len(quiz.Questions),
		Percentage: percentage,
		Passed:     percentage >= 70,
	}
	
	s.repo.SaveAttempt(attempt)
	return attempt, nil
}

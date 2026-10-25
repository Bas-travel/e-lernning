package quiz

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
)

var (
	ErrQuizNotFound     = errors.New("quiz not found")
	ErrNoAttemptYet     = errors.New("no attempt yet")
	ErrNoQuestionsInSet = errors.New("quiz has no questions")
)

// Repository is the MySQL-backed store for quizzes, their questions, and
// every attempt a learner has made.
type Repository struct {
	db *sql.DB
}

func NewRepository(db *sql.DB) *Repository {
	return &Repository{db: db}
}

// FindQuizByID loads one quiz's metadata (not its questions).
func (r *Repository) FindQuizByID(ctx context.Context, id int64) (Quiz, error) {
	var q Quiz
	var lessonID sql.NullInt64
	err := r.db.QueryRowContext(ctx, `
		SELECT id, course_id, lesson_id, title, pass_score_pct
		FROM quizzes
		WHERE id = ?
	`, id).Scan(&q.ID, &q.CourseID, &lessonID, &q.Title, &q.PassScorePct)
	if errors.Is(err, sql.ErrNoRows) {
		return Quiz{}, ErrQuizNotFound
	}
	if err != nil {
		return Quiz{}, fmt.Errorf("find quiz: %w", err)
	}
	if lessonID.Valid {
		q.LessonID = &lessonID.Int64
	}
	return q, nil
}

// FindQuizByCourse returns the course's primary quiz. A course may attach
// quizzes to individual lessons as well; those are fetched by lesson ID.
func (r *Repository) FindQuizByCourse(ctx context.Context, courseID int64) (Quiz, error) {
	var q Quiz
	var lessonID sql.NullInt64
	err := r.db.QueryRowContext(ctx, `
		SELECT id, course_id, lesson_id, title, pass_score_pct
		FROM quizzes
		WHERE course_id = ?
		ORDER BY (lesson_id IS NULL) DESC, id ASC
		LIMIT 1
	`, courseID).Scan(&q.ID, &q.CourseID, &lessonID, &q.Title, &q.PassScorePct)
	if errors.Is(err, sql.ErrNoRows) {
		return Quiz{}, ErrQuizNotFound
	}
	if err != nil {
		return Quiz{}, fmt.Errorf("find course quiz: %w", err)
	}
	if lessonID.Valid {
		q.LessonID = &lessonID.Int64
	}
	return q, nil
}

// ListQuestions returns the quiz's questions in display order, with the
// choices decoded from the JSON column back into structs.
func (r *Repository) ListQuestions(ctx context.Context, quizID int64) ([]Question, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT id, quiz_id, question, choices, correct_choice, COALESCE(skill_tag, ''), sort_order
		FROM quiz_questions
		WHERE quiz_id = ?
		ORDER BY sort_order ASC, id ASC
	`, quizID)
	if err != nil {
		return nil, fmt.Errorf("list quiz questions: %w", err)
	}
	defer rows.Close()

	out := []Question{}
	for rows.Next() {
		var q Question
		var rawChoices []byte
		if err := rows.Scan(&q.ID, &q.QuizID, &q.Question, &rawChoices,
			&q.CorrectChoice, &q.SkillTag, &q.SortOrder); err != nil {
			return nil, fmt.Errorf("scan quiz question: %w", err)
		}
		if err := json.Unmarshal(rawChoices, &q.Choices); err != nil {
			return nil, fmt.Errorf("decode choices for question %d: %w", q.ID, err)
		}
		out = append(out, q)
	}
	return out, rows.Err()
}

// SaveAttempt records one graded submission and returns the new attempt ID.
func (r *Repository) SaveAttempt(ctx context.Context, quizID, userID int64, answers map[string]string, scorePct float64, passed bool, breakdown map[string]float64) (int64, error) {
	answersJSON, err := json.Marshal(answers)
	if err != nil {
		return 0, fmt.Errorf("encode answers: %w", err)
	}
	breakdownJSON, err := json.Marshal(breakdown)
	if err != nil {
		return 0, fmt.Errorf("encode skill breakdown: %w", err)
	}

	res, err := r.db.ExecContext(ctx, `
		INSERT INTO quiz_attempts (quiz_id, user_id, answers, score_pct, passed, skill_breakdown)
		VALUES (?, ?, ?, ?, ?, ?)
	`, quizID, userID, answersJSON, scorePct, passed, breakdownJSON)
	if err != nil {
		return 0, fmt.Errorf("insert quiz attempt: %w", err)
	}
	return res.LastInsertId()
}

// ListAttempts returns the learner's attempt history for a quiz, newest
// first — the "your previous scores" view on the result screen.
func (r *Repository) ListAttempts(ctx context.Context, quizID, userID int64) ([]Attempt, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT id, quiz_id, user_id, score_pct, passed, skill_breakdown, attempted_at
		FROM quiz_attempts
		WHERE quiz_id = ? AND user_id = ?
		ORDER BY attempted_at DESC, id DESC
	`, quizID, userID)
	if err != nil {
		return nil, fmt.Errorf("list quiz attempts: %w", err)
	}
	defer rows.Close()

	out := []Attempt{}
	for rows.Next() {
		attempt, err := scanAttempt(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, attempt)
	}
	return out, rows.Err()
}

// FindBestAttempt returns the learner's highest-scoring attempt — what the
// course-completion checks and the "have I passed this quiz" badge read.
func (r *Repository) FindBestAttempt(ctx context.Context, quizID, userID int64) (Attempt, error) {
	row := r.db.QueryRowContext(ctx, `
		SELECT id, quiz_id, user_id, score_pct, passed, skill_breakdown, attempted_at
		FROM quiz_attempts
		WHERE quiz_id = ? AND user_id = ?
		ORDER BY passed DESC, score_pct DESC, id DESC
		LIMIT 1
	`, quizID, userID)

	attempt, err := scanAttempt(row)
	if errors.Is(err, sql.ErrNoRows) {
		return Attempt{}, ErrNoAttemptYet
	}
	return attempt, err
}

func scanAttempt(scanner interface{ Scan(...any) error }) (Attempt, error) {
	var a Attempt
	var rawBreakdown []byte
	if err := scanner.Scan(&a.ID, &a.QuizID, &a.UserID, &a.ScorePct, &a.Passed,
		&rawBreakdown, &a.AttemptedAt); err != nil {
		return Attempt{}, err
	}
	if len(rawBreakdown) > 0 {
		if err := json.Unmarshal(rawBreakdown, &a.SkillBreakdown); err != nil {
			return Attempt{}, fmt.Errorf("decode skill breakdown for attempt %d: %w", a.ID, err)
		}
	}
	if a.SkillBreakdown == nil {
		a.SkillBreakdown = map[string]float64{}
	}
	return a, nil
}

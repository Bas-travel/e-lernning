// Package quiz owns `quizzes`, `quiz_questions` and `quiz_attempts` — the
// "Practice" half of the Learn → Practice → Prove journey.
//
// Two rules shape the whole design: correct answers never leave the server
// before a submission, and every attempt is recorded so the result screen
// and the learner's history agree with each other.
package quiz

import "time"

// GeneralSkillTag is used for questions that carry no skill tag, so the
// breakdown always has at least one bucket to report.
const GeneralSkillTag = "General"

// Quiz mirrors a row in the `quizzes` table.
type Quiz struct {
	ID           int64
	CourseID     int64
	LessonID     *int64
	Title        string
	PassScorePct float64
}

// Choice is one answer option. Choices are stored as JSON in
// `quiz_questions.choices`, and the shape is stable across the API.
type Choice struct {
	ID   string `json:"id"`
	Text string `json:"text"`
}

// Question mirrors a row in `quiz_questions`. CorrectChoice is deliberately
// not serialised into any response DTO — see dto.go.
type Question struct {
	ID            int64
	QuizID        int64
	Question      string
	Choices       []Choice
	CorrectChoice string
	SkillTag      string
	SortOrder     int
}

// Attempt mirrors a row in `quiz_attempts`.
type Attempt struct {
	ID             int64
	QuizID         int64
	UserID         int64
	ScorePct       float64
	Passed         bool
	SkillBreakdown map[string]float64
	AttemptedAt    time.Time
}

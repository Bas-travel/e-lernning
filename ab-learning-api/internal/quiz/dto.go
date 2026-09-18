package quiz

// ---- Requests ----

// SubmitRequest is the POST /quizzes/{id}/submit body: a map of question ID
// to the choice the learner picked. The value may be either the choice's ID
// ("b") or its literal text, because the client renders text and older
// builds sent it straight back — the grader accepts both.
type SubmitRequest struct {
	Answers map[string]string `json:"answers"`
}

// ---- Responses ----

// QuizResponse is what GET /quizzes/{id} returns. CorrectChoice is absent by
// construction: there is no field for it, so it cannot leak.
type QuizResponse struct {
	ID           int64              `json:"id"`
	CourseID     int64              `json:"course_id"`
	LessonID     *int64             `json:"lesson_id,omitempty"`
	Title        string             `json:"title"`
	PassScorePct float64            `json:"pass_score_pct"`
	Questions    []QuestionResponse `json:"questions"`
}

// QuestionResponse is one question with its choices, stripped of the answer.
type QuestionResponse struct {
	ID        int64    `json:"id"`
	Question  string   `json:"question"`
	Choices   []Choice `json:"choices"`
	SkillTag  string   `json:"skill_tag,omitempty"`
	SortOrder int      `json:"sort_order"`
}

// QuestionResult is the per-question correction shown on the result screen.
// It is only ever returned after a submission.
type QuestionResult struct {
	QuestionID    int64  `json:"question_id"`
	Chosen        string `json:"chosen"`
	CorrectChoice string `json:"correct_choice"`
	Correct       bool   `json:"correct"`
	SkillTag      string `json:"skill_tag,omitempty"`
}

// AttemptResultResponse matches the `QuizAttemptResult` schema in
// 05-openapi.yaml and adds the per-question detail the result screen needs
// to explain the score.
type AttemptResultResponse struct {
	AttemptID      int64              `json:"attempt_id"`
	QuizID         int64              `json:"quiz_id"`
	Title          string             `json:"title"`
	Score          int                `json:"score"`
	Total          int                `json:"total"`
	ScorePct       float64            `json:"score_pct"`
	PassScorePct   float64            `json:"pass_score_pct"`
	Passed         bool               `json:"passed"`
	SkillBreakdown map[string]float64 `json:"skill_breakdown"`
	Results        []QuestionResult   `json:"results"`
	AttemptedAt    string             `json:"attempted_at"`
}

// ---- Mapping ----

func toQuizResponse(q Quiz, questions []Question) QuizResponse {
	out := make([]QuestionResponse, 0, len(questions))
	for _, question := range questions {
		out = append(out, QuestionResponse{
			ID:        question.ID,
			Question:  question.Question,
			Choices:   question.Choices,
			SkillTag:  question.SkillTag,
			SortOrder: question.SortOrder,
		})
	}
	return QuizResponse{
		ID:           q.ID,
		CourseID:     q.CourseID,
		LessonID:     q.LessonID,
		Title:        q.Title,
		PassScorePct: q.PassScorePct,
		Questions:    out,
	}
}

package quiz

type Question struct {
	ID      string   `json:"id"`
	Text    string   `json:"text"`
	Options []string `json:"options"`
	Correct string   `json:"correct"`
	Explain string   `json:"explain"`
}

type Quiz struct {
	ID        string     `json:"id"`
	CourseID  string     `json:"courseId"`
	Title     string     `json:"title"`
	Questions []Question `json:"questions"`
}

type QuizAttempt struct {
	ID         string  `json:"id"`
	QuizID     string  `json:"quizId"`
	UserID     string  `json:"userId"`
	Score      int     `json:"score"`
	Total      int     `json:"total"`
	Percentage float64 `json:"percentage"`
	Passed     bool    `json:"passed"`
}

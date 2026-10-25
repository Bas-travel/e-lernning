package quiz

type Repository struct {
	quizzes map[string]Quiz
	attempts map[string]QuizAttempt
}

func NewRepository() *Repository {
	return &Repository{
		quizzes: map[string]Quiz{},
		attempts: map[string]QuizAttempt{},
	}
}

func (r *Repository) SaveQuiz(q Quiz) {
	r.quizzes[q.ID] = q
}

func (r *Repository) GetQuiz(id string) (Quiz, bool) {
	q, ok := r.quizzes[id]
	return q, ok
}

func (r *Repository) SaveAttempt(a QuizAttempt) {
	r.attempts[a.ID] = a
}

func (r *Repository) GetAttempt(id string) (QuizAttempt, bool) {
	a, ok := r.attempts[id]
	return a, ok
}

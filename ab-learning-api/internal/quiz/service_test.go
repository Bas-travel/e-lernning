package quiz

import (
	"context"
	"encoding/json"
	"strings"
	"testing"

	"github.com/ablearning/ab-learning-api/internal/platform"
)

// ---- Fakes ----

type fakeStore struct {
	quizzes   map[int64]Quiz
	questions map[int64][]Question
	attempts  []Attempt
	nextID    int64
}

func newFakeStore() *fakeStore {
	return &fakeStore{quizzes: map[int64]Quiz{}, questions: map[int64][]Question{}}
}

func (f *fakeStore) addQuiz(quiz Quiz, questions ...Question) {
	f.quizzes[quiz.ID] = quiz
	f.questions[quiz.ID] = questions
}

func (f *fakeStore) FindQuizByID(_ context.Context, id int64) (Quiz, error) {
	q, ok := f.quizzes[id]
	if !ok {
		return Quiz{}, ErrQuizNotFound
	}
	return q, nil
}

func (f *fakeStore) FindQuizByCourse(_ context.Context, courseID int64) (Quiz, error) {
	for _, q := range f.quizzes {
		if q.CourseID == courseID {
			return q, nil
		}
	}
	return Quiz{}, ErrQuizNotFound
}

func (f *fakeStore) ListQuestions(_ context.Context, quizID int64) ([]Question, error) {
	return f.questions[quizID], nil
}

func (f *fakeStore) SaveAttempt(_ context.Context, quizID, userID int64, _ map[string]string, scorePct float64, passed bool, breakdown map[string]float64) (int64, error) {
	f.nextID++
	f.attempts = append(f.attempts, Attempt{
		ID: f.nextID, QuizID: quizID, UserID: userID,
		ScorePct: scorePct, Passed: passed, SkillBreakdown: breakdown,
	})
	return f.nextID, nil
}

func (f *fakeStore) ListAttempts(_ context.Context, quizID, userID int64) ([]Attempt, error) {
	// Newest first, mirroring the repository's
	// `ORDER BY attempted_at DESC, id DESC`.
	out := []Attempt{}
	for i := len(f.attempts) - 1; i >= 0; i-- {
		a := f.attempts[i]
		if a.QuizID == quizID && a.UserID == userID {
			out = append(out, a)
		}
	}
	return out, nil
}

func (f *fakeStore) FindBestAttempt(_ context.Context, quizID, userID int64) (Attempt, error) {
	best := Attempt{}
	found := false
	for _, a := range f.attempts {
		if a.QuizID != quizID || a.UserID != userID {
			continue
		}
		if !found || a.ScorePct > best.ScorePct {
			best, found = a, true
		}
	}
	if !found {
		return Attempt{}, ErrNoAttemptYet
	}
	return best, nil
}

type fakeEnrollments struct{ enrolled bool }

func (f fakeEnrollments) IsEnrolled(context.Context, int64, int64) (bool, error) {
	return f.enrolled, nil
}

// twoQuestionQuiz returns a quiz whose questions cover two skill tags, so
// the breakdown has something meaningful to compute.
func twoQuestionQuiz() (Quiz, []Question) {
	quiz := Quiz{ID: 1, CourseID: 10, Title: "Go Backend Fundamentals", PassScorePct: 70}
	questions := []Question{
		{
			ID: 100, QuizID: 1, Question: "Which keyword declares a function?",
			Choices:       []Choice{{ID: "a", Text: "func"}, {ID: "b", Text: "def"}},
			CorrectChoice: "a", SkillTag: "Language", SortOrder: 1,
		},
		{
			ID: 101, QuizID: 1, Question: "Which HTTP method creates a resource?",
			Choices:       []Choice{{ID: "a", Text: "GET"}, {ID: "b", Text: "POST"}},
			CorrectChoice: "b", SkillTag: "API Knowledge", SortOrder: 2,
		},
	}
	return quiz, questions
}

// ---- Serving questions ----

// The whole point of grading server-side: the correct answers must not be
// present anywhere in the payload the client receives.
func TestGetQuizNeverLeaksCorrectAnswers(t *testing.T) {
	store := newFakeStore()
	quiz, questions := twoQuestionQuiz()
	store.addQuiz(quiz, questions...)
	service := NewService(store, fakeEnrollments{enrolled: true})

	resp, err := service.GetQuiz(context.Background(), 1)
	if err != nil {
		t.Fatalf("get quiz: %v", err)
	}

	raw, err := json.Marshal(resp)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	if strings.Contains(string(raw), "correct_choice") || strings.Contains(string(raw), "CorrectChoice") {
		t.Fatalf("payload exposes the answer field: %s", raw)
	}

	if len(resp.Questions) != 2 {
		t.Fatalf("expected 2 questions, got %d", len(resp.Questions))
	}
	if len(resp.Questions[0].Choices) != 2 {
		t.Fatalf("expected the choices to be served, got %d", len(resp.Questions[0].Choices))
	}
}

func TestGetQuizNotFound(t *testing.T) {
	service := NewService(newFakeStore(), nil)

	_, err := service.GetQuiz(context.Background(), 999)
	wantStatus(t, err, 404)
}

func TestGetCourseQuizResolvesByCourse(t *testing.T) {
	store := newFakeStore()
	quiz, questions := twoQuestionQuiz()
	store.addQuiz(quiz, questions...)
	service := NewService(store, nil)

	resp, err := service.GetCourseQuiz(context.Background(), 10)
	if err != nil {
		t.Fatalf("get course quiz: %v", err)
	}
	if resp.ID != 1 {
		t.Fatalf("expected quiz 1, got %d", resp.ID)
	}

	_, err = service.GetCourseQuiz(context.Background(), 424242)
	wantStatus(t, err, 404)
}

// ---- Grading ----

func TestSubmitGradesByChoiceID(t *testing.T) {
	store := newFakeStore()
	quiz, questions := twoQuestionQuiz()
	store.addQuiz(quiz, questions...)
	service := NewService(store, nil)

	result, err := service.Submit(context.Background(), 7, 1, map[string]string{
		"100": "a", // correct
		"101": "b", // correct
	})
	if err != nil {
		t.Fatalf("submit: %v", err)
	}
	if result.Score != 2 || result.Total != 2 {
		t.Fatalf("expected 2/2, got %d/%d", result.Score, result.Total)
	}
	if result.ScorePct != 100 {
		t.Fatalf("expected 100%%, got %v", result.ScorePct)
	}
	if !result.Passed {
		t.Fatal("100% must pass a 70% quiz")
	}
	if len(result.Results) != 2 {
		t.Fatalf("expected per-question corrections, got %d", len(result.Results))
	}
}

// A client that echoes the choice text instead of its ID must still be
// graded correctly — older builds did exactly that.
func TestSubmitGradesByChoiceText(t *testing.T) {
	store := newFakeStore()
	quiz, questions := twoQuestionQuiz()
	store.addQuiz(quiz, questions...)
	service := NewService(store, nil)

	result, err := service.Submit(context.Background(), 7, 1, map[string]string{
		"100": "func", // correct choice's text, not its id
		"101": "POST",
	})
	if err != nil {
		t.Fatalf("submit: %v", err)
	}
	if result.Score != 2 {
		t.Fatalf("choice text must grade the same as choice id, got %d/2", result.Score)
	}
}

func TestSubmitComputesSkillBreakdown(t *testing.T) {
	store := newFakeStore()
	quiz, questions := twoQuestionQuiz()
	store.addQuiz(quiz, questions...)
	service := NewService(store, nil)

	result, err := service.Submit(context.Background(), 7, 1, map[string]string{
		"100": "a", // Language: correct
		"101": "a", // API Knowledge: wrong
	})
	if err != nil {
		t.Fatalf("submit: %v", err)
	}
	if result.Score != 1 {
		t.Fatalf("expected 1 correct, got %d", result.Score)
	}
	if result.SkillBreakdown["Language"] != 100 {
		t.Fatalf("expected Language 100, got %v", result.SkillBreakdown["Language"])
	}
	if result.SkillBreakdown["API Knowledge"] != 0 {
		t.Fatalf("expected API Knowledge 0, got %v", result.SkillBreakdown["API Knowledge"])
	}
	if result.ScorePct != 50 {
		t.Fatalf("expected 50%%, got %v", result.ScorePct)
	}
	if result.Passed {
		t.Fatal("50% must not pass a 70% quiz")
	}
}

// Answering nothing must score zero, not be mistaken for a pass.
func TestSubmitTreatsUnansweredQuestionsAsWrong(t *testing.T) {
	store := newFakeStore()
	quiz, questions := twoQuestionQuiz()
	store.addQuiz(quiz, questions...)
	service := NewService(store, nil)

	result, err := service.Submit(context.Background(), 7, 1, map[string]string{"999": "b"})
	if err != nil {
		t.Fatalf("submit: %v", err)
	}
	if result.Score != 0 {
		t.Fatalf("expected 0 correct, got %d", result.Score)
	}
	if result.Passed {
		t.Fatal("an empty submission must not pass")
	}
}

func TestSubmitRecordsTheAttempt(t *testing.T) {
	store := newFakeStore()
	quiz, questions := twoQuestionQuiz()
	store.addQuiz(quiz, questions...)
	service := NewService(store, nil)

	if _, err := service.Submit(context.Background(), 7, 1, map[string]string{"100": "a"}); err != nil {
		t.Fatalf("submit: %v", err)
	}
	if len(store.attempts) != 1 {
		t.Fatalf("expected 1 recorded attempt, got %d", len(store.attempts))
	}
	if store.attempts[0].UserID != 7 {
		t.Fatalf("attempt must be recorded against the caller, got user %d", store.attempts[0].UserID)
	}
}

func TestSubmitRejectsEmptyAnswers(t *testing.T) {
	store := newFakeStore()
	quiz, questions := twoQuestionQuiz()
	store.addQuiz(quiz, questions...)
	service := NewService(store, nil)

	_, err := service.Submit(context.Background(), 7, 1, map[string]string{})
	wantStatus(t, err, 400)
}

func TestSubmitRejectsQuizWithNoQuestions(t *testing.T) {
	store := newFakeStore()
	store.addQuiz(Quiz{ID: 2, CourseID: 10, Title: "Empty", PassScorePct: 70})
	service := NewService(store, nil)

	_, err := service.Submit(context.Background(), 7, 2, map[string]string{"1": "a"})
	wantStatus(t, err, 400)
}

func TestSubmitRequiresEnrollment(t *testing.T) {
	store := newFakeStore()
	quiz, questions := twoQuestionQuiz()
	store.addQuiz(quiz, questions...)
	service := NewService(store, fakeEnrollments{enrolled: false})

	_, err := service.Submit(context.Background(), 7, 1, map[string]string{"100": "a"})
	wantStatus(t, err, 403)

	// And the attempt must not have been written.
	if len(store.attempts) != 0 {
		t.Fatal("a blocked submission must not record an attempt")
	}
}

func TestSubmitUnknownQuiz(t *testing.T) {
	service := NewService(newFakeStore(), nil)

	_, err := service.Submit(context.Background(), 7, 404, map[string]string{"1": "a"})
	wantStatus(t, err, 404)
}

// ---- History ----

func TestHistoryIsScopedToTheCallerAndNewestFirst(t *testing.T) {
	store := newFakeStore()
	quiz, questions := twoQuestionQuiz()
	store.addQuiz(quiz, questions...)
	service := NewService(store, nil)

	if _, err := service.Submit(context.Background(), 7, 1, map[string]string{"100": "a"}); err != nil {
		t.Fatalf("submit: %v", err)
	}
	if _, err := service.Submit(context.Background(), 7, 1, map[string]string{"100": "a", "101": "b"}); err != nil {
		t.Fatalf("submit: %v", err)
	}
	// Another learner's attempt must never appear in my history.
	if _, err := service.Submit(context.Background(), 8, 1, map[string]string{"100": "a"}); err != nil {
		t.Fatalf("submit: %v", err)
	}

	history, err := service.History(context.Background(), 7, 1)
	if err != nil {
		t.Fatalf("history: %v", err)
	}
	if len(history) != 2 {
		t.Fatalf("expected exactly my 2 attempts, got %d", len(history))
	}
	if history[0].ScorePct != 100 {
		t.Fatalf("expected the newest attempt first, got %v%%", history[0].ScorePct)
	}
}

func wantStatus(t *testing.T, err error, want int) {
	t.Helper()
	if err == nil {
		t.Fatalf("expected an error with status %d, got nil", want)
	}
	appErr, ok := err.(*platform.AppError)
	if !ok {
		t.Fatalf("expected *platform.AppError, got %T: %v", err, err)
	}
	if appErr.Status != want {
		t.Fatalf("expected status %d, got %d (%s)", want, appErr.Status, appErr.Code)
	}
}

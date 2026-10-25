package quiz

import "testing"

func TestGetQuizByID(t *testing.T) {
	repo := NewRepository()
	repo.SaveQuiz(Quiz{ID: "q001", Title: "Go Backend Fundamentals", Questions: []Question{{ID: "q1", Text: "Test", Options: []string{"A", "B"}, Correct: "A"}}})

	service := NewService(repo)
	quiz, err := service.GetQuiz("q001")
	if err != nil {
		t.Fatal(err)
	}
	if quiz.Title == "" {
		t.Fatal("expected quiz title")
	}
}

func TestSubmitQuizCalculatesScore(t *testing.T) {
	repo := NewRepository()
	repo.SaveQuiz(Quiz{ID: "q001", Title: "Go Backend Fundamentals", Questions: []Question{{ID: "q1", Text: "Test", Options: []string{"A", "B"}, Correct: "A"}}})

	service := NewService(repo)
	attempt, err := service.SubmitQuiz("q001", map[string]string{"q1": "A"})
	if err != nil {
		t.Fatal(err)
	}
	if attempt.Score != 1 {
		t.Fatal("expected one correct answer")
	}
}

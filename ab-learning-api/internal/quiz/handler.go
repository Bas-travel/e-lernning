package quiz

import (
	"encoding/json"
	"net/http"
	"strings"

	"github.com/ablearning/api/pkg/httpx"
)

type Controller struct {
	service *Service
}

func NewController(service *Service) *Controller {
	return &Controller{service: service}
}

func RegisterRoutes(mux *http.ServeMux) {
	repo := NewRepository()
	repo.SaveQuiz(Quiz{
		ID:       "q001",
		CourseID: "c001",
		Title:    "Go Backend Fundamentals",
		Questions: []Question{
			{ID: "q1", Text: "What is Go commonly used for?", Options: []string{"Frontend UI", "Backend services", "Graphic design", "Database schema only"}, Correct: "Backend services", Explain: "Go is widely used for performant backend services and APIs."},
			{ID: "q2", Text: "Which keyword is used to declare a function?", Options: []string{"func", "fn", "function", "def"}, Correct: "func", Explain: "Functions in Go are declared with the func keyword."},
		},
	})

	controller := NewController(NewService(repo))
	mux.HandleFunc("/api/v1/quizzes/", controller.QuizHandler)
}

func (c *Controller) QuizHandler(w http.ResponseWriter, r *http.Request) {
	path := strings.Trim(strings.TrimPrefix(r.URL.Path, "/api/v1/quizzes/"), "/")
	if path == "" {
		httpx.JSON(w, http.StatusNotFound, map[string]string{"error": "quiz not found"})
		return
	}

	if r.Method == http.MethodGet {
		quiz, err := c.service.GetQuiz(path)
		if err != nil {
			httpx.JSON(w, http.StatusNotFound, map[string]string{"error": err.Error()})
			return
		}
		httpx.JSON(w, http.StatusOK, quiz)
		return
	}

	if r.Method == http.MethodPost {
		var payload struct {
			Answers map[string]string `json:"answers"`
		}
		if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
			httpx.JSON(w, http.StatusBadRequest, map[string]string{"error": "invalid body"})
			return
		}

		attempt, err := c.service.SubmitQuiz(path, payload.Answers)
		if err != nil {
			httpx.JSON(w, http.StatusBadRequest, map[string]string{"error": err.Error()})
			return
		}
		httpx.JSON(w, http.StatusOK, attempt)
		return
	}

	httpx.JSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
}

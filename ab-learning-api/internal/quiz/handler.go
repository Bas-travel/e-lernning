package quiz

import (
	"encoding/json"
	"net/http"

	"github.com/ablearning/ab-learning-api/internal/platform"
)

// Handler exposes the quiz domain. Every route is authenticated: a grade is
// always written against the caller's own user ID.
type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

func (h *Handler) RegisterRoutes(mux *http.ServeMux, protected func(http.Handler) http.Handler) {
	mux.Handle("GET /api/v1/quizzes/{id}", protected(http.HandlerFunc(h.getQuiz)))
	mux.Handle("POST /api/v1/quizzes/{id}/submit", protected(http.HandlerFunc(h.submit)))
	mux.Handle("GET /api/v1/quizzes/{id}/attempts", protected(http.HandlerFunc(h.history)))
	mux.Handle("GET /api/v1/courses/{id}/quiz", protected(http.HandlerFunc(h.getCourseQuiz)))
}

// getQuiz implements GET /quizzes/{id} (screen 14).
func (h *Handler) getQuiz(w http.ResponseWriter, r *http.Request) {
	quizID, err := platform.ParseID(r.PathValue("id"), "quiz")
	if err != nil {
		platform.WriteError(w, err)
		return
	}

	quiz, err := h.service.GetQuiz(r.Context(), quizID)
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, quiz)
}

// getCourseQuiz implements GET /courses/{id}/quiz — the course detail
// screen's "Practice" entry point, so the client never has to guess a quiz
// ID it was never told.
func (h *Handler) getCourseQuiz(w http.ResponseWriter, r *http.Request) {
	courseID, err := platform.ParseID(r.PathValue("id"), "course")
	if err != nil {
		platform.WriteError(w, err)
		return
	}

	quiz, err := h.service.GetCourseQuiz(r.Context(), courseID)
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, quiz)
}

// submit implements POST /quizzes/{id}/submit (screen 15).
func (h *Handler) submit(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}

	quizID, err := platform.ParseID(r.PathValue("id"), "quiz")
	if err != nil {
		platform.WriteError(w, err)
		return
	}

	var req SubmitRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		platform.WriteError(w, platform.ErrValidation("Request body is malformed."))
		return
	}

	result, err := h.service.Submit(r.Context(), userID, quizID, req.Answers)
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, result)
}

// history implements GET /quizzes/{id}/attempts.
func (h *Handler) history(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}

	quizID, err := platform.ParseID(r.PathValue("id"), "quiz")
	if err != nil {
		platform.WriteError(w, err)
		return
	}

	attempts, err := h.service.History(r.Context(), userID, quizID)
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, attempts)
}

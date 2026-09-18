package learning

import (
	"encoding/json"
	"net/http"

	"github.com/ablearning/ab-learning-api/internal/platform"
)

// Handler exposes the learning domain over HTTP. Every route is
// authenticated: enrollment and progress are always scoped to the caller's
// own user ID taken from the verified token, never from the request body.
type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

func (h *Handler) RegisterRoutes(mux *http.ServeMux, protected func(http.Handler) http.Handler) {
	mux.Handle("GET /api/v1/me/courses", protected(http.HandlerFunc(h.listMyCourses)))
	mux.Handle("POST /api/v1/enrollments", protected(http.HandlerFunc(h.enroll)))
	mux.Handle("GET /api/v1/enrollments/{id}", protected(http.HandlerFunc(h.getEnrollment)))
	mux.Handle("GET /api/v1/lessons/{id}", protected(http.HandlerFunc(h.getLesson)))
	mux.Handle("POST /api/v1/lessons/{id}/progress", protected(http.HandlerFunc(h.saveLessonProgress)))
}

// listMyCourses implements GET /me/courses (screen "My Learning").
func (h *Handler) listMyCourses(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}

	courses, err := h.service.ListMyCourses(r.Context(), userID)
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, courses)
}

// enroll implements POST /enrollments. It answers 201 for a new enrollment
// and 200 when the learner already had one, so clients can retry safely.
func (h *Handler) enroll(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}

	var req EnrollRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		platform.WriteError(w, platform.ErrValidation("Request body is malformed."))
		return
	}

	// The token is authoritative. A body that names a different user is an
	// attempt to enroll somebody else, which is refused rather than ignored.
	if req.UserID != 0 && req.UserID != userID {
		platform.WriteError(w, platform.ErrForbidden("You can only enroll your own account."))
		return
	}

	enrollment, created, err := h.service.Enroll(r.Context(), userID, req.CourseID)
	if err != nil {
		platform.WriteError(w, err)
		return
	}

	status := http.StatusOK
	if created {
		status = http.StatusCreated
	}
	platform.WriteJSON(w, status, enrollment)
}

// getEnrollment implements GET /enrollments/{id}.
func (h *Handler) getEnrollment(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}

	enrollmentID, err := platform.ParseID(r.PathValue("id"), "enrollment")
	if err != nil {
		platform.WriteError(w, err)
		return
	}

	enrollment, err := h.service.GetEnrollment(r.Context(), userID, enrollmentID)
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, enrollment)
}

// getLesson implements GET /lessons/{id} (screens 12–13).
func (h *Handler) getLesson(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}

	lessonID, err := platform.ParseID(r.PathValue("id"), "lesson")
	if err != nil {
		platform.WriteError(w, err)
		return
	}

	lesson, err := h.service.GetLesson(r.Context(), userID, lessonID)
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, lesson)
}

// saveLessonProgress implements POST /lessons/{id}/progress (screen 13).
func (h *Handler) saveLessonProgress(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}

	lessonID, err := platform.ParseID(r.PathValue("id"), "lesson")
	if err != nil {
		platform.WriteError(w, err)
		return
	}

	var req SaveProgressRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		platform.WriteError(w, platform.ErrValidation("Request body is malformed."))
		return
	}

	result, err := h.service.SaveLessonProgress(r.Context(), userID, lessonID, req)
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, result)
}

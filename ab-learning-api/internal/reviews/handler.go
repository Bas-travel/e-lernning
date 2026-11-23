package reviews

import (
	"errors"
	"net/http"
	"strconv"

	"github.com/ablearning/api/internal/platform"
)

type Handler struct{ svc *Service }

func NewHandler(svc *Service) *Handler { return &Handler{svc: svc} }

func (h *Handler) RegisterRoutes(mux *http.ServeMux, protected func(http.Handler) http.Handler) {
	mux.Handle("GET /api/v1/courses/{id}/reviews", protected(http.HandlerFunc(h.list)))
	mux.Handle("POST /api/v1/courses/{id}/reviews", protected(http.HandlerFunc(h.submit)))
}

func (h *Handler) list(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}
	courseID, err := platform.ParseID(r.PathValue("id"), "course")
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	offset, _ := strconv.Atoi(r.URL.Query().Get("offset"))
	page, err := h.svc.List(r.Context(), courseID, userID, limit, offset)
	if err != nil {
		platform.WriteError(w, mapError(err))
		return
	}
	platform.WriteJSON(w, http.StatusOK, page)
}

func (h *Handler) submit(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}
	courseID, err := platform.ParseID(r.PathValue("id"), "course")
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	var req struct {
		Rating  int    `json:"rating"`
		Comment string `json:"comment"`
	}
	if err := platform.DecodeJSON(r, &req); err != nil {
		platform.WriteError(w, err)
		return
	}
	if err := h.svc.Submit(r.Context(), userID, courseID, req.Rating, req.Comment); err != nil {
		platform.WriteError(w, mapError(err))
		return
	}
	platform.WriteJSON(w, http.StatusOK, map[string]bool{"ok": true})
}

func mapError(err error) error {
	switch {
	case errors.Is(err, ErrInvalid):
		return platform.ErrValidation("rating must be 1-5 and the comment at most 2000 characters")
	case errors.Is(err, ErrCourseNotFound):
		return platform.ErrNotFound(err.Error())
	case errors.Is(err, ErrNotEnrolled):
		return platform.Forbidden(err.Error())
	default:
		return err
	}
}

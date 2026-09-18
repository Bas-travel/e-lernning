package admin

import (
	"net/http"
	"strconv"

	"github.com/ablearning/ab-learning-api/internal/platform"
)

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

// RegisterRoutes wires this domain's endpoints onto mux. `guard` is the
// full middleware chain: requireAuth THEN RequireRole("ADMIN") — see
// cmd/api/main.go for how it's composed. Paths match 05-openapi.yaml.
func (h *Handler) RegisterRoutes(mux *http.ServeMux, guard func(http.Handler) http.Handler) {
	mux.Handle("GET /api/v1/admin/dashboard", guard(http.HandlerFunc(h.dashboard)))
	mux.Handle("GET /api/v1/admin/courses/pending", guard(http.HandlerFunc(h.pendingCourses)))
	mux.Handle("POST /api/v1/admin/courses/{id}/approve", guard(http.HandlerFunc(h.approveCourse)))
	mux.Handle("POST /api/v1/admin/courses/{id}/reject", guard(http.HandlerFunc(h.rejectCourse)))
}

func (h *Handler) dashboard(w http.ResponseWriter, r *http.Request) {
	dashboard, err := h.service.Dashboard(r.Context())
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, dashboard)
}

func (h *Handler) pendingCourses(w http.ResponseWriter, r *http.Request) {
	list, err := h.service.PendingCourses(r.Context())
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, list)
}

func (h *Handler) approveCourse(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.ParseInt(r.PathValue("id"), 10, 64)
	if err != nil {
		platform.WriteError(w, platform.ErrValidation("id must be a number"))
		return
	}
	if err := h.service.ApproveCourse(r.Context(), id); err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, map[string]bool{"approved": true})
}

func (h *Handler) rejectCourse(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.ParseInt(r.PathValue("id"), 10, 64)
	if err != nil {
		platform.WriteError(w, platform.ErrValidation("id must be a number"))
		return
	}
	var body struct {
		Reason string `json:"reason"`
	}
	if err := platform.DecodeJSON(r, &body); err != nil {
		platform.WriteError(w, err)
		return
	}
	if err := h.service.RejectCourse(r.Context(), id, body.Reason); err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, map[string]bool{"rejected": true})
}

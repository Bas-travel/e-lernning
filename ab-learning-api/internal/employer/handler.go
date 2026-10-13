package employer

import (
	"net/http"

	"github.com/ablearning/api/internal/platform"
)

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

// RegisterRoutes wires this domain's endpoints onto mux. `guard` is the
// full middleware chain: requireAuth THEN RequireRole("EMPLOYER") — see
// cmd/api/main.go for how it's composed.
func (h *Handler) RegisterRoutes(mux *http.ServeMux, guard func(http.Handler) http.Handler) {
	mux.Handle("GET /api/v1/employer/dashboard", guard(http.HandlerFunc(h.dashboard)))
	mux.Handle("GET /api/v1/employer/top-applicants", guard(http.HandlerFunc(h.topApplicants)))
	mux.Handle("GET /api/v1/employer/jobs", guard(http.HandlerFunc(h.jobs)))
	mux.Handle("POST /api/v1/employer/jobs", guard(http.HandlerFunc(h.createJob)))
	mux.Handle("GET /api/v1/employer/applications", guard(http.HandlerFunc(h.applications)))
	mux.Handle("PUT /api/v1/employer/applications/{id}", guard(http.HandlerFunc(h.updateApplication)))
}

func (h *Handler) dashboard(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}

	dashboard, err := h.service.Dashboard(r.Context(), userID)
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, dashboard)
}

func (h *Handler) topApplicants(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}

	list, err := h.service.TopApplicants(r.Context(), userID)
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, list)
}

func (h *Handler) jobs(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}
	items, err := h.service.Jobs(r.Context(), userID)
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, items)
}

func (h *Handler) createJob(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}
	var in CreateJobInput
	if err := platform.DecodeJSON(r, &in); err != nil {
		platform.WriteError(w, platform.ErrValidation("invalid request body"))
		return
	}
	item, err := h.service.CreateJob(r.Context(), userID, in)
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusCreated, item)
}

func (h *Handler) applications(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}
	items, err := h.service.Applications(r.Context(), userID)
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, items)
}

func (h *Handler) updateApplication(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}
	id, err := platform.ParseID(r.PathValue("id"), "application")
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	var in struct {
		Status string `json:"status"`
	}
	if err := platform.DecodeJSON(r, &in); err != nil {
		platform.WriteError(w, platform.ErrValidation("invalid request body"))
		return
	}
	if err := h.service.UpdateApplication(r.Context(), userID, id, in.Status); err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, map[string]string{"status": in.Status})
}

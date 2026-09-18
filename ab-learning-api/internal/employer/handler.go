package employer

import (
	"net/http"

	"github.com/ablearning/ab-learning-api/internal/platform"
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

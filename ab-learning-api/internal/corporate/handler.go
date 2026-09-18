package corporate

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
// full middleware chain: requireAuth THEN RequireRole("CORP_ADMIN",
// "CORP_MANAGER") — see cmd/api/main.go for how it's composed.
func (h *Handler) RegisterRoutes(mux *http.ServeMux, guard func(http.Handler) http.Handler) {
	mux.Handle("GET /api/v1/corporate/dashboard", guard(http.HandlerFunc(h.dashboard)))
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

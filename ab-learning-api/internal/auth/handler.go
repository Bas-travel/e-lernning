package auth

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

// RegisterRoutes wires this domain's endpoints onto mux, matching
// 05-openapi.yaml exactly. `protected` is a middleware chain that requires
// a valid JWT (see internal/platform.RequireAuth) — used for /me.
func (h *Handler) RegisterRoutes(mux *http.ServeMux, protected func(http.Handler) http.Handler) {
	mux.HandleFunc("POST /api/v1/auth/login", h.login)
	mux.HandleFunc("POST /api/v1/auth/register", h.register)
	mux.Handle("GET /api/v1/me", protected(http.HandlerFunc(h.me)))
}

func (h *Handler) login(w http.ResponseWriter, r *http.Request) {
	var req LoginRequest
	if err := platform.DecodeJSON(r, &req); err != nil {
		platform.WriteError(w, err)
		return
	}

	result, err := h.service.Login(r.Context(), req)
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, result)
}

func (h *Handler) register(w http.ResponseWriter, r *http.Request) {
	var req RegisterRequest
	if err := platform.DecodeJSON(r, &req); err != nil {
		platform.WriteError(w, err)
		return
	}

	user, err := h.service.Register(r.Context(), req)
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusCreated, user)
}

func (h *Handler) me(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}

	user, err := h.service.Me(r.Context(), userID)
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, user)
}

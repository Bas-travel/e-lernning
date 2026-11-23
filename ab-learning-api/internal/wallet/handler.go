package wallet

import (
	"errors"
	"net/http"
	"strconv"

	"github.com/ablearning/api/internal/platform"
)

type Handler struct{ svc *Service }

func NewHandler(svc *Service) *Handler { return &Handler{svc: svc} }

func (h *Handler) RegisterRoutes(mux *http.ServeMux, protected func(http.Handler) http.Handler) {
	mux.Handle("GET /api/v1/wallet", protected(http.HandlerFunc(h.balance)))
	mux.Handle("GET /api/v1/wallet/transactions", protected(http.HandlerFunc(h.transactions)))
	mux.Handle("POST /api/v1/wallet/sandbox/topup", protected(http.HandlerFunc(h.topup)))
}

func (h *Handler) balance(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}
	b, err := h.svc.Balance(r.Context(), userID)
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, b)
}

func (h *Handler) transactions(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	offset, _ := strconv.Atoi(r.URL.Query().Get("offset"))
	page, err := h.svc.Transactions(r.Context(), userID, limit, offset)
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, page)
}

func (h *Handler) topup(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}
	var req struct {
		Amount float64 `json:"amount"`
	}
	if err := platform.DecodeJSON(r, &req); err != nil {
		platform.WriteError(w, err)
		return
	}
	bal, applied, err := h.svc.SandboxTopup(r.Context(), userID, r.Header.Get("Idempotency-Key"), req.Amount)
	if err != nil {
		switch {
		case errors.Is(err, ErrInvalid):
			err = platform.ErrValidation(err.Error())
		case errors.Is(err, ErrDisabled):
			err = platform.ErrNotFound(err.Error())
		}
		platform.WriteError(w, err)
		return
	}
	status := http.StatusCreated
	if !applied {
		status = http.StatusOK // an earlier request with this key already credited
	}
	platform.WriteJSON(w, status, map[string]any{"applied": applied, "balance": bal})
}

package payments

import (
	"errors"
	"io"
	"net/http"

	"github.com/ablearning/api/internal/platform"
)

type Handler struct{ svc *Service }

func NewHandler(svc *Service) *Handler { return &Handler{svc: svc} }

func (h *Handler) RegisterRoutes(mux *http.ServeMux, protected func(http.Handler) http.Handler) {
	mux.Handle("POST /api/v1/checkout", protected(http.HandlerFunc(h.checkout)))
	mux.Handle("GET /api/v1/orders", protected(http.HandlerFunc(h.listOrders)))
	mux.Handle("GET /api/v1/orders/{code}", protected(http.HandlerFunc(h.getOrder)))
	mux.Handle("POST /api/v1/payments/sandbox/{code}/complete", protected(http.HandlerFunc(h.sandboxComplete)))
	// Called by the gateway, not by a logged-in user: authenticated by the
	// signature, never by a bearer token.
	mux.HandleFunc("POST /api/v1/payments/webhook/sandbox", h.webhook)
}

func (h *Handler) checkout(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}
	var req CheckoutRequest
	if err := platform.DecodeJSON(r, &req); err != nil {
		platform.WriteError(w, err)
		return
	}
	o, err := h.svc.Checkout(r.Context(), userID, r.Header.Get("Idempotency-Key"), req)
	if err != nil {
		platform.WriteError(w, mapError(err))
		return
	}
	if o.Status == "pending" {
		o.Sandbox = &SandboxInfo{CompleteURL: "/api/v1/payments/sandbox/" + o.Code + "/complete"}
	}
	platform.WriteJSON(w, http.StatusCreated, o)
}

func (h *Handler) listOrders(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}
	out, err := h.svc.ListOrders(r.Context(), userID)
	if err != nil {
		platform.WriteError(w, mapError(err))
		return
	}
	platform.WriteJSON(w, http.StatusOK, out)
}

func (h *Handler) getOrder(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}
	o, err := h.svc.GetOrder(r.Context(), userID, r.PathValue("code"))
	if err != nil {
		platform.WriteError(w, mapError(err))
		return
	}
	platform.WriteJSON(w, http.StatusOK, o)
}

func (h *Handler) sandboxComplete(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}
	var req struct {
		Result string `json:"result"` // success | failed
	}
	if err := platform.DecodeJSON(r, &req); err != nil {
		platform.WriteError(w, err)
		return
	}
	if req.Result != "success" && req.Result != "failed" {
		platform.WriteError(w, platform.ErrValidation("result must be success or failed"))
		return
	}
	o, err := h.svc.SandboxComplete(r.Context(), userID, r.PathValue("code"), req.Result == "success")
	if err != nil {
		platform.WriteError(w, mapError(err))
		return
	}
	platform.WriteJSON(w, http.StatusOK, o)
}

func (h *Handler) webhook(w http.ResponseWriter, r *http.Request) {
	body, err := io.ReadAll(http.MaxBytesReader(w, r.Body, 1<<20))
	if err != nil {
		platform.WriteError(w, platform.ErrValidation("could not read body"))
		return
	}
	applied, err := h.svc.HandleWebhook(r.Context(), r.Header, body)
	if err != nil {
		platform.WriteError(w, mapError(err))
		return
	}
	// 200 either way: a replayed event is not an error for the gateway.
	platform.WriteJSON(w, http.StatusOK, map[string]bool{"received": true, "applied": applied})
}

func mapError(err error) error {
	switch {
	case errors.Is(err, ErrInvalidRequest):
		return platform.ErrValidation(err.Error())
	case errors.Is(err, ErrCourseUnavailable), errors.Is(err, ErrBadCoupon):
		return platform.NewAppError(http.StatusUnprocessableEntity, "UNPROCESSABLE", err.Error())
	case errors.Is(err, ErrAlreadyOwned), errors.Is(err, ErrNotPending):
		return platform.ErrConflict(err.Error())
	case errors.Is(err, ErrOrderNotFound):
		return platform.ErrNotFound(err.Error())
	case errors.Is(err, ErrNotSandbox):
		return platform.ErrNotFound(err.Error())
	case errors.Is(err, ErrBadSignature), errors.Is(err, ErrStaleEvent):
		return platform.NewAppError(http.StatusUnauthorized, "INVALID_SIGNATURE", err.Error())
	default:
		return err
	}
}

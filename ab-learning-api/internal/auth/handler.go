package auth

import (
	"errors"
	"net/http"

	"github.com/ablearning/api/internal/httpx"
	"github.com/ablearning/api/internal/middleware"
)

type Handler struct{ svc *Service }

func Register(mux *http.ServeMux, guard middleware.Guard, svc *Service) {
	h := &Handler{svc: svc}
	mux.HandleFunc("POST /api/v1/auth/login", h.login)
	mux.HandleFunc("POST /api/v1/auth/register", h.register)
	mux.HandleFunc("POST /api/v1/auth/refresh", h.refresh)
	mux.Handle("GET /api/v1/me", guard.Require(h.me))
	mux.Handle("PUT /api/v1/me", guard.Require(h.updateMe))
	mux.HandleFunc("POST /api/v1/auth/verify-otp", h.verifyOTP)
	mux.HandleFunc("POST /api/v1/auth/resend-otp", h.resendOTP)
	mux.HandleFunc("POST /api/v1/auth/forgot-password", h.forgotPassword)
	mux.Handle("POST /api/v1/me/preferences", guard.Require(h.savePreferences))
}

func (h *Handler) login(w http.ResponseWriter, r *http.Request) {
	var req LoginRequest
	if err := httpx.Decode(w, r, &req); err != nil {
		httpx.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	resp, err := h.svc.Login(req)
	switch {
	case errors.Is(err, ErrInvalidCredentials):
		httpx.Error(w, http.StatusUnauthorized, err.Error())
	case errors.Is(err, ErrAccountInactive):
		httpx.Error(w, http.StatusForbidden, err.Error())
	case err != nil:
		httpx.Error(w, http.StatusInternalServerError, "internal error")
	default:
		httpx.JSON(w, http.StatusOK, resp)
	}
}

func (h *Handler) register(w http.ResponseWriter, r *http.Request) {
	var req RegisterRequest
	if err := httpx.Decode(w, r, &req); err != nil {
		httpx.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	u, err := h.svc.Register(req)
	switch {
	case errors.Is(err, ErrValidation):
		httpx.Error(w, http.StatusUnprocessableEntity, err.Error())
	case errors.Is(err, ErrEmailTaken):
		httpx.Error(w, http.StatusConflict, err.Error())
	case err != nil:
		httpx.Error(w, http.StatusInternalServerError, "internal error")
	default:
		httpx.JSON(w, http.StatusCreated, u)
	}
}

func (h *Handler) refresh(w http.ResponseWriter, r *http.Request) {
	var req RefreshRequest
	if err := httpx.Decode(w, r, &req); err != nil {
		httpx.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	resp, err := h.svc.Refresh(req.RefreshToken)
	if err != nil {
		httpx.Error(w, http.StatusUnauthorized, "invalid refresh token")
		return
	}
	httpx.JSON(w, http.StatusOK, resp)
}

func (h *Handler) me(w http.ResponseWriter, r *http.Request) {
	p, _ := middleware.PrincipalFrom(r.Context())
	u, err := h.svc.Me(p.UserID)
	if err != nil {
		httpx.Error(w, http.StatusNotFound, "user not found")
		return
	}
	httpx.JSON(w, http.StatusOK, u)
}

func (h *Handler) updateMe(w http.ResponseWriter, r *http.Request) {
	p, _ := middleware.PrincipalFrom(r.Context())
	var req UpdateProfileRequest
	if err := httpx.Decode(w, r, &req); err != nil {
		httpx.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	u, err := h.svc.UpdateMe(p.UserID, req)
	switch {
	case errors.Is(err, ErrValidation):
		httpx.Error(w, http.StatusUnprocessableEntity, err.Error())
	case errors.Is(err, ErrNotFound):
		httpx.Error(w, http.StatusNotFound, "user not found")
	case err != nil:
		httpx.Error(w, http.StatusInternalServerError, "internal error")
	default:
		httpx.JSON(w, http.StatusOK, toUserResponse(u))
	}
}

func (h *Handler) verifyOTP(w http.ResponseWriter, r *http.Request) {
	var req VerifyOTPRequest
	if err := httpx.Decode(w, r, &req); err != nil {
		httpx.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	switch err := h.svc.VerifyOTP(req.UserID, req.Code); {
	case errors.Is(err, ErrInvalidCode):
		httpx.Error(w, http.StatusUnprocessableEntity, err.Error())
	case err != nil:
		httpx.Error(w, http.StatusInternalServerError, "internal error")
	default:
		httpx.JSON(w, http.StatusOK, map[string]string{"status": "verified"})
	}
}

func (h *Handler) resendOTP(w http.ResponseWriter, r *http.Request) {
	var req ResendOTPRequest
	if err := httpx.Decode(w, r, &req); err != nil {
		httpx.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	switch err := h.svc.ResendOTP(req.UserID); {
	case errors.Is(err, ErrDeliveryUnavailable):
		httpx.Error(w, http.StatusNotImplemented, err.Error())
	case errors.Is(err, ErrTooManyRequests):
		httpx.Error(w, http.StatusTooManyRequests, err.Error())
	case errors.Is(err, ErrNotFound):
		httpx.Error(w, http.StatusNotFound, "user not found")
	case err != nil:
		httpx.Error(w, http.StatusInternalServerError, "internal error")
	default:
		httpx.JSON(w, http.StatusOK, map[string]string{"status": "sent"})
	}
}

func (h *Handler) forgotPassword(w http.ResponseWriter, r *http.Request) {
	var req ForgotPasswordRequest
	if err := httpx.Decode(w, r, &req); err != nil {
		httpx.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	switch err := h.svc.ForgotPassword(req.Email); {
	case errors.Is(err, ErrDeliveryUnavailable):
		httpx.Error(w, http.StatusNotImplemented, err.Error())
	case errors.Is(err, ErrValidation):
		httpx.Error(w, http.StatusUnprocessableEntity, err.Error())
	case err != nil:
		httpx.Error(w, http.StatusInternalServerError, "internal error")
	default:
		httpx.JSON(w, http.StatusOK, map[string]string{"status": "ok"})
	}
}

func (h *Handler) savePreferences(w http.ResponseWriter, r *http.Request) {
	p, _ := middleware.PrincipalFrom(r.Context())
	var req PreferencesRequest
	if err := httpx.Decode(w, r, &req); err != nil {
		httpx.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	switch err := h.svc.SavePreferences(p.UserID, req); {
	case errors.Is(err, ErrValidation):
		httpx.Error(w, http.StatusUnprocessableEntity, err.Error())
	case err != nil:
		httpx.Error(w, http.StatusInternalServerError, "internal error")
	default:
		httpx.JSON(w, http.StatusOK, map[string]string{"status": "saved"})
	}
}

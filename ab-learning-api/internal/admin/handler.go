package admin

import (
	"errors"
	"net/http"

	"github.com/ablearning/api/internal/httpx"
	"github.com/ablearning/api/internal/middleware"
)

type Handler struct{ svc *Service }

func Register(mux *http.ServeMux, guard middleware.Guard, svc *Service) {
	h := &Handler{svc: svc}
	adm := func(fn http.HandlerFunc) http.Handler { return guard.Require(fn, middleware.RoleAdmin) }

	mux.Handle("GET /api/v1/admin/dashboard", adm(h.dashboard))
	mux.Handle("GET /api/v1/admin/courses/pending", adm(h.moderation))
	mux.Handle("POST /api/v1/admin/courses/{id}/approve", adm(h.approve))
	mux.Handle("POST /api/v1/admin/courses/{id}/reject", adm(h.reject))
	mux.Handle("GET /api/v1/admin/users", adm(h.listUsers))
	mux.Handle("GET /api/v1/admin/users/{id}", adm(h.getUser))
	mux.Handle("PUT /api/v1/admin/users/{id}", adm(h.updateUser))
	mux.Handle("POST /api/v1/admin/users/{id}/suspend", adm(h.suspend))
	mux.Handle("GET /api/v1/admin/payments", adm(h.listPayments))
	mux.Handle("POST /api/v1/admin/payments/{id}/refund", adm(h.refund))
}

func adminID(r *http.Request) int64 {
	p, _ := middleware.PrincipalFrom(r.Context())
	return p.UserID
}

func fail(w http.ResponseWriter, err error) {
	switch {
	case errors.Is(err, ErrValidation):
		httpx.Error(w, http.StatusUnprocessableEntity, err.Error())
	case errors.Is(err, ErrNotFound):
		httpx.Error(w, http.StatusNotFound, "not found")
	case errors.Is(err, ErrState):
		httpx.Error(w, http.StatusConflict, err.Error())
	case errors.Is(err, ErrSelf):
		httpx.Error(w, http.StatusForbidden, err.Error())
	default:
		httpx.Error(w, http.StatusInternalServerError, "internal error")
	}
}

func idParam(w http.ResponseWriter, r *http.Request) (int64, bool) {
	id, ok := httpx.PathID(r, "id")
	if !ok {
		httpx.Error(w, http.StatusBadRequest, "invalid id")
	}
	return id, ok
}

func (h *Handler) dashboard(w http.ResponseWriter, r *http.Request) {
	d, err := h.svc.Dashboard()
	if err != nil {
		fail(w, err)
		return
	}
	httpx.JSON(w, http.StatusOK, d)
}

func (h *Handler) moderation(w http.ResponseWriter, r *http.Request) {
	out, err := h.svc.Moderation(r.URL.Query().Get("status"))
	if err != nil {
		fail(w, err)
		return
	}
	httpx.JSON(w, http.StatusOK, out)
}

func (h *Handler) approve(w http.ResponseWriter, r *http.Request) {
	id, ok := idParam(w, r)
	if !ok {
		return
	}
	if err := h.svc.Approve(id, adminID(r)); err != nil {
		fail(w, err)
		return
	}
	httpx.JSON(w, http.StatusOK, map[string]string{"status": "published"})
}

func (h *Handler) reject(w http.ResponseWriter, r *http.Request) {
	id, ok := idParam(w, r)
	if !ok {
		return
	}
	var req RejectRequest
	if err := httpx.Decode(w, r, &req); err != nil {
		httpx.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	if err := h.svc.Reject(id, adminID(r), req.Reason); err != nil {
		fail(w, err)
		return
	}
	httpx.JSON(w, http.StatusOK, map[string]string{"status": "rejected"})
}

func (h *Handler) listUsers(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query()
	limit := httpx.QueryInt(r, "limit", 50, 1, 200)
	page := httpx.QueryInt(r, "page", 1, 1, 100000)
	out, err := h.svc.ListUsers(UserFilter{Role: q.Get("role"), Status: q.Get("status"), Query: q.Get("q"),
		Limit: limit, Offset: (page - 1) * limit})
	if err != nil {
		fail(w, err)
		return
	}
	httpx.JSON(w, http.StatusOK, out)
}

func (h *Handler) getUser(w http.ResponseWriter, r *http.Request) {
	id, ok := idParam(w, r)
	if !ok {
		return
	}
	u, err := h.svc.GetUser(id)
	if err != nil {
		fail(w, err)
		return
	}
	httpx.JSON(w, http.StatusOK, u)
}

func (h *Handler) updateUser(w http.ResponseWriter, r *http.Request) {
	id, ok := idParam(w, r)
	if !ok {
		return
	}
	var in UserUpdate
	if err := httpx.Decode(w, r, &in); err != nil {
		httpx.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	u, err := h.svc.UpdateUser(id, adminID(r), in)
	if err != nil {
		fail(w, err)
		return
	}
	httpx.JSON(w, http.StatusOK, u)
}

func (h *Handler) suspend(w http.ResponseWriter, r *http.Request) {
	id, ok := idParam(w, r)
	if !ok {
		return
	}
	var req SuspendRequest
	_ = httpx.Decode(w, r, &req) // reason optional; empty body allowed
	u, err := h.svc.Suspend(id, adminID(r), req.Reason)
	if err != nil {
		fail(w, err)
		return
	}
	httpx.JSON(w, http.StatusOK, u)
}

func (h *Handler) listPayments(w http.ResponseWriter, r *http.Request) {
	out, err := h.svc.ListPayments(r.URL.Query().Get("status"))
	if err != nil {
		fail(w, err)
		return
	}
	httpx.JSON(w, http.StatusOK, out)
}

func (h *Handler) refund(w http.ResponseWriter, r *http.Request) {
	id, ok := idParam(w, r)
	if !ok {
		return
	}
	var req RefundRequest
	if err := httpx.Decode(w, r, &req); err != nil {
		httpx.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	res, err := h.svc.Refund(id, adminID(r), req)
	if err != nil {
		fail(w, err)
		return
	}
	httpx.JSON(w, http.StatusOK, res)
}

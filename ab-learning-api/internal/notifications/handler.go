package notifications

import (
	"errors"
	"net/http"
	"strconv"

	"github.com/ablearning/api/internal/platform"
)

type Handler struct{ svc *Service }

func NewHandler(svc *Service) *Handler { return &Handler{svc: svc} }

func (h *Handler) RegisterRoutes(mux *http.ServeMux, protected func(http.Handler) http.Handler) {
	mux.Handle("GET /api/v1/notifications", protected(http.HandlerFunc(h.list)))
	mux.Handle("POST /api/v1/notifications/read-all", protected(http.HandlerFunc(h.readAll)))
	mux.Handle("POST /api/v1/notifications/{id}/read", protected(http.HandlerFunc(h.read)))
}

func (h *Handler) list(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}
	q := r.URL.Query()
	limit, _ := strconv.Atoi(q.Get("limit"))
	offset, _ := strconv.Atoi(q.Get("offset"))
	page, err := h.svc.List(r.Context(), userID, q.Get("unread") == "true", limit, offset)
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, page)
}

func (h *Handler) read(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}
	id, err := platform.ParseID(r.PathValue("id"), "notification")
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	if err := h.svc.MarkRead(r.Context(), userID, id); err != nil {
		if errors.Is(err, ErrNotFound) {
			err = platform.ErrNotFound(err.Error())
		}
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, map[string]bool{"ok": true})
}

func (h *Handler) readAll(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}
	n, err := h.svc.MarkAllRead(r.Context(), userID)
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, map[string]int64{"updated": n})
}

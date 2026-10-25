package courses

import (
	"errors"
	"net/http"

	"github.com/ablearning/api/internal/httpx"
)

type Handler struct{ svc *Service }

func Register(mux *http.ServeMux, svc *Service) {
	h := &Handler{svc: svc}
	mux.HandleFunc("GET /api/v1/categories", h.categories)
	mux.HandleFunc("GET /api/v1/courses", h.list)
	mux.HandleFunc("GET /api/v1/search", h.list)
	mux.HandleFunc("GET /api/v1/courses/{id}", h.get)
	mux.HandleFunc("GET /api/v1/courses/{id}/curriculum", h.curriculum)
}

func (h *Handler) list(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query()
	limit := httpx.QueryInt(r, "limit", 20, 1, 100)
	page := httpx.QueryInt(r, "page", 1, 1, 100000)
	out, err := h.svc.List(ListFilter{
		Category: q.Get("category"), Level: q.Get("level"), Query: q.Get("q"),
		Limit: limit, Offset: (page - 1) * limit,
	})
	if err != nil {
		httpx.Error(w, http.StatusInternalServerError, "internal error")
		return
	}
	httpx.JSON(w, http.StatusOK, out)
}

func (h *Handler) get(w http.ResponseWriter, r *http.Request) {
	id, ok := httpx.PathID(r, "id")
	if !ok {
		httpx.Error(w, http.StatusBadRequest, "invalid course id")
		return
	}
	c, err := h.svc.Get(id)
	if errors.Is(err, ErrNotFound) {
		httpx.Error(w, http.StatusNotFound, err.Error())
		return
	}
	if err != nil {
		httpx.Error(w, http.StatusInternalServerError, "internal error")
		return
	}
	httpx.JSON(w, http.StatusOK, c)
}

func (h *Handler) curriculum(w http.ResponseWriter, r *http.Request) {
	id, ok := httpx.PathID(r, "id")
	if !ok {
		httpx.Error(w, http.StatusBadRequest, "invalid course id")
		return
	}
	s, err := h.svc.Curriculum(id)
	if errors.Is(err, ErrNotFound) {
		httpx.Error(w, http.StatusNotFound, err.Error())
		return
	}
	if err != nil {
		httpx.Error(w, http.StatusInternalServerError, "internal error")
		return
	}
	httpx.JSON(w, http.StatusOK, s)
}

func (h *Handler) categories(w http.ResponseWriter, r *http.Request) {
	out, err := h.svc.Categories()
	if err != nil {
		httpx.Error(w, http.StatusInternalServerError, "internal error")
		return
	}
	httpx.JSON(w, http.StatusOK, out)
}

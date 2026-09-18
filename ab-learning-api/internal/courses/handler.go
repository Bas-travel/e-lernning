package courses

import (
	"net/http"
	"strconv"

	"github.com/ablearning/ab-learning-api/internal/platform"
)

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

// RegisterRoutes wires public (no-auth) endpoints — browsing the catalog
// doesn't require a session, matching the GUEST role in the source spec.
func (h *Handler) RegisterRoutes(mux *http.ServeMux) {
	mux.HandleFunc("GET /api/v1/courses", h.list)
	mux.HandleFunc("GET /api/v1/courses/{id}", h.get)
	mux.HandleFunc("GET /api/v1/search", h.search)
}

func (h *Handler) list(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query()
	page, _ := strconv.Atoi(q.Get("page"))
	limit, _ := strconv.Atoi(q.Get("limit"))

	list, err := h.service.List(r.Context(), ListParams{
		Category: q.Get("category"),
		Level:    q.Get("level"),
		Page:     page,
		Limit:    limit,
	})
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, list)
}

func (h *Handler) search(w http.ResponseWriter, r *http.Request) {
	results, err := h.service.Search(r.Context(), r.URL.Query().Get("q"))
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, results)
}

func (h *Handler) get(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.ParseInt(r.PathValue("id"), 10, 64)
	if err != nil {
		platform.WriteError(w, platform.ErrValidation("id must be a number"))
		return
	}

	course, err := h.service.Get(r.Context(), id)
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, course)
}

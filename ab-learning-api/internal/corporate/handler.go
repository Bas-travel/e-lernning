package corporate

import (
	"errors"
	"log"
	"net/http"

	"github.com/ablearning/api/internal/httpx"
	"github.com/ablearning/api/internal/middleware"
)

type Handler struct{ svc *Service }

// Register mounts corporate routes. Managers get read access plus learning
// paths; only the org admin may add/edit employees.
func Register(mux *http.ServeMux, guard middleware.Guard, svc *Service) {
	h := &Handler{svc: svc}
	read := func(fn http.HandlerFunc) http.Handler {
		return guard.Require(fn, middleware.RoleCorpAdmin, middleware.RoleCorpManager)
	}
	write := func(fn http.HandlerFunc) http.Handler { return guard.Require(fn, middleware.RoleCorpAdmin) }

	mux.Handle("GET /api/v1/corporate/dashboard", read(h.dashboard))
	mux.Handle("GET /api/v1/corporate/employees", read(h.employees))
	mux.Handle("POST /api/v1/corporate/employees", write(h.addEmployee))
	mux.Handle("PUT /api/v1/corporate/employees/{id}", write(h.updateEmployee))
	mux.Handle("GET /api/v1/corporate/learning-paths", read(h.paths))
	mux.Handle("POST /api/v1/corporate/learning-paths", read(h.createPath))
}

func uid(r *http.Request) int64 { p, _ := middleware.PrincipalFrom(r.Context()); return p.UserID }

func fail(w http.ResponseWriter, err error) {
	switch {
	case IsValidation(err):
		httpx.Error(w, http.StatusUnprocessableEntity, err.Error())
	case errors.Is(err, ErrNotFound):
		httpx.Error(w, http.StatusNotFound, "not found")
	case errors.Is(err, ErrConflict):
		httpx.Error(w, http.StatusConflict, "user already belongs to an organization")
	default:
		log.Printf("corporate: %v", err)
		httpx.Error(w, http.StatusInternalServerError, "internal error")
	}
}

func (h *Handler) dashboard(w http.ResponseWriter, r *http.Request) {
	d, err := h.svc.Dashboard(r.Context(), uid(r))
	if err != nil {
		fail(w, err)
		return
	}
	httpx.JSON(w, http.StatusOK, d)
}

func (h *Handler) employees(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query()
	limit := httpx.QueryInt(r, "limit", 20, 1, 100)
	page := httpx.QueryInt(r, "page", 1, 1, 100000)
	out, err := h.svc.Employees(r.Context(), uid(r), EmployeeFilter{
		Query: q.Get("q"), Department: q.Get("department"), Status: q.Get("status"),
		Limit: limit, Offset: (page - 1) * limit,
	})
	if err != nil {
		fail(w, err)
		return
	}
	httpx.JSON(w, http.StatusOK, out)
}

func (h *Handler) addEmployee(w http.ResponseWriter, r *http.Request) {
	var in AddEmployeeInput
	if err := httpx.Decode(w, r, &in); err != nil {
		httpx.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	e, err := h.svc.AddEmployee(r.Context(), uid(r), in)
	if err != nil {
		fail(w, err)
		return
	}
	httpx.JSON(w, http.StatusCreated, e)
}

func (h *Handler) updateEmployee(w http.ResponseWriter, r *http.Request) {
	id, ok := httpx.PathID(r, "id")
	if !ok {
		httpx.Error(w, http.StatusBadRequest, "invalid employee id")
		return
	}
	var in UpdateEmployeeInput
	if err := httpx.Decode(w, r, &in); err != nil {
		httpx.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	if err := h.svc.UpdateEmployee(r.Context(), uid(r), id, in); err != nil {
		fail(w, err)
		return
	}
	httpx.JSON(w, http.StatusOK, map[string]string{"status": "updated"})
}

func (h *Handler) paths(w http.ResponseWriter, r *http.Request) {
	out, err := h.svc.Paths(r.Context(), uid(r))
	if err != nil {
		fail(w, err)
		return
	}
	httpx.JSON(w, http.StatusOK, out)
}

func (h *Handler) createPath(w http.ResponseWriter, r *http.Request) {
	var in CreatePathInput
	if err := httpx.Decode(w, r, &in); err != nil {
		httpx.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	id, err := h.svc.CreatePath(r.Context(), uid(r), in)
	if err != nil {
		fail(w, err)
		return
	}
	httpx.JSON(w, http.StatusCreated, map[string]int64{"id": id})
}

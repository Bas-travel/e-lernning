package instructor

import (
	"errors"
	"net/http"

	"github.com/ablearning/api/internal/httpx"
	"github.com/ablearning/api/internal/middleware"
)

type Handler struct {
	svc      *Service
	uploader Uploader
}

func Register(mux *http.ServeMux, guard middleware.Guard, svc *Service, up Uploader) {
	h := &Handler{svc: svc, uploader: up}
	inst := func(fn http.HandlerFunc) http.Handler { return guard.Require(fn, middleware.RoleInstructor) }

	mux.Handle("GET /api/v1/instructor/dashboard", inst(h.dashboard))
	mux.Handle("GET /api/v1/instructor/revenue", inst(h.revenue))
	mux.Handle("GET /api/v1/instructor/courses", inst(h.listCourses))
	mux.Handle("POST /api/v1/instructor/courses", inst(h.createCourse))
	mux.Handle("GET /api/v1/instructor/courses/{id}", inst(h.getCourse))
	mux.Handle("PUT /api/v1/instructor/courses/{id}", inst(h.updateCourse))
	mux.Handle("DELETE /api/v1/instructor/courses/{id}", inst(h.deleteCourse))
	mux.Handle("POST /api/v1/instructor/courses/{id}/submit", inst(h.submit))

	mux.Handle("POST /api/v1/course-sections", inst(h.createSection))
	mux.Handle("PUT /api/v1/course-sections/{id}", inst(h.updateSection))
	mux.Handle("DELETE /api/v1/course-sections/{id}", inst(h.deleteSection))
	mux.Handle("POST /api/v1/lessons", inst(h.createLesson))
	mux.Handle("PUT /api/v1/lessons/{id}", inst(h.updateLesson))
	mux.Handle("DELETE /api/v1/lessons/{id}", inst(h.deleteLesson))

	mux.Handle("POST /api/v1/instructor/uploads/video", inst(func(w http.ResponseWriter, r *http.Request) { h.upload(w, r, "video") }))
	mux.Handle("POST /api/v1/instructor/uploads/image", inst(func(w http.ResponseWriter, r *http.Request) { h.upload(w, r, "image") }))
}

func uid(r *http.Request) int64 {
	p, _ := middleware.PrincipalFrom(r.Context())
	return p.UserID
}

// fail maps domain errors to HTTP statuses.
func fail(w http.ResponseWriter, err error) {
	switch {
	case errors.Is(err, ErrValidation):
		httpx.Error(w, http.StatusUnprocessableEntity, err.Error())
	case errors.Is(err, ErrNotFound):
		httpx.Error(w, http.StatusNotFound, "not found")
	case errors.Is(err, ErrForbidden):
		httpx.Error(w, http.StatusForbidden, err.Error())
	case errors.Is(err, ErrLocked):
		httpx.Error(w, http.StatusConflict, err.Error())
	default:
		httpx.Error(w, http.StatusInternalServerError, "internal error")
	}
}

func (h *Handler) dashboard(w http.ResponseWriter, r *http.Request) {
	d, err := h.svc.Dashboard(uid(r))
	if err != nil {
		fail(w, err)
		return
	}
	httpx.JSON(w, http.StatusOK, d)
}

func (h *Handler) revenue(w http.ResponseWriter, r *http.Request) {
	d, err := h.svc.Revenue(uid(r))
	if err != nil {
		fail(w, err)
		return
	}
	httpx.JSON(w, http.StatusOK, d)
}

func (h *Handler) listCourses(w http.ResponseWriter, r *http.Request) {
	out, err := h.svc.ListCourses(uid(r), r.URL.Query().Get("status"))
	if err != nil {
		fail(w, err)
		return
	}
	httpx.JSON(w, http.StatusOK, out)
}

func (h *Handler) getCourse(w http.ResponseWriter, r *http.Request) {
	id, ok := httpx.PathID(r, "id")
	if !ok {
		httpx.Error(w, http.StatusBadRequest, "invalid id")
		return
	}
	c, err := h.svc.GetCourse(uid(r), id)
	if err != nil {
		fail(w, err)
		return
	}
	httpx.JSON(w, http.StatusOK, c)
}

func (h *Handler) createCourse(w http.ResponseWriter, r *http.Request) {
	var in CourseInput
	if err := httpx.Decode(w, r, &in); err != nil {
		httpx.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	c, err := h.svc.CreateCourse(uid(r), in)
	if err != nil {
		fail(w, err)
		return
	}
	httpx.JSON(w, http.StatusCreated, c)
}

func (h *Handler) updateCourse(w http.ResponseWriter, r *http.Request) {
	id, ok := httpx.PathID(r, "id")
	if !ok {
		httpx.Error(w, http.StatusBadRequest, "invalid id")
		return
	}
	var in CourseInput
	if err := httpx.Decode(w, r, &in); err != nil {
		httpx.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	c, err := h.svc.UpdateCourse(uid(r), id, in)
	if err != nil {
		fail(w, err)
		return
	}
	httpx.JSON(w, http.StatusOK, c)
}

func (h *Handler) deleteCourse(w http.ResponseWriter, r *http.Request) {
	id, ok := httpx.PathID(r, "id")
	if !ok {
		httpx.Error(w, http.StatusBadRequest, "invalid id")
		return
	}
	if err := h.svc.DeleteCourse(uid(r), id); err != nil {
		fail(w, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *Handler) submit(w http.ResponseWriter, r *http.Request) {
	id, ok := httpx.PathID(r, "id")
	if !ok {
		httpx.Error(w, http.StatusBadRequest, "invalid id")
		return
	}
	c, err := h.svc.Submit(uid(r), id)
	if err != nil {
		fail(w, err)
		return
	}
	httpx.JSON(w, http.StatusOK, c)
}

func (h *Handler) createSection(w http.ResponseWriter, r *http.Request) {
	var in SectionInput
	if err := httpx.Decode(w, r, &in); err != nil {
		httpx.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	s, err := h.svc.CreateSection(uid(r), in)
	if err != nil {
		fail(w, err)
		return
	}
	httpx.JSON(w, http.StatusCreated, s)
}

func (h *Handler) updateSection(w http.ResponseWriter, r *http.Request) {
	id, ok := httpx.PathID(r, "id")
	if !ok {
		httpx.Error(w, http.StatusBadRequest, "invalid id")
		return
	}
	var in SectionInput
	if err := httpx.Decode(w, r, &in); err != nil {
		httpx.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	if err := h.svc.UpdateSection(uid(r), id, in); err != nil {
		fail(w, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *Handler) deleteSection(w http.ResponseWriter, r *http.Request) {
	id, ok := httpx.PathID(r, "id")
	if !ok {
		httpx.Error(w, http.StatusBadRequest, "invalid id")
		return
	}
	if err := h.svc.DeleteSection(uid(r), id); err != nil {
		fail(w, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *Handler) createLesson(w http.ResponseWriter, r *http.Request) {
	var in LessonInput
	if err := httpx.Decode(w, r, &in); err != nil {
		httpx.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	l, err := h.svc.CreateLesson(uid(r), in)
	if err != nil {
		fail(w, err)
		return
	}
	httpx.JSON(w, http.StatusCreated, l)
}

func (h *Handler) updateLesson(w http.ResponseWriter, r *http.Request) {
	id, ok := httpx.PathID(r, "id")
	if !ok {
		httpx.Error(w, http.StatusBadRequest, "invalid id")
		return
	}
	var in LessonInput
	if err := httpx.Decode(w, r, &in); err != nil {
		httpx.Error(w, http.StatusBadRequest, err.Error())
		return
	}
	if err := h.svc.UpdateLesson(uid(r), id, in); err != nil {
		fail(w, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *Handler) deleteLesson(w http.ResponseWriter, r *http.Request) {
	id, ok := httpx.PathID(r, "id")
	if !ok {
		httpx.Error(w, http.StatusBadRequest, "invalid id")
		return
	}
	if err := h.svc.DeleteLesson(uid(r), id); err != nil {
		fail(w, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *Handler) upload(w http.ResponseWriter, r *http.Request, which string) {
	res, status, err := h.uploader.Save(w, r, which)
	if err != nil {
		httpx.Error(w, status, err.Error())
		return
	}
	httpx.JSON(w, status, res)
}

package courses

import (
	"net/http"
	"strings"

	"github.com/ablearning/api/pkg/httpx"
)

type Controller struct {
	service *Service
}

func NewController(service *Service) *Controller {
	return &Controller{service: service}
}

func RegisterRoutes(mux *http.ServeMux) {
	controller := NewController(NewService(NewRepository()))
	mux.HandleFunc("/api/v1/courses", controller.ListCourses)
	mux.HandleFunc("/api/v1/courses/", controller.CourseByID)
}

func (c *Controller) ListCourses(w http.ResponseWriter, r *http.Request) {
	courses := c.service.List()
	httpx.JSON(w, http.StatusOK, courses)
}

func (c *Controller) CourseByID(w http.ResponseWriter, r *http.Request) {
	id := strings.TrimPrefix(r.URL.Path, "/api/v1/courses/")
	if id == "" {
		httpx.JSON(w, http.StatusNotFound, map[string]string{"error": "missing id"})
		return
	}

	course, err := c.service.GetByID(id)
	if err != nil {
		httpx.JSON(w, http.StatusNotFound, map[string]string{"error": err.Error()})
		return
	}

	httpx.JSON(w, http.StatusOK, course)
}

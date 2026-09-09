package learning

import (
	"encoding/json"
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
	mux.HandleFunc("/api/v1/me/courses", controller.GetMyCoursesHandler)
	// Keep course catalog routes owned by the courses domain. Learning state lives
	// under enrollments, matching the public API contract and avoiding route overlap.
	mux.HandleFunc("/api/v1/enrollments/", controller.EnrollmentHandler)
}

func (c *Controller) GetMyCoursesHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		httpx.JSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
		return
	}

	httpx.JSON(w, http.StatusOK, c.service.GetMyCourses())
}

func (c *Controller) EnrollmentHandler(w http.ResponseWriter, r *http.Request) {
	path := strings.Trim(strings.TrimPrefix(r.URL.Path, "/api/v1/enrollments/"), "/")
	if path == "" {
		httpx.JSON(w, http.StatusNotFound, map[string]string{"error": "course not found"})
		return
	}

	segments := strings.Split(path, "/")
	courseID := segments[0]
	if len(segments) > 1 && segments[1] == "enroll" {
		switch r.Method {
		case http.MethodPost:
			enrollment, err := c.service.Enroll(courseID)
			if err != nil {
				httpx.JSON(w, http.StatusBadRequest, map[string]string{"error": err.Error()})
				return
			}
			httpx.JSON(w, http.StatusCreated, enrollment)
		default:
			httpx.JSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
		}
		return
	}

	switch r.Method {
	case http.MethodPost:
		var payload struct {
			Progress float64 `json:"progress"`
		}
		if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
			httpx.JSON(w, http.StatusBadRequest, map[string]string{"error": "invalid body"})
			return
		}

		updated, err := c.service.UpdateProgress(courseID, payload.Progress)
		if err != nil {
			httpx.JSON(w, http.StatusBadRequest, map[string]string{"error": err.Error()})
			return
		}
		httpx.JSON(w, http.StatusOK, updated)
	case http.MethodGet:
		if enrollment, exists := c.service.repo.GetEnrollment(courseID); exists {
			httpx.JSON(w, http.StatusOK, enrollment)
			return
		}
		httpx.JSON(w, http.StatusNotFound, map[string]string{"error": "enrollment not found"})
	default:
		httpx.JSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
	}
}

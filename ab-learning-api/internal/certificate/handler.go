package certificate

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
	mux.HandleFunc("/api/v1/certificates", controller.ListCertificates)
	mux.HandleFunc("/api/v1/certificates/", controller.CertificateDetail)
}

func (c *Controller) ListCertificates(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		httpx.JSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
		return
	}
	httpx.JSON(w, http.StatusOK, c.service.List())
}

func (c *Controller) CertificateDetail(w http.ResponseWriter, r *http.Request) {
	id := strings.Trim(strings.TrimPrefix(r.URL.Path, "/api/v1/certificates/"), "/")
	if id == "" {
		httpx.JSON(w, http.StatusNotFound, map[string]string{"error": "certificate not found"})
		return
	}

	if r.Method != http.MethodGet {
		httpx.JSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
		return
	}

	cert, err := c.service.Get(id)
	if err != nil {
		httpx.JSON(w, http.StatusNotFound, map[string]string{"error": err.Error()})
		return
	}

	httpx.JSON(w, http.StatusOK, cert)
}

func (c *Controller) IssueCertificate(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		httpx.JSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
		return
	}

	var payload struct {
		CourseID   string `json:"courseId"`
		CourseName string `json:"courseName"`
	}
	if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
		httpx.JSON(w, http.StatusBadRequest, map[string]string{"error": "invalid body"})
		return
	}

	cert, err := c.service.Issue(payload.CourseID, payload.CourseName)
	if err != nil {
		httpx.JSON(w, http.StatusBadRequest, map[string]string{"error": err.Error()})
		return
	}

	httpx.JSON(w, http.StatusCreated, cert)
}

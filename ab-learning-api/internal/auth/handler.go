package auth

import (
	"encoding/json"
	"net/http"

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
	mux.HandleFunc("/api/v1/auth/login", controller.Login)
}

func (c *Controller) Login(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		httpx.JSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
		return
	}

	var req LoginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		httpx.JSON(w, http.StatusBadRequest, map[string]string{"error": "invalid body"})
		return
	}

	resp, err := c.service.Login(req)
	if err != nil {
		httpx.JSON(w, http.StatusUnauthorized, map[string]string{"error": err.Error()})
		return
	}

	httpx.JSON(w, http.StatusOK, resp)
}

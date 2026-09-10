package auth

import (
	"encoding/json"
	"net/http"

	"github.com/ablearning/api/pkg/httpx"
)

type loginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type loginResponse struct {
	Token string `json:"token"`
}

func RegisterRoutes(mux *http.ServeMux) {
	mux.HandleFunc("/api/v1/auth/login", Login)
}

func Login(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		httpx.JSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
		return
	}

	var req loginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		httpx.JSON(w, http.StatusBadRequest, map[string]string{"error": "invalid body"})
		return
	}

	// Prototype stub: accept any credentials
	resp := loginResponse{Token: "stub-access-token"}
	httpx.JSON(w, http.StatusOK, resp)
}

package corporate

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/ablearning/api/internal/middleware"
	"github.com/ablearning/api/internal/security"
)

func TestCorporateManagerCannotCreateLearningPath(t *testing.T) {
	const secret = "test-secret"
	mux := http.NewServeMux()
	Register(mux, middleware.Guard{Secret: secret}, NewService(NewRepository(nil)))
	token, err := security.IssueToken(secret, 42, middleware.RoleCorpManager, "access", time.Hour)
	if err != nil {
		t.Fatal(err)
	}
	req := httptest.NewRequest(http.MethodPost, "/api/v1/corporate/learning-paths", strings.NewReader(`{"name":"Path","course_ids":[1]}`))
	req.Header.Set("Authorization", "Bearer "+token)
	req.Header.Set("Content-Type", "application/json")
	res := httptest.NewRecorder()
	mux.ServeHTTP(res, req)
	if res.Code != http.StatusForbidden {
		t.Fatalf("manager POST status = %d, want %d (body: %s)", res.Code, http.StatusForbidden, res.Body.String())
	}
}

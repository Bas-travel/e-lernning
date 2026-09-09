package future

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

func newRouter() *http.ServeMux {
	mux := http.NewServeMux()
	RegisterRoutes(mux)
	return mux
}

func request(mux http.Handler, method, path, body string) *httptest.ResponseRecorder {
	req := httptest.NewRequest(method, path, bytes.NewBufferString(body))
	if body != "" {
		req.Header.Set("Content-Type", "application/json")
	}
	res := httptest.NewRecorder()
	mux.ServeHTTP(res, req)
	return res
}

func TestReadEndpointsReturnPrototypeData(t *testing.T) {
	mux := newRouter()
	cases := []struct{ path, key string }{
		{"/api/v1/skills/assessment", "questions"}, {"/api/v1/skills/result", "overall"},
		{"/api/v1/career-paths/backend", "title"}, {"/api/v1/portfolio", "headline"},
		{"/api/v1/jobs", ""}, {"/api/v1/jobs/j001", "company"},
		{"/api/v1/corporate/dashboard", "employees"}, {"/api/v1/corporate/employees", ""},
		{"/api/v1/corporate/learning-paths", ""}, {"/api/v1/admin/dashboard", "users"},
		{"/api/v1/admin/users", ""}, {"/api/v1/admin/courses/pending", ""},
		{"/api/v1/admin/payments", ""}, {"/api/v1/admin/audit-logs", ""},
	}
	for _, tc := range cases {
		t.Run(tc.path, func(t *testing.T) {
			res := request(mux, http.MethodGet, tc.path, "")
			if res.Code != http.StatusOK || !json.Valid(res.Body.Bytes()) {
				t.Fatalf("GET %s returned %d: %s", tc.path, res.Code, res.Body.String())
			}
			if tc.key != "" && !bytes.Contains(res.Body.Bytes(), []byte(`"`+tc.key+`"`)) {
				t.Errorf("GET %s response does not contain %q", tc.path, tc.key)
			}
		})
	}
}

func TestTutorValidationAndMutationEndpoints(t *testing.T) {
	mux := newRouter()
	if res := request(mux, http.MethodPost, "/api/v1/ai/tutor", `{"message":"Explain REST API"}`); res.Code != http.StatusOK || !bytes.Contains(res.Body.Bytes(), []byte(`"answer"`)) {
		t.Fatalf("successful tutor request = %d, %s", res.Code, res.Body.String())
	}
	if got := request(mux, http.MethodPost, "/api/v1/ai/tutor", `{}`).Code; got != http.StatusBadRequest {
		t.Errorf("missing tutor message = %d, want %d", got, http.StatusBadRequest)
	}
	cases := []struct {
		method, path, body string
		status             int
		expected           string
	}{
		{http.MethodPost, "/api/v1/skills/assessment", `{"answers":{"s1":"Advanced"}}`, http.StatusOK, `"overall":72`},
		{http.MethodPut, "/api/v1/portfolio", `{"headline":"Go engineer","skills":["Go"],"projects":[]}`, http.StatusOK, `"userId":"user-demo"`},
		{http.MethodPost, "/api/v1/jobs/j001/apply", `{"portfolioId":"p001"}`, http.StatusCreated, `"status":"submitted"`},
		{http.MethodPost, "/api/v1/corporate/learning-paths", `{"name":"New hire path"}`, http.StatusCreated, `"status":"created"`},
	}
	for _, tc := range cases {
		res := request(mux, tc.method, tc.path, tc.body)
		if res.Code != tc.status || !bytes.Contains(res.Body.Bytes(), []byte(tc.expected)) {
			t.Errorf("%s %s returned %d: %s", tc.method, tc.path, res.Code, res.Body.String())
		}
	}
	if res := request(mux, http.MethodGet, "/api/v1/portfolio", ""); !bytes.Contains(res.Body.Bytes(), []byte(`"headline":"Go engineer"`)) {
		t.Errorf("portfolio update was not persisted: %s", res.Body.String())
	}
}

func TestUnknownResourcesAndUnsupportedMethods(t *testing.T) {
	mux := newRouter()
	if got := request(mux, http.MethodGet, "/api/v1/jobs/missing", "").Code; got != http.StatusNotFound {
		t.Errorf("unknown job = %d, want %d", got, http.StatusNotFound)
	}
	if got := request(mux, http.MethodDelete, "/api/v1/admin/dashboard", "").Code; got != http.StatusMethodNotAllowed {
		t.Errorf("unsupported method = %d, want %d", got, http.StatusMethodNotAllowed)
	}
}

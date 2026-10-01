package platform

import (
	"net/http"
	"net/http/httptest"
	"testing"
	"time"
)

func TestRateLimitRejectsRequestsOverLimitAndSeparatesClients(t *testing.T) {
	handler := RateLimit(1, time.Minute)(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusNoContent)
	}))

	request := func(remoteAddr string) int {
		req := httptest.NewRequest(http.MethodGet, "/", nil)
		req.RemoteAddr = remoteAddr
		res := httptest.NewRecorder()
		handler.ServeHTTP(res, req)
		return res.Code
	}

	if got := request("192.0.2.1:1000"); got != http.StatusNoContent {
		t.Fatalf("first request status = %d", got)
	}
	if got := request("192.0.2.1:1001"); got != http.StatusTooManyRequests {
		t.Fatalf("over-limit request status = %d", got)
	}
	if got := request("192.0.2.2:1000"); got != http.StatusNoContent {
		t.Fatalf("separate client status = %d", got)
	}
}
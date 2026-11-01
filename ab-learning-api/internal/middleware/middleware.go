// Package middleware provides authentication, RBAC and CORS/logging wrappers.
package middleware

import (
	"context"
	"log"
	"net/http"
	"strings"
	"time"

	"github.com/ablearning/api/internal/httpx"
	"github.com/ablearning/api/internal/security"
)

// Role codes — mirror `roles.code` in the DB and `User.role` in OpenAPI.
const (
	RoleLearner     = "LEARNER"
	RoleInstructor  = "INSTRUCTOR"
	RoleCorpAdmin   = "CORP_ADMIN"
	RoleCorpManager = "CORP_MANAGER"
	RoleEmployer    = "EMPLOYER"
	RoleAdmin       = "ADMIN"
)

type Principal struct {
	UserID int64
	Role   string
}

type ctxKey struct{}

func PrincipalFrom(ctx context.Context) (Principal, bool) {
	p, ok := ctx.Value(ctxKey{}).(Principal)
	return p, ok
}

// Guard builds handlers that require a valid access token and (optionally)
// one of the allowed roles.
type Guard struct{ Secret string }

func (g Guard) Require(next http.HandlerFunc, roles ...string) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		h := r.Header.Get("Authorization")
		if !strings.HasPrefix(h, "Bearer ") {
			httpx.Error(w, http.StatusUnauthorized, "missing bearer token")
			return
		}
		claims, err := security.ParseToken(g.Secret, strings.TrimPrefix(h, "Bearer "), "access")
		if err != nil {
			httpx.Error(w, http.StatusUnauthorized, "invalid or expired token")
			return
		}
		if len(roles) > 0 {
			allowed := false
			for _, role := range roles {
				if claims.Role == role {
					allowed = true
					break
				}
			}
			if !allowed {
				httpx.Error(w, http.StatusForbidden, "your role is not allowed to access this resource")
				return
			}
		}
		next(w, r.WithContext(context.WithValue(r.Context(), ctxKey{}, Principal{UserID: claims.Sub, Role: claims.Role})))
	})
}

type statusWriter struct {
	http.ResponseWriter
	status int
}

func (s *statusWriter) WriteHeader(c int) { s.status = c; s.ResponseWriter.WriteHeader(c) }

// Common wraps the mux with CORS, panic recovery and request logging.
func Common(allowOrigin string, next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", allowOrigin)
		w.Header().Set("Access-Control-Allow-Headers", "Authorization, Content-Type")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}
		sw := &statusWriter{ResponseWriter: w, status: 200}
		start := time.Now()
		defer func() {
			if rec := recover(); rec != nil {
				log.Printf("panic: %v", rec)
				httpx.Error(sw, http.StatusInternalServerError, "internal error")
			}
			log.Printf("%s %s %d %s", r.Method, r.URL.Path, sw.status, time.Since(start).Round(time.Millisecond))
		}()
		next.ServeHTTP(sw, r)
	})
}

package platform

import (
	"context"
	"log"
	"net/http"
	"strings"
	"time"
)

// ---- Logging ----

type statusRecorder struct {
	http.ResponseWriter
	status int
}

func (r *statusRecorder) WriteHeader(status int) {
	r.status = status
	r.ResponseWriter.WriteHeader(status)
}

// Logging logs method, path, status, and duration for every request.
func Logging(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		rec := &statusRecorder{ResponseWriter: w, status: http.StatusOK}
		next.ServeHTTP(rec, r)
		log.Printf("%s %s -> %d (%s)", r.Method, r.URL.Path, rec.status, time.Since(start))
	})
}

// ---- Panic recovery ----

// Recover converts a panic in any handler into a 500 AppError instead of
// crashing the process — one bad request should never take down the API.
func Recover(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		defer func() {
			if rec := recover(); rec != nil {
				log.Printf("panic recovered: %v", rec)
				WriteError(w, ErrInternal)
			}
		}()
		next.ServeHTTP(w, r)
	})
}

// ---- CORS ----

// CORS allows the Flutter web build (served from a different origin during
// development) to call this API. Tighten AllowedOrigin in production.
func CORS(allowedOrigin string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Access-Control-Allow-Origin", allowedOrigin)
			w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
			w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
			if r.Method == http.MethodOptions {
				w.WriteHeader(http.StatusNoContent)
				return
			}
			next.ServeHTTP(w, r)
		})
	}
}

// ---- Auth ----

type ctxKey string

const userIDKey ctxKey = "user_id"
const userRoleKey ctxKey = "user_role"

// TokenVerifier is satisfied by pkg/jwtx.Manager — kept as an interface
// here so this package doesn't import pkg/jwtx directly (avoids an import
// cycle and keeps middleware testable with a fake verifier).
type TokenVerifier interface {
	Verify(token string) (userID int64, role string, err error)
}

// RequireAuth reads the `Authorization: Bearer <token>` header, verifies
// it, and stores the resulting user ID/role on the request context for
// handlers to read via UserIDFromContext / RoleFromContext.
func RequireAuth(verifier TokenVerifier) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			header := r.Header.Get("Authorization")
			token, ok := strings.CutPrefix(header, "Bearer ")
			if !ok || token == "" {
				WriteError(w, ErrUnauthorized)
				return
			}

			userID, role, err := verifier.Verify(token)
			if err != nil {
				WriteError(w, ErrUnauthorized)
				return
			}

			ctx := context.WithValue(r.Context(), userIDKey, userID)
			ctx = context.WithValue(ctx, userRoleKey, role)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

func UserIDFromContext(ctx context.Context) (int64, bool) {
	id, ok := ctx.Value(userIDKey).(int64)
	return id, ok
}

func RoleFromContext(ctx context.Context) (string, bool) {
	role, ok := ctx.Value(userRoleKey).(string)
	return role, ok
}

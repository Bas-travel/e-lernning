// Package employer implements screen 39: the employer dashboard.
package employer

import (
	"database/sql"
	"net/http"

	"github.com/ablearning/api/internal/middleware"
)

func Register(mux *http.ServeMux, guard middleware.Guard, db *sql.DB) {
	h := NewHandler(NewService(NewRepository(db)))
	h.RegisterRoutes(mux, func(next http.Handler) http.Handler {
		return guard.Require(next.ServeHTTP, middleware.RoleEmployer)
	})
}

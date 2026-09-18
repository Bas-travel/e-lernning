// Command api is the AB Learning backend's entrypoint. It wires config,
// the MySQL pool, JWT manager, and every domain's handler onto one
// net/http.ServeMux, then serves it.
package main

import (
	"log"
	"net/http"

	"github.com/ablearning/ab-learning-api/internal/admin"
	"github.com/ablearning/ab-learning-api/internal/auth"
	"github.com/ablearning/ab-learning-api/internal/config"
	"github.com/ablearning/ab-learning-api/internal/corporate"
	"github.com/ablearning/ab-learning-api/internal/courses"
	"github.com/ablearning/ab-learning-api/internal/employer"
	"github.com/ablearning/ab-learning-api/internal/home"
	"github.com/ablearning/ab-learning-api/internal/instructor"
	"github.com/ablearning/ab-learning-api/internal/platform"
	"github.com/ablearning/ab-learning-api/pkg/jwtx"
)

func main() {
	cfg := config.Load()

	db, err := platform.NewMySQL(cfg.DBDSN)
	if err != nil {
		log.Fatalf("database: %v", err)
	}
	defer db.Close()
	log.Println("connected to MySQL")

	jwtManager := jwtx.NewManager(cfg.JWTSecret, cfg.AccessTokenTTL)
	requireAuth := platform.RequireAuth(jwtManager)

	mux := http.NewServeMux()

	mux.HandleFunc("GET /health", func(w http.ResponseWriter, r *http.Request) {
		platform.WriteJSON(w, http.StatusOK, map[string]string{"status": "ok"})
	})

	// Each domain owns its own routes — see internal/<domain>/handler.go.
	// Adding a new domain (e.g. quizzes) means: write its own
	// model/dto/repository/service/handler.go following this exact
	// pattern, then add two lines here.
	authRepo := auth.NewRepository(db)
	authService := auth.NewService(authRepo, jwtManager)
	auth.NewHandler(authService).RegisterRoutes(mux, requireAuth)

	homeRepo := home.NewRepository(db)
	homeService := home.NewService(homeRepo)
	home.NewHandler(homeService).RegisterRoutes(mux, requireAuth)

	coursesRepo := courses.NewRepository(db)
	coursesService := courses.NewService(coursesRepo)
	courses.NewHandler(coursesService).RegisterRoutes(mux)

	// ---- Phase 2: one role-guarded domain per remaining role. Each guard
	// chain is requireAuth (verify the JWT) THEN RequireRole (check the
	// role inside that JWT matches). Wrong role -> 403 FORBIDDEN, not a
	// silent redirect — the Flutter app decides what to show for that. ----

	instructorGuard := func(h http.Handler) http.Handler {
		return requireAuth(platform.RequireRole("INSTRUCTOR")(h))
	}
	instructorRepo := instructor.NewRepository(db)
	instructorService := instructor.NewService(instructorRepo)
	instructor.NewHandler(instructorService).RegisterRoutes(mux, instructorGuard)

	corpGuard := func(h http.Handler) http.Handler {
		return requireAuth(platform.RequireRole("CORP_ADMIN", "CORP_MANAGER")(h))
	}
	corpRepo := corporate.NewRepository(db)
	corpService := corporate.NewService(corpRepo)
	corporate.NewHandler(corpService).RegisterRoutes(mux, corpGuard)

	employerGuard := func(h http.Handler) http.Handler {
		return requireAuth(platform.RequireRole("EMPLOYER")(h))
	}
	employerRepo := employer.NewRepository(db)
	employerService := employer.NewService(employerRepo)
	employer.NewHandler(employerService).RegisterRoutes(mux, employerGuard)

	adminGuard := func(h http.Handler) http.Handler {
		return requireAuth(platform.RequireRole("ADMIN")(h))
	}
	adminRepo := admin.NewRepository(db)
	adminService := admin.NewService(adminRepo)
	admin.NewHandler(adminService).RegisterRoutes(mux, adminGuard)

	var handler http.Handler = mux
	handler = platform.CORS(cfg.AllowedOrigin)(handler)
	handler = platform.Logging(handler)
	handler = platform.Recover(handler)

	log.Printf("AB Learning API listening on :%s", cfg.Port)
	if err := http.ListenAndServe(":"+cfg.Port, handler); err != nil {
		log.Fatalf("server: %v", err)
	}
}

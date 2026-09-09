// Command api is the AB Learning backend's entrypoint. It wires config,
// the MySQL pool, JWT manager, and every domain's handler onto one
// net/http.ServeMux, then serves it.
package main

import (
	"log"
	"net/http"

	"github.com/ablearning/ab-learning-api/internal/auth"
	"github.com/ablearning/ab-learning-api/internal/config"
	"github.com/ablearning/ab-learning-api/internal/courses"
	"github.com/ablearning/ab-learning-api/internal/home"
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

	var handler http.Handler = mux
	handler = platform.CORS(cfg.AllowedOrigin)(handler)
	handler = platform.Logging(handler)
	handler = platform.Recover(handler)

	log.Printf("AB Learning API listening on :%s", cfg.Port)
	if err := http.ListenAndServe(":"+cfg.Port, handler); err != nil {
		log.Fatalf("server: %v", err)
	}
}

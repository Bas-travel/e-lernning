package main

import (
	"context"
	"errors"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/ablearning/api/internal/admin"
	"github.com/ablearning/api/internal/auth"
	"github.com/ablearning/api/internal/certificate"
	"github.com/ablearning/api/internal/config"
	"github.com/ablearning/api/internal/corporate"
	"github.com/ablearning/api/internal/courses"
	"github.com/ablearning/api/internal/database"
	"github.com/ablearning/api/internal/employer"
	"github.com/ablearning/api/internal/home"
	"github.com/ablearning/api/internal/httpx"
	"github.com/ablearning/api/internal/instructor"
	"github.com/ablearning/api/internal/learning"
	"github.com/ablearning/api/internal/middleware"
	"github.com/ablearning/api/internal/platform"
	"github.com/ablearning/api/internal/quiz"
	"github.com/ablearning/api/internal/security"
)

type accessTokenVerifier struct {
	secret string
}

func (v accessTokenVerifier) Verify(token string) (int64, string, error) {
	claims, err := security.ParseToken(v.secret, token, "access")
	return claims.Sub, claims.Role, err
}

func main() {
	cfg := config.Load()

	if err := database.Migrate(cfg.DBDSN, cfg.MigrationsDir); err != nil {
		log.Fatalf("migrate: %v", err)
	}
	db, err := database.Open(cfg.DBDSN)
	if err != nil {
		log.Fatalf("database: %v", err)
	}
	defer db.Close()

	if cfg.SeedDev {
		if cfg.Env == "production" {
			log.Fatal("SEED_DEV must not be enabled in production")
		}
		if err := database.SeedDev(db); err != nil {
			log.Fatalf("seed: %v", err)
		}
	}

	mux := http.NewServeMux()
	guard := middleware.Guard{Secret: cfg.JWTSecret}
	protected := platform.RequireAuth(accessTokenVerifier{secret: cfg.JWTSecret})
	learningRepo := learning.NewRepository(db)
	certificateRepo := certificate.NewSQLRepository(db)

	mux.HandleFunc("GET /api/v1/health", func(w http.ResponseWriter, r *http.Request) {
		if err := db.PingContext(r.Context()); err != nil {
			httpx.Error(w, http.StatusServiceUnavailable, "database unavailable")
			return
		}
		httpx.JSON(w, http.StatusOK, map[string]string{"status": "ok"})
	})

	auth.Register(mux, guard, auth.NewService(auth.NewRepository(db), cfg.JWTSecret))
	courses.Register(mux, courses.NewService(courses.NewRepository(db)))
	home.NewHandler(home.NewService(home.NewRepository(db))).RegisterRoutes(mux, protected)
	learning.NewHandler(learning.NewService(learningRepo, learningRepo, certificateRepo)).RegisterRoutes(mux, protected)
	quiz.NewHandler(quiz.NewService(quiz.NewRepository(db), learningRepo)).RegisterRoutes(mux, protected)
	certificate.NewHTTPHandler(certificateRepo).RegisterRoutes(mux, protected)
	instructor.Register(mux, guard, instructor.NewService(instructor.NewRepository(db)), instructor.Uploader{
		Dir: cfg.UploadDir, MaxVideo: cfg.MaxVideoMB << 20, MaxImage: 5 << 20,
	})
	admin.Register(mux, guard, admin.NewService(admin.NewRepository(db)))
	corporate.Register(mux, guard, corporate.NewService(corporate.NewRepository(db)))
	employer.Register(mux, guard, db)

	// Uploaded media (Phase 3 local storage; Phase 4 moves to a video CDN).
	_ = os.MkdirAll(cfg.UploadDir, 0o755)
	mux.Handle("GET /uploads/", http.StripPrefix("/uploads/",
		http.FileServer(instructor.NoListFS{FS: http.Dir(cfg.UploadDir)})))

	srv := &http.Server{
		Addr:              ":" + cfg.Port,
		Handler:           middleware.Common(cfg.CORSAllowOrigin, platform.RateLimit(cfg.RateLimitRequests, time.Duration(cfg.RateLimitWindowSec)*time.Second)(mux)),
		ReadHeaderTimeout: 10 * time.Second,
		ReadTimeout:       0, // large video uploads
		IdleTimeout:       60 * time.Second,
	}

	go func() {
		log.Printf("AB LEARNING API listening on :%s (env=%s)", cfg.Port, cfg.Env)
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			log.Fatal(err)
		}
	}()

	stop := make(chan os.Signal, 1)
	signal.Notify(stop, syscall.SIGINT, syscall.SIGTERM)
	<-stop
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()
	_ = srv.Shutdown(ctx)
}

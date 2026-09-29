// Package config loads runtime configuration from environment variables.
package config

import (
	"log"
	"os"
	"strconv"
)

type Config struct {
	Env             string // dev | staging | production
	Port            string
	DBDSN           string
	JWTSecret       string
	UploadDir       string
	MaxVideoMB      int64
	MigrationsDir   string
	SeedDev         bool
	CORSAllowOrigin string
}

func Load() Config {
	c := Config{
		Env:             get("APP_ENV", "dev"),
		Port:            get("PORT", "8080"),
		DBDSN:           get("DB_DSN", "root:@tcp(127.0.0.1:3306)/ablearning?charset=utf8mb4&loc=UTC"),
		JWTSecret:       os.Getenv("JWT_SECRET"),
		UploadDir:       get("UPLOAD_DIR", "./uploads"),
		MaxVideoMB:      getInt("MAX_VIDEO_MB", 500),
		MigrationsDir:   get("MIGRATIONS_DIR", "db/migrations"),
		SeedDev:         get("SEED_DEV", "false") == "true",
		CORSAllowOrigin: get("CORS_ALLOW_ORIGIN", "*"),
	}
	if c.JWTSecret == "" {
		if c.Env == "production" {
			log.Fatal("JWT_SECRET must be set when APP_ENV=production")
		}
		log.Println("WARNING: JWT_SECRET not set — using an insecure development secret")
		c.JWTSecret = "dev-only-insecure-secret-change-me"
	}
	return c
}

func get(k, def string) string {
	if v := os.Getenv(k); v != "" {
		return v
	}
	return def
}

func getInt(k string, def int64) int64 {
	if v := os.Getenv(k); v != "" {
		if n, err := strconv.ParseInt(v, 10, 64); err == nil {
			return n
		}
	}
	return def
}

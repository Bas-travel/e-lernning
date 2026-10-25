// Package config loads runtime configuration from environment variables.
package config

import (
	"fmt"
	"log"
	"os"
	"strconv"
)

type Config struct {
	Env                string // dev | staging | production
	Port               string
	DBDSN              string
	JWTSecret          string
	UploadDir          string
	MaxVideoMB         int64
	MigrationsDir      string
	SeedDev            bool
	CORSAllowOrigin    string
	RateLimitRequests  int
	RateLimitWindowSec int64
}

func Load() Config {
	env := get("APP_ENV", "dev")
	corsDefault := "http://localhost:3000"
	dsnDefault := "root:@tcp(127.0.0.1:3306)/ablearning?charset=utf8mb4&parseTime=true&loc=UTC"
	if env == "staging" || env == "production" {
		corsDefault = ""
		dsnDefault = ""
	}
	c := Config{
		Env:                env,
		Port:               get("PORT", "8080"),
		DBDSN:              get("DB_DSN", dsnDefault),
		JWTSecret:          os.Getenv("JWT_SECRET"),
		UploadDir:          get("UPLOAD_DIR", "./uploads"),
		MaxVideoMB:         getInt("MAX_VIDEO_MB", 500),
		MigrationsDir:      get("MIGRATIONS_DIR", "db/migrations"),
		SeedDev:            get("SEED_DEV", "false") == "true",
		CORSAllowOrigin:    get("CORS_ALLOW_ORIGIN", corsDefault),
		RateLimitRequests:  int(getInt("RATE_LIMIT_REQUESTS", 120)),
		RateLimitWindowSec: getInt("RATE_LIMIT_WINDOW_SECONDS", 60),
	}
	if c.JWTSecret == "" {
		if c.Env == "production" || c.Env == "staging" {
			log.Fatal("JWT_SECRET must be set when APP_ENV is staging or production")
		}
		log.Println("WARNING: JWT_SECRET not set — using an insecure development secret")
		c.JWTSecret = "dev-only-insecure-secret-change-me"
	}
	if err := c.Validate(); err != nil {
		log.Fatal(err)
	}
	return c
}

func (c Config) Validate() error {
	if c.MaxVideoMB <= 0 {
		return fmt.Errorf("MAX_VIDEO_MB must be positive")
	}
	if c.RateLimitRequests <= 0 || c.RateLimitWindowSec <= 0 {
		return fmt.Errorf("rate limit requests and window must be positive")
	}
	if c.Env != "staging" && c.Env != "production" {
		return nil
	}
	if len(c.JWTSecret) < 32 {
		return fmt.Errorf("JWT_SECRET must contain at least 32 characters in staging and production")
	}
	if c.DBDSN == "" {
		return fmt.Errorf("DB_DSN must be set in staging and production")
	}
	if c.SeedDev {
		return fmt.Errorf("SEED_DEV must be disabled in staging and production")
	}
	if c.CORSAllowOrigin == "" || c.CORSAllowOrigin == "*" {
		return fmt.Errorf("CORS_ALLOW_ORIGIN must be an explicit origin in staging and production")
	}
	return nil
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

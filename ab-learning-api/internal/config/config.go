// Package config centralizes every environment-driven setting the API
// needs. main.go calls Load() once at startup; nothing else in the
// codebase calls os.Getenv directly, so every configurable value is
// discoverable by reading this one file.
package config

import (
	"bufio"
	"os"
	"strings"
	"time"
)

type Config struct {
	Port            string
	DBDSN           string
	JWTSecret       string
	AccessTokenTTL  time.Duration
	RefreshTokenTTL time.Duration
	AllowedOrigin   string
}

// Load reads `.env` (if present) then falls back to defaults. Real
// environment variables always win over the .env file, so this is safe to
// use in both local dev and a real deployment.
func Load() Config {
	loadDotEnv(".env")

	return Config{
		Port:  getEnv("PORT", "8080"),
		DBDSN: getEnv("DB_DSN", "ab_app:ab_app_pw@tcp(127.0.0.1:3307)/ab_learning?parseTime=true&charset=utf8mb4"), JWTSecret: getEnv("JWT_SECRET", "dev-secret-change-me"),
		AccessTokenTTL:  15 * time.Minute,
		RefreshTokenTTL: 30 * 24 * time.Hour,
		AllowedOrigin:   getEnv("ALLOWED_ORIGIN", "*"),
	}
}

func getEnv(key, fallback string) string {
	if v, ok := os.LookupEnv(key); ok && v != "" {
		return v
	}
	return fallback
}

// loadDotEnv is intentionally dependency-free: parses simple KEY=VALUE
// lines, skips blanks/#comments, and never overwrites a variable that's
// already set in the real environment.
func loadDotEnv(path string) {
	f, err := os.Open(path)
	if err != nil {
		return
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		parts := strings.SplitN(line, "=", 2)
		if len(parts) != 2 {
			continue
		}
		key := strings.TrimSpace(parts[0])
		value := strings.Trim(strings.TrimSpace(parts[1]), `"'`)
		if _, exists := os.LookupEnv(key); !exists {
			os.Setenv(key, value)
		}
	}
}

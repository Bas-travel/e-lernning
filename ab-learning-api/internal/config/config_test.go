package config

import "testing"

func TestValidateRequiresProductionSecretsAndOrigins(t *testing.T) {
	valid := Config{
		Env:                "production",
		DBDSN:              "app:secret@tcp(db:3306)/ablearning?parseTime=true",
		JWTSecret:          "01234567890123456789012345678901",
		CORSAllowOrigin:    "https://app.example.com",
		MaxVideoMB:         500,
		RateLimitRequests:  120,
		RateLimitWindowSec: 60,
	}
	if err := valid.Validate(); err != nil {
		t.Fatalf("valid production config rejected: %v", err)
	}

	tests := []struct {
		name   string
		update func(*Config)
	}{
		{"short JWT secret", func(c *Config) { c.JWTSecret = "short" }},
		{"missing database DSN", func(c *Config) { c.DBDSN = "" }},
		{"seed data enabled", func(c *Config) { c.SeedDev = true }},
		{"wildcard CORS", func(c *Config) { c.CORSAllowOrigin = "*" }},
		{"missing CORS origin", func(c *Config) { c.CORSAllowOrigin = "" }},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			config := valid
			test.update(&config)
			if err := config.Validate(); err == nil {
				t.Fatal("expected invalid production config to be rejected")
			}
		})
	}
}

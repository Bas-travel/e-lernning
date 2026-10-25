// Package jwtx wraps golang-jwt/jwt/v5 with just what this API needs:
// issue an access token carrying (user_id, role), and verify one back.
// Kept separate from internal/auth so any future service (not just HTTP
// handlers) can issue/verify tokens without importing the auth domain.
package jwtx

import (
	"errors"
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

type Manager struct {
	secret []byte
	ttl    time.Duration
}

func NewManager(secret string, ttl time.Duration) *Manager {
	return &Manager{secret: []byte(secret), ttl: ttl}
}

type claims struct {
	UserID int64  `json:"uid"`
	Role   string `json:"role"`
	jwt.RegisteredClaims
}

// Issue creates a signed access token for the given user.
func (m *Manager) Issue(userID int64, role string) (string, error) {
	now := time.Now()
	c := claims{
		UserID: userID,
		Role:   role,
		RegisteredClaims: jwt.RegisteredClaims{
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(now.Add(m.ttl)),
			Issuer:    "ab-learning-api",
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, c)
	return token.SignedString(m.secret)
}

// Verify parses and validates a token, returning the embedded user ID and
// role. Satisfies internal/platform.TokenVerifier.
func (m *Manager) Verify(tokenString string) (int64, string, error) {
	var c claims
	token, err := jwt.ParseWithClaims(tokenString, &c, func(t *jwt.Token) (interface{}, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", t.Header["alg"])
		}
		return m.secret, nil
	})
	if err != nil {
		return 0, "", err
	}
	if !token.Valid {
		return 0, "", errors.New("invalid token")
	}
	return c.UserID, c.Role, nil
}

package security

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"strings"
	"time"
)

type Claims struct {
	Sub  int64  `json:"sub"`
	Role string `json:"role"`
	Typ  string `json:"typ"` // access | refresh
	Iat  int64  `json:"iat"`
	Exp  int64  `json:"exp"`
}

var jwtHeader = base64.RawURLEncoding.EncodeToString([]byte(`{"alg":"HS256","typ":"JWT"}`))

func sign(secret []byte, data string) string {
	m := hmac.New(sha256.New, secret)
	m.Write([]byte(data))
	return base64.RawURLEncoding.EncodeToString(m.Sum(nil))
}

func IssueToken(secret string, userID int64, role, typ string, ttl time.Duration) (string, error) {
	now := time.Now()
	body, err := json.Marshal(Claims{Sub: userID, Role: role, Typ: typ, Iat: now.Unix(), Exp: now.Add(ttl).Unix()})
	if err != nil {
		return "", err
	}
	unsigned := jwtHeader + "." + base64.RawURLEncoding.EncodeToString(body)
	return unsigned + "." + sign([]byte(secret), unsigned), nil
}

// ParseToken verifies signature + expiry and that the token type matches.
func ParseToken(secret, token, wantTyp string) (Claims, error) {
	parts := strings.Split(token, ".")
	if len(parts) != 3 || parts[0] != jwtHeader {
		return Claims{}, ErrInvalidToken
	}
	unsigned := parts[0] + "." + parts[1]
	if !hmac.Equal([]byte(sign([]byte(secret), unsigned)), []byte(parts[2])) {
		return Claims{}, ErrInvalidToken
	}
	raw, err := base64.RawURLEncoding.DecodeString(parts[1])
	if err != nil {
		return Claims{}, ErrInvalidToken
	}
	var c Claims
	if err := json.Unmarshal(raw, &c); err != nil {
		return Claims{}, ErrInvalidToken
	}
	if c.Typ != wantTyp || time.Now().Unix() >= c.Exp {
		return Claims{}, ErrInvalidToken
	}
	return c, nil
}

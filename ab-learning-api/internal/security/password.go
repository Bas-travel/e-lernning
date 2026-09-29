// Package security contains password hashing and JWT helpers built on the
// standard library only (no external crypto deps). Phase 5 (Security &
// Compliance) should evaluate moving to argon2id/bcrypt.
package security

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/base64"
	"errors"
	"fmt"
	"strconv"
	"strings"
)

const pbkdf2Iterations = 210_000

func pbkdf2SHA256(password, salt []byte, iter, keyLen int) []byte {
	prf := hmac.New(sha256.New, password)
	hashLen := prf.Size()
	blocks := (keyLen + hashLen - 1) / hashLen
	var out []byte
	for b := 1; b <= blocks; b++ {
		prf.Reset()
		prf.Write(salt)
		prf.Write([]byte{byte(b >> 24), byte(b >> 16), byte(b >> 8), byte(b)})
		u := prf.Sum(nil)
		t := append([]byte(nil), u...)
		for i := 1; i < iter; i++ {
			prf.Reset()
			prf.Write(u)
			u = prf.Sum(nil)
			for j := range t {
				t[j] ^= u[j]
			}
		}
		out = append(out, t...)
	}
	return out[:keyLen]
}

// HashPassword returns "pbkdf2$sha256$<iter>$<salt>$<hash>".
func HashPassword(password string) (string, error) {
	salt := make([]byte, 16)
	if _, err := rand.Read(salt); err != nil {
		return "", err
	}
	h := pbkdf2SHA256([]byte(password), salt, pbkdf2Iterations, 32)
	return fmt.Sprintf("pbkdf2$sha256$%d$%s$%s", pbkdf2Iterations,
		base64.RawStdEncoding.EncodeToString(salt), base64.RawStdEncoding.EncodeToString(h)), nil
}

func VerifyPassword(password, encoded string) bool {
	p := strings.Split(encoded, "$")
	if len(p) != 5 || p[0] != "pbkdf2" || p[1] != "sha256" {
		return false
	}
	iter, err := strconv.Atoi(p[2])
	if err != nil || iter < 1 {
		return false
	}
	salt, err1 := base64.RawStdEncoding.DecodeString(p[3])
	want, err2 := base64.RawStdEncoding.DecodeString(p[4])
	if err1 != nil || err2 != nil {
		return false
	}
	got := pbkdf2SHA256([]byte(password), salt, iter, len(want))
	return subtle.ConstantTimeCompare(got, want) == 1
}

// RandomToken returns a URL-safe random string of n bytes of entropy.
func RandomToken(n int) (string, error) {
	b := make([]byte, n)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return base64.RawURLEncoding.EncodeToString(b), nil
}

var ErrInvalidToken = errors.New("invalid token")

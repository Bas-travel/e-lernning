package auth

import (
	"errors"
	"net/mail"
	"strings"
	"time"

	"github.com/ablearning/api/internal/security"
)

const (
	accessTTL  = time.Hour
	refreshTTL = 30 * 24 * time.Hour
)

var (
	ErrInvalidCredentials = errors.New("invalid email or password")
	ErrAccountInactive    = errors.New("account is suspended or deactivated")
	ErrValidation         = errors.New("validation failed")
)

type Service struct {
	repo   *Repository
	secret string
}

func NewService(repo *Repository, secret string) *Service {
	return &Service{repo: repo, secret: secret}
}

func (s *Service) tokens(u userRow) (AuthTokenResponse, error) {
	access, err := security.IssueToken(s.secret, u.ID, u.Role, "access", accessTTL)
	if err != nil {
		return AuthTokenResponse{}, err
	}
	refresh, err := security.IssueToken(s.secret, u.ID, u.Role, "refresh", refreshTTL)
	if err != nil {
		return AuthTokenResponse{}, err
	}
	return AuthTokenResponse{AccessToken: access, RefreshToken: refresh, User: toUserResponse(u.User)}, nil
}

func (s *Service) Login(req LoginRequest) (AuthTokenResponse, error) {
	identifier := strings.ToLower(strings.TrimSpace(req.Identifier))
	if identifier == "" || req.Password == "" {
		return AuthTokenResponse{}, ErrInvalidCredentials
	}
	u, err := s.repo.ByEmail(identifier)
	if err != nil {
		// Same error for unknown user and wrong password (no user enumeration).
		return AuthTokenResponse{}, ErrInvalidCredentials
	}
	if !security.VerifyPassword(req.Password, u.PasswordHash) {
		return AuthTokenResponse{}, ErrInvalidCredentials
	}
	if u.Status != "active" {
		return AuthTokenResponse{}, ErrAccountInactive
	}
	s.repo.TouchLogin(u.ID)
	return s.tokens(u)
}

func (s *Service) Register(req RegisterRequest) (User, error) {
	req.Email = strings.ToLower(strings.TrimSpace(req.Email))
	req.FirstName = strings.TrimSpace(req.FirstName)
	req.LastName = strings.TrimSpace(req.LastName)
	if _, err := mail.ParseAddress(req.Email); err != nil {
		return User{}, errors.Join(ErrValidation, errors.New("a valid email is required"))
	}
	if req.FirstName == "" || req.LastName == "" {
		return User{}, errors.Join(ErrValidation, errors.New("first_name and last_name are required"))
	}
	if len(req.Password) < 8 {
		return User{}, errors.Join(ErrValidation, errors.New("password must be at least 8 characters"))
	}
	hash, err := security.HashPassword(req.Password)
	if err != nil {
		return User{}, err
	}
	id, err := s.repo.CreateLearner(req, hash)
	if err != nil {
		return User{}, err
	}
	u, err := s.repo.ByID(id)
	return u.User, err
}

func (s *Service) Me(id int64) (User, error) {
	u, err := s.repo.ByID(id)
	return u.User, err
}

// Refresh exchanges a valid refresh token for a fresh token pair.
// NOTE: tokens are stateless (no rotation/revocation yet) — Phase 5 item.
func (s *Service) Refresh(refreshToken string) (AuthTokenResponse, error) {
	claims, err := security.ParseToken(s.secret, refreshToken, "refresh")
	if err != nil {
		return AuthTokenResponse{}, ErrInvalidCredentials
	}
	u, err := s.repo.ByID(claims.Sub)
	if err != nil || u.Status != "active" {
		return AuthTokenResponse{}, ErrInvalidCredentials
	}
	return s.tokens(u)
}

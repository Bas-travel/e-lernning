package auth

import (
	"context"
	"errors"
	"strings"

	"github.com/ablearning/ab-learning-api/internal/platform"
	"github.com/ablearning/ab-learning-api/pkg/jwtx"
	"golang.org/x/crypto/bcrypt"
)

type Service struct {
	repo *Repository
	jwt  *jwtx.Manager
}

func NewService(repo *Repository, jwt *jwtx.Manager) *Service {
	return &Service{repo: repo, jwt: jwt}
}

// Login implements screen 03. Accepts either email or phone as the
// identifier, per the mockup's single "Email or phone" field.
func (s *Service) Login(ctx context.Context, req LoginRequest) (AuthTokenResponse, error) {
	identifier := strings.TrimSpace(req.Identifier)
	if identifier == "" || req.Password == "" {
		return AuthTokenResponse{}, platform.ErrValidation("identifier and password are required")
	}

	user, err := s.repo.FindByIdentifier(ctx, identifier)
	if errors.Is(err, ErrUserNotFound) {
		return AuthTokenResponse{}, platform.ErrInvalidCreds
	}
	if err != nil {
		return AuthTokenResponse{}, err
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
		return AuthTokenResponse{}, platform.ErrInvalidCreds
	}

	access, err := s.jwt.Issue(user.ID, user.RoleCode)
	if err != nil {
		return AuthTokenResponse{}, err
	}
	// Refresh tokens would normally be a separate, longer-lived, rotatable
	// token persisted server-side. Kept as a second signed JWT here to
	// keep the scaffold's dependency surface small — swap for a real
	// refresh-token table before shipping to production.
	refresh, err := s.jwt.Issue(user.ID, user.RoleCode)
	if err != nil {
		return AuthTokenResponse{}, err
	}

	_ = s.repo.UpdateLastLogin(ctx, user.ID) // best-effort, don't fail login over it

	return AuthTokenResponse{
		AccessToken:  access,
		RefreshToken: refresh,
		User:         toUserResponse(user),
	}, nil
}

// Register implements screen 04.
func (s *Service) Register(ctx context.Context, req RegisterRequest) (UserResponse, error) {
	req.Email = strings.TrimSpace(strings.ToLower(req.Email))
	req.FirstName = strings.TrimSpace(req.FirstName)
	req.LastName = strings.TrimSpace(req.LastName)

	if req.Email == "" || req.Password == "" || req.FirstName == "" {
		return UserResponse{}, platform.ErrValidation("first_name, email and password are required")
	}
	if len(req.Password) < 8 {
		return UserResponse{}, platform.ErrValidation("password must be at least 8 characters")
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return UserResponse{}, err
	}

	userID, err := s.repo.Create(ctx, req, string(hash))
	if errors.Is(err, ErrEmailTaken) {
		return UserResponse{}, platform.ErrConflict("An account with this email already exists.")
	}
	if err != nil {
		return UserResponse{}, err
	}

	user, err := s.repo.FindByID(ctx, userID)
	if err != nil {
		return UserResponse{}, err
	}
	return toUserResponse(user), nil
}

// Me implements GET /me — reads the user ID that platform.RequireAuth
// already verified and attached to the request context.
func (s *Service) Me(ctx context.Context, userID int64) (UserResponse, error) {
	user, err := s.repo.FindByID(ctx, userID)
	if errors.Is(err, ErrUserNotFound) {
		return UserResponse{}, platform.ErrUnauthorized
	}
	if err != nil {
		return UserResponse{}, err
	}
	return toUserResponse(user), nil
}

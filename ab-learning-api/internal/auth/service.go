package auth

import (
	"errors"
	"fmt"
	"net/mail"
	"strings"
)

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func validateCredentials(email, password string) error {
	email = strings.TrimSpace(email)
	password = strings.TrimSpace(password)

	if email == "" || password == "" {
		return errors.New("email and password are required")
	}

	if _, err := mail.ParseAddress(email); err != nil {
		return errors.New("email must be valid")
	}

	if len(password) < 8 {
		return errors.New("password must be at least 8 characters")
	}

	return nil
}

func (s *Service) Login(req LoginRequest) (LoginResponse, error) {
	if err := validateCredentials(req.Email, req.Password); err != nil {
		return LoginResponse{}, err
	}

	return LoginResponse{Token: "stub-access-token", Email: strings.TrimSpace(req.Email)}, nil
}

func (s *Service) Register(req RegisterRequest) (LoginResponse, error) {
	name := strings.TrimSpace(req.Name)
	email := strings.TrimSpace(req.Email)
	password := strings.TrimSpace(req.Password)

	if name == "" {
		return LoginResponse{}, errors.New("name is required")
	}

	if err := validateCredentials(email, password); err != nil {
		return LoginResponse{}, err
	}

	if len(name) < 2 {
		return LoginResponse{}, errors.New("name must be at least 2 characters")
	}

	if s.repo == nil {
		return LoginResponse{}, fmt.Errorf("repository unavailable")
	}

	return LoginResponse{Token: "stub-access-token", Email: email, UserID: "user_stub_001"}, nil
}

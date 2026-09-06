package auth

import "errors"

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) Login(req LoginRequest) (LoginResponse, error) {
	if req.Email == "" || req.Password == "" {
		return LoginResponse{}, errors.New("email and password are required")
	}

	// Prototype stub: accept any valid email/password pair
	_ = s.repo
	return LoginResponse{Token: "stub-access-token"}, nil
}

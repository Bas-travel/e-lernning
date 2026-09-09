package courses

import (
	"context"
	"errors"

	"github.com/ablearning/ab-learning-api/internal/platform"
)

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) List(ctx context.Context, params ListParams) ([]Course, error) {
	return s.repo.List(ctx, params)
}

func (s *Service) Search(ctx context.Context, q string) ([]Course, error) {
	if q == "" {
		return nil, platform.ErrValidation("query parameter 'q' is required")
	}
	return s.repo.Search(ctx, q, 20)
}

func (s *Service) Get(ctx context.Context, id int64) (Course, error) {
	c, err := s.repo.FindByID(ctx, id)
	if errors.Is(err, ErrNotFound) {
		return Course{}, platform.ErrNotFound("Course could not be found.")
	}
	return c, err
}

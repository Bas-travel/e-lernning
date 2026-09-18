package instructor

import (
	"context"

	"github.com/ablearning/ab-learning-api/internal/platform"
)

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) Dashboard(ctx context.Context, userID int64) (Dashboard, error) {
	d, err := s.repo.DashboardByUserID(ctx, userID)
	if err != nil {
		return Dashboard{}, platform.ErrInternal
	}
	return d, nil
}

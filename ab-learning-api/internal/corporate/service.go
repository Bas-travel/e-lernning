package corporate

import (
	"context"
	"database/sql"
	"errors"

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
		if errors.Is(err, sql.ErrNoRows) {
			return Dashboard{}, platform.ErrNotFound("This account isn't linked to any organization yet.")
		}
		return Dashboard{}, platform.ErrInternal
	}
	return d, nil
}

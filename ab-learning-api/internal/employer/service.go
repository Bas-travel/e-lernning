package employer

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
			return Dashboard{}, platform.ErrNotFound("This account isn't linked to an employer profile yet.")
		}
		return Dashboard{}, platform.ErrInternal
	}
	return d, nil
}

func (s *Service) TopApplicants(ctx context.Context, userID int64) ([]TopApplicant, error) {
	list, err := s.repo.TopApplicants(ctx, userID, 5)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return []TopApplicant{}, nil
		}
		return nil, platform.ErrInternal
	}
	if list == nil {
		list = []TopApplicant{}
	}
	return list, nil
}

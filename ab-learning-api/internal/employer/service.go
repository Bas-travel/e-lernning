package employer

import (
	"context"
	"database/sql"
	"errors"
	"strings"

	"github.com/ablearning/api/internal/platform"
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

func (s *Service) Jobs(ctx context.Context, userID int64) ([]Job, error) {
	items, err := s.repo.JobsByUserID(ctx, userID)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, platform.ErrNotFound("This account isn't linked to an employer profile yet.")
	}
	if err != nil {
		return nil, platform.ErrInternal
	}
	return items, nil
}

func (s *Service) CreateJob(ctx context.Context, userID int64, in CreateJobInput) (Job, error) {
	in.Title = strings.TrimSpace(in.Title)
	in.Description = strings.TrimSpace(in.Description)
	in.Location = strings.TrimSpace(in.Location)
	if len([]rune(in.Title)) < 3 || len([]rune(in.Title)) > 200 {
		return Job{}, platform.ErrValidation("title must be 3-200 characters")
	}
	if len(in.Description) > 20000 || len(in.Location) > 150 {
		return Job{}, platform.ErrValidation("job details are too long")
	}
	job, err := s.repo.CreateJob(ctx, userID, in)
	if errors.Is(err, sql.ErrNoRows) {
		return Job{}, platform.ErrNotFound("This account isn't linked to an employer profile yet.")
	}
	if err != nil {
		return Job{}, platform.ErrInternal
	}
	return job, nil
}

func (s *Service) Applications(ctx context.Context, userID int64) ([]Application, error) {
	items, err := s.repo.ApplicationsByUserID(ctx, userID)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, platform.ErrNotFound("This account isn't linked to an employer profile yet.")
	}
	if err != nil {
		return nil, platform.ErrInternal
	}
	return items, nil
}

func (s *Service) UpdateApplication(ctx context.Context, userID, applicationID int64, status string) error {
	switch status {
	case "reviewed", "shortlisted", "rejected", "hired":
	default:
		return platform.ErrValidation("status must be reviewed, shortlisted, rejected or hired")
	}
	if err := s.repo.UpdateApplicationStatus(ctx, userID, applicationID, status); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return platform.ErrNotFound("application not found")
		}
		return platform.ErrInternal
	}
	return nil
}

package admin

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

func (s *Service) Dashboard(ctx context.Context) (Dashboard, error) {
	d, err := s.repo.Dashboard(ctx)
	if err != nil {
		return Dashboard{}, platform.ErrInternal
	}
	return d, nil
}

func (s *Service) PendingCourses(ctx context.Context) ([]PendingCourse, error) {
	list, err := s.repo.PendingCourses(ctx, 20)
	if err != nil {
		return nil, platform.ErrInternal
	}
	if list == nil {
		list = []PendingCourse{}
	}
	return list, nil
}

func (s *Service) ApproveCourse(ctx context.Context, courseID int64) error {
	if err := s.repo.ApproveCourse(ctx, courseID); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return platform.ErrNotFound("No pending course with that ID.")
		}
		return platform.ErrInternal
	}
	return nil
}

func (s *Service) RejectCourse(ctx context.Context, courseID int64, reason string) error {
	if reason == "" {
		return platform.ErrValidation("A rejection reason is required.")
	}
	if err := s.repo.RejectCourse(ctx, courseID, reason); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return platform.ErrNotFound("No pending course with that ID.")
		}
		return platform.ErrInternal
	}
	return nil
}

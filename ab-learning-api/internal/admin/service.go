package admin

import (
	"errors"
	"fmt"
	"strings"
)

var (
	ErrValidation = errors.New("validation failed")
	ErrSelf       = errors.New("you cannot perform this action on your own account")
)

type Service struct{ repo *Repository }

func NewService(repo *Repository) *Service { return &Service{repo: repo} }

func invalid(msg string) error { return fmt.Errorf("%w: %s", ErrValidation, msg) }

func (s *Service) Dashboard() (Dashboard, error) { return s.repo.Dashboard() }

func (s *Service) Moderation(status string) ([]ModerationCourse, error) {
	if status == "" {
		status = "pending_review"
	}
	switch status {
	case "pending_review", "published", "rejected", "reported":
	default:
		return nil, invalid("status must be pending_review, published, rejected or reported")
	}
	return s.repo.ModerationList(status)
}

func (s *Service) Approve(courseID, adminID int64) error {
	return s.repo.Moderate(courseID, adminID, true, "")
}

func (s *Service) Reject(courseID, adminID int64, reason string) error {
	reason = strings.TrimSpace(reason)
	if l := len([]rune(reason)); l < 3 || l > 500 {
		return invalid("a rejection reason of 3-500 characters is required")
	}
	return s.repo.Moderate(courseID, adminID, false, reason)
}

func (s *Service) ListUsers(f UserFilter) ([]User, error) {
	f.Query = strings.TrimSpace(f.Query)
	if f.Status != "" && f.Status != "active" && f.Status != "suspended" && f.Status != "deactivated" {
		return nil, invalid("status must be active, suspended or deactivated")
	}
	return s.repo.ListUsers(f)
}

func (s *Service) GetUser(id int64) (UserDetail, error) { return s.repo.GetUser(id) }

func (s *Service) UpdateUser(id, adminID int64, in UserUpdate) (UserDetail, error) {
	if in.Role == nil && in.Status == nil {
		return UserDetail{}, invalid("provide role and/or status")
	}
	if id == adminID {
		return UserDetail{}, ErrSelf
	}
	if in.Status != nil && *in.Status != "active" && *in.Status != "suspended" && *in.Status != "deactivated" {
		return UserDetail{}, invalid("status must be active, suspended or deactivated")
	}
	if in.Role != nil {
		ok, err := s.repo.RoleExists(*in.Role)
		if err != nil {
			return UserDetail{}, err
		}
		if !ok {
			return UserDetail{}, invalid("unknown role")
		}
	}
	if err := s.repo.UpdateUser(id, adminID, in); err != nil {
		return UserDetail{}, err
	}
	return s.repo.GetUser(id)
}

func (s *Service) Suspend(id, adminID int64, reason string) (UserDetail, error) {
	if id == adminID {
		return UserDetail{}, ErrSelf
	}
	if err := s.repo.Suspend(id, adminID, strings.TrimSpace(reason)); err != nil {
		return UserDetail{}, err
	}
	return s.repo.GetUser(id)
}

func (s *Service) ListPayments(status string) ([]Payment, error) {
	if status != "" && status != "pending" && status != "success" && status != "failed" {
		return nil, invalid("status must be pending, success or failed")
	}
	return s.repo.ListPayments(status)
}

func (s *Service) Refund(paymentID, adminID int64, req RefundRequest) (RefundResult, error) {
	req.Reason = strings.TrimSpace(req.Reason)
	if len([]rune(req.Reason)) < 3 {
		return RefundResult{}, invalid("a refund reason is required")
	}
	if req.Amount != nil && *req.Amount <= 0 {
		return RefundResult{}, invalid("amount must be positive")
	}
	return s.repo.Refund(paymentID, adminID, req)
}

package corporate

import (
	"context"
	"errors"
	"net/mail"
	"strings"
	"time"
)

// ValidationError is returned for bad client input (mapped to HTTP 422).
type ValidationError struct{ Msg string }

func (e ValidationError) Error() string { return "validation failed: " + e.Msg }

type Service struct{ repo *Repository }

func NewService(repo *Repository) *Service { return &Service{repo: repo} }

func (s *Service) org(ctx context.Context, userID int64) (int64, error) {
	return s.repo.OrgForUser(ctx, userID)
}

func (s *Service) Dashboard(ctx context.Context, userID int64) (Dashboard, error) {
	org, err := s.org(ctx, userID)
	if err != nil {
		return Dashboard{}, err
	}
	return s.repo.Dashboard(ctx, org)
}

func (s *Service) Employees(ctx context.Context, userID int64, f EmployeeFilter) ([]Employee, error) {
	org, err := s.org(ctx, userID)
	if err != nil {
		return nil, err
	}
	if f.Status != "" && f.Status != "active" && f.Status != "inactive" {
		return nil, ValidationError{"status must be active or inactive"}
	}
	return s.repo.ListEmployees(ctx, org, f)
}

func (s *Service) AddEmployee(ctx context.Context, userID int64, in AddEmployeeInput) (Employee, error) {
	org, err := s.org(ctx, userID)
	if err != nil {
		return Employee{}, err
	}
	in.Email = strings.ToLower(strings.TrimSpace(in.Email))
	if _, err := mail.ParseAddress(in.Email); err != nil {
		return Employee{}, ValidationError{"a valid email is required"}
	}
	if in.RoleInOrg == "" {
		in.RoleInOrg = "employee"
	}
	// 'admin' is reserved for the organization owner and cannot be granted here.
	if in.RoleInOrg != "employee" && in.RoleInOrg != "manager" {
		return Employee{}, ValidationError{"role_in_org must be employee or manager"}
	}
	in.Department = strings.TrimSpace(in.Department)
	if len(in.Department) > 150 {
		return Employee{}, ValidationError{"department is too long"}
	}
	return s.repo.AddEmployee(ctx, org, in)
}

func (s *Service) UpdateEmployee(ctx context.Context, userID, id int64, in UpdateEmployeeInput) error {
	org, err := s.org(ctx, userID)
	if err != nil {
		return err
	}
	if in.Status != nil && *in.Status != "active" && *in.Status != "inactive" {
		return ValidationError{"status must be active or inactive"}
	}
	if in.Department != nil && len(*in.Department) > 150 {
		return ValidationError{"department is too long"}
	}
	return s.repo.UpdateEmployee(ctx, org, id, in)
}

func (s *Service) Paths(ctx context.Context, userID int64) ([]LearningPath, error) {
	org, err := s.org(ctx, userID)
	if err != nil {
		return nil, err
	}
	return s.repo.ListPaths(ctx, org)
}

func (s *Service) CreatePath(ctx context.Context, userID int64, in CreatePathInput) (int64, error) {
	org, err := s.org(ctx, userID)
	if err != nil {
		return 0, err
	}
	in.Name = strings.TrimSpace(in.Name)
	if in.Name == "" || len(in.Name) > 200 {
		return 0, ValidationError{"name is required (max 200 chars)"}
	}
	if len(in.Goal) > 300 {
		return 0, ValidationError{"goal is too long (max 300 chars)"}
	}
	if in.Deadline != nil {
		if _, err := time.Parse("2006-01-02", *in.Deadline); err != nil {
			return 0, ValidationError{"deadline must be YYYY-MM-DD"}
		}
	}
	if len(in.CourseIDs) == 0 {
		return 0, ValidationError{"at least one course is required"}
	}
	seen := map[int64]bool{}
	for _, id := range in.CourseIDs {
		if seen[id] {
			return 0, ValidationError{"duplicate course_ids"}
		}
		seen[id] = true
	}
	return s.repo.CreatePath(ctx, org, in)
}

func IsValidation(err error) bool { var v ValidationError; return errors.As(err, &v) }

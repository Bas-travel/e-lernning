package learning

import (
	"errors"
	"fmt"
)

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) Enroll(courseID string) (Enrollment, error) {
	if courseID == "" {
		return Enrollment{}, errors.New("course id is required")
	}

	if _, exists := s.repo.GetEnrollment(courseID); exists {
		return Enrollment{}, fmt.Errorf("course %s already enrolled", courseID)
	}

	e := Enrollment{
		ID:       fmt.Sprintf("enr-%s", courseID),
		CourseID: courseID,
		UserID:   "user-demo",
		Progress: 0,
		Status:   "active",
	}
	
	s.repo.SaveEnrollment(e)
	return e, nil
}

func (s *Service) UpdateProgress(courseID string, value float64) (Enrollment, error) {
	if courseID == "" {
		return Enrollment{}, errors.New("course id is required")
	}

	if value < 0 || value > 100 {
		return Enrollment{}, errors.New("progress must be between 0 and 100")
	}

	e, exists := s.repo.GetEnrollment(courseID)
	if !exists {
		return Enrollment{}, fmt.Errorf("enrollment for %s not found", courseID)
	}

	e.Progress = value
	e.Completed = value >= 100
	e.Status = "completed"
	if !e.Completed {
		e.Status = "active"
	}

	s.repo.SaveEnrollment(e)
	return e, nil
}

func (s *Service) GetMyCourses() []Enrollment {
	return s.repo.ListEnrollments()
}

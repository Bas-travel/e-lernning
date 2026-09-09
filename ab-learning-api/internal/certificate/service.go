package certificate

import (
	"errors"
	"fmt"
	"time"
)

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) Issue(courseID string, courseName string) (Certificate, error) {
	if courseID == "" || courseName == "" {
		return Certificate{}, errors.New("course id and name are required")
	}

	issuedAt := time.Now().Format(time.RFC3339)
	cert := Certificate{
		ID:         fmt.Sprintf("cert-%s", courseID),
		CourseID:   courseID,
		UserID:     "user-demo",
		CourseName: courseName,
		IssuedAt:   issuedAt,
		Status:     "issued",
	}

	s.repo.Save(cert)
	return cert, nil
}

func (s *Service) Get(id string) (Certificate, error) {
	if id == "" {
		return Certificate{}, errors.New("certificate id is required")
	}

	cert, ok := s.repo.Get(id)
	if !ok {
		return Certificate{}, fmt.Errorf("certificate %s not found", id)
	}
	return cert, nil
}

func (s *Service) List() []Certificate {
	return s.repo.List()
}

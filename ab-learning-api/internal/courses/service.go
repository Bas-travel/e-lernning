package courses

import "fmt"

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) List() []Course {
	return []Course{
		{ID: "c001", Title: "Go Backend Professional"},
		{ID: "c002", Title: "Flutter Professional"},
	}
}

func (s *Service) GetByID(id string) (Course, error) {
	if id == "" {
		return Course{}, fmt.Errorf("missing id")
	}
	return Course{ID: id, Title: "Course " + id}, nil
}

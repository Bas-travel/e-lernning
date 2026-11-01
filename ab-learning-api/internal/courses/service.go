package courses

import "strings"

type Service struct{ repo *Repository }

func NewService(repo *Repository) *Service { return &Service{repo: repo} }

func (s *Service) List(f ListFilter) ([]Course, error) {
	f.Query = strings.TrimSpace(f.Query)
	return s.repo.List(f)
}

func (s *Service) Get(id int64) (Course, error) { return s.repo.Get(id) }

// Curriculum only exposes published courses to the public.
func (s *Service) Curriculum(id int64) ([]Section, error) {
	if _, err := s.repo.Get(id); err != nil {
		return nil, err
	}
	return s.repo.Curriculum(id)
}

func (s *Service) Categories() ([]Category, error) { return s.repo.Categories() }

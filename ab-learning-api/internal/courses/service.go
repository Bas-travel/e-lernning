package courses

import (
	"fmt"
	"strings"
)

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) List() []Course {
	return []Course{
		{
			ID:               "c001",
			Title:            "Go Backend Professional",
			Category:         "Backend",
			Level:            "Intermediate",
			Instructor:       "Nattapong",
			Duration:         "6 weeks",
			Price:            1490,
			Rating:           4.9,
			ShortDescription: "Build production-ready APIs and service patterns.",
			Description:      "Learn the Go backend stack, HTTP routes, layered architecture, and deployment-ready service design.",
			Lessons: []Lesson{
				{ID: "l1", Title: "REST Foundations", Duration: "18 min"},
				{ID: "l2", Title: "Layered Architecture", Duration: "24 min"},
				{ID: "l3", Title: "Middleware and Validation", Duration: "27 min"},
			},
		},
		{
			ID:               "c002",
			Title:            "Flutter Professional",
			Category:         "Mobile",
			Level:            "Intermediate",
			Instructor:       "Kanya",
			Duration:         "5 weeks",
			Price:            1390,
			Rating:           4.8,
			ShortDescription: "Create polished mobile experiences with Flutter and routing.",
			Description:      "Design interactive interfaces, manage state, and ship a production-ready app shell with clean architecture.",
			Lessons: []Lesson{
				{ID: "l1", Title: "App Architecture", Duration: "20 min"},
				{ID: "l2", Title: "Navigation and Routes", Duration: "16 min"},
				{ID: "l3", Title: "State and UI Patterns", Duration: "28 min"},
			},
		},
	}
}

func (s *Service) Filter(category, search string) []Course {
	category = strings.TrimSpace(strings.ToLower(category))
	search = strings.TrimSpace(strings.ToLower(search))

	items := s.List()
	filtered := make([]Course, 0, len(items))
	for _, item := range items {
		matchCategory := category == "" || strings.EqualFold(item.Category, category)
		matchSearch := search == "" || strings.Contains(strings.ToLower(item.Title), search) || strings.Contains(strings.ToLower(item.ShortDescription), search)
		if matchCategory && matchSearch {
			filtered = append(filtered, item)
		}
	}
	return filtered
}

func (s *Service) GetByID(id string) (Course, error) {
	if id == "" {
		return Course{}, fmt.Errorf("missing id")
	}

	for _, course := range s.List() {
		if strings.EqualFold(course.ID, id) {
			return course, nil
		}
	}

	return Course{}, fmt.Errorf("course not found")
}

package learning

type Repository struct {
	enrollments map[string]Enrollment
}

func NewRepository() *Repository {
	return &Repository{enrollments: map[string]Enrollment{}}
}

func (r *Repository) SaveEnrollment(e Enrollment) {
	r.enrollments[e.CourseID] = e
}

func (r *Repository) GetEnrollment(courseID string) (Enrollment, bool) {
	e, ok := r.enrollments[courseID]
	return e, ok
}

func (r *Repository) ListEnrollments() []Enrollment {
	items := make([]Enrollment, 0, len(r.enrollments))
	for _, e := range r.enrollments {
		items = append(items, e)
	}
	return items
}

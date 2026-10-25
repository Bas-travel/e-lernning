package certificate

type Repository struct {
	certificates map[string]Certificate
}

func NewRepository() *Repository {
	return &Repository{certificates: map[string]Certificate{}}
}

func (r *Repository) Save(c Certificate) {
	r.certificates[c.ID] = c
}

func (r *Repository) Get(id string) (Certificate, bool) {
	c, ok := r.certificates[id]
	return c, ok
}

func (r *Repository) List() []Certificate {
	items := make([]Certificate, 0, len(r.certificates))
	for _, c := range r.certificates {
		items = append(items, c)
	}
	return items
}

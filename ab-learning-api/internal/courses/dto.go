package courses

// Course matches the `Course` schema in 05-openapi.yaml.
type Course struct {
	ID             int64    `json:"id"`
	Title          string   `json:"title"`
	Slug           string   `json:"slug"`
	Description    string   `json:"description"`
	ThumbnailURL   *string  `json:"thumbnail_url"`
	Price          float64  `json:"price"`
	DiscountPrice  *float64 `json:"discount_price"`
	RatingAvg      float64  `json:"rating_avg"`
	StudentCount   int      `json:"student_count"`
	Level          string   `json:"level"`
	Status         string   `json:"status"`
	InstructorName string   `json:"instructor_name"`
	CategoryName   string   `json:"category_name"`
}

type ListParams struct {
	Category string
	Level    string
	Page     int
	Limit    int
}

package courses

// Course maps to the `courses` table (see db/schema, 04-schema.sql) joined
// with its instructor and category for display purposes.
type Course struct {
	ID          int64  `json:"id"`
	Title       string `json:"title"`
	Slug        string `json:"slug"`
	Description string `json:"description"`
	// ThumbnailURL   string   `json:"thumbnailUrl"`
	ThumbnailURL   *string  `json:"thumbnailUrl,omitempty"`
	Price          float64  `json:"price"`
	DiscountPrice  *float64 `json:"discountPrice,omitempty"`
	RatingAvg      float64  `json:"ratingAvg"`
	StudentCount   int      `json:"studentCount"`
	Level          string   `json:"level"`
	Status         string   `json:"status"`
	InstructorName string   `json:"instructorName"`
	CategoryName   string   `json:"categoryName"`
}

// ListParams filters GET /api/v1/courses (screen 09 — Explore).
type ListParams struct {
	Category string
	Level    string
	Page     int
	Limit    int
}

// Lesson represents a single video/content unit inside a course curriculum.
type Lesson struct {
	ID       string `json:"id"`
	Title    string `json:"title"`
	Duration string `json:"duration"`
}

// Package courses serves the public (published-only) course catalog.
package courses

type InstructorRef struct {
	ID          int64  `json:"id"`
	DisplayName string `json:"display_name"`
}

// Course mirrors the `Course` schema in 05-openapi.yaml.
type Course struct {
	ID            int64         `json:"id"`
	Title         string        `json:"title"`
	Slug          string        `json:"slug"`
	Description   string        `json:"description"`
	ThumbnailURL  string        `json:"thumbnail_url"`
	Price         float64       `json:"price"`
	DiscountPrice *float64      `json:"discount_price"`
	RatingAvg     float64       `json:"rating_avg"`
	StudentCount  int           `json:"student_count"`
	Level         string        `json:"level"`
	Status        string        `json:"status"`
	Category      string        `json:"category"`
	Instructor    InstructorRef `json:"instructor"`
}

type Lesson struct {
	ID              int64  `json:"id"`
	Title           string `json:"title"`
	Type            string `json:"type"`
	DurationSeconds int    `json:"duration_seconds"`
	VideoURL        string `json:"video_url"`
	IsPreview       bool   `json:"is_preview"`
}

type Section struct {
	ID      int64    `json:"id"`
	Title   string   `json:"title"`
	Lessons []Lesson `json:"lessons"`
}

type ListFilter struct {
	Category string
	Level    string
	Query    string
	Limit    int
	Offset   int
}

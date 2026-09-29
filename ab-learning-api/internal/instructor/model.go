// Package instructor implements the Instructor domain: dashboard, course
// builder (courses/sections/lessons), media upload and revenue.
package instructor

import "time"

type CourseInput struct {
	Title         string   `json:"title"`
	Description   string   `json:"description"`
	CategoryID    int64    `json:"category_id"`
	Level         string   `json:"level"`
	Language      string   `json:"language"`
	ThumbnailURL  string   `json:"thumbnail_url"`
	Price         float64  `json:"price"`
	DiscountPrice *float64 `json:"discount_price"`
}

type Lesson struct {
	ID              int64  `json:"id"`
	SectionID       int64  `json:"section_id"`
	Title           string `json:"title"`
	Type            string `json:"type"`
	VideoURL        string `json:"video_url"`
	DurationSeconds int    `json:"duration_seconds"`
	IsPreview       bool   `json:"is_preview"`
	SortOrder       int    `json:"sort_order"`
}

type Section struct {
	ID        int64    `json:"id"`
	CourseID  int64    `json:"course_id"`
	Title     string   `json:"title"`
	SortOrder int      `json:"sort_order"`
	Lessons   []Lesson `json:"lessons"`
}

type Course struct {
	ID             int64     `json:"id"`
	Title          string    `json:"title"`
	Slug           string    `json:"slug"`
	Description    string    `json:"description"`
	ThumbnailURL   string    `json:"thumbnail_url"`
	Price          float64   `json:"price"`
	DiscountPrice  *float64  `json:"discount_price"`
	Level          string    `json:"level"`
	Language       string    `json:"language"`
	Status         string    `json:"status"`
	RejectedReason string    `json:"rejected_reason"`
	CategoryID     int64     `json:"category_id"`
	Category       string    `json:"category"`
	StudentCount   int       `json:"student_count"`
	RatingAvg      float64   `json:"rating_avg"`
	LessonCount    int       `json:"lesson_count"`
	DurationMin    int       `json:"duration_minutes"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
	Sections       []Section `json:"sections,omitempty"`
}

type SectionInput struct {
	CourseID  int64  `json:"course_id"`
	Title     string `json:"title"`
	SortOrder int    `json:"sort_order"`
}

type LessonInput struct {
	SectionID       int64  `json:"section_id"`
	Title           string `json:"title"`
	Type            string `json:"type"`
	VideoURL        string `json:"video_url"`
	DurationSeconds int    `json:"duration_seconds"`
	IsPreview       bool   `json:"is_preview"`
	SortOrder       int    `json:"sort_order"`
}

type TopCourse struct {
	ID           int64   `json:"id"`
	Title        string  `json:"title"`
	StudentCount int     `json:"student_count"`
	RatingAvg    float64 `json:"rating_avg"`
}

type Dashboard struct {
	RevenueTotal     float64     `json:"revenue_total"`
	StudentsTotal    int         `json:"students_total"`
	CoursesTotal     int         `json:"courses_total"`
	CoursesPublished int         `json:"courses_published"`
	RatingAvg        float64     `json:"rating_avg"`
	CompletionAvgPct float64     `json:"completion_avg_pct"`
	TopCourses       []TopCourse `json:"top_courses"`
}

type Payout struct {
	ID          int64      `json:"id"`
	PeriodStart string     `json:"period_start"`
	PeriodEnd   string     `json:"period_end"`
	Gross       float64    `json:"gross_amount"`
	PlatformFee float64    `json:"platform_fee"`
	Net         float64    `json:"net_amount"`
	Status      string     `json:"status"`
	PaidAt      *time.Time `json:"paid_at"`
}

type Revenue struct {
	Gross       float64  `json:"gross"`
	PlatformFee float64  `json:"platform_fee"`
	Net         float64  `json:"net"`
	Pending     float64  `json:"pending"`
	PaidOut     float64  `json:"paid_out"`
	Payouts     []Payout `json:"payouts"`
}

type UploadResult struct {
	URL          string `json:"url"`
	SizeBytes    int64  `json:"size_bytes"`
	ContentType  string `json:"content_type"`
	OriginalName string `json:"original_name"`
}

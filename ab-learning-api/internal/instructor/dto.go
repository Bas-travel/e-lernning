package instructor

// Dashboard mirrors screen 31's KPI cards — real aggregates over this
// instructor's own courses, not mock numbers.
type Dashboard struct {
	CourseCount   int     `json:"course_count"`
	TotalStudents int     `json:"total_students"`
	AvgRating     float64 `json:"avg_rating"`
}

package admin

// Dashboard mirrors screen 40's platform-wide KPI cards.
type Dashboard struct {
	TotalUsers        int     `json:"total_users"`
	TotalInstructors  int     `json:"total_instructors"`
	TotalCourses      int     `json:"total_courses"`
	TotalRevenue      float64 `json:"total_revenue"`
	PendingModeration int     `json:"pending_moderation"`
}

// PendingCourse is one row in screen 41's Course Moderation queue.
type PendingCourse struct {
	ID             int64  `json:"id"`
	Title          string `json:"title"`
	InstructorName string `json:"instructor_name"`
	Category       string `json:"category"`
	SubmittedAt    string `json:"submitted_at"`
}

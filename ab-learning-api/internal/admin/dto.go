package admin

// PendingCourse is one row in screen 41's Course Moderation queue.
type PendingCourse struct {
	ID             int64  `json:"id"`
	Title          string `json:"title"`
	InstructorName string `json:"instructor_name"`
	Category       string `json:"category"`
	SubmittedAt    string `json:"submitted_at"`
}

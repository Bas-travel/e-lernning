package certificate

type Certificate struct {
	ID         string `json:"id"`
	CourseID   string `json:"courseId"`
	UserID     string `json:"userId"`
	CourseName string `json:"courseName"`
	IssuedAt   string `json:"issuedAt"`
	Status     string `json:"status"`
}

package learning

type Enrollment struct {
	ID        string  `json:"id"`
	CourseID  string  `json:"courseId"`
	UserID    string  `json:"userId"`
	Progress  float64 `json:"progress"`
	Status    string  `json:"status"`
	Completed bool    `json:"completed"`
}

type LessonProgress struct {
	LessonID  string  `json:"lessonId"`
	Progress  float64 `json:"progress"`
	Completed bool    `json:"completed"`
}

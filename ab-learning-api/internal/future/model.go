// Package future contains the in-memory prototype endpoints for Sprints 7–10.
package future

type TutorRequest struct {
	Message  string `json:"message"`
	CourseID string `json:"courseId,omitempty"`
	LessonID string `json:"lessonId,omitempty"`
}

type TutorResponse struct {
	Answer      string   `json:"answer"`
	Suggestions []string `json:"suggestions"`
}

type SkillResult struct {
	Overall              int            `json:"overall"`
	Skills               map[string]int `json:"skills"`
	RecommendedCourseIDs []string       `json:"recommendedCourseIds"`
}

type CareerPath struct {
	ID                   string   `json:"id"`
	Title                string   `json:"title"`
	Progress             int      `json:"progress"`
	RequiredSkills       []string `json:"requiredSkills"`
	RecommendedCourseIDs []string `json:"recommendedCourseIds"`
}

type Portfolio struct {
	UserID   string             `json:"userId"`
	Headline string             `json:"headline"`
	Skills   []string           `json:"skills"`
	Projects []PortfolioProject `json:"projects"`
}

type PortfolioProject struct {
	Title       string `json:"title"`
	Description string `json:"description"`
	URL         string `json:"url,omitempty"`
}

type Job struct {
	ID         string   `json:"id"`
	Title      string   `json:"title"`
	Company    string   `json:"company"`
	Location   string   `json:"location"`
	Salary     string   `json:"salary"`
	Skills     []string `json:"skills"`
	MatchScore int      `json:"matchScore"`
}

type Application struct {
	JobID       string `json:"jobId"`
	PortfolioID string `json:"portfolioId,omitempty"`
	Status      string `json:"status"`
}

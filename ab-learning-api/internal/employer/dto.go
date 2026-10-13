package employer

import "time"

type Dashboard struct {
	CompanyName       string `json:"company_name"`
	OpenJobs          int    `json:"open_jobs"`
	TotalApplications int    `json:"total_applications"`
	ShortlistedCount  int    `json:"shortlisted_count"`
	HiredCount        int    `json:"hired_count"`
}

// TopApplicant is the highest match-score candidate across all of this
// employer's open jobs — feeds screen 39's "Recommended Talent" card.
type TopApplicant struct {
	UserID     int64   `json:"user_id"`
	Name       string  `json:"name"`
	Headline   string  `json:"headline"`
	MatchScore float64 `json:"match_score"`
	JobTitle   string  `json:"job_title"`
}

type Job struct {
	ID          int64     `json:"id"`
	Title       string    `json:"title"`
	Description string    `json:"description"`
	Location    string    `json:"location"`
	Status      string    `json:"status"`
	CreatedAt   time.Time `json:"created_at"`
}

type CreateJobInput struct {
	Title       string `json:"title"`
	Description string `json:"description"`
	Location    string `json:"location"`
}

type Application struct {
	ID        int64     `json:"id"`
	UserID    int64     `json:"user_id"`
	Name      string    `json:"name"`
	Email     string    `json:"email"`
	JobTitle  string    `json:"job_title"`
	Status    string    `json:"status"`
	AppliedAt time.Time `json:"applied_at"`
}

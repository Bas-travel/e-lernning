package employer

// Dashboard mirrors screen 39's KPI cards for an Employer's own job
// postings and applicant pipeline.
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

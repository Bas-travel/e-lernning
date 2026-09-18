package corporate

// Dashboard mirrors screen 36's KPI cards for a Corp Admin/Manager's own
// organization.
type Dashboard struct {
	OrganizationName    string  `json:"organization_name"`
	EmployeeCount       int     `json:"employee_count"`
	RegisteredEmployees int     `json:"registered_employees"`
	TrainingBudget      float64 `json:"training_budget"`
	ActiveLearners      int     `json:"active_learners"`
	CompletionRatePct   float64 `json:"completion_rate_pct"`
}

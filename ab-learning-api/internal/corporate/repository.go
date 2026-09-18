package corporate

import (
	"context"
	"database/sql"
)

type Repository struct {
	db *sql.DB
}

func NewRepository(db *sql.DB) *Repository {
	return &Repository{db: db}
}

// DashboardByUserID resolves which organization this Corp Admin/Manager
// belongs to via organization_users, then aggregates over it. Returns
// sql.ErrNoRows if the account isn't linked to any organization yet —
// callers should map that to a clear "not part of an organization" error
// rather than a generic 500.
func (r *Repository) DashboardByUserID(ctx context.Context, userID int64) (Dashboard, error) {
	var d Dashboard
	var orgID int64
	err := r.db.QueryRowContext(ctx, `
		SELECT
			o.id,
			o.name,
			o.employee_count,
			o.training_budget,
			(SELECT COUNT(*) FROM organization_users WHERE organization_id = o.id) AS registered_employees
		FROM organizations o
		JOIN organization_users ou ON ou.organization_id = o.id
		WHERE ou.user_id = ?
		LIMIT 1
	`, userID).Scan(&orgID, &d.OrganizationName, &d.EmployeeCount, &d.TrainingBudget, &d.RegisteredEmployees)
	if err != nil {
		return d, err
	}

	// Second query: how many of this org's people are actually learning,
	// and how far along on average. A learner counts as "active" the
	// moment they have any in-progress enrollment.
	err = r.db.QueryRowContext(ctx, `
		SELECT
			COUNT(DISTINCT e.user_id),
			COALESCE(AVG(e.progress_pct), 0)
		FROM enrollments e
		JOIN organization_users ou ON ou.user_id = e.user_id
		WHERE ou.organization_id = ?
	`, orgID).Scan(&d.ActiveLearners, &d.CompletionRatePct)
	if err != nil {
		return d, err
	}
	return d, nil
}

package employer

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

// employerIDByUserID resolves the employers.id row for a logged-in
// EMPLOYER account. Every other query in this repository needs it first.
func (r *Repository) employerIDByUserID(ctx context.Context, userID int64) (int64, string, error) {
	var employerID int64
	var companyName string
	err := r.db.QueryRowContext(ctx, `
		SELECT id, company_name FROM employers WHERE user_id = ?
	`, userID).Scan(&employerID, &companyName)
	return employerID, companyName, err
}

// DashboardByUserID aggregates this employer's job postings and the
// applications against them. Returns sql.ErrNoRows if the account isn't
// linked to an employer record yet.
func (r *Repository) DashboardByUserID(ctx context.Context, userID int64) (Dashboard, error) {
	employerID, companyName, err := r.employerIDByUserID(ctx, userID)
	if err != nil {
		return Dashboard{}, err
	}

	d := Dashboard{CompanyName: companyName}
	err = r.db.QueryRowContext(ctx, `
		SELECT
			(SELECT COUNT(*) FROM jobs WHERE employer_id = ? AND status = 'open'),
			(SELECT COUNT(*) FROM job_applications ja JOIN jobs j ON j.id = ja.job_id WHERE j.employer_id = ?),
			(SELECT COUNT(*) FROM job_applications ja JOIN jobs j ON j.id = ja.job_id WHERE j.employer_id = ? AND ja.status = 'shortlisted'),
			(SELECT COUNT(*) FROM job_applications ja JOIN jobs j ON j.id = ja.job_id WHERE j.employer_id = ? AND ja.status = 'hired')
	`, employerID, employerID, employerID, employerID).Scan(
		&d.OpenJobs, &d.TotalApplications, &d.ShortlistedCount, &d.HiredCount,
	)
	return d, err
}

// TopApplicants returns the highest match-score candidates across this
// employer's jobs — screen 39's "Recommended Talent" rail.
func (r *Repository) TopApplicants(ctx context.Context, userID int64, limit int) ([]TopApplicant, error) {
	employerID, _, err := r.employerIDByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}

	rows, err := r.db.QueryContext(ctx, `
		SELECT ja.user_id, COALESCE(p.first_name, u.email, ''), COALESCE(pf.headline, ''), ja.match_score, j.title
		FROM job_applications ja
		JOIN jobs j ON j.id = ja.job_id
		JOIN users u ON u.id = ja.user_id
		LEFT JOIN profiles p ON p.user_id = u.id
		LEFT JOIN portfolios pf ON pf.id = ja.portfolio_id
		WHERE j.employer_id = ?
		ORDER BY ja.match_score DESC
		LIMIT ?
	`, employerID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var out []TopApplicant
	for rows.Next() {
		var t TopApplicant
		var score sql.NullFloat64
		if err := rows.Scan(&t.UserID, &t.Name, &t.Headline, &score, &t.JobTitle); err != nil {
			return nil, err
		}
		if score.Valid {
			t.MatchScore = score.Float64
		}
		out = append(out, t)
	}
	return out, rows.Err()
}

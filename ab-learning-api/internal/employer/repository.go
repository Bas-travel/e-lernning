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

func (r *Repository) JobsByUserID(ctx context.Context, userID int64) ([]Job, error) {
	employerID, _, err := r.employerIDByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}
	rows, err := r.db.QueryContext(ctx, `SELECT id, title, COALESCE(description,''), COALESCE(location,''), status, created_at
		FROM jobs WHERE employer_id = ? ORDER BY created_at DESC, id DESC`, employerID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	items := []Job{}
	for rows.Next() {
		var item Job
		if err := rows.Scan(&item.ID, &item.Title, &item.Description, &item.Location, &item.Status, &item.CreatedAt); err != nil {
			return nil, err
		}
		items = append(items, item)
	}
	return items, rows.Err()
}

func (r *Repository) CreateJob(ctx context.Context, userID int64, in CreateJobInput) (Job, error) {
	employerID, _, err := r.employerIDByUserID(ctx, userID)
	if err != nil {
		return Job{}, err
	}
	res, err := r.db.ExecContext(ctx, `INSERT INTO jobs (employer_id, title, description, location, status)
		VALUES (?, ?, ?, ?, 'open')`, employerID, in.Title, in.Description, in.Location)
	if err != nil {
		return Job{}, err
	}
	id, err := res.LastInsertId()
	if err != nil {
		return Job{}, err
	}
	var job Job
	err = r.db.QueryRowContext(ctx, `SELECT id, title, COALESCE(description,''), COALESCE(location,''), status, created_at
		FROM jobs WHERE id = ? AND employer_id = ?`, id, employerID).Scan(
		&job.ID, &job.Title, &job.Description, &job.Location, &job.Status, &job.CreatedAt)
	return job, err
}

func (r *Repository) ApplicationsByUserID(ctx context.Context, userID int64) ([]Application, error) {
	employerID, _, err := r.employerIDByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}
	rows, err := r.db.QueryContext(ctx, `SELECT ja.id, ja.user_id,
		COALESCE(NULLIF(TRIM(CONCAT(COALESCE(p.first_name,''), ' ', COALESCE(p.last_name,''))), ''), u.email),
		u.email, j.title, ja.status, ja.applied_at
		FROM job_applications ja JOIN jobs j ON j.id = ja.job_id
		JOIN users u ON u.id = ja.user_id LEFT JOIN profiles p ON p.user_id = u.id
		WHERE j.employer_id = ? ORDER BY ja.applied_at DESC, ja.id DESC`, employerID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	items := []Application{}
	for rows.Next() {
		var item Application
		if err := rows.Scan(&item.ID, &item.UserID, &item.Name, &item.Email, &item.JobTitle, &item.Status, &item.AppliedAt); err != nil {
			return nil, err
		}
		items = append(items, item)
	}
	return items, rows.Err()
}

func (r *Repository) UpdateApplicationStatus(ctx context.Context, userID, applicationID int64, status string) error {
	employerID, _, err := r.employerIDByUserID(ctx, userID)
	if err != nil {
		return err
	}
	res, err := r.db.ExecContext(ctx, `UPDATE job_applications ja JOIN jobs j ON j.id = ja.job_id
		SET ja.status = ? WHERE ja.id = ? AND j.employer_id = ?`, status, applicationID, employerID)
	if err != nil {
		return err
	}
	if count, _ := res.RowsAffected(); count == 0 {
		var exists int
		err := r.db.QueryRowContext(ctx, `SELECT 1 FROM job_applications ja JOIN jobs j ON j.id = ja.job_id
			WHERE ja.id = ? AND j.employer_id = ?`, applicationID, employerID).Scan(&exists)
		if err != nil {
			return err
		}
	}
	return nil
}

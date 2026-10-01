// Package employer implements screen 39: the employer dashboard.
package employer

import (
	"database/sql"
	"errors"
	"log"
	"net/http"

	"github.com/ablearning/api/internal/httpx"
	"github.com/ablearning/api/internal/middleware"
)

type KPI struct {
	Label string `json:"label"`
	Value int    `json:"value"`
}

type Candidate struct {
	Name       string  `json:"name"`
	Headline   string  `json:"headline"`
	MatchScore float64 `json:"match_score"`
	Status     string  `json:"status"`
	Job        string  `json:"job"`
}

type LegacyDashboard struct {
	Company    string      `json:"company"`
	KPIs       []KPI       `json:"kpis"`
	TopMatches []Candidate `json:"top_matches"`
}

func Register(mux *http.ServeMux, guard middleware.Guard, db *sql.DB) {
	mux.Handle("GET /api/v1/employer/dashboard", guard.Require(func(w http.ResponseWriter, r *http.Request) {
		p, _ := middleware.PrincipalFrom(r.Context())
		d, err := load(r, db, p.UserID)
		if errors.Is(err, sql.ErrNoRows) {
			httpx.Error(w, http.StatusNotFound, "no employer profile for this account")
			return
		}
		if err != nil {
			log.Printf("employer: %v", err)
			httpx.Error(w, http.StatusInternalServerError, "internal error")
			return
		}
		httpx.JSON(w, http.StatusOK, d)
	}, middleware.RoleEmployer))
}

func load(r *http.Request, db *sql.DB, userID int64) (LegacyDashboard, error) {
	ctx := r.Context()
	var d LegacyDashboard
	var empID int64
	if err := db.QueryRowContext(ctx, `SELECT id, company_name FROM employers WHERE user_id = ?`, userID).Scan(&empID, &d.Company); err != nil {
		return d, err
	}
	var openJobs, apps, shortlisted, hired, candidates int
	err := db.QueryRowContext(ctx, `
		SELECT COUNT(DISTINCT CASE WHEN j.status = 'open' THEN j.id END),
		       COUNT(a.id),
		       COALESCE(SUM(a.status = 'shortlisted'), 0),
		       COALESCE(SUM(a.status = 'hired'), 0),
		       COUNT(DISTINCT a.user_id)
		FROM jobs j LEFT JOIN job_applications a ON a.job_id = j.id
		WHERE j.employer_id = ?`, empID).Scan(&openJobs, &apps, &shortlisted, &hired, &candidates)
	if err != nil {
		return d, err
	}
	d.KPIs = []KPI{{"Candidates", candidates}, {"Applications", apps}, {"Open Jobs", openJobs}, {"Shortlisted", shortlisted}, {"Hired", hired}}
	rows, err := db.QueryContext(ctx, `
		SELECT TRIM(CONCAT(COALESCE(p.first_name,''), ' ', COALESCE(p.last_name,''))), COALESCE(pf.headline,''),
		       COALESCE(a.match_score, 0), a.status, j.title
		FROM job_applications a
		JOIN jobs j ON j.id = a.job_id
		JOIN profiles p ON p.user_id = a.user_id
		JOIN portfolios pf ON pf.id = a.portfolio_id
		WHERE j.employer_id = ? ORDER BY a.match_score DESC LIMIT 5`, empID)
	if err != nil {
		return d, err
	}
	defer rows.Close()
	d.TopMatches = []Candidate{}
	for rows.Next() {
		var c Candidate
		if err := rows.Scan(&c.Name, &c.Headline, &c.MatchScore, &c.Status, &c.Job); err != nil {
			return d, err
		}
		d.TopMatches = append(d.TopMatches, c)
	}
	return d, rows.Err()
}

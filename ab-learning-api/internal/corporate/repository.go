package corporate

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"strings"
)

var (
	ErrNotFound = errors.New("not found")
	ErrConflict = errors.New("conflict")
)

type Repository struct{ db *sql.DB }

func NewRepository(db *sql.DB) *Repository { return &Repository{db: db} }

// OrgForUser resolves the organization the caller belongs to (active membership).
func (r *Repository) OrgForUser(ctx context.Context, userID int64) (int64, error) {
	var id int64
	err := r.db.QueryRowContext(ctx,
		`SELECT organization_id FROM organization_users WHERE user_id = ? AND status = 'active' LIMIT 1`, userID).Scan(&id)
	if errors.Is(err, sql.ErrNoRows) {
		return 0, ErrNotFound
	}
	return id, err
}

func (r *Repository) Dashboard(ctx context.Context, orgID int64) (Dashboard, error) {
	var d Dashboard
	var employees, active, enrollments, completed int
	var hours, budget float64
	if err := r.db.QueryRowContext(ctx, `SELECT name, training_budget FROM organizations WHERE id = ?`, orgID).Scan(&d.Organization, &budget); err != nil {
		return d, err
	}
	err := r.db.QueryRowContext(ctx, `
		SELECT COUNT(DISTINCT ou.user_id),
		       COUNT(DISTINCT CASE WHEN e.status = 'in_progress' THEN ou.user_id END),
		       COUNT(e.id),
		       COALESCE(SUM(e.status = 'completed'), 0),
		       COALESCE(SUM(CASE WHEN e.status = 'completed' THEN c.duration_minutes ELSE 0 END), 0) / 60
		FROM organization_users ou
		LEFT JOIN enrollments e ON e.user_id = ou.user_id
		LEFT JOIN courses c ON c.id = e.course_id
		WHERE ou.organization_id = ? AND ou.status = 'active'`, orgID).
		Scan(&employees, &active, &enrollments, &completed, &hours)
	if err != nil {
		return d, err
	}
	rate := 0.0
	if enrollments > 0 {
		rate = float64(completed) * 100 / float64(enrollments)
	}
	d.KPIs = []KPI{
		{"Employees", fmt.Sprint(employees)},
		{"Active Learners", fmt.Sprint(active)},
		{"Completion Rate", fmt.Sprintf("%.0f%%", rate)},
		{"Training Hours", fmt.Sprintf("%.0f", hours)},
		{"Training Budget", fmt.Sprintf("฿%.0f", budget)},
	}
	rows, err := r.db.QueryContext(ctx, `
		SELECT COALESCE(NULLIF(ou.department, ''), 'Unassigned'), COUNT(DISTINCT ou.user_id), COALESCE(AVG(e.progress_pct), 0)
		FROM organization_users ou LEFT JOIN enrollments e ON e.user_id = ou.user_id
		WHERE ou.organization_id = ? AND ou.status = 'active'
		GROUP BY 1 ORDER BY 1`, orgID)
	if err != nil {
		return d, err
	}
	defer rows.Close()
	d.Departments = []DeptPerformance{}
	for rows.Next() {
		var p DeptPerformance
		if err := rows.Scan(&p.Department, &p.Employees, &p.AvgProgress); err != nil {
			return d, err
		}
		d.Departments = append(d.Departments, p)
	}
	return d, rows.Err()
}

func (r *Repository) ListEmployees(ctx context.Context, orgID int64, f EmployeeFilter) ([]Employee, error) {
	q := `SELECT ou.id, u.id, TRIM(CONCAT(COALESCE(p.first_name,''), ' ', COALESCE(p.last_name,''))), u.email,
	             COALESCE(ou.department, ''), ou.role_in_org, ou.status, COUNT(e.id), COALESCE(AVG(e.progress_pct), 0)
	      FROM organization_users ou
	      JOIN users u ON u.id = ou.user_id
	      LEFT JOIN profiles p ON p.user_id = u.id
	      LEFT JOIN enrollments e ON e.user_id = u.id
	      WHERE ou.organization_id = ?`
	args := []any{orgID}
	if f.Query != "" {
		q += ` AND (u.email LIKE ? OR p.first_name LIKE ? OR p.last_name LIKE ?)`
		like := "%" + escapeLike(f.Query) + "%"
		args = append(args, like, like, like)
	}
	if f.Department != "" {
		q += ` AND ou.department = ?`
		args = append(args, f.Department)
	}
	if f.Status != "" {
		q += ` AND ou.status = ?`
		args = append(args, f.Status)
	}
	q += ` GROUP BY ou.id, u.id, p.first_name, p.last_name, u.email, ou.department, ou.role_in_org, ou.status
	       ORDER BY ou.id LIMIT ? OFFSET ?`
	args = append(args, f.Limit, f.Offset)
	rows, err := r.db.QueryContext(ctx, q, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []Employee{}
	for rows.Next() {
		var e Employee
		if err := rows.Scan(&e.ID, &e.UserID, &e.Name, &e.Email, &e.Department, &e.RoleInOrg, &e.Status, &e.CoursesEnrolled, &e.AvgProgress); err != nil {
			return nil, err
		}
		out = append(out, e)
	}
	return out, rows.Err()
}

func escapeLike(s string) string {
	return strings.NewReplacer(`\`, `\\`, `%`, `\%`, `_`, `\_`).Replace(s)
}

// AddEmployee attaches an existing platform user (by email) to the organization.
func (r *Repository) AddEmployee(ctx context.Context, orgID int64, in AddEmployeeInput) (Employee, error) {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return Employee{}, err
	}
	defer tx.Rollback()
	var userID int64
	if err := tx.QueryRowContext(ctx, `SELECT id FROM users WHERE email = ?`, in.Email).Scan(&userID); errors.Is(err, sql.ErrNoRows) {
		return Employee{}, ErrNotFound
	} else if err != nil {
		return Employee{}, err
	}
	// A user can belong to one organization at a time.
	var existing int
	if err := tx.QueryRowContext(ctx, `SELECT COUNT(*) FROM organization_users WHERE user_id = ? AND status = 'active'`, userID).Scan(&existing); err != nil {
		return Employee{}, err
	}
	if existing > 0 {
		return Employee{}, ErrConflict
	}
	res, err := tx.ExecContext(ctx,
		`INSERT INTO organization_users (organization_id, user_id, department, role_in_org) VALUES (?, ?, ?, ?)
		 ON DUPLICATE KEY UPDATE status = 'active', department = VALUES(department), role_in_org = VALUES(role_in_org)`,
		orgID, userID, in.Department, in.RoleInOrg)
	if err != nil {
		return Employee{}, err
	}
	if _, err := tx.ExecContext(ctx, `UPDATE organizations SET employee_count =
		(SELECT COUNT(*) FROM organization_users WHERE organization_id = ? AND status = 'active') WHERE id = ?`, orgID, orgID); err != nil {
		return Employee{}, err
	}
	_ = res
	if err := tx.Commit(); err != nil {
		return Employee{}, err
	}
	list, err := r.ListEmployees(ctx, orgID, EmployeeFilter{Query: in.Email, Limit: 1})
	if err != nil || len(list) == 0 {
		return Employee{}, err
	}
	return list[0], nil
}

func (r *Repository) UpdateEmployee(ctx context.Context, orgID, id int64, in UpdateEmployeeInput) error {
	res, err := r.db.ExecContext(ctx, `UPDATE organization_users SET
		department = COALESCE(?, department), status = COALESCE(?, status)
		WHERE id = ? AND organization_id = ?`, in.Department, in.Status, id, orgID)
	if err != nil {
		return err
	}
	if n, _ := res.RowsAffected(); n == 0 {
		// RowsAffected is 0 both for "no such row" and "nothing changed"; disambiguate.
		var x int
		if err := r.db.QueryRowContext(ctx, `SELECT 1 FROM organization_users WHERE id = ? AND organization_id = ?`, id, orgID).Scan(&x); errors.Is(err, sql.ErrNoRows) {
			return ErrNotFound
		}
	}
	_, err = r.db.ExecContext(ctx, `UPDATE organizations SET employee_count =
		(SELECT COUNT(*) FROM organization_users WHERE organization_id = ? AND status = 'active') WHERE id = ?`, orgID, orgID)
	return err
}

func (r *Repository) ListPaths(ctx context.Context, orgID int64) ([]LearningPath, error) {
	rows, err := r.db.QueryContext(ctx, `SELECT id, name, COALESCE(goal,''), DATE_FORMAT(deadline, '%Y-%m-%d'), created_at
		FROM learning_paths WHERE organization_id = ? ORDER BY id DESC`, orgID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []LearningPath{}
	for rows.Next() {
		var p LearningPath
		var dl sql.NullString
		if err := rows.Scan(&p.ID, &p.Name, &p.Goal, &dl, &p.CreatedAt); err != nil {
			return nil, err
		}
		if dl.Valid {
			p.Deadline = &dl.String
		}
		p.Courses = []PathCourse{}
		out = append(out, p)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	rows.Close()
	for i := range out {
		cr, err := r.db.QueryContext(ctx, `SELECT c.id, c.title FROM learning_path_courses lpc
			JOIN courses c ON c.id = lpc.course_id WHERE lpc.learning_path_id = ? ORDER BY lpc.id`, out[i].ID)
		if err != nil {
			return nil, err
		}
		for cr.Next() {
			var pc PathCourse
			if err := cr.Scan(&pc.ID, &pc.Title); err != nil {
				cr.Close()
				return nil, err
			}
			out[i].Courses = append(out[i].Courses, pc)
		}
		cr.Close()
	}
	return out, nil
}

func (r *Repository) CreatePath(ctx context.Context, orgID int64, in CreatePathInput) (int64, error) {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return 0, err
	}
	defer tx.Rollback()
	// Only published courses can be assigned.
	for _, cid := range in.CourseIDs {
		var x int
		if err := tx.QueryRowContext(ctx, `SELECT 1 FROM courses WHERE id = ? AND status = 'published'`, cid).Scan(&x); errors.Is(err, sql.ErrNoRows) {
			return 0, fmt.Errorf("%w: course %d is not available", ErrNotFound, cid)
		} else if err != nil {
			return 0, err
		}
	}
	res, err := tx.ExecContext(ctx, `INSERT INTO learning_paths (organization_id, name, goal, deadline) VALUES (?, ?, ?, ?)`,
		orgID, in.Name, in.Goal, in.Deadline)
	if err != nil {
		return 0, err
	}
	id, _ := res.LastInsertId()
	for _, cid := range in.CourseIDs {
		if _, err := tx.ExecContext(ctx, `INSERT INTO learning_path_courses (learning_path_id, course_id) VALUES (?, ?)`, id, cid); err != nil {
			return 0, err
		}
	}
	return id, tx.Commit()
}

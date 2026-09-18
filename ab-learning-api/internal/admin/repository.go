package admin

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

// Dashboard has no per-user scoping — an ADMIN sees the whole platform,
// unlike every other role's dashboard in this codebase.
func (r *Repository) Dashboard(ctx context.Context) (Dashboard, error) {
	var d Dashboard
	err := r.db.QueryRowContext(ctx, `
		SELECT
			(SELECT COUNT(*) FROM users),
			(SELECT COUNT(*) FROM instructors),
			(SELECT COUNT(*) FROM courses),
			(SELECT COALESCE(SUM(amount),0) FROM payments WHERE status = 'success'),
			(SELECT COUNT(*) FROM courses WHERE status = 'pending_review')
	`).Scan(&d.TotalUsers, &d.TotalInstructors, &d.TotalCourses, &d.TotalRevenue, &d.PendingModeration)
	return d, err
}

// PendingCourses is screen 41's moderation queue.
func (r *Repository) PendingCourses(ctx context.Context, limit int) ([]PendingCourse, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT c.id, c.title, COALESCE(p.first_name, u.email, ''), cat.name_en, c.created_at
		FROM courses c
		JOIN instructors i ON i.id = c.instructor_id
		JOIN users u ON u.id = i.user_id
		LEFT JOIN profiles p ON p.user_id = u.id
		JOIN categories cat ON cat.id = c.category_id
		WHERE c.status = 'pending_review'
		ORDER BY c.created_at ASC
		LIMIT ?
	`, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var out []PendingCourse
	for rows.Next() {
		var p PendingCourse
		var submittedAt sql.NullTime
		if err := rows.Scan(&p.ID, &p.Title, &p.InstructorName, &p.Category, &submittedAt); err != nil {
			return nil, err
		}
		if submittedAt.Valid {
			p.SubmittedAt = submittedAt.Time.Format("2006-01-02T15:04:05Z07:00")
		}
		out = append(out, p)
	}
	return out, rows.Err()
}

// ApproveCourse implements screen 41's Approve action.
func (r *Repository) ApproveCourse(ctx context.Context, courseID int64) error {
	res, err := r.db.ExecContext(ctx, `
		UPDATE courses SET status = 'published', published_at = NOW()
		WHERE id = ? AND status = 'pending_review'
	`, courseID)
	if err != nil {
		return err
	}
	n, err := res.RowsAffected()
	if err != nil {
		return err
	}
	if n == 0 {
		return sql.ErrNoRows
	}
	return nil
}

// RejectCourse implements screen 41's Reject action.
func (r *Repository) RejectCourse(ctx context.Context, courseID int64, reason string) error {
	res, err := r.db.ExecContext(ctx, `
		UPDATE courses SET status = 'rejected', rejected_reason = ?
		WHERE id = ? AND status = 'pending_review'
	`, reason, courseID)
	if err != nil {
		return err
	}
	n, err := res.RowsAffected()
	if err != nil {
		return err
	}
	if n == 0 {
		return sql.ErrNoRows
	}
	return nil
}

package instructor

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

// DashboardByUserID aggregates directly over `courses` for the instructor
// row linked to this user — returns zero values (not an error) if the
// user has no courses yet, since "no data" is a valid, expected state for
// a brand-new instructor account.
func (r *Repository) DashboardByUserID(ctx context.Context, userID int64) (Dashboard, error) {
	var d Dashboard
	err := r.db.QueryRowContext(ctx, `
		SELECT
			COUNT(*)                         AS course_count,
			COALESCE(SUM(c.student_count),0) AS total_students,
			COALESCE(AVG(c.rating_avg),0)    AS avg_rating
		FROM courses c
		JOIN instructors i ON i.id = c.instructor_id
		WHERE i.user_id = ?
	`, userID).Scan(&d.CourseCount, &d.TotalStudents, &d.AvgRating)
	return d, err
}

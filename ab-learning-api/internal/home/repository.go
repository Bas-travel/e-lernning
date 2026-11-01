package home

import (
	"context"
	"database/sql"
	"fmt"
)

type Repository struct {
	db *sql.DB
}

func NewRepository(db *sql.DB) *Repository {
	return &Repository{db: db}
}

func (repo *Repository) GreetingName(ctx context.Context, userID int64) (string, error) {
	var name string
	err := repo.db.QueryRowContext(ctx, `
		SELECT COALESCE(NULLIF(first_name, ''), 'นักเรียน') FROM profiles WHERE user_id = ?
	`, userID).Scan(&name)
	if err != nil {
		if err == sql.ErrNoRows {
			return "นักเรียน", nil
		}
		return "", fmt.Errorf("greeting name: %w", err)
	}
	return name, nil
}

// ContinueLearning returns the learner's most recently touched in-progress
// courses — screen 08's "Continue Learning" rail.
func (repo *Repository) ContinueLearning(ctx context.Context, userID int64, limit int) ([]CourseSummary, error) {
	rows, err := repo.db.QueryContext(ctx, `
		SELECT c.id, c.title, COALESCE(p.first_name, ins_u.email, ''), e.progress_pct
		FROM enrollments e
		JOIN courses c ON c.id = e.course_id
		JOIN instructors ins ON ins.id = c.instructor_id
		JOIN users ins_u ON ins_u.id = ins.user_id
		LEFT JOIN profiles p ON p.user_id = ins_u.id
		WHERE e.user_id = ? AND e.status = 'in_progress'
		ORDER BY e.enrolled_at DESC
		LIMIT ?
	`, userID, limit)
	if err != nil {
		return nil, fmt.Errorf("continue learning query: %w", err)
	}
	defer rows.Close()

	var out []CourseSummary
	for rows.Next() {
		var c CourseSummary
		var progress float64
		if err := rows.Scan(&c.ID, &c.Title, &c.InstructorName, &progress); err != nil {
			return nil, fmt.Errorf("scan continue learning row: %w", err)
		}
		c.ProgressPct = &progress
		c.ThumbnailGradient = "primary"
		out = append(out, c)
	}
	return out, rows.Err()
}

// Recommended returns published courses the learner hasn't already
// enrolled in, ranked by rating — screen 08's "Recommended for you" rail.
func (repo *Repository) Recommended(ctx context.Context, userID int64, limit int) ([]CourseSummary, error) {
	rows, err := repo.db.QueryContext(ctx, `
		SELECT c.id, c.title, COALESCE(p.first_name, ins_u.email, ''), c.price, c.discount_price, c.rating_avg
		FROM courses c
		JOIN instructors ins ON ins.id = c.instructor_id
		JOIN users ins_u ON ins_u.id = ins.user_id
		LEFT JOIN profiles p ON p.user_id = ins_u.id
		WHERE c.status = 'published'
		  AND c.id NOT IN (SELECT course_id FROM enrollments WHERE user_id = ?)
		ORDER BY c.rating_avg DESC, c.student_count DESC
		LIMIT ?
	`, userID, limit)
	if err != nil {
		return nil, fmt.Errorf("recommended query: %w", err)
	}
	defer rows.Close()

	gradients := []string{"primary", "accent", "secondary"}
	var out []CourseSummary
	for rows.Next() {
		var c CourseSummary
		var discount sql.NullFloat64
		if err := rows.Scan(&c.ID, &c.Title, &c.InstructorName, &c.Price, &discount, &c.RatingAvg); err != nil {
			return nil, fmt.Errorf("scan recommended row: %w", err)
		}
		if discount.Valid {
			c.DiscountPrice = &discount.Float64
		}
		c.ThumbnailGradient = gradients[len(out)%len(gradients)]
		out = append(out, c)
	}
	return out, rows.Err()
}

// UpcomingLive returns live sessions the learner can still join or
// register for — screen 08's "Live coming up" rail.
func (repo *Repository) UpcomingLive(ctx context.Context, limit int) ([]LiveSummary, error) {
	rows, err := repo.db.QueryContext(ctx, `
		SELECT ls.id, ls.title, COALESCE(p.first_name, u.email, ''), ls.scheduled_at, ls.status
		FROM live_sessions ls
		JOIN instructors ins ON ins.id = ls.instructor_id
		JOIN users u ON u.id = ins.user_id
		LEFT JOIN profiles p ON p.user_id = u.id
		WHERE ls.status IN ('upcoming', 'live')
		ORDER BY ls.scheduled_at ASC
		LIMIT ?
	`, limit)
	if err != nil {
		return nil, fmt.Errorf("upcoming live query: %w", err)
	}
	defer rows.Close()

	var out []LiveSummary
	for rows.Next() {
		var l LiveSummary
		var scheduledAt sql.NullTime
		if err := rows.Scan(&l.ID, &l.Title, &l.InstructorName, &scheduledAt, &l.Status); err != nil {
			return nil, fmt.Errorf("scan live row: %w", err)
		}
		if scheduledAt.Valid {
			l.ScheduledAt = scheduledAt.Time.Format("2006-01-02T15:04:05Z07:00")
		}
		out = append(out, l)
	}
	return out, rows.Err()
}

// CareerPathProgress is a simple, honest proxy for now: the learner's
// average progress across all active enrollments. Swap for a real
// skill-gap-weighted calculation once career_path_skills is populated
// with real assessment data (see skill_results in 04-schema.sql).
func (repo *Repository) CareerPathProgress(ctx context.Context, userID int64) (float64, error) {
	var avg sql.NullFloat64
	err := repo.db.QueryRowContext(ctx, `
		SELECT AVG(progress_pct) FROM enrollments WHERE user_id = ?
	`, userID).Scan(&avg)
	if err != nil {
		return 0, fmt.Errorf("career path progress: %w", err)
	}
	if !avg.Valid {
		return 0, nil
	}
	return avg.Float64, nil
}

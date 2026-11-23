package reviews

import (
	"context"
	"database/sql"
	"fmt"
)

type SQLRepository struct{ db *sql.DB }

func NewRepository(db *sql.DB) *SQLRepository { return &SQLRepository{db: db} }

func (r *SQLRepository) CourseExists(ctx context.Context, courseID int64) (bool, error) {
	var one int
	err := r.db.QueryRowContext(ctx,
		`SELECT 1 FROM courses WHERE id = ? AND status = 'published'`, courseID).Scan(&one)
	if err == sql.ErrNoRows {
		return false, nil
	}
	return err == nil, err
}

func (r *SQLRepository) Enrolled(ctx context.Context, userID, courseID int64) (bool, error) {
	var one int
	err := r.db.QueryRowContext(ctx,
		`SELECT 1 FROM enrollments WHERE user_id = ? AND course_id = ?`, userID, courseID).Scan(&one)
	if err == sql.ErrNoRows {
		return false, nil
	}
	return err == nil, err
}

func (r *SQLRepository) Upsert(ctx context.Context, courseID, userID int64, rating int, comment string) error {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback() }()
	if _, err := tx.ExecContext(ctx,
		`INSERT INTO reviews (course_id, user_id, rating, comment) VALUES (?, ?, ?, ?)
		 ON DUPLICATE KEY UPDATE rating = VALUES(rating), comment = VALUES(comment)`,
		courseID, userID, rating, comment); err != nil {
		return fmt.Errorf("save review: %w", err)
	}
	if _, err := tx.ExecContext(ctx,
		`UPDATE courses c
		   JOIN (SELECT COUNT(*) AS n, AVG(rating) AS a FROM reviews WHERE course_id = ?) s
		    SET c.rating_count = s.n, c.rating_avg = ROUND(s.a, 2)
		  WHERE c.id = ?`, courseID, courseID); err != nil {
		return fmt.Errorf("refresh course rating: %w", err)
	}
	return tx.Commit()
}

func (r *SQLRepository) List(ctx context.Context, courseID, viewerID int64, limit, offset int) ([]Review, error) {
	rows, err := r.db.QueryContext(ctx,
		`SELECT rv.id, rv.rating, COALESCE(rv.comment, ''),
		        TRIM(CONCAT(COALESCE(p.first_name, ''), ' ', COALESCE(p.last_name, ''))),
		        rv.user_id = ?, rv.created_at
		   FROM reviews rv LEFT JOIN profiles p ON p.user_id = rv.user_id
		  WHERE rv.course_id = ?
		  ORDER BY rv.created_at DESC, rv.id DESC LIMIT ? OFFSET ?`,
		viewerID, courseID, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("list reviews: %w", err)
	}
	defer rows.Close()
	var out []Review
	for rows.Next() {
		var v Review
		if err := rows.Scan(&v.ID, &v.Rating, &v.Comment, &v.Author, &v.Mine, &v.CreatedAt); err != nil {
			return nil, err
		}
		if v.Author == "" {
			v.Author = "ผู้เรียน"
		}
		out = append(out, v)
	}
	return out, rows.Err()
}

func (r *SQLRepository) Summary(ctx context.Context, courseID int64) (float64, int, error) {
	var avg sql.NullFloat64
	var n int
	err := r.db.QueryRowContext(ctx,
		`SELECT AVG(rating), COUNT(*) FROM reviews WHERE course_id = ?`, courseID).Scan(&avg, &n)
	return avg.Float64, n, err
}

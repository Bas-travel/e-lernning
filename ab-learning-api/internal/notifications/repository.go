package notifications

import (
	"context"
	"database/sql"
	"fmt"
)

type SQLRepository struct{ db *sql.DB }

func NewRepository(db *sql.DB) *SQLRepository { return &SQLRepository{db: db} }

func (r *SQLRepository) List(ctx context.Context, userID int64, unreadOnly bool, limit, offset int) ([]Notification, error) {
	q := `SELECT id, type, title, COALESCE(body, ''), is_read, created_at
		FROM notifications WHERE user_id = ?`
	if unreadOnly {
		q += ` AND is_read = 0`
	}
	q += ` ORDER BY created_at DESC, id DESC LIMIT ? OFFSET ?`
	rows, err := r.db.QueryContext(ctx, q, userID, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("list notifications: %w", err)
	}
	defer rows.Close()
	var out []Notification
	for rows.Next() {
		var n Notification
		var read int
		if err := rows.Scan(&n.ID, &n.Type, &n.Title, &n.Body, &read, &n.CreatedAt); err != nil {
			return nil, err
		}
		n.IsRead = read != 0
		out = append(out, n)
	}
	return out, rows.Err()
}

func (r *SQLRepository) CountUnread(ctx context.Context, userID int64) (int, error) {
	var n int
	err := r.db.QueryRowContext(ctx,
		`SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0`, userID).Scan(&n)
	return n, err
}

func (r *SQLRepository) MarkRead(ctx context.Context, userID, id int64) (bool, error) {
	// is_read may already be 1 (0 rows changed), so check existence separately.
	if _, err := r.db.ExecContext(ctx,
		`UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?`, id, userID); err != nil {
		return false, err
	}
	var one int
	err := r.db.QueryRowContext(ctx,
		`SELECT 1 FROM notifications WHERE id = ? AND user_id = ?`, id, userID).Scan(&one)
	if err == sql.ErrNoRows {
		return false, nil
	}
	return err == nil, err
}

func (r *SQLRepository) MarkAllRead(ctx context.Context, userID int64) (int64, error) {
	res, err := r.db.ExecContext(ctx,
		`UPDATE notifications SET is_read = 1 WHERE user_id = ? AND is_read = 0`, userID)
	if err != nil {
		return 0, err
	}
	return res.RowsAffected()
}

func (r *SQLRepository) Create(ctx context.Context, userID int64, n Notification) error {
	_, err := r.db.ExecContext(ctx,
		`INSERT INTO notifications (user_id, type, title, body) VALUES (?, ?, ?, ?)`,
		userID, n.Type, n.Title, n.Body)
	return err
}

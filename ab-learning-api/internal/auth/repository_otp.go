package auth

import (
	"database/sql"
	"errors"
	"time"
)

// InsertOTP stores a freshly generated one-time code.
func (r *Repository) InsertOTP(userID int64, code, purpose string, expires time.Time) error {
	_, err := r.db.Exec(`INSERT INTO otp_verifications (user_id, code, purpose, expires_at) VALUES (?, ?, ?, ?)`,
		userID, code, purpose, expires)
	return err
}

// LastOTPAt returns when the newest code for the user/purpose was created.
func (r *Repository) LastOTPAt(userID int64, purpose string) (time.Time, bool, error) {
	var created time.Time
	err := r.db.QueryRow(`SELECT created_at FROM otp_verifications
		WHERE user_id = ? AND purpose = ? ORDER BY id DESC LIMIT 1`, userID, purpose).Scan(&created)
	if errors.Is(err, sql.ErrNoRows) {
		return time.Time{}, false, nil
	}
	return created, err == nil, err
}

// ConsumeOTP marks a matching, unexpired, unused code as consumed. For the
// `register` purpose it also stamps users.email_verified_at.
func (r *Repository) ConsumeOTP(userID int64, code, purpose string, now time.Time) (bool, error) {
	tx, err := r.db.Begin()
	if err != nil {
		return false, err
	}
	defer func() { _ = tx.Rollback() }()

	res, err := tx.Exec(`UPDATE otp_verifications SET consumed_at = ?
		WHERE user_id = ? AND code = ? AND purpose = ? AND consumed_at IS NULL AND expires_at > ?`,
		now, userID, code, purpose, now)
	if err != nil {
		return false, err
	}
	if n, _ := res.RowsAffected(); n == 0 {
		return false, nil
	}
	if purpose == "register" {
		if _, err := tx.Exec(`UPDATE users SET email_verified_at = ? WHERE id = ? AND email_verified_at IS NULL`, now, userID); err != nil {
			return false, err
		}
	}
	return true, tx.Commit()
}

// EmailVerified reports whether the user already verified their e-mail.
func (r *Repository) EmailVerified(userID int64) (bool, error) {
	var verified bool
	err := r.db.QueryRow(`SELECT email_verified_at IS NOT NULL FROM users WHERE id = ?`, userID).Scan(&verified)
	if errors.Is(err, sql.ErrNoRows) {
		return false, ErrNotFound
	}
	return verified, err
}

// InsertReset stores the SHA-256 of a password-reset token.
func (r *Repository) InsertReset(userID int64, tokenHash string, expires time.Time) error {
	_, err := r.db.Exec(`INSERT INTO password_resets (user_id, token, expires_at) VALUES (?, ?, ?)`,
		userID, tokenHash, expires)
	return err
}

// SavePreferences upserts the onboarding answers (`user_preferences.user_id` is UNIQUE).
func (r *Repository) SavePreferences(userID int64, interestsJSON []byte, level, goal any) error {
	_, err := r.db.Exec(`INSERT INTO user_preferences (user_id, interests, level, goal) VALUES (?, ?, ?, ?)
		ON DUPLICATE KEY UPDATE interests = VALUES(interests), level = VALUES(level), goal = VALUES(goal)`,
		userID, interestsJSON, level, goal)
	return err
}

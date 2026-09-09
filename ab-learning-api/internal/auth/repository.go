package auth

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
)

var ErrUserNotFound = errors.New("user not found")
var ErrEmailTaken = errors.New("email already registered")

type Repository struct {
	db *sql.DB
}

func NewRepository(db *sql.DB) *Repository {
	return &Repository{db: db}
}

const userSelectCols = `
	u.id, u.email, u.phone, u.password_hash, r.code,
	COALESCE(p.first_name, ''), COALESCE(p.last_name, ''), p.avatar_url, u.created_at
`

func (repo *Repository) scanUser(row *sql.Row) (User, error) {
	var u User
	err := row.Scan(&u.ID, &u.Email, &u.Phone, &u.PasswordHash, &u.RoleCode,
		&u.FirstName, &u.LastName, &u.AvatarURL, &u.CreatedAt)
	if errors.Is(err, sql.ErrNoRows) {
		return User{}, ErrUserNotFound
	}
	if err != nil {
		return User{}, fmt.Errorf("scan user: %w", err)
	}
	return u, nil
}

// FindByIdentifier looks a user up by email OR phone — screen 03 (Login)
// lets the person type either into the same field.
func (repo *Repository) FindByIdentifier(ctx context.Context, identifier string) (User, error) {
	row := repo.db.QueryRowContext(ctx, `
		SELECT `+userSelectCols+`
		FROM users u
		JOIN roles r ON r.id = u.role_id
		LEFT JOIN profiles p ON p.user_id = u.id
		WHERE u.email = ? OR u.phone = ?
		LIMIT 1
	`, identifier, identifier)
	return repo.scanUser(row)
}

func (repo *Repository) FindByID(ctx context.Context, id int64) (User, error) {
	row := repo.db.QueryRowContext(ctx, `
		SELECT `+userSelectCols+`
		FROM users u
		JOIN roles r ON r.id = u.role_id
		LEFT JOIN profiles p ON p.user_id = u.id
		WHERE u.id = ?
		LIMIT 1
	`, id)
	return repo.scanUser(row)
}

// Create inserts a new LEARNER user + profile in one transaction (screen 04
// — Register always creates a Learner; other roles are provisioned by an
// Admin, not self-registration).
func (repo *Repository) Create(ctx context.Context, req RegisterRequest, passwordHash string) (int64, error) {
	tx, err := repo.db.BeginTx(ctx, nil)
	if err != nil {
		return 0, fmt.Errorf("begin tx: %w", err)
	}
	defer tx.Rollback() //nolint:errcheck // no-op if already committed

	var roleID int64
	if err := tx.QueryRowContext(ctx, `SELECT id FROM roles WHERE code = 'LEARNER'`).Scan(&roleID); err != nil {
		return 0, fmt.Errorf("look up LEARNER role (did you run db/seed/seed.sql?): %w", err)
	}

	var exists int
	if err := tx.QueryRowContext(ctx, `SELECT COUNT(*) FROM users WHERE email = ?`, req.Email).Scan(&exists); err != nil {
		return 0, fmt.Errorf("check existing email: %w", err)
	}
	if exists > 0 {
		return 0, ErrEmailTaken
	}

	res, err := tx.ExecContext(ctx, `
		INSERT INTO users (role_id, email, phone, password_hash, status)
		VALUES (?, ?, NULLIF(?, ''), ?, 'active')
	`, roleID, req.Email, req.Phone, passwordHash)
	if err != nil {
		return 0, fmt.Errorf("insert user: %w", err)
	}

	userID, err := res.LastInsertId()
	if err != nil {
		return 0, fmt.Errorf("get inserted id: %w", err)
	}

	if _, err := tx.ExecContext(ctx, `
		INSERT INTO profiles (user_id, first_name, last_name)
		VALUES (?, ?, ?)
	`, userID, req.FirstName, req.LastName); err != nil {
		return 0, fmt.Errorf("insert profile: %w", err)
	}

	// Every new learner gets a wallet — mirrors what screen 28 (Wallet)
	// expects to exist for any learner account.
	if _, err := tx.ExecContext(ctx, `
		INSERT INTO wallets (user_id, coin_balance, cash_balance) VALUES (?, 0, 0)
	`, userID); err != nil {
		return 0, fmt.Errorf("insert wallet: %w", err)
	}

	if err := tx.Commit(); err != nil {
		return 0, fmt.Errorf("commit tx: %w", err)
	}

	return userID, nil
}

func (repo *Repository) UpdateLastLogin(ctx context.Context, userID int64) error {
	_, err := repo.db.ExecContext(ctx, `UPDATE users SET last_login_at = NOW() WHERE id = ?`, userID)
	return err
}

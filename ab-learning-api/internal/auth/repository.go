package auth

import (
	"database/sql"
	"errors"
)

var (
	ErrNotFound       = errors.New("not found")
	ErrEmailTaken     = errors.New("email already registered")
)

type Repository struct{ db *sql.DB }

func NewRepository(db *sql.DB) *Repository { return &Repository{db: db} }

type userRow struct {
	User
	PasswordHash string
	Status       string
}

const userSelect = `
	SELECT u.id, u.email, r.code, COALESCE(p.first_name,''), COALESCE(p.last_name,''),
	       COALESCE(p.avatar_url,''), u.password_hash, u.status
	FROM users u
	JOIN roles r ON r.id = u.role_id
	LEFT JOIN profiles p ON p.user_id = u.id`

func (r *Repository) scan(row *sql.Row) (userRow, error) {
	var u userRow
	err := row.Scan(&u.ID, &u.Email, &u.Role, &u.FirstName, &u.LastName, &u.AvatarURL, &u.PasswordHash, &u.Status)
	if errors.Is(err, sql.ErrNoRows) {
		return userRow{}, ErrNotFound
	}
	return u, err
}

func (r *Repository) ByEmail(email string) (userRow, error) {
	return r.scan(r.db.QueryRow(userSelect+` WHERE u.email = ?`, email))
}

func (r *Repository) ByID(id int64) (userRow, error) {
	return r.scan(r.db.QueryRow(userSelect+` WHERE u.id = ?`, id))
}

func (r *Repository) TouchLogin(id int64) {
	_, _ = r.db.Exec(`UPDATE users SET last_login_at = NOW() WHERE id = ?`, id)
}

// CreateLearner inserts a LEARNER user + profile in one transaction.
func (r *Repository) CreateLearner(req RegisterRequest, hash string) (int64, error) {
	tx, err := r.db.Begin()
	if err != nil {
		return 0, err
	}
	defer tx.Rollback()

	var taken int
	if err := tx.QueryRow(`SELECT COUNT(*) FROM users WHERE email = ? OR (? <> '' AND phone = ?)`, req.Email, req.Phone, req.Phone).Scan(&taken); err != nil {
		return 0, err
	}
	if taken > 0 {
		return 0, ErrEmailTaken
	}
	var phone any
	if req.Phone != "" {
		phone = req.Phone
	}
	res, err := tx.Exec(`INSERT INTO users (role_id, email, phone, password_hash)
		SELECT id, ?, ?, ? FROM roles WHERE code = 'LEARNER'`, req.Email, phone, hash)
	if err != nil {
		return 0, err
	}
	id, _ := res.LastInsertId()
	if _, err := tx.Exec(`INSERT INTO profiles (user_id, first_name, last_name) VALUES (?, ?, ?)`, id, req.FirstName, req.LastName); err != nil {
		return 0, err
	}
	return id, tx.Commit()
}

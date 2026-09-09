package auth

import "time"

// User mirrors the `users` + `profiles` tables (joined), and the `User`
// schema in 05-openapi.yaml.
type User struct {
	ID           int64
	Email        string
	Phone        *string
	PasswordHash string
	RoleCode     string // GUEST, LEARNER, INSTRUCTOR, CORP_ADMIN, CORP_MANAGER, EMPLOYER, ADMIN
	FirstName    string
	LastName     string
	AvatarURL    *string
	CreatedAt    time.Time
}

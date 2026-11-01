package auth

// User mirrors the `User` schema in 05-openapi.yaml.
type User struct {
	ID        int64  `json:"id"`
	Email     string `json:"email"`
	Role      string `json:"role"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	AvatarURL string `json:"avatar_url"`
}

type RefreshRequest struct {
	RefreshToken string `json:"refresh_token"`
}

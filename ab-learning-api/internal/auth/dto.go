package auth

// ---- Requests ----

// LoginRequest matches the `/auth/login` request body in 05-openapi.yaml.
type LoginRequest struct {
	Identifier string `json:"identifier"` // email or phone
	Password   string `json:"password"`
}

// RegisterRequest matches the `/auth/register` request body.
type RegisterRequest struct {
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	Email     string `json:"email"`
	Phone     string `json:"phone"`
	Password  string `json:"password"`
}

// ---- Responses ----

// UserResponse matches the `User` schema.
type UserResponse struct {
	ID        int64   `json:"id"`
	Email     string  `json:"email"`
	Role      string  `json:"role"`
	FirstName string  `json:"first_name"`
	LastName  string  `json:"last_name"`
	AvatarURL *string `json:"avatar_url"`
}

// AuthTokenResponse matches the `AuthTokenResponse` schema.
type AuthTokenResponse struct {
	AccessToken  string       `json:"access_token"`
	RefreshToken string       `json:"refresh_token"`
	User         UserResponse `json:"user"`
}

func toUserResponse(u User) UserResponse {
	return UserResponse{
		ID:        u.ID,
		Email:     u.Email,
		Role:      u.RoleCode,
		FirstName: u.FirstName,
		LastName:  u.LastName,
		AvatarURL: u.AvatarURL,
	}
}

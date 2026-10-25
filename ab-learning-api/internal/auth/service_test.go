package auth

import "testing"

func TestLoginRequiresCredentials(t *testing.T) {
	service := NewService(NewRepository(nil), "test-secret")

	_, err := service.Login(LoginRequest{Identifier: "", Password: ""})
	if err == nil {
		t.Fatal("expected validation error")
	}
}

func TestRegisterRequiresValidEmailAndPassword(t *testing.T) {
	service := NewService(NewRepository(nil), "test-secret")

	_, err := service.Register(RegisterRequest{Email: "bad-email", Password: "short"})
	if err == nil {
		t.Fatal("expected validation error")
	}
}

package auth

import (
	"errors"
	"strings"
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
)

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

func TestUpdateMeValidatesNames(t *testing.T) {
	service := NewService(NewRepository(nil), "test-secret")

	for _, req := range []UpdateProfileRequest{
		{FirstName: "", LastName: "Suksawat"},
		{FirstName: "Anan", LastName: "   "},
		{FirstName: strings.Repeat("ก", 101), LastName: "Suksawat"},
	} {
		if _, err := service.UpdateMe(1, req); !errors.Is(err, ErrValidation) {
			t.Fatalf("UpdateMe(%+v) = %v, want ErrValidation", req, err)
		}
	}
}

func TestUpdateMeSavesTrimmedNameAndReturnsUser(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()
	service := NewService(NewRepository(db), "test-secret")

	mock.ExpectExec("INSERT INTO profiles").
		WithArgs(int64(7), "Anan", "Suksawat").
		WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectQuery("SELECT u.id").
		WithArgs(int64(7)).
		WillReturnRows(sqlmock.NewRows([]string{"id", "email", "code", "first", "last", "avatar", "hash", "status"}).
			AddRow(int64(7), "a@x.test", "LEARNER", "Anan", "Suksawat", "", "h", "active"))

	u, err := service.UpdateMe(7, UpdateProfileRequest{FirstName: " Anan ", LastName: "Suksawat "})
	if err != nil {
		t.Fatalf("UpdateMe: %v", err)
	}
	if u.FirstName != "Anan" || u.LastName != "Suksawat" || u.Role != "LEARNER" {
		t.Fatalf("unexpected user: %+v", u)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatal(err)
	}
}

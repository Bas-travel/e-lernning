package auth

import (
	"errors"
	"testing"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
)

type fakeNotifier struct {
	otpEmail, otp     string
	resetEmail, reset string
}

func (f *fakeNotifier) SendOTP(email, code string) error {
	f.otpEmail, f.otp = email, code
	return nil
}

func (f *fakeNotifier) SendResetToken(email, token string) error {
	f.resetEmail, f.reset = email, token
	return nil
}

var userCols = []string{"id", "email", "code", "first", "last", "avatar", "hash", "status"}

func newMockService(t *testing.T) (*Service, sqlmock.Sqlmock) {
	t.Helper()
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { _ = db.Close() })
	return NewService(NewRepository(db), "test-secret"), mock
}

func TestDeliveryEndpointsAreUnavailableWithoutNotifier(t *testing.T) {
	svc := NewService(NewRepository(nil), "test-secret")
	if err := svc.ResendOTP(1); !errors.Is(err, ErrDeliveryUnavailable) {
		t.Fatalf("ResendOTP = %v, want ErrDeliveryUnavailable", err)
	}
	if err := svc.ForgotPassword("a@x.test"); !errors.Is(err, ErrDeliveryUnavailable) {
		t.Fatalf("ForgotPassword = %v, want ErrDeliveryUnavailable", err)
	}
}

func TestVerifyOTPRejectsMalformedCodeWithoutTouchingTheDatabase(t *testing.T) {
	svc := NewService(NewRepository(nil), "test-secret")
	for _, code := range []string{"", "123", "1234567", "   "} {
		if err := svc.VerifyOTP(5, code); !errors.Is(err, ErrInvalidCode) {
			t.Fatalf("VerifyOTP(%q) = %v, want ErrInvalidCode", code, err)
		}
	}
	if err := svc.VerifyOTP(0, "123456"); !errors.Is(err, ErrInvalidCode) {
		t.Fatalf("VerifyOTP(user 0) = %v, want ErrInvalidCode", err)
	}
}

func TestVerifyOTPConsumesCodeAndVerifiesEmail(t *testing.T) {
	svc, mock := newMockService(t)
	mock.ExpectBegin()
	mock.ExpectExec("UPDATE otp_verifications").
		WithArgs(sqlmock.AnyArg(), int64(5), "123456", "register", sqlmock.AnyArg()).
		WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectExec("UPDATE users SET email_verified_at").
		WithArgs(sqlmock.AnyArg(), int64(5)).
		WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectCommit()

	if err := svc.VerifyOTP(5, " 123456 "); err != nil {
		t.Fatalf("VerifyOTP: %v", err)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatal(err)
	}
}

func TestVerifyOTPWrongOrExpiredCode(t *testing.T) {
	svc, mock := newMockService(t)
	mock.ExpectBegin()
	mock.ExpectExec("UPDATE otp_verifications").
		WillReturnResult(sqlmock.NewResult(0, 0))
	mock.ExpectRollback()

	if err := svc.VerifyOTP(5, "000000"); !errors.Is(err, ErrInvalidCode) {
		t.Fatalf("VerifyOTP = %v, want ErrInvalidCode", err)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatal(err)
	}
}

func TestResendOTPIsThrottled(t *testing.T) {
	svc, mock := newMockService(t)
	svc.WithNotifier(&fakeNotifier{})
	mock.ExpectQuery("SELECT email_verified_at IS NOT NULL").
		WithArgs(int64(5)).
		WillReturnRows(sqlmock.NewRows([]string{"v"}).AddRow(false))
	mock.ExpectQuery("SELECT created_at FROM otp_verifications").
		WithArgs(int64(5), "register").
		WillReturnRows(sqlmock.NewRows([]string{"created_at"}).AddRow(time.Now().UTC()))

	if err := svc.ResendOTP(5); !errors.Is(err, ErrTooManyRequests) {
		t.Fatalf("ResendOTP = %v, want ErrTooManyRequests", err)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatal(err)
	}
}

func TestResendOTPIssuesAndDeliversANewCode(t *testing.T) {
	svc, mock := newMockService(t)
	n := &fakeNotifier{}
	svc.WithNotifier(n)
	mock.ExpectQuery("SELECT email_verified_at IS NOT NULL").
		WillReturnRows(sqlmock.NewRows([]string{"v"}).AddRow(false))
	mock.ExpectQuery("SELECT created_at FROM otp_verifications").
		WillReturnRows(sqlmock.NewRows([]string{"created_at"}).AddRow(time.Now().UTC().Add(-2 * time.Minute)))
	mock.ExpectQuery("SELECT u.id").
		WithArgs(int64(5)).
		WillReturnRows(sqlmock.NewRows(userCols).
			AddRow(int64(5), "a@x.test", "LEARNER", "A", "B", "", "h", "active"))
	mock.ExpectExec("INSERT INTO otp_verifications").
		WithArgs(int64(5), sqlmock.AnyArg(), "register", sqlmock.AnyArg()).
		WillReturnResult(sqlmock.NewResult(1, 1))

	if err := svc.ResendOTP(5); err != nil {
		t.Fatalf("ResendOTP: %v", err)
	}
	if n.otpEmail != "a@x.test" || len(n.otp) != 6 {
		t.Fatalf("notifier got %q / %q", n.otpEmail, n.otp)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatal(err)
	}
}

func TestForgotPasswordHidesUnknownAccounts(t *testing.T) {
	svc, mock := newMockService(t)
	n := &fakeNotifier{}
	svc.WithNotifier(n)
	mock.ExpectQuery("SELECT u.id").
		WithArgs("nobody@x.test").
		WillReturnRows(sqlmock.NewRows(userCols))

	if err := svc.ForgotPassword("Nobody@X.test "); err != nil {
		t.Fatalf("ForgotPassword: %v", err)
	}
	if n.reset != "" {
		t.Fatal("no token must be sent for an unknown e-mail")
	}
	if err := svc.ForgotPassword("not-an-email"); !errors.Is(err, ErrValidation) {
		t.Fatalf("ForgotPassword(invalid) = %v, want ErrValidation", err)
	}
}

func TestForgotPasswordStoresOnlyAHashOfTheToken(t *testing.T) {
	svc, mock := newMockService(t)
	n := &fakeNotifier{}
	svc.WithNotifier(n)
	mock.ExpectQuery("SELECT u.id").
		WithArgs("a@x.test").
		WillReturnRows(sqlmock.NewRows(userCols).
			AddRow(int64(5), "a@x.test", "LEARNER", "A", "B", "", "h", "active"))
	mock.ExpectExec("INSERT INTO password_resets").
		WithArgs(int64(5), sqlmock.AnyArg(), sqlmock.AnyArg()).
		WillReturnResult(sqlmock.NewResult(1, 1))

	if err := svc.ForgotPassword("a@x.test"); err != nil {
		t.Fatalf("ForgotPassword: %v", err)
	}
	if n.resetEmail != "a@x.test" || len(n.reset) != 64 {
		t.Fatalf("notifier got %q / %q", n.resetEmail, n.reset)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatal(err)
	}
}

func TestSavePreferencesAcceptsAppLabels(t *testing.T) {
	svc, mock := newMockService(t)
	mock.ExpectExec("INSERT INTO user_preferences").
		WithArgs(int64(7), []byte(`["AI","Data"]`), "beginner", "get_job").
		WillReturnResult(sqlmock.NewResult(1, 1))

	err := svc.SavePreferences(7, PreferencesRequest{
		Interests: []string{" AI ", "", "Data"},
		Level:     "Beginner",
		Goal:      "Get a Job",
	})
	if err != nil {
		t.Fatalf("SavePreferences: %v", err)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatal(err)
	}
}

func TestSavePreferencesValidates(t *testing.T) {
	svc := NewService(NewRepository(nil), "test-secret")
	for _, req := range []PreferencesRequest{
		{Level: "expert"},
		{Goal: "world domination"},
		{Interests: make([]string, 21)},
	} {
		if err := svc.SavePreferences(7, req); !errors.Is(err, ErrValidation) {
			t.Fatalf("SavePreferences(%+v) = %v, want ErrValidation", req, err)
		}
	}
}

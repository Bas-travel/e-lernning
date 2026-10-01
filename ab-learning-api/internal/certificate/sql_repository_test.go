package certificate

import (
	"context"
	"database/sql/driver"
	"errors"
	"regexp"
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
)

type certificateCodeMatcher struct{}

func (certificateCodeMatcher) Match(value driver.Value) bool {
	code, ok := value.(string)
	return ok && regexp.MustCompile(`^AB-[A-F0-9]{32}$`).MatchString(code)
}

func TestIssueForEnrollmentRequiresCompletedEnrollment(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()

	mock.ExpectQuery(regexp.QuoteMeta("SELECT status FROM enrollments WHERE id = ?")).
		WithArgs(int64(12)).WillReturnRows(sqlmock.NewRows([]string{"status"}).AddRow("in_progress"))

	_, err = NewSQLRepository(db).IssueForEnrollment(context.Background(), 12)
	if !errors.Is(err, ErrEnrollmentIncomplete) {
		t.Fatalf("expected incomplete enrollment error, got %v", err)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatal(err)
	}
}

func TestIssueForEnrollmentReturnsStableIDOnDuplicate(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()

	mock.ExpectQuery(regexp.QuoteMeta("SELECT status FROM enrollments WHERE id = ?")).
		WithArgs(int64(12)).WillReturnRows(sqlmock.NewRows([]string{"status"}).AddRow("completed"))
	mock.ExpectExec(regexp.QuoteMeta("INSERT INTO certificates (enrollment_id, certificate_code)\n\t\tVALUES (?, ?)\n\t\tON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id)")).
		WithArgs(int64(12), certificateCodeMatcher{}).
		WillReturnResult(sqlmock.NewResult(47, 1))

	id, err := NewSQLRepository(db).IssueForEnrollment(context.Background(), 12)
	if err != nil {
		t.Fatal(err)
	}
	if id != 47 {
		t.Fatalf("expected id 47, got %d", id)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatal(err)
	}
}
package learning

import (
	"context"
	"regexp"
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
)

func TestHasPaidForCourseChecksSettledPayment(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()

	query := `
		SELECT EXISTS (
			SELECT 1
			FROM orders o
			JOIN order_items oi ON oi.order_id = o.id
			JOIN payments p ON p.order_id = o.id
			WHERE o.user_id = ? AND oi.course_id = ?
			  AND o.status = 'paid' AND p.status = 'success'
		)`
	mock.ExpectQuery(regexp.QuoteMeta(query)).WithArgs(int64(9), int64(3)).
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(true))

	paid, err := NewRepository(db).HasPaidForCourse(context.Background(), 9, 3)
	if err != nil {
		t.Fatal(err)
	}
	if !paid {
		t.Fatal("expected settled course payment to grant access")
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatal(err)
	}
}

func TestIsEnrolledReturnsFalseWhenEnrollmentIsMissing(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()

	query := `SELECT ` + enrollmentCols + `
		FROM enrollments e
		WHERE e.user_id = ? AND e.course_id = ?
		LIMIT 1
	`
	mock.ExpectQuery(regexp.QuoteMeta(query)).WithArgs(int64(9), int64(3)).
		WillReturnRows(sqlmock.NewRows([]string{"id", "user_id", "course_id", "progress_pct", "status", "last_lesson_id", "enrolled_at", "completed_at"}))

	enrolled, err := NewRepository(db).IsEnrolled(context.Background(), 9, 3)
	if err != nil {
		t.Fatal(err)
	}
	if enrolled {
		t.Fatal("expected no enrollment")
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatal(err)
	}
}

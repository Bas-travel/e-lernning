package courses

import (
	"regexp"
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
)

func TestListTrimsQueryAndReturnsCatalogItems(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()

	query := courseSelect + " WHERE c.status = 'published' AND (c.title LIKE ? OR c.description LIKE ?) ORDER BY c.student_count DESC, c.id DESC LIMIT ? OFFSET ?"
	mock.ExpectQuery(regexp.QuoteMeta(query)).
		WithArgs("%Go%", "%Go%", 20, 0).
		WillReturnRows(sqlmock.NewRows([]string{
			"id", "title", "slug", "description", "thumbnail_url", "price", "discount_price",
			"rating_avg", "student_count", "level", "status", "category", "instructor_id", "instructor_name",
		}).AddRow(1, "Go Backend", "go-backend", "Course description", "", 25.0, nil, 4.8, 120, "beginner", "published", "engineering", 7, "Alex"))

	service := NewService(NewRepository(db))
	items, err := service.List(ListFilter{Query: " Go ", Limit: 20})
	if err != nil {
		t.Fatal(err)
	}
	if len(items) != 1 || items[0].Title != "Go Backend" || items[0].Instructor.DisplayName != "Alex" {
		t.Fatalf("unexpected catalog response: %#v", items)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatal(err)
	}
}

func TestGetReturnsNotFoundForMissingCourse(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()

	mock.ExpectQuery(regexp.QuoteMeta(courseSelect+" WHERE c.id = ? AND c.status = 'published'")) .
		WithArgs(int64(404)).WillReturnRows(sqlmock.NewRows([]string{
			"id", "title", "slug", "description", "thumbnail_url", "price", "discount_price",
			"rating_avg", "student_count", "level", "status", "category", "instructor_id", "instructor_name",
		}))

	service := NewService(NewRepository(db))
	_, err = service.Get(404)
	if err != ErrNotFound {
		t.Fatalf("expected ErrNotFound, got %v", err)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatal(err)
	}
}

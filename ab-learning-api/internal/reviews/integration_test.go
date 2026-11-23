package reviews

import (
	"context"
	"errors"
	"fmt"
	"os"
	"testing"
	"time"

	"github.com/ablearning/api/internal/database"
)

// Runs only when TEST_DB_DSN points at a disposable database.
func TestReviewsAgainstMySQL(t *testing.T) {
	dsn := os.Getenv("TEST_DB_DSN")
	if dsn == "" {
		t.Skip("TEST_DB_DSN not set; skipping MySQL reviews test")
	}
	if err := database.Migrate(dsn, "../../db/migrations"); err != nil {
		t.Fatalf("migrate: %v", err)
	}
	db, err := database.Open(dsn)
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()
	if err := database.SeedDev(db); err != nil {
		t.Fatalf("seed: %v", err)
	}

	mkUser := func(tag string) int64 {
		res, err := db.Exec(`INSERT INTO users (role_id, email, password_hash, status)
			SELECT id, ?, 'x', 'active' FROM roles WHERE code = 'learner'`,
			fmt.Sprintf("rev-%s-%d@example.test", tag, time.Now().UnixNano()))
		if err != nil {
			t.Fatal(err)
		}
		id, _ := res.LastInsertId()
		return id
	}
	a, b, outsider := mkUser("a"), mkUser("b"), mkUser("o")

	// A published course nobody has reviewed yet, so the maths is exact.
	var courseID int64
	if err := db.QueryRow(`SELECT c.id FROM courses c WHERE c.status = 'published'
		AND NOT EXISTS (SELECT 1 FROM reviews r WHERE r.course_id = c.id)
		ORDER BY c.id LIMIT 1`).Scan(&courseID); err != nil {
		t.Fatalf("no unreviewed published course: %v", err)
	}
	for _, u := range []int64{a, b} {
		if _, err := db.Exec(`INSERT INTO enrollments (user_id, course_id) VALUES (?, ?)`, u, courseID); err != nil {
			t.Fatal(err)
		}
	}

	svc := NewService(NewRepository(db))
	ctx := context.Background()

	if err := svc.Submit(ctx, outsider, courseID, 5, ""); !errors.Is(err, ErrNotEnrolled) {
		t.Fatalf("outsider: %v", err)
	}
	if err := svc.Submit(ctx, a, courseID, 5, "great"); err != nil {
		t.Fatal(err)
	}
	if err := svc.Submit(ctx, b, courseID, 3, ""); err != nil {
		t.Fatal(err)
	}
	if err := svc.Submit(ctx, b, courseID, 4, "better on second look"); err != nil {
		t.Fatalf("edit: %v", err)
	}

	p, err := svc.List(ctx, courseID, a, 10, 0)
	if err != nil {
		t.Fatal(err)
	}
	if p.RatingCnt != 2 || p.RatingAvg != 4.5 || len(p.Items) != 2 {
		t.Fatalf("summary = %+v", p)
	}
	mine := 0
	for _, it := range p.Items {
		if it.Mine {
			mine++
		}
	}
	if mine != 1 {
		t.Fatalf("exactly one review should be mine, got %d", mine)
	}

	var avg float64
	var cnt int
	if err := db.QueryRow(`SELECT rating_avg, rating_count FROM courses WHERE id = ?`, courseID).Scan(&avg, &cnt); err != nil {
		t.Fatal(err)
	}
	if cnt != 2 || avg != 4.5 {
		t.Fatalf("courses row = avg %v count %d, want 4.5 / 2", avg, cnt)
	}
}

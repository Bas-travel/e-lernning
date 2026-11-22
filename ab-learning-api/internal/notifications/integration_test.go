package notifications

import (
	"context"
	"fmt"
	"os"
	"testing"
	"time"

	"github.com/ablearning/api/internal/database"
)

// TestNotificationsAgainstMySQL exercises the real SQL. Runs only when
// TEST_DB_DSN points at a disposable database.
func TestNotificationsAgainstMySQL(t *testing.T) {
	dsn := os.Getenv("TEST_DB_DSN")
	if dsn == "" {
		t.Skip("TEST_DB_DSN not set; skipping MySQL notifications test")
	}
	if err := database.Migrate(dsn, "../../db/migrations"); err != nil {
		t.Fatalf("migrate: %v", err)
	}
	db, err := database.Open(dsn)
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()

	mkUser := func(tag string) int64 {
		res, err := db.Exec(`INSERT INTO users (role_id, email, password_hash, status)
			SELECT id, ?, 'x', 'active' FROM roles WHERE code = 'learner'`,
			fmt.Sprintf("notif-%s-%d@example.test", tag, time.Now().UnixNano()))
		if err != nil {
			t.Fatalf("create user: %v", err)
		}
		id, _ := res.LastInsertId()
		return id
	}
	a, b := mkUser("a"), mkUser("b")
	svc := NewService(NewRepository(db))
	ctx := context.Background()

	for i := 1; i <= 3; i++ {
		if err := svc.Notify(ctx, a, "order_paid", fmt.Sprintf("n%d", i), "body"); err != nil {
			t.Fatal(err)
		}
	}
	_ = svc.Notify(ctx, b, "order_paid", "other user", "")

	p, err := svc.List(ctx, a, false, 2, 0)
	if err != nil {
		t.Fatal(err)
	}
	if len(p.Items) != 2 || p.Unread != 3 || p.Items[0].Title != "n3" {
		t.Fatalf("page 1 = %+v", p)
	}
	p2, _ := svc.List(ctx, a, false, 2, 2)
	if len(p2.Items) != 1 || p2.Items[0].Title != "n1" {
		t.Fatalf("page 2 = %+v", p2)
	}
	if err := svc.MarkRead(ctx, b, p.Items[0].ID); err != ErrNotFound {
		t.Fatalf("other user's mark-read err = %v, want ErrNotFound", err)
	}
	if err := svc.MarkRead(ctx, a, p.Items[0].ID); err != nil {
		t.Fatal(err)
	}
	if err := svc.MarkRead(ctx, a, p.Items[0].ID); err != nil {
		t.Fatalf("repeat mark-read must succeed: %v", err)
	}
	n, err := svc.MarkAllRead(ctx, a)
	if err != nil || n != 2 {
		t.Fatalf("mark-all = %d, %v; want 2", n, err)
	}
	pb, _ := svc.List(ctx, b, true, 10, 0)
	if pb.Unread != 1 || len(pb.Items) != 1 {
		t.Fatalf("user b must be untouched: %+v", pb)
	}
}

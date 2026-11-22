package payments

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"os"
	"testing"
	"time"

	"github.com/ablearning/api/internal/database"
)

// TestPaymentsAgainstMySQL runs checkout, the signed webhook, replay
// protection and enrollment against a real, disposable MySQL. It only runs
// when TEST_DB_DSN is set (never point it at a shared or production DB).
func TestPaymentsAgainstMySQL(t *testing.T) {
	dsn := os.Getenv("TEST_DB_DSN")
	if dsn == "" {
		t.Skip("TEST_DB_DSN not set; skipping MySQL payments integration test")
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

	// A brand-new learner, so earlier test runs cannot already own the course.
	email := fmt.Sprintf("pay-test-%d@example.test", time.Now().UnixNano())
	res, err := db.Exec(`INSERT INTO users (role_id, email, password_hash, status)
		SELECT id, ?, 'x', 'active' FROM roles WHERE code = 'learner'`, email)
	if err != nil {
		t.Fatalf("create user: %v", err)
	}
	userID, _ := res.LastInsertId()

	var courseID int64
	if err := db.QueryRow(`SELECT id FROM courses
		WHERE status = 'published' AND COALESCE(discount_price, price) > 0 ORDER BY id LIMIT 1`).Scan(&courseID); err != nil {
		t.Fatalf("no paid published course in seed data: %v", err)
	}

	ctx := context.Background()
	provider := NewSandboxProvider("integration-test-secret")
	svc := NewService(NewRepository(db), provider)

	// 1. Checkout creates a pending order + payment.
	order, err := svc.Checkout(ctx, userID, "it-key-0001", CheckoutRequest{CourseIDs: []int64{courseID}, Method: "card"})
	if err != nil {
		t.Fatalf("checkout: %v", err)
	}
	if order.Status != "pending" || order.PaymentStatus != "pending" || order.GrandTotal <= 0 || len(order.Items) != 1 {
		t.Fatalf("unexpected new order %+v", order)
	}

	// 2. The same Idempotency-Key returns the same order.
	again, err := svc.Checkout(ctx, userID, "it-key-0001", CheckoutRequest{CourseIDs: []int64{courseID}, Method: "card"})
	if err != nil || again.Code != order.Code {
		t.Fatalf("idempotent retry: %v code=%v want %s", err, again, order.Code)
	}

	// 3. A signed "succeeded" webhook marks it paid and enrolls the learner.
	body := []byte(fmt.Sprintf(`{"id":"evt_it_1","type":"payment.succeeded","order_code":%q}`, order.Code))
	h := http.Header{}
	h.Set(SignatureHeader, provider.Sign(body, time.Now()))
	applied, err := svc.HandleWebhook(ctx, h, body)
	if err != nil || !applied {
		t.Fatalf("webhook: applied=%v err=%v", applied, err)
	}
	paid, err := svc.GetOrder(ctx, userID, order.Code)
	if err != nil || paid.Status != "paid" || paid.PaymentStatus != "success" {
		t.Fatalf("order after webhook: %+v err=%v", paid, err)
	}
	var enrolled int
	_ = db.QueryRow(`SELECT COUNT(*) FROM enrollments WHERE user_id = ? AND course_id = ?`, userID, courseID).Scan(&enrolled)
	if enrolled != 1 {
		t.Fatalf("expected 1 enrollment, got %d", enrolled)
	}

	// 4. Replaying the identical event changes nothing.
	applied, err = svc.HandleWebhook(ctx, h, body)
	if err != nil || applied {
		t.Fatalf("replay must be ignored: applied=%v err=%v", applied, err)
	}
	var notices int
	_ = db.QueryRow(`SELECT COUNT(*) FROM notifications WHERE user_id = ? AND type = 'order_paid'`, userID).Scan(&notices)
	if notices != 1 {
		t.Fatalf("expected exactly 1 order_paid notification after paid + replay, got %d", notices)
	}
	var events int
	_ = db.QueryRow(`SELECT COUNT(*) FROM payment_events WHERE provider = 'sandbox' AND event_id = 'evt_it_1'`).Scan(&events)
	if events != 1 {
		t.Fatalf("expected 1 stored event, got %d", events)
	}

	// 5. A forged signature is rejected.
	forged := http.Header{}
	forged.Set(SignatureHeader, "t=1,v1=00")
	if _, err := svc.HandleWebhook(ctx, forged, body); !errors.Is(err, ErrBadSignature) {
		t.Fatalf("forged signature accepted: %v", err)
	}

	// 6. The learner cannot buy the same course twice.
	if _, err := svc.Checkout(ctx, userID, "it-key-0002", CheckoutRequest{CourseIDs: []int64{courseID}, Method: "card"}); !errors.Is(err, ErrAlreadyOwned) {
		t.Fatalf("want ErrAlreadyOwned, got %v", err)
	}
}

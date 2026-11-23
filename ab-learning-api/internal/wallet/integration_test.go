package wallet

import (
	"context"
	"fmt"
	"os"
	"sync"
	"testing"
	"time"

	"github.com/ablearning/api/internal/database"
)

// Runs only when TEST_DB_DSN points at a disposable database.
func TestWalletAgainstMySQL(t *testing.T) {
	dsn := os.Getenv("TEST_DB_DSN")
	if dsn == "" {
		t.Skip("TEST_DB_DSN not set; skipping MySQL wallet test")
	}
	if err := database.Migrate(dsn, "../../db/migrations"); err != nil {
		t.Fatalf("migrate: %v", err)
	}
	db, err := database.Open(dsn)
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()

	res, err := db.Exec(`INSERT INTO users (role_id, email, password_hash, status)
		SELECT id, ?, 'x', 'active' FROM roles WHERE code = 'learner'`,
		fmt.Sprintf("wallet-%d@example.test", time.Now().UnixNano()))
	if err != nil {
		t.Fatal(err)
	}
	userID, _ := res.LastInsertId()
	svc := NewService(NewRepository(db), true)
	ctx := context.Background()

	if b, err := svc.Balance(ctx, userID); err != nil || b.CashBalance != 0 {
		t.Fatalf("new user balance = %+v, %v", b, err)
	}
	bal, applied, err := svc.SandboxTopup(ctx, userID, "it-key-0001", 100.50)
	if err != nil || !applied || bal.CashBalance != 100.5 {
		t.Fatalf("topup: %+v applied=%v err=%v", bal, applied, err)
	}
	bal, applied, err = svc.SandboxTopup(ctx, userID, "it-key-0001", 100.50)
	if err != nil || applied || bal.CashBalance != 100.5 {
		t.Fatalf("retry must not credit twice: %+v applied=%v err=%v", bal, applied, err)
	}

	// Ten concurrent top-ups with different keys must all land exactly once.
	var wg sync.WaitGroup
	for i := 0; i < 10; i++ {
		wg.Add(1)
		go func(i int) {
			defer wg.Done()
			if _, _, err := svc.SandboxTopup(ctx, userID, fmt.Sprintf("it-conc-%04d", i), 1.00); err != nil {
				t.Errorf("concurrent topup %d: %v", i, err)
			}
		}(i)
	}
	wg.Wait()
	b, _ := svc.Balance(ctx, userID)
	if b.CashBalance != 110.5 {
		t.Fatalf("balance after concurrent top-ups = %v, want 110.5", b.CashBalance)
	}

	page, err := svc.Transactions(ctx, userID, 100, 0)
	if err != nil || len(page.Items) != 11 {
		t.Fatalf("ledger rows = %d, %v; want 11", len(page.Items), err)
	}
	// Newest first; the oldest row is the 100.50 one and its running balance.
	last := page.Items[len(page.Items)-1]
	if last.Type != "topup" || last.Amount != 100.5 || last.BalanceAfter != 100.5 {
		t.Fatalf("oldest ledger row = %+v", last)
	}
	if page.Items[0].BalanceAfter != 110.5 {
		t.Fatalf("newest running balance = %v, want 110.5", page.Items[0].BalanceAfter)
	}
}

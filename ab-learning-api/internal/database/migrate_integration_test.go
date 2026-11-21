package database

import (
	"database/sql"
	"os"
	"testing"
)

// TestMigrateFromEmpty applies every migration to a real MySQL instance and
// then applies them again to prove idempotency. It only runs when
// TEST_DB_DSN points at a disposable, empty database (never production).
func TestMigrateFromEmpty(t *testing.T) {
	dsn := os.Getenv("TEST_DB_DSN")
	if dsn == "" {
		t.Skip("TEST_DB_DSN not set; skipping MySQL migration integration test")
	}
	dir := "../../db/migrations"

	if err := Migrate(dsn, dir); err != nil {
		t.Fatalf("first migrate: %v", err)
	}
	if err := Migrate(dsn, dir); err != nil {
		t.Fatalf("second migrate (idempotency): %v", err)
	}

	db, err := sql.Open("mysql", dsn)
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()

	var n int
	if err := db.QueryRow(`SELECT COUNT(*) FROM schema_migrations`).Scan(&n); err != nil {
		t.Fatal(err)
	}
	if n < 2 {
		t.Fatalf("expected >=2 recorded migrations, got %d", n)
	}
	for _, tbl := range []string{"users", "roles"} {
		var c int
		if err := db.QueryRow(`SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = ?`, tbl).Scan(&c); err != nil {
			t.Fatal(err)
		}
		if c != 1 {
			t.Errorf("expected table %s after migration", tbl)
		}
	}
}

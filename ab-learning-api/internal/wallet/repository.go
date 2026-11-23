package wallet

import (
	"context"
	"database/sql"
	"errors"
	"fmt"

	"github.com/go-sql-driver/mysql"
)

const mysqlDeadlock = 1213

// Topup retries when MySQL picks this transaction as a deadlock victim
// (possible only when two first-ever top-ups create the wallet together).
func (r *SQLRepository) Topup(ctx context.Context, userID int64, satang int64, key, reference string) (bool, Balance, error) {
	var applied bool
	var bal Balance
	var err error
	for attempt := 0; attempt < 3; attempt++ {
		applied, bal, err = r.topupOnce(ctx, userID, satang, key, reference)
		var me *mysql.MySQLError
		if !errors.As(err, &me) || me.Number != mysqlDeadlock {
			return applied, bal, err
		}
	}
	return applied, bal, err
}

type SQLRepository struct{ db *sql.DB }

func NewRepository(db *sql.DB) *SQLRepository { return &SQLRepository{db: db} }

func (r *SQLRepository) Balance(ctx context.Context, userID int64) (Balance, error) {
	var b Balance
	err := r.db.QueryRowContext(ctx,
		`SELECT COALESCE(coin_balance, 0), COALESCE(cash_balance, 0) FROM wallets WHERE user_id = ?`,
		userID).Scan(&b.CoinBalance, &b.CashBalance)
	if errors.Is(err, sql.ErrNoRows) {
		return Balance{}, nil // no wallet yet means an empty one
	}
	return b, err
}

func (r *SQLRepository) Transactions(ctx context.Context, userID int64, limit, offset int) ([]Transaction, error) {
	rows, err := r.db.QueryContext(ctx,
		`SELECT t.id, t.type, t.amount, t.balance_after, COALESCE(t.reference, ''), t.created_at
		   FROM wallet_transactions t JOIN wallets w ON w.id = t.wallet_id
		  WHERE w.user_id = ?
		  ORDER BY t.created_at DESC, t.id DESC LIMIT ? OFFSET ?`, userID, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("list wallet transactions: %w", err)
	}
	defer rows.Close()
	var out []Transaction
	for rows.Next() {
		var t Transaction
		if err := rows.Scan(&t.ID, &t.Type, &t.Amount, &t.BalanceAfter, &t.Reference, &t.CreatedAt); err != nil {
			return nil, err
		}
		out = append(out, t)
	}
	return out, rows.Err()
}

func satangString(s int64) string { return fmt.Sprintf("%d.%02d", s/100, s%100) }

func (r *SQLRepository) topupOnce(ctx context.Context, userID int64, satang int64, key, reference string) (bool, Balance, error) {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return false, Balance{}, err
	}
	defer func() { _ = tx.Rollback() }()

	// Lock the existing row first. Going straight to INSERT IGNORE would take
	// a shared lock on the duplicate and deadlock two concurrent top-ups.
	var walletID int64
	err = tx.QueryRowContext(ctx,
		`SELECT id FROM wallets WHERE user_id = ? FOR UPDATE`, userID).Scan(&walletID)
	if errors.Is(err, sql.ErrNoRows) {
		if _, err := tx.ExecContext(ctx, `INSERT IGNORE INTO wallets (user_id) VALUES (?)`, userID); err != nil {
			return false, Balance{}, fmt.Errorf("create wallet: %w", err)
		}
		err = tx.QueryRowContext(ctx,
			`SELECT id FROM wallets WHERE user_id = ? FOR UPDATE`, userID).Scan(&walletID)
	}
	if err != nil {
		return false, Balance{}, fmt.Errorf("lock wallet: %w", err)
	}

	// The wallet row is locked, so this check cannot race another top-up.
	var seen int
	err = tx.QueryRowContext(ctx,
		`SELECT 1 FROM wallet_transactions WHERE wallet_id = ? AND idempotency_key = ?`,
		walletID, key).Scan(&seen)
	if err == nil {
		bal, err := balanceTx(ctx, tx, walletID)
		return false, bal, err
	}
	if !errors.Is(err, sql.ErrNoRows) {
		return false, Balance{}, err
	}

	amount := satangString(satang)
	if _, err := tx.ExecContext(ctx,
		`UPDATE wallets SET cash_balance = cash_balance + ? WHERE id = ?`, amount, walletID); err != nil {
		return false, Balance{}, fmt.Errorf("credit wallet: %w", err)
	}
	if _, err := tx.ExecContext(ctx,
		`INSERT INTO wallet_transactions (wallet_id, type, amount, balance_after, reference, idempotency_key)
		 SELECT id, 'topup', ?, cash_balance, ?, ? FROM wallets WHERE id = ?`,
		amount, reference, key, walletID); err != nil {
		return false, Balance{}, fmt.Errorf("write ledger: %w", err)
	}
	bal, err := balanceTx(ctx, tx, walletID)
	if err != nil {
		return false, Balance{}, err
	}
	if err := tx.Commit(); err != nil {
		return false, Balance{}, err
	}
	return true, bal, nil
}

func balanceTx(ctx context.Context, tx *sql.Tx, walletID int64) (Balance, error) {
	var b Balance
	err := tx.QueryRowContext(ctx,
		`SELECT COALESCE(coin_balance, 0), COALESCE(cash_balance, 0) FROM wallets WHERE id = ?`,
		walletID).Scan(&b.CoinBalance, &b.CashBalance)
	return b, err
}

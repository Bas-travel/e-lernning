// Package wallet keeps a user's balance and its ledger. Money is handled as
// integer satang (1/100 baht) in Go and DECIMAL(12,2) in MySQL, never as a
// float, and every change is a ledger row written in the same transaction.
package wallet

import (
	"context"
	"errors"
	"fmt"
	"math"
	"time"
)

var (
	ErrInvalid  = errors.New("invalid request")
	ErrDisabled = errors.New("sandbox wallet top-ups are not enabled")
)

const (
	MaxTopupSatang = 5_000_000 // 50,000 baht per top-up
	DefaultLimit   = 20
	MaxLimit       = 100
)

type Balance struct {
	CoinBalance int64   `json:"coin_balance"`
	CashBalance float64 `json:"cash_balance"`
}

type Transaction struct {
	ID           int64     `json:"id"`
	Type         string    `json:"type"`
	Amount       float64   `json:"amount"`
	BalanceAfter float64   `json:"balance_after"`
	Reference    string    `json:"reference"`
	CreatedAt    time.Time `json:"created_at"`
}

type TransactionPage struct {
	Items  []Transaction `json:"items"`
	Limit  int           `json:"limit"`
	Offset int           `json:"offset"`
}

type Repository interface {
	Balance(ctx context.Context, userID int64) (Balance, error)
	Transactions(ctx context.Context, userID int64, limit, offset int) ([]Transaction, error)
	// Topup credits the wallet and appends a ledger row atomically. When the
	// key was used before, nothing changes and applied is false.
	Topup(ctx context.Context, userID int64, satang int64, key, reference string) (applied bool, bal Balance, err error)
}

// toSatang converts a JSON number of baht to satang, rejecting anything
// that is not an exact amount with at most two decimals.
func toSatang(baht float64) (int64, error) {
	if math.IsNaN(baht) || math.IsInf(baht, 0) || baht <= 0 {
		return 0, ErrInvalid
	}
	s := int64(math.Round(baht * 100))
	if math.Abs(baht*100-float64(s)) > 1e-6 {
		return 0, fmt.Errorf("%w: at most 2 decimals", ErrInvalid)
	}
	if s < 1 || s > MaxTopupSatang {
		return 0, fmt.Errorf("%w: amount must be between 0.01 and 50000", ErrInvalid)
	}
	return s, nil
}

func clampPaging(limit, offset int) (int, int) {
	if limit <= 0 {
		limit = DefaultLimit
	}
	if limit > MaxLimit {
		limit = MaxLimit
	}
	if offset < 0 {
		offset = 0
	}
	return limit, offset
}

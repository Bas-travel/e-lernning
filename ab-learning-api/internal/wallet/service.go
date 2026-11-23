package wallet

import (
	"context"
	"fmt"
	"strings"
)

type Service struct {
	repo          Repository
	sandboxTopups bool
}

// NewService enables the simulated top-up only while the payment mode is
// the sandbox; with real gateways it stays off until a gateway adapter
// exists.
func NewService(repo Repository, sandboxTopups bool) *Service {
	return &Service{repo: repo, sandboxTopups: sandboxTopups}
}

func (s *Service) Balance(ctx context.Context, userID int64) (Balance, error) {
	return s.repo.Balance(ctx, userID)
}

func (s *Service) Transactions(ctx context.Context, userID int64, limit, offset int) (*TransactionPage, error) {
	limit, offset = clampPaging(limit, offset)
	items, err := s.repo.Transactions(ctx, userID, limit, offset)
	if err != nil {
		return nil, err
	}
	if items == nil {
		items = []Transaction{}
	}
	return &TransactionPage{Items: items, Limit: limit, Offset: offset}, nil
}

func (s *Service) SandboxTopup(ctx context.Context, userID int64, key string, baht float64) (Balance, bool, error) {
	if !s.sandboxTopups {
		return Balance{}, false, ErrDisabled
	}
	key = strings.TrimSpace(key)
	if len(key) < 8 || len(key) > 80 {
		return Balance{}, false, fmt.Errorf("%w: Idempotency-Key header must be 8-80 characters", ErrInvalid)
	}
	satang, err := toSatang(baht)
	if err != nil {
		return Balance{}, false, err
	}
	applied, bal, err := s.repo.Topup(ctx, userID, satang, key, "sandbox top-up")
	return bal, applied, err
}

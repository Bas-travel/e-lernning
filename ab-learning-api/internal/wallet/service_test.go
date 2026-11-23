package wallet

import (
	"bytes"
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/ablearning/api/internal/platform"
)

func TestToSatang(t *testing.T) {
	good := map[float64]int64{0.01: 1, 1: 100, 100.5: 10050, 19.99: 1999, 50000: 5_000_000}
	for in, want := range good {
		got, err := toSatang(in)
		if err != nil || got != want {
			t.Errorf("toSatang(%v) = %d, %v; want %d", in, got, err, want)
		}
	}
	for _, in := range []float64{0, -5, 0.001, 1.005, 50000.01, 1e12} {
		if _, err := toSatang(in); !errors.Is(err, ErrInvalid) {
			t.Errorf("toSatang(%v) err = %v, want ErrInvalid", in, err)
		}
	}
}

type memRepo struct {
	satang int64
	keys   map[string]bool
	ledger int
}

func newMem() *memRepo { return &memRepo{keys: map[string]bool{}} }

func (m *memRepo) Balance(context.Context, int64) (Balance, error) {
	return Balance{CashBalance: float64(m.satang) / 100}, nil
}

func (m *memRepo) Transactions(context.Context, int64, int, int) ([]Transaction, error) {
	return nil, nil
}

func (m *memRepo) Topup(_ context.Context, _ int64, satang int64, key, _ string) (bool, Balance, error) {
	if m.keys[key] {
		b, _ := m.Balance(context.Background(), 0)
		return false, b, nil
	}
	m.keys[key] = true
	m.satang += satang
	m.ledger++
	b, _ := m.Balance(context.Background(), 0)
	return true, b, nil
}

func TestTopupIsIdempotentAndValidated(t *testing.T) {
	repo := newMem()
	svc := NewService(repo, true)
	ctx := context.Background()

	if _, _, err := svc.SandboxTopup(ctx, 1, "short", 10); !errors.Is(err, ErrInvalid) {
		t.Errorf("short key: %v", err)
	}
	if _, _, err := svc.SandboxTopup(ctx, 1, "key-00001", 0); !errors.Is(err, ErrInvalid) {
		t.Errorf("zero amount: %v", err)
	}
	bal, applied, err := svc.SandboxTopup(ctx, 1, "key-00001", 100.5)
	if err != nil || !applied || bal.CashBalance != 100.5 {
		t.Fatalf("first = %+v %v %v", bal, applied, err)
	}
	bal, applied, err = svc.SandboxTopup(ctx, 1, "key-00001", 100.5)
	if err != nil || applied || bal.CashBalance != 100.5 || repo.ledger != 1 {
		t.Fatalf("retry must not credit again: %+v %v %v ledger=%d", bal, applied, err, repo.ledger)
	}
}

func TestTopupDisabledOutsideSandbox(t *testing.T) {
	svc := NewService(newMem(), false)
	if _, _, err := svc.SandboxTopup(context.Background(), 1, "key-00001", 10); !errors.Is(err, ErrDisabled) {
		t.Fatalf("err = %v, want ErrDisabled", err)
	}
}

type fakeVerifier struct{}

func (fakeVerifier) Verify(tok string) (int64, string, error) {
	if tok == "u1" {
		return 1, "LEARNER", nil
	}
	return 0, "", errors.New("bad token")
}

func TestHTTP(t *testing.T) {
	mux := http.NewServeMux()
	NewHandler(NewService(newMem(), true)).RegisterRoutes(mux, platform.RequireAuth(fakeVerifier{}))
	srv := httptest.NewServer(mux)
	defer srv.Close()

	do := func(method, path, token, key, body string) int {
		req, _ := http.NewRequest(method, srv.URL+path, bytes.NewBufferString(body))
		req.Header.Set("Content-Type", "application/json")
		if token != "" {
			req.Header.Set("Authorization", "Bearer "+token)
		}
		if key != "" {
			req.Header.Set("Idempotency-Key", key)
		}
		resp, err := http.DefaultClient.Do(req)
		if err != nil {
			t.Fatal(err)
		}
		resp.Body.Close()
		return resp.StatusCode
	}
	checks := []struct {
		name string
		got  int
		want int
	}{
		{"anonymous balance", do("GET", "/api/v1/wallet", "", "", ""), 401},
		{"anonymous topup", do("POST", "/api/v1/wallet/sandbox/topup", "", "key-00001", `{"amount":5}`), 401},
		{"balance", do("GET", "/api/v1/wallet", "u1", "", ""), 200},
		{"transactions", do("GET", "/api/v1/wallet/transactions", "u1", "", ""), 200},
		{"topup without key", do("POST", "/api/v1/wallet/sandbox/topup", "u1", "", `{"amount":5}`), 400},
		{"topup bad amount", do("POST", "/api/v1/wallet/sandbox/topup", "u1", "key-00001", `{"amount":-5}`), 400},
		{"topup created", do("POST", "/api/v1/wallet/sandbox/topup", "u1", "key-00001", `{"amount":5}`), 201},
		{"topup replay", do("POST", "/api/v1/wallet/sandbox/topup", "u1", "key-00001", `{"amount":5}`), 200},
	}
	for _, c := range checks {
		if c.got != c.want {
			t.Errorf("%s: status %d, want %d", c.name, c.got, c.want)
		}
	}
}

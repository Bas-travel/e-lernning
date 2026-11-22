package notifications

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/ablearning/api/internal/platform"
)

// memRepo is an in-memory Repository that enforces per-user ownership the
// same way the SQL one does.
type memRepo struct {
	rows   []Notification
	owners map[int64]int64
	next   int64
}

func newMem() *memRepo { return &memRepo{owners: map[int64]int64{}} }

func (m *memRepo) Create(_ context.Context, userID int64, n Notification) error {
	m.next++
	n.ID = m.next
	m.rows = append(m.rows, n)
	m.owners[n.ID] = userID
	return nil
}

func (m *memRepo) List(_ context.Context, userID int64, unreadOnly bool, limit, offset int) ([]Notification, error) {
	var mine []Notification
	for i := len(m.rows) - 1; i >= 0; i-- { // newest first
		r := m.rows[i]
		if m.owners[r.ID] == userID && (!unreadOnly || !r.IsRead) {
			mine = append(mine, r)
		}
	}
	if offset >= len(mine) {
		return nil, nil
	}
	mine = mine[offset:]
	if limit < len(mine) {
		mine = mine[:limit]
	}
	return mine, nil
}

func (m *memRepo) CountUnread(_ context.Context, userID int64) (int, error) {
	n := 0
	for _, r := range m.rows {
		if m.owners[r.ID] == userID && !r.IsRead {
			n++
		}
	}
	return n, nil
}

func (m *memRepo) MarkRead(_ context.Context, userID, id int64) (bool, error) {
	for i := range m.rows {
		if m.rows[i].ID == id && m.owners[id] == userID {
			m.rows[i].IsRead = true
			return true, nil
		}
	}
	return false, nil
}

func (m *memRepo) MarkAllRead(_ context.Context, userID int64) (int64, error) {
	var n int64
	for i := range m.rows {
		if m.owners[m.rows[i].ID] == userID && !m.rows[i].IsRead {
			m.rows[i].IsRead = true
			n++
		}
	}
	return n, nil
}

func TestNotifyValidates(t *testing.T) {
	svc := NewService(newMem())
	ctx := context.Background()
	for name, c := range map[string]struct{ typ, title, body string }{
		"empty type":  {"", "t", ""},
		"empty title": {"order_paid", "  ", ""},
		"long title":  {"order_paid", strings.Repeat("ก", 201), ""},
		"long body":   {"order_paid", "ok", strings.Repeat("x", 501)},
		"long type":   {strings.Repeat("t", 51), "ok", ""},
	} {
		if err := svc.Notify(ctx, 1, c.typ, c.title, c.body); !errors.Is(err, ErrInvalid) {
			t.Errorf("%s: err = %v, want ErrInvalid", name, err)
		}
	}
	if err := svc.Notify(ctx, 1, "order_paid", "ชำระเงินสำเร็จ", "ขอบคุณ"); err != nil {
		t.Fatalf("valid notification rejected: %v", err)
	}
}

func TestListClampsPagingAndReturnsEmptySlice(t *testing.T) {
	svc := NewService(newMem())
	page, err := svc.List(context.Background(), 1, false, 9999, -5)
	if err != nil {
		t.Fatal(err)
	}
	if page.Limit != MaxLimit || page.Offset != 0 {
		t.Errorf("limit/offset = %d/%d, want %d/0", page.Limit, page.Offset, MaxLimit)
	}
	if page.Items == nil {
		t.Error("Items must be [] not null so clients can iterate")
	}
	page, _ = svc.List(context.Background(), 1, false, 0, 0)
	if page.Limit != DefaultLimit {
		t.Errorf("default limit = %d", page.Limit)
	}
}

func TestUsersOnlySeeAndChangeTheirOwn(t *testing.T) {
	repo := newMem()
	svc := NewService(repo)
	ctx := context.Background()
	_ = svc.Notify(ctx, 1, "a", "for user 1", "")
	_ = svc.Notify(ctx, 2, "a", "for user 2", "")

	if err := svc.MarkRead(ctx, 2, 1); !errors.Is(err, ErrNotFound) {
		t.Fatalf("user 2 marking user 1's row: err = %v, want ErrNotFound", err)
	}
	p, _ := svc.List(ctx, 1, false, 10, 0)
	if len(p.Items) != 1 || p.Items[0].Title != "for user 1" || p.Unread != 1 {
		t.Fatalf("user 1 page = %+v", p)
	}
	if err := svc.MarkRead(ctx, 1, 1); err != nil {
		t.Fatal(err)
	}
	if err := svc.MarkRead(ctx, 1, 1); err != nil { // idempotent
		t.Fatalf("second mark-read: %v", err)
	}
	p, _ = svc.List(ctx, 1, true, 10, 0)
	if len(p.Items) != 0 || p.Unread != 0 {
		t.Fatalf("unread filter after read = %+v", p)
	}
	if n, _ := svc.MarkAllRead(ctx, 1); n != 0 {
		t.Errorf("mark-all with nothing unread updated %d", n)
	}
}

type fakeVerifier struct{}

func (fakeVerifier) Verify(tok string) (int64, string, error) {
	switch tok {
	case "u1":
		return 1, "LEARNER", nil
	case "u2":
		return 2, "LEARNER", nil
	}
	return 0, "", errors.New("bad token")
}

func newServer(t *testing.T) (*httptest.Server, *Service) {
	t.Helper()
	svc := NewService(newMem())
	mux := http.NewServeMux()
	NewHandler(svc).RegisterRoutes(mux, platform.RequireAuth(fakeVerifier{}))
	srv := httptest.NewServer(mux)
	t.Cleanup(srv.Close)
	return srv, svc
}

func do(t *testing.T, srv *httptest.Server, method, path, token string) (int, map[string]any) {
	t.Helper()
	req, _ := http.NewRequest(method, srv.URL+path, nil)
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	defer resp.Body.Close()
	var body map[string]any
	_ = json.NewDecoder(resp.Body).Decode(&body)
	return resp.StatusCode, body
}

func TestHTTPRequiresAuthAndIsolatesUsers(t *testing.T) {
	srv, svc := newServer(t)
	_ = svc.Notify(context.Background(), 1, "order_paid", "paid", "")

	if code, _ := do(t, srv, "GET", "/api/v1/notifications", ""); code != http.StatusUnauthorized {
		t.Errorf("no token: %d", code)
	}
	code, body := do(t, srv, "GET", "/api/v1/notifications", "u1")
	if code != 200 || body["unread"].(float64) != 1 {
		t.Fatalf("u1 list: %d %v", code, body)
	}
	if code, _ := do(t, srv, "POST", "/api/v1/notifications/1/read", "u2"); code != http.StatusNotFound {
		t.Errorf("u2 reading u1's notification: %d, want 404", code)
	}
	if code, _ := do(t, srv, "POST", "/api/v1/notifications/abc/read", "u1"); code != http.StatusBadRequest {
		t.Errorf("bad id: %d, want 400", code)
	}
	if code, _ := do(t, srv, "POST", "/api/v1/notifications/1/read", "u1"); code != 200 {
		t.Errorf("u1 mark read: %d", code)
	}
	code, body = do(t, srv, "POST", "/api/v1/notifications/read-all", "u1")
	if code != 200 || body["updated"].(float64) != 0 {
		t.Errorf("read-all: %d %v", code, body)
	}
}

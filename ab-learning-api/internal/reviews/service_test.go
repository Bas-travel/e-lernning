package reviews

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/ablearning/api/internal/platform"
)

type memRepo struct {
	published map[int64]bool
	enrolled  map[[2]int64]bool
	reviews   map[[2]int64]Review // key: course, user
	nextID    int64
}

func newMem() *memRepo {
	return &memRepo{
		published: map[int64]bool{1: true},
		enrolled:  map[[2]int64]bool{{10, 1}: true},
		reviews:   map[[2]int64]Review{},
	}
}

func (m *memRepo) CourseExists(_ context.Context, id int64) (bool, error) {
	return m.published[id], nil
}

func (m *memRepo) Enrolled(_ context.Context, u, c int64) (bool, error) {
	return m.enrolled[[2]int64{u, c}], nil
}

func (m *memRepo) Upsert(_ context.Context, c, u int64, rating int, comment string) error {
	k := [2]int64{c, u}
	v, ok := m.reviews[k]
	if !ok {
		m.nextID++
		v.ID = m.nextID
	}
	v.Rating, v.Comment = rating, comment
	m.reviews[k] = v
	return nil
}

func (m *memRepo) List(_ context.Context, c, viewer int64, limit, offset int) ([]Review, error) {
	var out []Review
	for k, v := range m.reviews {
		if k[0] == c {
			v.Mine = k[1] == viewer
			out = append(out, v)
		}
	}
	return out, nil
}

func (m *memRepo) Summary(_ context.Context, c int64) (float64, int, error) {
	sum, n := 0, 0
	for k, v := range m.reviews {
		if k[0] == c {
			sum += v.Rating
			n++
		}
	}
	if n == 0 {
		return 0, 0, nil
	}
	return float64(sum) / float64(n), n, nil
}

func TestSubmitRules(t *testing.T) {
	svc := NewService(newMem())
	ctx := context.Background()
	for _, rating := range []int{0, 6, -1} {
		if err := svc.Submit(ctx, 10, 1, rating, ""); !errors.Is(err, ErrInvalid) {
			t.Errorf("rating %d: err = %v, want ErrInvalid", rating, err)
		}
	}
	if err := svc.Submit(ctx, 10, 1, 5, strings.Repeat("ก", MaxComment+1)); !errors.Is(err, ErrInvalid) {
		t.Errorf("long comment: %v", err)
	}
	if err := svc.Submit(ctx, 10, 99, 5, ""); !errors.Is(err, ErrCourseNotFound) {
		t.Errorf("unknown course: %v", err)
	}
	if err := svc.Submit(ctx, 11, 1, 5, ""); !errors.Is(err, ErrNotEnrolled) {
		t.Errorf("not enrolled: %v", err)
	}
	if err := svc.Submit(ctx, 10, 1, 4, "  ดีมาก  "); err != nil {
		t.Fatalf("valid review: %v", err)
	}
}

func TestResubmitEditsInsteadOfDuplicating(t *testing.T) {
	svc := NewService(newMem())
	ctx := context.Background()
	_ = svc.Submit(ctx, 10, 1, 3, "ok")
	_ = svc.Submit(ctx, 10, 1, 5, "better")
	p, err := svc.List(ctx, 1, 10, 0, 0)
	if err != nil {
		t.Fatal(err)
	}
	if p.RatingCnt != 1 || p.RatingAvg != 5 || len(p.Items) != 1 || !p.Items[0].Mine {
		t.Fatalf("page = %+v", p)
	}
	if p.Items[0].Comment != "better" {
		t.Errorf("comment = %q", p.Items[0].Comment)
	}
	if p.Limit != DefaultLimit {
		t.Errorf("limit = %d", p.Limit)
	}
}

type fakeVerifier struct{}

func (fakeVerifier) Verify(tok string) (int64, string, error) {
	switch tok {
	case "u10":
		return 10, "LEARNER", nil
	case "u11":
		return 11, "LEARNER", nil
	}
	return 0, "", errors.New("bad token")
}

func call(t *testing.T, srv *httptest.Server, method, path, token, body string) int {
	t.Helper()
	req, _ := http.NewRequest(method, srv.URL+path, bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	defer resp.Body.Close()
	if method == "GET" && resp.StatusCode == 200 {
		var p Page
		if err := json.NewDecoder(resp.Body).Decode(&p); err != nil || p.Items == nil {
			t.Errorf("list body: %v items=%v", err, p.Items)
		}
	}
	return resp.StatusCode
}

func TestHTTPStatusCodes(t *testing.T) {
	mux := http.NewServeMux()
	NewHandler(NewService(newMem())).RegisterRoutes(mux, platform.RequireAuth(fakeVerifier{}))
	srv := httptest.NewServer(mux)
	defer srv.Close()
	p := "/api/v1/courses/1/reviews"

	cases := []struct {
		name, method, path, token, body string
		want                            int
	}{
		{"anonymous list", "GET", p, "", "", 401},
		{"anonymous post", "POST", p, "", `{"rating":5}`, 401},
		{"bad course id", "GET", "/api/v1/courses/x/reviews", "u10", "", 400},
		{"unknown course", "GET", "/api/v1/courses/99/reviews", "u10", "", 404},
		{"bad rating", "POST", p, "u10", `{"rating":9}`, 400},
		{"not enrolled", "POST", p, "u11", `{"rating":5}`, 403},
		{"enrolled ok", "POST", p, "u10", `{"rating":5,"comment":"great"}`, 200},
		{"list ok", "GET", p, "u11", "", 200},
	}
	for _, c := range cases {
		if got := call(t, srv, c.method, c.path, c.token, c.body); got != c.want {
			t.Errorf("%s: status %d, want %d", c.name, got, c.want)
		}
	}
}

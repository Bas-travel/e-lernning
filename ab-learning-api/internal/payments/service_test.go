package payments

import (
	"context"
	"errors"
	"net/http"
	"testing"
	"time"
)

// fakeRepo is an in-memory Repository.
type fakeRepo struct {
	courses map[int64]CourseLine
	owned   map[int64]bool
	coupons map[string]*Coupon
	orders  map[string]*Order // by code
	byKey   map[string]string // idempotency key -> code
	events  map[string]bool
	created int
	applied int
	items   map[string][]CourseLine
}

func newFakeRepo() *fakeRepo {
	return &fakeRepo{
		courses: map[int64]CourseLine{
			1: {ID: 1, Title: "Go", Price: 1000, Status: "published"},
			2: {ID: 2, Title: "SQL", Price: 500, Status: "published"},
			3: {ID: 3, Title: "Free", Price: 0, Status: "published"},
			4: {ID: 4, Title: "Draft", Price: 100, Status: "draft"},
		},
		owned: map[int64]bool{}, coupons: map[string]*Coupon{},
		orders: map[string]*Order{}, byKey: map[string]string{},
		events: map[string]bool{}, items: map[string][]CourseLine{},
	}
}

func (f *fakeRepo) CoursesForSale(_ context.Context, ids []int64) ([]CourseLine, error) {
	var out []CourseLine
	for _, id := range ids {
		if c, ok := f.courses[id]; ok {
			out = append(out, c)
		}
	}
	return out, nil
}
func (f *fakeRepo) OwnedCourses(_ context.Context, _ int64, ids []int64) ([]int64, error) {
	var out []int64
	for _, id := range ids {
		if f.owned[id] {
			out = append(out, id)
		}
	}
	return out, nil
}
func (f *fakeRepo) FindCoupon(_ context.Context, code string) (*Coupon, error) {
	if c, ok := f.coupons[code]; ok {
		return c, nil
	}
	return nil, ErrBadCoupon
}
func (f *fakeRepo) FindOrderByIdempotency(_ context.Context, _ int64, key string) (*Order, error) {
	if code, ok := f.byKey[key]; ok {
		return f.orders[code], nil
	}
	return nil, nil
}
func (f *fakeRepo) CreateOrder(_ context.Context, n NewOrder) error {
	f.created++
	f.byKey[n.IdempotencyKey] = n.Code
	f.items[n.Code] = n.Items
	f.orders[n.Code] = &Order{
		Code: n.Code, UserID: n.UserID, Status: "pending", Subtotal: n.Subtotal,
		DiscountTotal: n.Discount, GrandTotal: n.Grand, Method: n.Method, PaymentStatus: "pending",
	}
	return nil
}
func (f *fakeRepo) GetOrder(_ context.Context, userID int64, code string) (*Order, error) {
	o, ok := f.orders[code]
	if !ok || o.UserID != userID {
		return nil, ErrOrderNotFound
	}
	cp := *o
	return &cp, nil
}
func (f *fakeRepo) ListOrders(context.Context, int64) ([]Order, error) { return nil, nil }
func (f *fakeRepo) ApplyEvent(_ context.Context, provider string, ev Event, _ []byte) (bool, error) {
	key := provider + "/" + ev.ID
	if f.events[key] {
		return false, nil
	}
	f.events[key] = true
	o, ok := f.orders[ev.OrderCode]
	if !ok {
		return false, ErrOrderNotFound
	}
	if o.Status == "pending" {
		f.applied++
		if ev.Type == EventSucceeded {
			o.Status, o.PaymentStatus = "paid", "success"
			for _, l := range f.items[o.Code] {
				f.owned[l.ID] = true
			}
		} else {
			o.Status, o.PaymentStatus = "failed", "failed"
		}
	}
	return true, nil
}

func newSvc(repo *fakeRepo) (*Service, *SandboxProvider) {
	p := NewSandboxProvider("test-secret")
	s := NewService(repo, p)
	s.now = func() time.Time { return time.Unix(1_800_000_000, 0) }
	return s, p
}

func TestCheckoutPricing(t *testing.T) {
	repo := newFakeRepo()
	repo.coupons["TEN"] = &Coupon{ID: 9, Code: "TEN", Type: "percent", Value: 10}
	repo.coupons["ONLYSQL"] = &Coupon{ID: 10, Code: "ONLYSQL", Type: "fixed", Value: 9999, CourseID: ptr(int64(2))}
	svc, _ := newSvc(repo)
	ctx := context.Background()

	o, err := svc.Checkout(ctx, 1, "key-aaaaaaaa", CheckoutRequest{CourseIDs: []int64{1, 2}, Method: "card", CouponCode: "TEN"})
	if err != nil {
		t.Fatal(err)
	}
	if o.Subtotal != 1500 || o.DiscountTotal != 150 || o.GrandTotal != 1350 || o.Status != "pending" {
		t.Fatalf("unexpected totals %+v", o)
	}

	// A fixed coupon is capped by the eligible course's price.
	o, err = svc.Checkout(ctx, 1, "key-bbbbbbbb", CheckoutRequest{CourseIDs: []int64{1, 2}, Method: "card", CouponCode: "ONLYSQL"})
	if err != nil {
		t.Fatal(err)
	}
	if o.DiscountTotal != 500 || o.GrandTotal != 1000 {
		t.Fatalf("fixed coupon not capped: %+v", o)
	}
}

func TestCheckoutIsIdempotent(t *testing.T) {
	repo := newFakeRepo()
	svc, _ := newSvc(repo)
	ctx := context.Background()
	req := CheckoutRequest{CourseIDs: []int64{1}, Method: "promptpay"}

	a, err := svc.Checkout(ctx, 1, "same-key-1", req)
	if err != nil {
		t.Fatal(err)
	}
	b, err := svc.Checkout(ctx, 1, "same-key-1", req)
	if err != nil {
		t.Fatal(err)
	}
	if a.Code != b.Code || repo.created != 1 {
		t.Fatalf("retry created a second order: %s vs %s (created=%d)", a.Code, b.Code, repo.created)
	}
}

func TestCheckoutValidation(t *testing.T) {
	repo := newFakeRepo()
	repo.owned[2] = true
	repo.coupons["OLD"] = &Coupon{ID: 1, Code: "OLD", Type: "percent", Value: 10, ExpiresAt: ptr(time.Unix(1_700_000_000, 0))}
	repo.coupons["USED"] = &Coupon{ID: 2, Code: "USED", Type: "percent", Value: 10, MaxUses: ptr(1), UsedCount: 1}
	svc, _ := newSvc(repo)
	ctx := context.Background()

	cases := []struct {
		name string
		key  string
		req  CheckoutRequest
		want error
	}{
		{"short key", "x", CheckoutRequest{CourseIDs: []int64{1}, Method: "card"}, ErrInvalidRequest},
		{"bad method", "key-12345678", CheckoutRequest{CourseIDs: []int64{1}, Method: "bitcoin"}, ErrInvalidRequest},
		{"no courses", "key-12345678", CheckoutRequest{Method: "card"}, ErrInvalidRequest},
		{"unknown course", "key-12345678", CheckoutRequest{CourseIDs: []int64{99}, Method: "card"}, ErrCourseUnavailable},
		{"unpublished course", "key-12345678", CheckoutRequest{CourseIDs: []int64{4}, Method: "card"}, ErrCourseUnavailable},
		{"already owned", "key-12345678", CheckoutRequest{CourseIDs: []int64{2}, Method: "card"}, ErrAlreadyOwned},
		{"expired coupon", "key-12345678", CheckoutRequest{CourseIDs: []int64{1}, Method: "card", CouponCode: "OLD"}, ErrBadCoupon},
		{"exhausted coupon", "key-12345678", CheckoutRequest{CourseIDs: []int64{1}, Method: "card", CouponCode: "USED"}, ErrBadCoupon},
		{"unknown coupon", "key-12345678", CheckoutRequest{CourseIDs: []int64{1}, Method: "card", CouponCode: "NOPE"}, ErrBadCoupon},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			if _, err := svc.Checkout(ctx, 1, c.key, c.req); !errors.Is(err, c.want) {
				t.Fatalf("want %v, got %v", c.want, err)
			}
		})
	}
}

func TestFreeOrderCompletesImmediately(t *testing.T) {
	repo := newFakeRepo()
	svc, _ := newSvc(repo)
	o, err := svc.Checkout(context.Background(), 1, "free-key-1", CheckoutRequest{CourseIDs: []int64{3}, Method: "card"})
	if err != nil {
		t.Fatal(err)
	}
	if o.Status != "paid" || !repo.owned[3] {
		t.Fatalf("free order not completed: %+v owned=%v", o, repo.owned)
	}
}

func TestWebhookIsIdempotentAndEnrolls(t *testing.T) {
	repo := newFakeRepo()
	svc, p := newSvc(repo)
	ctx := context.Background()
	o, _ := svc.Checkout(ctx, 1, "key-webhook", CheckoutRequest{CourseIDs: []int64{1}, Method: "card"})

	body := []byte(`{"id":"evt_1","type":"payment.succeeded","order_code":"` + o.Code + `"}`)
	h := http.Header{}
	h.Set(SignatureHeader, p.Sign(body, svc.now()))

	applied, err := svc.HandleWebhook(ctx, h, body)
	if err != nil || !applied {
		t.Fatalf("first delivery: applied=%v err=%v", applied, err)
	}
	applied, err = svc.HandleWebhook(ctx, h, body) // replay
	if err != nil || applied {
		t.Fatalf("replay must be ignored: applied=%v err=%v", applied, err)
	}
	if repo.applied != 1 || !repo.owned[1] {
		t.Fatalf("state changed %d times, owned=%v", repo.applied, repo.owned)
	}
}

func TestWebhookRejectsBadSignature(t *testing.T) {
	repo := newFakeRepo()
	svc, _ := newSvc(repo)
	h := http.Header{}
	h.Set(SignatureHeader, "t=1800000000,v1=deadbeef")
	if _, err := svc.HandleWebhook(context.Background(), h, []byte(`{}`)); !errors.Is(err, ErrBadSignature) {
		t.Fatalf("want ErrBadSignature, got %v", err)
	}
}

func TestSandboxCompleteSuccessFailureAndOwnership(t *testing.T) {
	repo := newFakeRepo()
	svc, _ := newSvc(repo)
	ctx := context.Background()

	ok, _ := svc.Checkout(ctx, 1, "key-success", CheckoutRequest{CourseIDs: []int64{1}, Method: "card"})
	if _, err := svc.SandboxComplete(ctx, 2, ok.Code, true); !errors.Is(err, ErrOrderNotFound) {
		t.Fatalf("another user must not complete my order: %v", err)
	}
	done, err := svc.SandboxComplete(ctx, 1, ok.Code, true)
	if err != nil || done.Status != "paid" || !repo.owned[1] {
		t.Fatalf("success path: %+v err=%v", done, err)
	}
	if _, err := svc.SandboxComplete(ctx, 1, ok.Code, true); !errors.Is(err, ErrNotPending) {
		t.Fatalf("completing twice must fail: %v", err)
	}

	bad, _ := svc.Checkout(ctx, 1, "key-failure", CheckoutRequest{CourseIDs: []int64{2}, Method: "card"})
	failed, err := svc.SandboxComplete(ctx, 1, bad.Code, false)
	if err != nil || failed.Status != "failed" || repo.owned[2] {
		t.Fatalf("failure path: %+v owned=%v err=%v", failed, repo.owned, err)
	}
}

func ptr[T any](v T) *T { return &v }

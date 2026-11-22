package payments

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"math"
	"net/http"
	"strings"
	"time"
)

var (
	ErrInvalidRequest    = errors.New("invalid checkout request")
	ErrCourseUnavailable = errors.New("a course is not available for purchase")
	ErrAlreadyOwned      = errors.New("you already own one of these courses")
	ErrBadCoupon         = errors.New("coupon is invalid, expired or not applicable")
	ErrOrderNotFound     = errors.New("order not found")
	ErrNotPending        = errors.New("order is not awaiting payment")
	ErrNotSandbox        = errors.New("sandbox payments are not enabled")
	// ErrDuplicateOrder is returned by the repository when the idempotency
	// key (or order code) already exists.
	ErrDuplicateOrder = errors.New("duplicate order")
)

// Repository is the persistence the service needs.
type Repository interface {
	CoursesForSale(ctx context.Context, ids []int64) ([]CourseLine, error)
	OwnedCourses(ctx context.Context, userID int64, ids []int64) ([]int64, error)
	FindCoupon(ctx context.Context, code string) (*Coupon, error)
	FindOrderByIdempotency(ctx context.Context, userID int64, key string) (*Order, error)
	CreateOrder(ctx context.Context, n NewOrder) error
	GetOrder(ctx context.Context, userID int64, code string) (*Order, error)
	ListOrders(ctx context.Context, userID int64) ([]Order, error)
	// ApplyEvent records the event and updates payment/order/enrollments in
	// one transaction. applied=false means the event id was seen before.
	ApplyEvent(ctx context.Context, provider string, ev Event, raw []byte) (applied bool, err error)
}

type Service struct {
	repo     Repository
	provider Provider
	now      func() time.Time
}

func NewService(repo Repository, provider Provider) *Service {
	return &Service{repo: repo, provider: provider, now: time.Now}
}

func (s *Service) Checkout(ctx context.Context, userID int64, idemKey string, req CheckoutRequest) (*Order, error) {
	idemKey = strings.TrimSpace(idemKey)
	if len(idemKey) < 8 || len(idemKey) > 80 {
		return nil, fmt.Errorf("%w: Idempotency-Key header must be 8-80 characters", ErrInvalidRequest)
	}
	if req.Method != "promptpay" && req.Method != "card" {
		return nil, fmt.Errorf("%w: method must be promptpay or card", ErrInvalidRequest)
	}
	ids := dedupe(req.CourseIDs)
	if len(ids) == 0 || len(ids) > 10 {
		return nil, fmt.Errorf("%w: choose between 1 and 10 courses", ErrInvalidRequest)
	}

	// A retry with the same key returns the original order, never a new one.
	if o, err := s.repo.FindOrderByIdempotency(ctx, userID, idemKey); err != nil {
		return nil, err
	} else if o != nil {
		return o, nil
	}

	lines, err := s.repo.CoursesForSale(ctx, ids)
	if err != nil {
		return nil, err
	}
	if len(lines) != len(ids) {
		return nil, ErrCourseUnavailable
	}
	var subtotal float64
	for _, l := range lines {
		if l.Status != "published" {
			return nil, ErrCourseUnavailable
		}
		subtotal += l.Price
	}
	owned, err := s.repo.OwnedCourses(ctx, userID, ids)
	if err != nil {
		return nil, err
	}
	if len(owned) > 0 {
		return nil, ErrAlreadyOwned
	}

	var couponID *int64
	var discount float64
	if code := strings.TrimSpace(req.CouponCode); code != "" {
		c, err := s.repo.FindCoupon(ctx, code)
		if err != nil {
			return nil, err
		}
		discount, err = couponDiscount(c, lines, s.now())
		if err != nil {
			return nil, err
		}
		couponID = &c.ID
	}
	subtotal = round2(subtotal)
	grand := round2(subtotal - discount)

	orderCode, err := newOrderCode(s.now())
	if err != nil {
		return nil, err
	}
	ref, err := s.provider.CreatePayment(orderCode, grand)
	if err != nil {
		return nil, fmt.Errorf("create payment: %w", err)
	}
	err = s.repo.CreateOrder(ctx, NewOrder{
		UserID: userID, Code: orderCode, IdempotencyKey: idemKey, CouponID: couponID,
		Subtotal: subtotal, Discount: discount, Grand: grand, Method: req.Method,
		Provider: s.provider.Name(), ProviderRef: ref, Items: lines,
	})
	if errors.Is(err, ErrDuplicateOrder) {
		// Lost a race with a concurrent identical request.
		if o, ferr := s.repo.FindOrderByIdempotency(ctx, userID, idemKey); ferr == nil && o != nil {
			return o, nil
		}
	}
	if err != nil {
		return nil, err
	}

	if grand == 0 { // nothing to charge: complete immediately
		ev := Event{ID: "free-" + orderCode, Type: EventSucceeded, OrderCode: orderCode}
		if _, err := s.repo.ApplyEvent(ctx, s.provider.Name(), ev, []byte("{}")); err != nil {
			return nil, err
		}
	}
	return s.repo.GetOrder(ctx, userID, orderCode)
}

func (s *Service) GetOrder(ctx context.Context, userID int64, code string) (*Order, error) {
	return s.repo.GetOrder(ctx, userID, code)
}

func (s *Service) ListOrders(ctx context.Context, userID int64) ([]Order, error) {
	return s.repo.ListOrders(ctx, userID)
}

// HandleWebhook authenticates a provider callback and applies it. It is safe
// to call repeatedly with the same event.
func (s *Service) HandleWebhook(ctx context.Context, h http.Header, body []byte) (applied bool, err error) {
	ev, err := s.provider.ParseWebhook(h, body, s.now())
	if err != nil {
		return false, err
	}
	return s.repo.ApplyEvent(ctx, s.provider.Name(), ev, body)
}

// SandboxComplete simulates the gateway calling back for the caller's own
// pending order. The event is signed and goes through HandleWebhook, so the
// real verification path is exercised.
func (s *Service) SandboxComplete(ctx context.Context, userID int64, code string, success bool) (*Order, error) {
	sp, ok := s.provider.(*SandboxProvider)
	if !ok {
		return nil, ErrNotSandbox
	}
	o, err := s.repo.GetOrder(ctx, userID, code)
	if err != nil {
		return nil, err
	}
	if o.Status != "pending" {
		return nil, ErrNotPending
	}
	id, err := randomHex(12)
	if err != nil {
		return nil, err
	}
	typ := EventFailed
	if success {
		typ = EventSucceeded
	}
	body, _ := json.Marshal(map[string]string{"id": "evt_" + id, "type": typ, "order_code": code})
	h := http.Header{}
	h.Set(SignatureHeader, sp.Sign(body, s.now()))
	if _, err := s.HandleWebhook(ctx, h, body); err != nil {
		return nil, err
	}
	return s.repo.GetOrder(ctx, userID, code)
}

func couponDiscount(c *Coupon, lines []CourseLine, now time.Time) (float64, error) {
	if c == nil {
		return 0, ErrBadCoupon
	}
	if c.ExpiresAt != nil && !c.ExpiresAt.After(now) {
		return 0, ErrBadCoupon
	}
	if c.MaxUses != nil && c.UsedCount >= *c.MaxUses {
		return 0, ErrBadCoupon
	}
	var eligible float64
	for _, l := range lines {
		if c.CourseID == nil || *c.CourseID == l.ID {
			eligible += l.Price
		}
	}
	if eligible <= 0 {
		return 0, ErrBadCoupon
	}
	var d float64
	switch c.Type {
	case "percent":
		d = eligible * math.Min(c.Value, 100) / 100
	case "fixed":
		d = math.Min(c.Value, eligible)
	default:
		return 0, ErrBadCoupon
	}
	return round2(d), nil
}

func round2(v float64) float64 { return math.Round(v*100) / 100 }

func dedupe(in []int64) []int64 {
	seen := map[int64]bool{}
	out := make([]int64, 0, len(in))
	for _, id := range in {
		if id > 0 && !seen[id] {
			seen[id] = true
			out = append(out, id)
		}
	}
	return out
}

func randomHex(n int) (string, error) {
	b := make([]byte, n)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return hex.EncodeToString(b), nil
}

func newOrderCode(now time.Time) (string, error) {
	r, err := randomHex(4)
	if err != nil {
		return "", err
	}
	return "ORD-" + now.UTC().Format("20060102") + "-" + strings.ToUpper(r), nil
}

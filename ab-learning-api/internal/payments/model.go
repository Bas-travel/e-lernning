package payments

import "time"

type CheckoutRequest struct {
	CourseIDs  []int64 `json:"course_ids"`
	CouponCode string  `json:"coupon_code"`
	Method     string  `json:"method"` // promptpay | card
}

type OrderItem struct {
	CourseID int64   `json:"course_id"`
	Title    string  `json:"title"`
	Price    float64 `json:"price"`
}

type Order struct {
	ID            int64       `json:"-"`
	UserID        int64       `json:"-"`
	Code          string      `json:"order_code"`
	Status        string      `json:"status"`
	Subtotal      float64     `json:"subtotal"`
	DiscountTotal float64     `json:"discount_total"`
	GrandTotal    float64     `json:"grand_total"`
	Method        string      `json:"method"`
	PaymentStatus string      `json:"payment_status"`
	Items         []OrderItem `json:"items"`
	CreatedAt     time.Time   `json:"created_at"`
	// Sandbox lets a client finish the flow without a real gateway.
	Sandbox *SandboxInfo `json:"sandbox,omitempty"`
}

type SandboxInfo struct {
	CompleteURL string `json:"complete_url"`
}

// CourseLine is a course as priced for sale.
type CourseLine struct {
	ID     int64
	Title  string
	Price  float64 // effective price (discount wins when non-NULL)
	Status string
}

type Coupon struct {
	ID        int64
	Code      string
	Type      string // percent | fixed
	Value     float64
	CourseID  *int64
	MaxUses   *int
	UsedCount int
	ExpiresAt *time.Time
}

// NewOrder is everything the repository needs to persist a checkout.
type NewOrder struct {
	UserID         int64
	Code           string
	IdempotencyKey string
	CouponID       *int64
	Subtotal       float64
	Discount       float64
	Grand          float64
	Method         string
	Provider       string
	ProviderRef    string
	Items          []CourseLine
}

// Package admin implements the Admin domain: dashboard, course moderation,
// user management and payment management (with audit logging).
package admin

import "time"

type Dashboard struct {
	UsersTotal       int     `json:"users_total"`
	Learners         int     `json:"learners"`
	Instructors      int     `json:"instructors"`
	CoursesPublished int     `json:"courses_published"`
	CoursesPending   int     `json:"courses_pending"`
	Revenue          float64 `json:"revenue"`
	GMV              float64 `json:"gmv"`
	OpenReports      int     `json:"open_reports"`
}

type ModerationCourse struct {
	ID             int64     `json:"id"`
	Title          string    `json:"title"`
	Instructor     string    `json:"instructor"`
	Category       string    `json:"category"`
	Price          float64   `json:"price"`
	Status         string    `json:"status"`
	RejectedReason string    `json:"rejected_reason"`
	LessonCount    int       `json:"lesson_count"`
	OpenReports    int       `json:"open_reports"`
	UpdatedAt      time.Time `json:"updated_at"`
}

type User struct {
	ID          int64      `json:"id"`
	Email       string     `json:"email"`
	Role        string     `json:"role"`
	Status      string     `json:"status"`
	FirstName   string     `json:"first_name"`
	LastName    string     `json:"last_name"`
	CreatedAt   time.Time  `json:"created_at"`
	LastLoginAt *time.Time `json:"last_login_at"`
}

type UserDetail struct {
	User
	OrdersCount int     `json:"orders_count"`
	TotalSpent  float64 `json:"total_spent"`
}

type UserFilter struct {
	Role, Status, Query string
	Limit, Offset       int
}

type UserUpdate struct {
	Role   *string `json:"role"`
	Status *string `json:"status"`
}

type Payment struct {
	ID             int64      `json:"id"`
	OrderCode      string     `json:"order_code"`
	UserEmail      string     `json:"user_email"`
	Amount         float64    `json:"amount"`
	RefundedAmount float64    `json:"refunded_amount"`
	Method         string     `json:"method"`
	Status         string     `json:"status"`
	OrderStatus    string     `json:"order_status"`
	PaidAt         *time.Time `json:"paid_at"`
}

type RefundRequest struct {
	Amount *float64 `json:"amount"` // omitted = refund everything still refundable
	Reason string   `json:"reason"`
}

type RefundResult struct {
	RefundID       int64   `json:"refund_id"`
	PaymentID      int64   `json:"payment_id"`
	Amount         float64 `json:"amount"`
	TotalRefunded  float64 `json:"total_refunded"`
	OrderStatus    string  `json:"order_status"`
}

type RejectRequest struct {
	Reason string `json:"reason"`
}

type SuspendRequest struct {
	Reason string `json:"reason"`
}

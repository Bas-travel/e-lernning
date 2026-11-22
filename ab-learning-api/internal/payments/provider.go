// Package payments implements checkout, payment tracking and webhook
// handling. It is gateway-agnostic: a Provider creates payments and verifies
// webhooks, and only SandboxProvider exists today. Live mode is deliberately
// not implemented — it needs explicit written approval first.
package payments

import (
	"net/http"
	"time"
)

// Event is a provider notification, already authenticated.
type Event struct {
	ID        string // unique per provider; used for idempotency
	Type      string // EventSucceeded | EventFailed
	OrderCode string
}

const (
	EventSucceeded = "payment.succeeded"
	EventFailed    = "payment.failed"
)

// Provider is what a payment gateway adapter must offer.
type Provider interface {
	Name() string
	// CreatePayment registers a payment for an order and returns the
	// provider's reference for it.
	CreatePayment(orderCode string, amount float64) (ref string, err error)
	// ParseWebhook authenticates the request (signature, freshness) and
	// returns the event, or an error if it must be rejected.
	ParseWebhook(h http.Header, body []byte, now time.Time) (Event, error)
}

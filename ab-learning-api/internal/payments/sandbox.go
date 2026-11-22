package payments

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"
)

// SignatureHeader carries "t=<unix seconds>,v1=<hex hmac-sha256>" where the
// MAC covers "<t>.<raw body>".
const SignatureHeader = "X-Sandbox-Signature"

var (
	ErrBadSignature = errors.New("invalid webhook signature")
	ErrStaleEvent   = errors.New("webhook timestamp outside tolerance")
)

// SandboxProvider is a fake gateway for local/test/staging use. It never
// moves money and makes no network calls.
type SandboxProvider struct {
	Secret    []byte
	Tolerance time.Duration
}

func NewSandboxProvider(secret string) *SandboxProvider {
	return &SandboxProvider{Secret: []byte(secret), Tolerance: 5 * time.Minute}
}

func (p *SandboxProvider) Name() string { return "sandbox" }

func (p *SandboxProvider) CreatePayment(orderCode string, _ float64) (string, error) {
	return "sbx_" + orderCode, nil
}

// Sign produces the header value for body at time ts.
func (p *SandboxProvider) Sign(body []byte, ts time.Time) string {
	t := strconv.FormatInt(ts.Unix(), 10)
	return fmt.Sprintf("t=%s,v1=%s", t, p.mac(t, body))
}

func (p *SandboxProvider) mac(t string, body []byte) string {
	m := hmac.New(sha256.New, p.Secret)
	m.Write([]byte(t))
	m.Write([]byte("."))
	m.Write(body)
	return hex.EncodeToString(m.Sum(nil))
}

func (p *SandboxProvider) ParseWebhook(h http.Header, body []byte, now time.Time) (Event, error) {
	var t, sig string
	for _, part := range strings.Split(h.Get(SignatureHeader), ",") {
		k, v, ok := strings.Cut(strings.TrimSpace(part), "=")
		if !ok {
			continue
		}
		switch k {
		case "t":
			t = v
		case "v1":
			sig = v
		}
	}
	if t == "" || sig == "" {
		return Event{}, ErrBadSignature
	}
	// Constant-time compare, checked BEFORE the body is trusted.
	if !hmac.Equal([]byte(sig), []byte(p.mac(t, body))) {
		return Event{}, ErrBadSignature
	}
	secs, err := strconv.ParseInt(t, 10, 64)
	if err != nil {
		return Event{}, ErrBadSignature
	}
	age := now.Sub(time.Unix(secs, 0))
	if age > p.Tolerance || age < -p.Tolerance {
		return Event{}, ErrStaleEvent
	}
	var payload struct {
		ID        string `json:"id"`
		Type      string `json:"type"`
		OrderCode string `json:"order_code"`
	}
	if err := json.Unmarshal(body, &payload); err != nil {
		return Event{}, fmt.Errorf("%w: malformed webhook body: %v", ErrInvalidRequest, err)
	}
	if payload.ID == "" || payload.OrderCode == "" ||
		(payload.Type != EventSucceeded && payload.Type != EventFailed) {
		return Event{}, fmt.Errorf("%w: webhook missing id, order_code or a known type", ErrInvalidRequest)
	}
	return Event{ID: payload.ID, Type: payload.Type, OrderCode: payload.OrderCode}, nil
}

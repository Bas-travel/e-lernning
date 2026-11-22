package payments

import (
	"errors"
	"net/http"
	"testing"
	"time"
)

func TestSandboxWebhookVerification(t *testing.T) {
	p := NewSandboxProvider("test-secret")
	now := time.Unix(1_800_000_000, 0)
	body := []byte(`{"id":"evt_1","type":"payment.succeeded","order_code":"ORD-1"}`)

	hdr := func(v string) http.Header {
		h := http.Header{}
		h.Set(SignatureHeader, v)
		return h
	}

	t.Run("valid signature", func(t *testing.T) {
		ev, err := p.ParseWebhook(hdr(p.Sign(body, now)), body, now)
		if err != nil {
			t.Fatal(err)
		}
		if ev.ID != "evt_1" || ev.Type != EventSucceeded || ev.OrderCode != "ORD-1" {
			t.Fatalf("unexpected event %+v", ev)
		}
	})
	t.Run("tampered body", func(t *testing.T) {
		sig := p.Sign(body, now)
		tampered := []byte(`{"id":"evt_1","type":"payment.succeeded","order_code":"ORD-2"}`)
		if _, err := p.ParseWebhook(hdr(sig), tampered, now); !errors.Is(err, ErrBadSignature) {
			t.Fatalf("want ErrBadSignature, got %v", err)
		}
	})
	t.Run("wrong secret", func(t *testing.T) {
		other := NewSandboxProvider("another-secret")
		if _, err := p.ParseWebhook(hdr(other.Sign(body, now)), body, now); !errors.Is(err, ErrBadSignature) {
			t.Fatalf("want ErrBadSignature, got %v", err)
		}
	})
	t.Run("missing header", func(t *testing.T) {
		if _, err := p.ParseWebhook(http.Header{}, body, now); !errors.Is(err, ErrBadSignature) {
			t.Fatalf("want ErrBadSignature, got %v", err)
		}
	})
	t.Run("stale timestamp is rejected even with a valid MAC", func(t *testing.T) {
		old := now.Add(-10 * time.Minute)
		if _, err := p.ParseWebhook(hdr(p.Sign(body, old)), body, now); !errors.Is(err, ErrStaleEvent) {
			t.Fatalf("want ErrStaleEvent, got %v", err)
		}
	})
	t.Run("unknown event type", func(t *testing.T) {
		bad := []byte(`{"id":"e","type":"refund.created","order_code":"ORD-1"}`)
		if _, err := p.ParseWebhook(hdr(p.Sign(bad, now)), bad, now); !errors.Is(err, ErrInvalidRequest) {
			t.Fatalf("want ErrInvalidRequest, got %v", err)
		}
	})
}

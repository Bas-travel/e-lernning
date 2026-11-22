-- Sandbox payments: idempotent checkout + webhook event log.

ALTER TABLE orders
  ADD COLUMN idempotency_key VARCHAR(80) NULL AFTER order_code,
  ADD UNIQUE KEY uq_orders_user_idempotency (user_id, idempotency_key);

ALTER TABLE payments
  ADD COLUMN provider VARCHAR(30) NOT NULL DEFAULT 'sandbox' AFTER method;

-- One row per provider event. The unique key makes webhook delivery
-- idempotent: a replayed event is recognised and ignored.
CREATE TABLE payment_events (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  provider      VARCHAR(30)  NOT NULL,
  event_id      VARCHAR(100) NOT NULL,
  event_type    VARCHAR(50)  NOT NULL,
  order_code    VARCHAR(30)  NULL,
  payload       TEXT         NOT NULL,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_payment_event (provider, event_id),
  INDEX idx_payment_events_order (order_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Wallet top-ups are idempotent per (wallet, key): a retried request credits once.
ALTER TABLE wallet_transactions
  ADD COLUMN idempotency_key VARCHAR(80) NULL AFTER reference,
  ADD UNIQUE KEY uq_wallet_tx_idem (wallet_id, idempotency_key);

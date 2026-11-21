package auth

import "log"

// Notifier delivers one-time codes and reset tokens to a user. Production
// delivery (SMTP, SMS, ...) is not implemented yet: until a Notifier is wired
// in, the OTP / forgot-password endpoints answer 501 Not Implemented, which
// the Flutter client already treats as "feature not available".
type Notifier interface {
	SendOTP(email, code string) error
	SendResetToken(email, token string) error
}

// LogNotifier writes codes to the server log. It exists so the sign-up flow
// can be exercised locally and MUST NOT be enabled in staging or production
// (config.Load only selects it when APP_ENV=dev and AUTH_DELIVERY=log).
type LogNotifier struct{}

func (LogNotifier) SendOTP(email, code string) error {
	log.Printf("[dev-only] OTP for %s: %s", email, code)
	return nil
}

func (LogNotifier) SendResetToken(email, token string) error {
	log.Printf("[dev-only] password reset token for %s: %s", email, token)
	return nil
}

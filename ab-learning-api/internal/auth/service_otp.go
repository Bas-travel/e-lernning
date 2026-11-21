package auth

import (
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"math/big"
	"net/mail"
	"strings"
	"time"
	"unicode/utf8"
)

const (
	otpTTL        = 10 * time.Minute
	otpResendGap  = 60 * time.Second
	resetTokenTTL = time.Hour

	purposeRegister = "register"
)

var (
	ErrDeliveryUnavailable = errors.New("code delivery is not configured")
	ErrTooManyRequests     = errors.New("please wait before requesting another code")
	ErrInvalidCode         = errors.New("invalid or expired code")
)

// WithNotifier enables OTP / reset-token delivery.
func (s *Service) WithNotifier(n Notifier) *Service {
	s.notifier = n
	return s
}

func newOTPCode() (string, error) {
	n, err := rand.Int(rand.Reader, big.NewInt(1_000_000))
	if err != nil {
		return "", err
	}
	return fmt.Sprintf("%06d", n.Int64()), nil
}

func (s *Service) issueOTP(u User) error {
	code, err := newOTPCode()
	if err != nil {
		return err
	}
	if err := s.repo.InsertOTP(u.ID, code, purposeRegister, time.Now().UTC().Add(otpTTL)); err != nil {
		return err
	}
	return s.notifier.SendOTP(u.Email, code)
}

// ResendOTP issues a new sign-up code, at most one per minute.
func (s *Service) ResendOTP(userID int64) error {
	if s.notifier == nil {
		return ErrDeliveryUnavailable
	}
	verified, err := s.repo.EmailVerified(userID)
	if err != nil {
		return err
	}
	if verified {
		return nil // nothing to do
	}
	if last, ok, err := s.repo.LastOTPAt(userID, purposeRegister); err != nil {
		return err
	} else if ok && time.Since(last) < otpResendGap {
		return ErrTooManyRequests
	}
	u, err := s.repo.ByID(userID)
	if err != nil {
		return err
	}
	return s.issueOTP(u.User)
}

// VerifyOTP consumes a sign-up code and marks the e-mail verified.
func (s *Service) VerifyOTP(userID int64, code string) error {
	code = strings.TrimSpace(code)
	if userID <= 0 || len(code) != 6 {
		return ErrInvalidCode
	}
	ok, err := s.repo.ConsumeOTP(userID, code, purposeRegister, time.Now().UTC())
	if err != nil {
		return err
	}
	if !ok {
		return ErrInvalidCode
	}
	return nil
}

// ForgotPassword creates a reset token for the account, if one exists. It
// reports success for unknown e-mails so callers cannot enumerate accounts.
func (s *Service) ForgotPassword(email string) error {
	if s.notifier == nil {
		return ErrDeliveryUnavailable
	}
	email = strings.ToLower(strings.TrimSpace(email))
	if _, err := mail.ParseAddress(email); err != nil {
		return errors.Join(ErrValidation, errors.New("a valid email is required"))
	}
	u, err := s.repo.ByEmail(email)
	if errors.Is(err, ErrNotFound) {
		return nil
	}
	if err != nil {
		return err
	}
	raw := make([]byte, 32)
	if _, err := rand.Read(raw); err != nil {
		return err
	}
	token := hex.EncodeToString(raw)
	sum := sha256.Sum256([]byte(token))
	if err := s.repo.InsertReset(u.ID, hex.EncodeToString(sum[:]), time.Now().UTC().Add(resetTokenTTL)); err != nil {
		return err
	}
	return s.notifier.SendResetToken(u.Email, token)
}

var goalEnum = map[string]string{
	"get_job": "get_job", "get_a_job": "get_job",
	"upskill":       "upskill",
	"career_change": "career_change",
	"freelance":     "freelance",
	"business":      "business",
}

var levelEnum = map[string]bool{"beginner": true, "intermediate": true, "advanced": true}

func normalizeKey(v string) string {
	return strings.ReplaceAll(strings.ToLower(strings.TrimSpace(v)), " ", "_")
}

// SavePreferences stores the onboarding answers. Level and goal accept both
// the enum values and the labels the app shows ("Get a Job").
func (s *Service) SavePreferences(userID int64, req PreferencesRequest) error {
	if len(req.Interests) > 20 {
		return errors.Join(ErrValidation, errors.New("at most 20 interests"))
	}
	interests := make([]string, 0, len(req.Interests))
	for _, in := range req.Interests {
		in = strings.TrimSpace(in)
		if in == "" {
			continue
		}
		if utf8.RuneCountInString(in) > 50 {
			return errors.Join(ErrValidation, errors.New("interest names must be at most 50 characters"))
		}
		interests = append(interests, in)
	}
	var level any
	if k := normalizeKey(req.Level); k != "" {
		if !levelEnum[k] {
			return errors.Join(ErrValidation, errors.New("level must be beginner, intermediate or advanced"))
		}
		level = k
	}
	var goal any
	if k := normalizeKey(req.Goal); k != "" {
		g, ok := goalEnum[k]
		if !ok {
			return errors.Join(ErrValidation, errors.New("unknown goal"))
		}
		goal = g
	}
	payload, err := json.Marshal(interests)
	if err != nil {
		return err
	}
	return s.repo.SavePreferences(userID, payload, level, goal)
}

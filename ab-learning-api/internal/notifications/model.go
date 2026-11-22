// Package notifications serves the in-app notification inbox. A user can only
// ever see and change their own rows.
package notifications

import (
	"context"
	"errors"
	"strings"
	"time"
)

var ErrNotFound = errors.New("notification not found")
var ErrInvalid = errors.New("invalid notification")

const (
	DefaultLimit = 20
	MaxLimit     = 100
)

type Notification struct {
	ID        int64     `json:"id"`
	Type      string    `json:"type"`
	Title     string    `json:"title"`
	Body      string    `json:"body"`
	IsRead    bool      `json:"is_read"`
	CreatedAt time.Time `json:"created_at"`
}

type Page struct {
	Items  []Notification `json:"items"`
	Unread int            `json:"unread"`
	Limit  int            `json:"limit"`
	Offset int            `json:"offset"`
}

type Repository interface {
	List(ctx context.Context, userID int64, unreadOnly bool, limit, offset int) ([]Notification, error)
	CountUnread(ctx context.Context, userID int64) (int, error)
	// MarkRead reports false when the row does not exist or is not the user's.
	MarkRead(ctx context.Context, userID, id int64) (bool, error)
	MarkAllRead(ctx context.Context, userID int64) (int64, error)
	Create(ctx context.Context, userID int64, n Notification) error
}

func clampPaging(limit, offset int) (int, int) {
	if limit <= 0 {
		limit = DefaultLimit
	}
	if limit > MaxLimit {
		limit = MaxLimit
	}
	if offset < 0 {
		offset = 0
	}
	return limit, offset
}

func validate(n Notification) error {
	n.Type, n.Title = strings.TrimSpace(n.Type), strings.TrimSpace(n.Title)
	if n.Type == "" || len(n.Type) > 50 {
		return ErrInvalid
	}
	if n.Title == "" || len([]rune(n.Title)) > 200 || len([]rune(n.Body)) > 500 {
		return ErrInvalid
	}
	return nil
}

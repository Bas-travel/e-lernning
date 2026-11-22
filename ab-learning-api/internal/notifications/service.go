package notifications

import (
	"context"
	"strings"
)

type Service struct{ repo Repository }

func NewService(repo Repository) *Service { return &Service{repo: repo} }

func (s *Service) List(ctx context.Context, userID int64, unreadOnly bool, limit, offset int) (*Page, error) {
	limit, offset = clampPaging(limit, offset)
	items, err := s.repo.List(ctx, userID, unreadOnly, limit, offset)
	if err != nil {
		return nil, err
	}
	unread, err := s.repo.CountUnread(ctx, userID)
	if err != nil {
		return nil, err
	}
	if items == nil {
		items = []Notification{}
	}
	return &Page{Items: items, Unread: unread, Limit: limit, Offset: offset}, nil
}

func (s *Service) MarkRead(ctx context.Context, userID, id int64) error {
	ok, err := s.repo.MarkRead(ctx, userID, id)
	if err != nil {
		return err
	}
	if !ok {
		return ErrNotFound
	}
	return nil
}

func (s *Service) MarkAllRead(ctx context.Context, userID int64) (int64, error) {
	return s.repo.MarkAllRead(ctx, userID)
}

// Notify stores a notification for a user. Other modules call this when
// something the user should hear about happens.
func (s *Service) Notify(ctx context.Context, userID int64, typ, title, body string) error {
	n := Notification{Type: strings.TrimSpace(typ), Title: strings.TrimSpace(title), Body: body}
	if err := validate(n); err != nil {
		return err
	}
	return s.repo.Create(ctx, userID, n)
}

package reviews

import "context"

type Service struct{ repo Repository }

func NewService(repo Repository) *Service { return &Service{repo: repo} }

// List is public; viewerID (0 when anonymous) only sets Review.Mine.
func (s *Service) List(ctx context.Context, courseID, viewerID int64, limit, offset int) (*Page, error) {
	ok, err := s.repo.CourseExists(ctx, courseID)
	if err != nil {
		return nil, err
	}
	if !ok {
		return nil, ErrCourseNotFound
	}
	limit, offset = clampPaging(limit, offset)
	items, err := s.repo.List(ctx, courseID, viewerID, limit, offset)
	if err != nil {
		return nil, err
	}
	avg, count, err := s.repo.Summary(ctx, courseID)
	if err != nil {
		return nil, err
	}
	if items == nil {
		items = []Review{}
	}
	return &Page{Items: items, RatingAvg: avg, RatingCnt: count, Limit: limit, Offset: offset}, nil
}

func (s *Service) Submit(ctx context.Context, userID, courseID int64, rating int, comment string) error {
	if rating < 1 || rating > 5 {
		return ErrInvalid
	}
	comment, err := cleanComment(comment)
	if err != nil {
		return err
	}
	ok, err := s.repo.CourseExists(ctx, courseID)
	if err != nil {
		return err
	}
	if !ok {
		return ErrCourseNotFound
	}
	enrolled, err := s.repo.Enrolled(ctx, userID, courseID)
	if err != nil {
		return err
	}
	if !enrolled {
		return ErrNotEnrolled
	}
	return s.repo.Upsert(ctx, courseID, userID, rating, comment)
}

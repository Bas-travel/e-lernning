// Package reviews lets enrolled learners rate a course once (editable) and
// lists the reviews of published courses.
package reviews

import (
	"context"
	"errors"
	"strings"
	"time"
)

var (
	ErrCourseNotFound = errors.New("course not found")
	ErrNotEnrolled    = errors.New("only enrolled learners can review a course")
	ErrInvalid        = errors.New("invalid review")
)

const (
	MaxComment   = 2000
	DefaultLimit = 20
	MaxLimit     = 50
)

type Review struct {
	ID        int64     `json:"id"`
	Rating    int       `json:"rating"`
	Comment   string    `json:"comment"`
	Author    string    `json:"author"`
	Mine      bool      `json:"mine"`
	CreatedAt time.Time `json:"created_at"`
}

type Page struct {
	Items     []Review `json:"items"`
	RatingAvg float64  `json:"rating_avg"`
	RatingCnt int      `json:"rating_count"`
	Limit     int      `json:"limit"`
	Offset    int      `json:"offset"`
}

type Repository interface {
	// CourseExists reports whether the course is published.
	CourseExists(ctx context.Context, courseID int64) (bool, error)
	Enrolled(ctx context.Context, userID, courseID int64) (bool, error)
	// Upsert stores the user's single review and refreshes the course's
	// rating_avg / rating_count in the same transaction.
	Upsert(ctx context.Context, courseID, userID int64, rating int, comment string) error
	List(ctx context.Context, courseID, viewerID int64, limit, offset int) ([]Review, error)
	Summary(ctx context.Context, courseID int64) (avg float64, count int, err error)
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

func cleanComment(c string) (string, error) {
	c = strings.TrimSpace(c)
	if len([]rune(c)) > MaxComment {
		return "", ErrInvalid
	}
	return c, nil
}

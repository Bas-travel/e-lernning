package learning

import "time"

// ---- Requests ----

// EnrollRequest is the POST /enrollments body. user_id is optional: when
// the caller is authenticated the token's user wins, and a user_id that
// disagrees with the token is rejected rather than silently honoured.
type EnrollRequest struct {
	UserID   int64 `json:"user_id"`
	CourseID int64 `json:"course_id"`
}

// SaveProgressRequest is the POST /lessons/{id}/progress body.
type SaveProgressRequest struct {
	WatchedSeconds int    `json:"watched_seconds"`
	Status         string `json:"status"`
}

// ---- Responses ----

// EnrollmentResponse matches the `Enrollment` schema in 05-openapi.yaml.
type EnrollmentResponse struct {
	ID          int64   `json:"id"`
	UserID      int64   `json:"user_id"`
	CourseID    int64   `json:"course_id"`
	Status      string  `json:"status"`
	Progress    float64 `json:"progress"`
	StartedAt   string  `json:"started_at"`
	CompletedAt *string `json:"completed_at,omitempty"`
}

// EnrolledCourseResponse is one row of "My Learning": the course card the
// learner sees plus the enrollment state that sits on top of it.
type EnrolledCourseResponse struct {
	ID             int64   `json:"id"`
	EnrollmentID   int64   `json:"enrollment_id"`
	Title          string  `json:"title"`
	Slug           string  `json:"slug"`
	ThumbnailURL   *string `json:"thumbnail_url,omitempty"`
	InstructorName string  `json:"instructor_name"`
	Level          string  `json:"level"`
	Progress       float64 `json:"progress"`
	Status         string  `json:"status"`
	TotalLessons   int     `json:"total_lessons"`
	DoneLessons    int     `json:"done_lessons"`
	LastLessonID   *int64  `json:"last_lesson_id,omitempty"`
	EnrolledAt     string  `json:"enrolled_at"`
	CompletedAt    *string `json:"completed_at,omitempty"`
}

// LessonResponse is what the video player screen loads. Correct quiz
// answers are never part of this payload — that lives in the quiz domain.
type LessonResponse struct {
	ID              int64   `json:"id"`
	SectionID       int64   `json:"section_id"`
	SectionTitle    string  `json:"section_title"`
	CourseID        int64   `json:"course_id"`
	Title           string  `json:"title"`
	Type            string  `json:"type"`
	VideoURL        *string `json:"video_url,omitempty"`
	DurationSeconds int     `json:"duration_seconds"`
	SortOrder       int     `json:"sort_order"`
	IsPreview       bool    `json:"is_preview"`
	Status          string  `json:"status"`
	WatchedSeconds  int     `json:"watched_seconds"`
}

// LessonProgressResult is returned by POST /lessons/{id}/progress. It
// carries the recomputed enrollment so the client can move its progress
// bar without re-fetching, and the certificate ID when this save is what
// completed the course.
type LessonProgressResult struct {
	Lesson          LessonResponse     `json:"lesson"`
	Enrollment      EnrollmentResponse `json:"enrollment"`
	CourseCompleted bool               `json:"course_completed"`
	CertificateID   *int64             `json:"certificate_id,omitempty"`
}

// ---- Mapping ----

func toEnrollmentResponse(e Enrollment) EnrollmentResponse {
	return EnrollmentResponse{
		ID:          e.ID,
		UserID:      e.UserID,
		CourseID:    e.CourseID,
		Status:      e.Status,
		Progress:    e.ProgressPct,
		StartedAt:   formatTime(e.EnrolledAt),
		CompletedAt: formatOptionalTime(e.CompletedAt),
	}
}

func toEnrolledCourseResponse(c EnrolledCourse) EnrolledCourseResponse {
	return EnrolledCourseResponse{
		ID:             c.CourseID,
		EnrollmentID:   c.EnrollmentID,
		Title:          c.Title,
		Slug:           c.Slug,
		ThumbnailURL:   c.ThumbnailURL,
		InstructorName: c.InstructorName,
		Level:          c.Level,
		Progress:       c.ProgressPct,
		Status:         c.Status,
		TotalLessons:   c.TotalLessons,
		DoneLessons:    c.DoneLessons,
		LastLessonID:   c.LastLessonID,
		EnrolledAt:     formatTime(c.EnrolledAt),
		CompletedAt:    formatOptionalTime(c.CompletedAt),
	}
}

func toLessonResponse(l Lesson, p LessonProgress) LessonResponse {
	return LessonResponse{
		ID:              l.ID,
		SectionID:       l.SectionID,
		SectionTitle:    l.SectionTitle,
		CourseID:        l.CourseID,
		Title:           l.Title,
		Type:            l.Type,
		VideoURL:        l.VideoURL,
		DurationSeconds: l.DurationSeconds,
		SortOrder:       l.SortOrder,
		IsPreview:       l.IsPreview,
		Status:          p.Status,
		WatchedSeconds:  p.WatchedSeconds,
	}
}

func toLessonProgressResponse(p LessonProgress) LessonProgressResponse {
	return LessonProgressResponse{
		LessonID:       p.LessonID,
		Status:         p.Status,
		WatchedSeconds: p.WatchedSeconds,
		CompletedAt:    formatOptionalTime(p.CompletedAt),
	}
}

// LessonProgressResponse is the `LessonProgress` schema in 05-openapi.yaml.
type LessonProgressResponse struct {
	LessonID       int64   `json:"lesson_id"`
	Status         string  `json:"status"`
	WatchedSeconds int     `json:"watched_seconds"`
	CompletedAt    *string `json:"completed_at,omitempty"`
}

func formatTime(t time.Time) string {
	return t.Format(time.RFC3339)
}

func formatOptionalTime(t *time.Time) *string {
	if t == nil {
		return nil
	}
	formatted := t.Format(time.RFC3339)
	return &formatted
}

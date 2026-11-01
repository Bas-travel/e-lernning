// Package learning owns the two tables that turn a purchase into actual
// learning: `enrollments` (does this learner have access to this course,
// and how far along are they) and `lesson_progress` (which lesson units are
// done, and how many seconds of each video were watched).
//
// It is the source of truth for course completion: when an enrollment
// reaches 100% the service notifies the certificates domain through the
// CertificateIssuer interface (see service.go), which is what makes the
// "learn to certificate" journey work end to end.
package learning

import "time"

// Enrollment statuses — matches the ENUM in db/init/01_schema.sql.
const (
	StatusInProgress = "in_progress"
	StatusCompleted  = "completed"
	StatusDropped    = "dropped"
)

// Lesson progress statuses — matches the ENUM in db/init/01_schema.sql.
const (
	LessonNotStarted = "not_started"
	LessonInProgress = "in_progress"
	LessonCompleted  = "completed"
)

// CompletionThresholdPct is the progress at which an enrollment counts as
// finished and a certificate becomes issuable.
const CompletionThresholdPct = 100.0

// Enrollment mirrors a row in the `enrollments` table.
type Enrollment struct {
	ID           int64
	UserID       int64
	CourseID     int64
	ProgressPct  float64
	Status       string
	LastLessonID *int64
	EnrolledAt   time.Time
	CompletedAt  *time.Time
}

// EnrolledCourse is an enrollment joined with the course columns a learner
// needs on "My Learning", plus the lesson counters that drive the
// "3 of 12 lessons done" line without a second round-trip.
type EnrolledCourse struct {
	EnrollmentID   int64
	CourseID       int64
	Title          string
	Slug           string
	ThumbnailURL   *string
	InstructorName string
	Level          string
	ProgressPct    float64
	Status         string
	TotalLessons   int
	DoneLessons    int
	LastLessonID   *int64
	EnrolledAt     time.Time
	CompletedAt    *time.Time
}

// Lesson mirrors a row in `lessons` joined with its section, so the player
// knows which course the lesson belongs to — required to check that the
// requesting learner is actually enrolled before serving the video URL.
type Lesson struct {
	ID              int64
	SectionID       int64
	CourseID        int64
	SectionTitle    string
	Title           string
	Type            string
	VideoURL        *string
	DurationSeconds int
	SortOrder       int
	IsPreview       bool
}

// LessonProgress mirrors a row in `lesson_progress`.
type LessonProgress struct {
	LessonID       int64
	Status         string
	WatchedSeconds int
	CompletedAt    *time.Time
}

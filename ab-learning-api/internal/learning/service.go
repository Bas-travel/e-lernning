package learning

import (
	"context"
	"errors"
	"math"

	"github.com/ablearning/ab-learning-api/internal/platform"
)

// Store is the persistence contract this service needs. Declaring it here
// (rather than depending on *Repository) keeps the business rules unit
// testable with an in-memory fake, and leaves the MySQL implementation
// swappable.
type Store interface {
	FindEnrollmentByUserAndCourse(ctx context.Context, userID, courseID int64) (Enrollment, error)
	FindEnrollmentByID(ctx context.Context, id int64) (Enrollment, error)
	CreateEnrollment(ctx context.Context, userID, courseID int64) (Enrollment, error)
	ListEnrolledCourses(ctx context.Context, userID int64) ([]EnrolledCourse, error)
	FindCourseForEnrollment(ctx context.Context, courseID int64) (CourseAccess, error)
	FindLesson(ctx context.Context, lessonID int64) (Lesson, error)
	ListCourseLessons(ctx context.Context, courseID int64) ([]Lesson, error)
	FindLessonProgress(ctx context.Context, enrollmentID, lessonID int64) (LessonProgress, error)
	SaveLessonProgress(ctx context.Context, enrollmentID int64, lessonID int64, watchedSeconds int, status string) error
	CountCourseLessons(ctx context.Context, courseID int64) (int, error)
	CountCompletedLessons(ctx context.Context, enrollmentID int64) (int, error)
	UpdateEnrollmentProgress(ctx context.Context, enrollmentID int64, progressPct float64, status string, lastLessonID int64) error
}

// PurchaseChecker answers "has this learner already paid for this course".
// The commerce domain implements it; keeping it an interface here means
// learning never imports commerce, so the two can evolve independently.
type PurchaseChecker interface {
	HasPaidForCourse(ctx context.Context, userID, courseID int64) (bool, error)
}

// CertificateIssuer turns a finished enrollment into a certificate. The
// certificate domain implements it and is required to be idempotent — the
// learner's save is retried freely, and only one certificate may ever exist
// per enrollment (enforced by a UNIQUE key on the certificates table).
type CertificateIssuer interface {
	IssueForEnrollment(ctx context.Context, enrollmentID int64) (int64, error)
}

// Service holds the enrollment and progress rules. purchases and certs may
// be nil in unit tests, in which case the paid-course gate and automatic
// certificate issuance are skipped.
type Service struct {
	store     Store
	purchases PurchaseChecker
	certs     CertificateIssuer
}

func NewService(store Store, purchases PurchaseChecker, certs CertificateIssuer) *Service {
	return &Service{store: store, purchases: purchases, certs: certs}
}

// ListMyCourses implements GET /me/courses — "My Learning".
func (s *Service) ListMyCourses(ctx context.Context, userID int64) ([]EnrolledCourseResponse, error) {
	courses, err := s.store.ListEnrolledCourses(ctx, userID)
	if err != nil {
		return nil, err
	}

	out := make([]EnrolledCourseResponse, 0, len(courses))
	for _, c := range courses {
		out = append(out, toEnrolledCourseResponse(c))
	}
	return out, nil
}

// Enroll implements POST /enrollments.
//
// Free courses enroll straight away. Paid courses require a settled payment
// first — that check is what stops a learner from reading a paid course by
// POSTing an ID they never bought, and the purchase itself is recorded by
// the commerce domain when a payment succeeds.
//
// Enrolling twice is not an error: the second call returns the existing
// enrollment with created=false so the endpoint is safe to retry.
func (s *Service) Enroll(ctx context.Context, userID, courseID int64) (EnrollmentResponse, bool, error) {
	if userID <= 0 {
		return EnrollmentResponse{}, false, platform.ErrUnauthorized
	}
	if courseID <= 0 {
		return EnrollmentResponse{}, false, platform.ErrValidation("course_id is required")
	}

	course, err := s.store.FindCourseForEnrollment(ctx, courseID)
	if errors.Is(err, ErrCourseNotFound) {
		return EnrollmentResponse{}, false, platform.ErrNotFound("Course could not be found.")
	}
	if err != nil {
		return EnrollmentResponse{}, false, err
	}
	// A course that isn't published is treated as non-existent from the
	// outside — no hint that a draft with this ID exists.
	if course.Status != "published" {
		return EnrollmentResponse{}, false, platform.ErrNotFound("Course could not be found.")
	}

	if course.EffectivePrice() > 0 && s.purchases != nil {
		paid, err := s.purchases.HasPaidForCourse(ctx, userID, courseID)
		if err != nil {
			return EnrollmentResponse{}, false, err
		}
		if !paid {
			return EnrollmentResponse{}, false, platform.ErrPaymentRequired("Purchase this course before enrolling.")
		}
	}

	enrollment, err := s.store.CreateEnrollment(ctx, userID, courseID)
	if errors.Is(err, ErrAlreadyEnrolled) {
		existing, findErr := s.store.FindEnrollmentByUserAndCourse(ctx, userID, courseID)
		if findErr != nil {
			return EnrollmentResponse{}, false, findErr
		}
		return toEnrollmentResponse(existing), false, nil
	}
	if err != nil {
		return EnrollmentResponse{}, false, err
	}
	return toEnrollmentResponse(enrollment), true, nil
}

// GetEnrollment implements GET /enrollments/{id}. Someone else's enrollment
// reads as "not found" rather than "forbidden", so IDs can't be probed.
func (s *Service) GetEnrollment(ctx context.Context, userID, enrollmentID int64) (EnrollmentResponse, error) {
	enrollment, err := s.store.FindEnrollmentByID(ctx, enrollmentID)
	if errors.Is(err, ErrEnrollmentNotFound) {
		return EnrollmentResponse{}, platform.ErrNotFound("Enrollment could not be found.")
	}
	if err != nil {
		return EnrollmentResponse{}, err
	}
	if enrollment.UserID != userID {
		return EnrollmentResponse{}, platform.ErrNotFound("Enrollment could not be found.")
	}
	return toEnrollmentResponse(enrollment), nil
}

// GetLesson implements GET /lessons/{id} — the video player's payload.
// Preview lessons play without an enrollment; everything else requires one.
func (s *Service) GetLesson(ctx context.Context, userID, lessonID int64) (LessonResponse, error) {
	lesson, err := s.store.FindLesson(ctx, lessonID)
	if errors.Is(err, ErrLessonNotFound) {
		return LessonResponse{}, platform.ErrNotFound("Lesson could not be found.")
	}
	if err != nil {
		return LessonResponse{}, err
	}

	progress := LessonProgress{LessonID: lessonID, Status: LessonNotStarted}
	if lesson.IsPreview {
		return toLessonResponse(lesson, progress), nil
	}

	enrollment, err := s.store.FindEnrollmentByUserAndCourse(ctx, userID, lesson.CourseID)
	if errors.Is(err, ErrEnrollmentNotFound) {
		return LessonResponse{}, platform.ErrForbidden("Enroll in this course to watch this lesson.")
	}
	if err != nil {
		return LessonResponse{}, err
	}

	progress, err = s.store.FindLessonProgress(ctx, enrollment.ID, lessonID)
	if err != nil {
		return LessonResponse{}, err
	}
	return toLessonResponse(lesson, progress), nil
}

// SaveLessonProgress implements POST /lessons/{id}/progress and is where a
// course actually finishes: it stores the lesson state, recomputes the
// enrollment percentage from the lesson counts, and issues the certificate
// the moment the last lesson lands.
func (s *Service) SaveLessonProgress(ctx context.Context, userID, lessonID int64, req SaveProgressRequest) (LessonProgressResult, error) {
	if req.WatchedSeconds < 0 {
		return LessonProgressResult{}, platform.ErrValidation("watched_seconds cannot be negative")
	}

	status := req.Status
	if status == "" {
		status = LessonInProgress
	}
	if status != LessonInProgress && status != LessonCompleted {
		return LessonProgressResult{}, platform.ErrValidation("status must be 'in_progress' or 'completed'")
	}
	// A lesson with zero seconds watched that claims to be completed is
	// almost always a client bug — reject rather than silently trust it.
	if status == LessonCompleted && req.WatchedSeconds == 0 {
		status = LessonInProgress
	}

	lesson, err := s.store.FindLesson(ctx, lessonID)
	if errors.Is(err, ErrLessonNotFound) {
		return LessonProgressResult{}, platform.ErrNotFound("Lesson could not be found.")
	}
	if err != nil {
		return LessonProgressResult{}, err
	}

	enrollment, err := s.store.FindEnrollmentByUserAndCourse(ctx, userID, lesson.CourseID)
	if errors.Is(err, ErrEnrollmentNotFound) {
		return LessonProgressResult{}, platform.ErrForbidden("Enroll in this course to track progress.")
	}
	if err != nil {
		return LessonProgressResult{}, err
	}

	if err := s.store.SaveLessonProgress(ctx, enrollment.ID, lessonID, req.WatchedSeconds, status); err != nil {
		return LessonProgressResult{}, err
	}

	updated, err := s.recomputeProgress(ctx, enrollment, lessonID)
	if err != nil {
		return LessonProgressResult{}, err
	}

	saved, err := s.store.FindLessonProgress(ctx, enrollment.ID, lessonID)
	if err != nil {
		return LessonProgressResult{}, err
	}

	result := LessonProgressResult{
		Lesson:          toLessonResponse(lesson, saved),
		Enrollment:      toEnrollmentResponse(updated),
		CourseCompleted: updated.Status == StatusCompleted,
	}

	// Idempotent by contract — issuing on every call means a learner who
	// finishes offline, or a request that failed after the DB write, still
	// ends up with exactly one certificate.
	if result.CourseCompleted && s.certs != nil {
		certID, err := s.certs.IssueForEnrollment(ctx, enrollment.ID)
		if err != nil {
			return LessonProgressResult{}, err
		}
		result.CertificateID = &certID
	}

	return result, nil
}

// recomputeProgress derives the enrollment percentage from completed
// lessons rather than trusting anything the client sent.
func (s *Service) recomputeProgress(ctx context.Context, enrollment Enrollment, lastLessonID int64) (Enrollment, error) {
	total, err := s.store.CountCourseLessons(ctx, enrollment.CourseID)
	if err != nil {
		return Enrollment{}, err
	}
	done, err := s.store.CountCompletedLessons(ctx, enrollment.ID)
	if err != nil {
		return Enrollment{}, err
	}

	progressPct := 0.0
	if total > 0 {
		progressPct = math.Round(float64(done)/float64(total)*10000) / 100
	}

	status := StatusInProgress
	if total > 0 && done >= total {
		progressPct = CompletionThresholdPct
		status = StatusCompleted
	}

	if err := s.store.UpdateEnrollmentProgress(ctx, enrollment.ID, progressPct, status, lastLessonID); err != nil {
		return Enrollment{}, err
	}
	return s.store.FindEnrollmentByID(ctx, enrollment.ID)
}

// IsEnrolled reports whether the learner already owns a course.
func (s *Service) IsEnrolled(ctx context.Context, userID, courseID int64) (bool, error) {
	_, err := s.store.FindEnrollmentByUserAndCourse(ctx, userID, courseID)
	if errors.Is(err, ErrEnrollmentNotFound) {
		return false, nil
	}
	if err != nil {
		return false, err
	}
	return true, nil
}

// EnrollByUserAndCourse is the entry point the commerce domain calls once a
// payment settles. It writes the enrollment directly and deliberately skips
// the purchase gate in Enroll — the payment that triggered this call is
// already recorded, and checking it here would only re-read the row the
// caller just wrote. Already owning the course is success, not an error:
// buying twice must never fail the payment that just succeeded.
func (s *Service) EnrollByUserAndCourse(ctx context.Context, userID, courseID int64) error {
	if userID <= 0 || courseID <= 0 {
		return platform.ErrValidation("user_id and course_id are required")
	}
	_, err := s.store.CreateEnrollment(ctx, userID, courseID)
	if errors.Is(err, ErrAlreadyEnrolled) {
		return nil
	}
	return err
}

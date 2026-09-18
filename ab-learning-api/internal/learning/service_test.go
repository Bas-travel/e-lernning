package learning

import (
	"context"
	"errors"
	"testing"

	"github.com/ablearning/ab-learning-api/internal/platform"
)

// ---- Fake store ----

// fakeStore is an in-memory Store used to exercise the business rules
// without a database. It mirrors the two behaviours callers rely on: the
// unique (user, course) enrollment, and lesson progress that only ever
// moves forward.
type fakeStore struct {
	nextEnrollmentID int64
	byID             map[int64]Enrollment
	byUserCourse     map[[2]int64]int64
	courses          map[int64]CourseAccess
	lessons          map[int64]Lesson
	courseLessons    map[int64][]int64
	progress         map[[2]int64]LessonProgress
}

func newFakeStore() *fakeStore {
	return &fakeStore{
		byID:          map[int64]Enrollment{},
		byUserCourse:  map[[2]int64]int64{},
		courses:       map[int64]CourseAccess{},
		lessons:       map[int64]Lesson{},
		courseLessons: map[int64][]int64{},
		progress:      map[[2]int64]LessonProgress{},
	}
}

func (f *fakeStore) addCourse(id int64, status string, price float64, discount *float64) {
	f.courses[id] = CourseAccess{ID: id, Price: price, DiscountPrice: discount, Status: status}
}

func (f *fakeStore) addLesson(courseID, lessonID int64, isPreview bool) {
	f.lessons[lessonID] = Lesson{ID: lessonID, CourseID: courseID, IsPreview: isPreview}
	f.courseLessons[courseID] = append(f.courseLessons[courseID], lessonID)
}

func (f *fakeStore) FindEnrollmentByUserAndCourse(_ context.Context, userID, courseID int64) (Enrollment, error) {
	id, ok := f.byUserCourse[[2]int64{userID, courseID}]
	if !ok {
		return Enrollment{}, ErrEnrollmentNotFound
	}
	return f.byID[id], nil
}

func (f *fakeStore) FindEnrollmentByID(_ context.Context, id int64) (Enrollment, error) {
	e, ok := f.byID[id]
	if !ok {
		return Enrollment{}, ErrEnrollmentNotFound
	}
	return e, nil
}

func (f *fakeStore) CreateEnrollment(_ context.Context, userID, courseID int64) (Enrollment, error) {
	if _, ok := f.byUserCourse[[2]int64{userID, courseID}]; ok {
		return Enrollment{}, ErrAlreadyEnrolled
	}
	f.nextEnrollmentID++
	e := Enrollment{ID: f.nextEnrollmentID, UserID: userID, CourseID: courseID, Status: StatusInProgress}
	f.byID[e.ID] = e
	f.byUserCourse[[2]int64{userID, courseID}] = e.ID
	return e, nil
}

func (f *fakeStore) ListEnrolledCourses(_ context.Context, userID int64) ([]EnrolledCourse, error) {
	out := []EnrolledCourse{}
	for _, e := range f.byID {
		if e.UserID == userID {
			out = append(out, EnrolledCourse{EnrollmentID: e.ID, CourseID: e.CourseID, ProgressPct: e.ProgressPct})
		}
	}
	return out, nil
}

func (f *fakeStore) FindCourseForEnrollment(_ context.Context, courseID int64) (CourseAccess, error) {
	c, ok := f.courses[courseID]
	if !ok {
		return CourseAccess{}, ErrCourseNotFound
	}
	return c, nil
}

func (f *fakeStore) FindLesson(_ context.Context, lessonID int64) (Lesson, error) {
	l, ok := f.lessons[lessonID]
	if !ok {
		return Lesson{}, ErrLessonNotFound
	}
	return l, nil
}

func (f *fakeStore) ListCourseLessons(_ context.Context, courseID int64) ([]Lesson, error) {
	out := []Lesson{}
	for _, id := range f.courseLessons[courseID] {
		out = append(out, f.lessons[id])
	}
	return out, nil
}

func (f *fakeStore) FindLessonProgress(_ context.Context, enrollmentID, lessonID int64) (LessonProgress, error) {
	p, ok := f.progress[[2]int64{enrollmentID, lessonID}]
	if !ok {
		return LessonProgress{LessonID: lessonID, Status: LessonNotStarted}, nil
	}
	return p, nil
}

func (f *fakeStore) SaveLessonProgress(_ context.Context, enrollmentID, lessonID int64, watchedSeconds int, status string) error {
	key := [2]int64{enrollmentID, lessonID}
	existing, ok := f.progress[key]
	if ok && existing.Status == LessonCompleted {
		// Completed is terminal; only the watch counter keeps moving.
		if watchedSeconds > existing.WatchedSeconds {
			existing.WatchedSeconds = watchedSeconds
		}
		f.progress[key] = existing
		return nil
	}
	f.progress[key] = LessonProgress{LessonID: lessonID, Status: status, WatchedSeconds: watchedSeconds}
	return nil
}

func (f *fakeStore) CountCourseLessons(_ context.Context, courseID int64) (int, error) {
	return len(f.courseLessons[courseID]), nil
}

func (f *fakeStore) CountCompletedLessons(_ context.Context, enrollmentID int64) (int, error) {
	done := 0
	for key, p := range f.progress {
		if key[0] == enrollmentID && p.Status == LessonCompleted {
			done++
		}
	}
	return done, nil
}

func (f *fakeStore) UpdateEnrollmentProgress(_ context.Context, enrollmentID int64, progressPct float64, status string, lastLessonID int64) error {
	e, ok := f.byID[enrollmentID]
	if !ok {
		return ErrEnrollmentNotFound
	}
	e.ProgressPct = progressPct
	e.Status = status
	e.LastLessonID = &lastLessonID
	f.byID[enrollmentID] = e
	return nil
}

// ---- Fakes for the cross-domain seams ----

type fakePurchases struct{ paid bool }

func (f fakePurchases) HasPaidForCourse(context.Context, int64, int64) (bool, error) {
	return f.paid, nil
}

type fakeCertificates struct {
	issued []int64
	nextID int64
}

func (f *fakeCertificates) IssueForEnrollment(_ context.Context, enrollmentID int64) (int64, error) {
	for i, id := range f.issued {
		if id == enrollmentID {
			return int64(i + 1), nil // idempotent: same certificate every time
		}
	}
	f.issued = append(f.issued, enrollmentID)
	f.nextID++
	return f.nextID, nil
}

// ---- Helpers ----

func wantAppError(t *testing.T, err error, wantStatus int) {
	t.Helper()
	var appErr *platform.AppError
	if !errors.As(err, &appErr) {
		t.Fatalf("expected *platform.AppError, got %v", err)
	}
	if appErr.Status != wantStatus {
		t.Fatalf("expected status %d, got %d (%s)", wantStatus, appErr.Status, appErr.Code)
	}
}

// ---- Enrollment rules ----

func TestEnrollFreeCourseCreatesEnrollment(t *testing.T) {
	store := newFakeStore()
	store.addCourse(1, "published", 0, nil)
	service := NewService(store, fakePurchases{paid: false}, nil)

	enrollment, created, err := service.Enroll(context.Background(), 7, 1)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !created {
		t.Fatal("expected a newly created enrollment")
	}
	if enrollment.Progress != 0 {
		t.Fatalf("new enrollment should start at 0%%, got %v", enrollment.Progress)
	}
	if enrollment.Status != StatusInProgress {
		t.Fatalf("expected in_progress, got %q", enrollment.Status)
	}
}

func TestEnrollPaidCourseRequiresPurchase(t *testing.T) {
	store := newFakeStore()
	store.addCourse(1, "published", 4990, nil)
	service := NewService(store, fakePurchases{paid: false}, nil)

	_, _, err := service.Enroll(context.Background(), 7, 1)
	wantAppError(t, err, 402)

	if len(store.byUserCourse) != 0 {
		t.Fatal("a blocked enrollment must not write a row")
	}
}

func TestEnrollPaidCourseSucceedsOncePaid(t *testing.T) {
	store := newFakeStore()
	store.addCourse(1, "published", 4990, nil)
	service := NewService(store, fakePurchases{paid: true}, nil)

	_, created, err := service.Enroll(context.Background(), 7, 1)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !created {
		t.Fatal("expected enrollment to be created after purchase")
	}
}

// A discounted course is gated on what the learner actually pays, so a
// 100%-off discount must not demand a purchase.
func TestEnrollUsesEffectivePriceForGate(t *testing.T) {
	free := 0.0
	store := newFakeStore()
	store.addCourse(1, "published", 4990, &free)
	service := NewService(store, fakePurchases{paid: false}, nil)

	_, created, err := service.Enroll(context.Background(), 7, 1)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !created {
		t.Fatal("a fully discounted course should enroll without a purchase")
	}
}

func TestEnrollIsIdempotentForExistingEnrollment(t *testing.T) {
	store := newFakeStore()
	store.addCourse(1, "published", 0, nil)
	service := NewService(store, fakePurchases{}, nil)

	first, _, err := service.Enroll(context.Background(), 7, 1)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	second, created, err := service.Enroll(context.Background(), 7, 1)
	if err != nil {
		t.Fatalf("second enroll must not fail: %v", err)
	}
	if created {
		t.Fatal("second enroll must report created=false")
	}
	if first.ID != second.ID {
		t.Fatalf("expected the same enrollment back, got %d then %d", first.ID, second.ID)
	}
}

func TestEnrollHidesUnpublishedCourse(t *testing.T) {
	store := newFakeStore()
	store.addCourse(1, "draft", 0, nil)
	service := NewService(store, fakePurchases{}, nil)

	_, _, err := service.Enroll(context.Background(), 7, 1)
	wantAppError(t, err, 404)
}

func TestGetEnrollmentHidesOtherLearnersEnrollment(t *testing.T) {
	store := newFakeStore()
	store.addCourse(1, "published", 0, nil)
	service := NewService(store, fakePurchases{}, nil)

	owned, _, err := service.Enroll(context.Background(), 7, 1)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if _, err := service.GetEnrollment(context.Background(), 7, owned.ID); err != nil {
		t.Fatalf("owner should be able to read it: %v", err)
	}

	_, err = service.GetEnrollment(context.Background(), 99, owned.ID)
	wantAppError(t, err, 404)
}

func TestEnrollByUserAndCourseBypassesPurchaseGate(t *testing.T) {
	store := newFakeStore()
	store.addCourse(1, "published", 4990, nil)
	// The purchase checker would say "not paid" — the post-payment path
	// must not consult it, because the payment is already recorded.
	service := NewService(store, fakePurchases{paid: false}, nil)

	if err := service.EnrollByUserAndCourse(context.Background(), 7, 1); err != nil {
		t.Fatalf("post-payment enrollment failed: %v", err)
	}
	// Buying the same course twice must stay a success.
	if err := service.EnrollByUserAndCourse(context.Background(), 7, 1); err != nil {
		t.Fatalf("repeat enrollment must be a no-op, got: %v", err)
	}
}

// ---- Lesson access ----

func TestGetLessonAllowsPreviewWithoutEnrollment(t *testing.T) {
	store := newFakeStore()
	store.addCourse(1, "published", 0, nil)
	store.addLesson(1, 10, true)
	service := NewService(store, fakePurchases{}, nil)

	lesson, err := service.GetLesson(context.Background(), 7, 10)
	if err != nil {
		t.Fatalf("preview lesson should be readable: %v", err)
	}
	if !lesson.IsPreview {
		t.Fatal("expected is_preview to be reported")
	}
}

func TestGetLessonRequiresEnrollmentForNonPreview(t *testing.T) {
	store := newFakeStore()
	store.addCourse(1, "published", 0, nil)
	store.addLesson(1, 10, false)
	service := NewService(store, fakePurchases{}, nil)

	_, err := service.GetLesson(context.Background(), 7, 10)
	wantAppError(t, err, 403)
}

// ---- Progress and completion ----

func TestSaveLessonProgressRecomputesPercentage(t *testing.T) {
	store := newFakeStore()
	store.addCourse(1, "published", 0, nil)
	for _, id := range []int64{10, 11, 12, 13} {
		store.addLesson(1, id, false)
	}
	service := NewService(store, fakePurchases{}, nil)

	if _, _, err := service.Enroll(context.Background(), 7, 1); err != nil {
		t.Fatalf("enroll: %v", err)
	}

	result, err := service.SaveLessonProgress(context.Background(), 7, 10,
		SaveProgressRequest{WatchedSeconds: 480, Status: LessonCompleted})
	if err != nil {
		t.Fatalf("save progress: %v", err)
	}
	if result.Enrollment.Progress != 25 {
		t.Fatalf("expected 25%% after 1 of 4 lessons, got %v", result.Enrollment.Progress)
	}
	if result.CourseCompleted {
		t.Fatal("a quarter-done course must not report completion")
	}
	if result.CertificateID != nil {
		t.Fatal("no certificate should be issued before the course is finished")
	}
}

func TestSaveLessonProgressIssuesCertificateOnCompletion(t *testing.T) {
	store := newFakeStore()
	store.addCourse(1, "published", 0, nil)
	store.addLesson(1, 10, false)
	store.addLesson(1, 11, false)
	certs := &fakeCertificates{}
	service := NewService(store, fakePurchases{}, certs)

	if _, _, err := service.Enroll(context.Background(), 7, 1); err != nil {
		t.Fatalf("enroll: %v", err)
	}

	first, err := service.SaveLessonProgress(context.Background(), 7, 10,
		SaveProgressRequest{WatchedSeconds: 300, Status: LessonCompleted})
	if err != nil {
		t.Fatalf("save first lesson: %v", err)
	}
	if first.Enrollment.Progress != 50 {
		t.Fatalf("expected 50%%, got %v", first.Enrollment.Progress)
	}

	last, err := service.SaveLessonProgress(context.Background(), 7, 11,
		SaveProgressRequest{WatchedSeconds: 600, Status: LessonCompleted})
	if err != nil {
		t.Fatalf("save last lesson: %v", err)
	}
	if !last.CourseCompleted {
		t.Fatal("finishing the last lesson must complete the course")
	}
	if last.Enrollment.Progress != 100 {
		t.Fatalf("expected 100%%, got %v", last.Enrollment.Progress)
	}
	if last.Enrollment.Status != StatusCompleted {
		t.Fatalf("expected status completed, got %q", last.Enrollment.Status)
	}
	if last.CertificateID == nil {
		t.Fatal("expected a certificate to be issued on completion")
	}

	// Re-saving must reuse the same certificate, not mint a second one.
	again, err := service.SaveLessonProgress(context.Background(), 7, 11,
		SaveProgressRequest{WatchedSeconds: 900, Status: LessonCompleted})
	if err != nil {
		t.Fatalf("re-save: %v", err)
	}
	if again.CertificateID == nil || *again.CertificateID != *last.CertificateID {
		t.Fatalf("expected the same certificate, got %v then %v", last.CertificateID, again.CertificateID)
	}
	if len(certs.issued) != 1 {
		t.Fatalf("expected exactly 1 certificate for the enrollment, got %d", len(certs.issued))
	}
}

func TestSaveLessonProgressRejectsNegativeWatchedSeconds(t *testing.T) {
	store := newFakeStore()
	service := NewService(store, fakePurchases{}, nil)

	_, err := service.SaveLessonProgress(context.Background(), 7, 10,
		SaveProgressRequest{WatchedSeconds: -1, Status: LessonCompleted})
	wantAppError(t, err, 400)
}

func TestSaveLessonProgressRequiresEnrollment(t *testing.T) {
	store := newFakeStore()
	store.addCourse(1, "published", 0, nil)
	store.addLesson(1, 10, false)
	service := NewService(store, fakePurchases{}, nil)

	_, err := service.SaveLessonProgress(context.Background(), 7, 10,
		SaveProgressRequest{WatchedSeconds: 120, Status: LessonCompleted})
	wantAppError(t, err, 403)
}

// Claiming a lesson is complete without watching any of it is treated as an
// in-progress save, so a buggy client can't finish a course for free.
func TestSaveLessonProgressIgnoresZeroSecondCompletion(t *testing.T) {
	store := newFakeStore()
	store.addCourse(1, "published", 0, nil)
	store.addLesson(1, 10, false)
	service := NewService(store, fakePurchases{}, nil)

	if _, _, err := service.Enroll(context.Background(), 7, 1); err != nil {
		t.Fatalf("enroll: %v", err)
	}

	result, err := service.SaveLessonProgress(context.Background(), 7, 10,
		SaveProgressRequest{WatchedSeconds: 0, Status: LessonCompleted})
	if err != nil {
		t.Fatalf("save progress: %v", err)
	}
	if result.CourseCompleted {
		t.Fatal("a zero-second save must not complete the course")
	}
	if result.Lesson.Status != LessonInProgress {
		t.Fatalf("expected in_progress, got %q", result.Lesson.Status)
	}
}

func TestListMyCoursesIsScopedToTheCaller(t *testing.T) {
	store := newFakeStore()
	store.addCourse(1, "published", 0, nil)
	store.addCourse(2, "published", 0, nil)
	service := NewService(store, fakePurchases{}, nil)

	if _, _, err := service.Enroll(context.Background(), 7, 1); err != nil {
		t.Fatalf("enroll: %v", err)
	}
	if _, _, err := service.Enroll(context.Background(), 8, 2); err != nil {
		t.Fatalf("enroll: %v", err)
	}

	mine, err := service.ListMyCourses(context.Background(), 7)
	if err != nil {
		t.Fatalf("list: %v", err)
	}
	if len(mine) != 1 {
		t.Fatalf("expected exactly my 1 course, got %d", len(mine))
	}
	if mine[0].ID != 1 {
		t.Fatalf("expected course 1, got %d", mine[0].ID)
	}
}

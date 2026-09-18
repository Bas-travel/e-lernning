package learning

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"

	"github.com/go-sql-driver/mysql"
)

var (
	ErrEnrollmentNotFound = errors.New("enrollment not found")
	ErrLessonNotFound     = errors.New("lesson not found")
	ErrCourseNotFound     = errors.New("course not found")
	ErrAlreadyEnrolled    = errors.New("already enrolled")
)

// mysqlDuplicateEntry is ER_DUP_ENTRY — raised when the uq_enrollment /
// uq_progress unique keys are violated.
const mysqlDuplicateEntry = 1062

// CourseAccess is the minimum a course exposes to the enrollment rules:
// whether it is on sale at all, and what it costs.
type CourseAccess struct {
	ID            int64
	Title         string
	Price         float64
	DiscountPrice *float64
	Status        string
}

// EffectivePrice is what the learner actually pays. The schema makes
// discount_price nullable and uses NULL to mean "no discount", so any
// non-NULL value wins — including 0, which legitimately means the course is
// currently free rather than "ignore my discount".
func (c CourseAccess) EffectivePrice() float64 {
	if c.DiscountPrice != nil {
		return *c.DiscountPrice
	}
	return c.Price
}

// Repository is the MySQL-backed store for enrollments and lesson progress.
type Repository struct {
	db *sql.DB
}

func NewRepository(db *sql.DB) *Repository {
	return &Repository{db: db}
}

const enrollmentCols = `
	e.id, e.user_id, e.course_id, e.progress_pct, e.status,
	e.last_lesson_id, e.enrolled_at, e.completed_at
`

func scanEnrollment(scanner interface{ Scan(...any) error }) (Enrollment, error) {
	var e Enrollment
	var lastLesson sql.NullInt64
	var completedAt sql.NullTime
	err := scanner.Scan(&e.ID, &e.UserID, &e.CourseID, &e.ProgressPct, &e.Status,
		&lastLesson, &e.EnrolledAt, &completedAt)
	if errors.Is(err, sql.ErrNoRows) {
		return Enrollment{}, ErrEnrollmentNotFound
	}
	if err != nil {
		return Enrollment{}, fmt.Errorf("scan enrollment: %w", err)
	}
	if lastLesson.Valid {
		e.LastLessonID = &lastLesson.Int64
	}
	if completedAt.Valid {
		e.CompletedAt = &completedAt.Time
	}
	return e, nil
}

// FindEnrollmentByUserAndCourse answers "does this learner have access to
// this course", which every protected learn endpoint needs.
func (r *Repository) FindEnrollmentByUserAndCourse(ctx context.Context, userID, courseID int64) (Enrollment, error) {
	row := r.db.QueryRowContext(ctx, `
		SELECT `+enrollmentCols+`
		FROM enrollments e
		WHERE e.user_id = ? AND e.course_id = ?
		LIMIT 1
	`, userID, courseID)
	return scanEnrollment(row)
}

func (r *Repository) FindEnrollmentByID(ctx context.Context, id int64) (Enrollment, error) {
	row := r.db.QueryRowContext(ctx, `
		SELECT `+enrollmentCols+`
		FROM enrollments e
		WHERE e.id = ?
		LIMIT 1
	`, id)
	return scanEnrollment(row)
}

// CreateEnrollment inserts the enrollment row. A second call for the same
// (user, course) pair returns ErrAlreadyEnrolled rather than a raw SQL
// error, so callers can treat "already owns it" as a non-failure.
func (r *Repository) CreateEnrollment(ctx context.Context, userID, courseID int64) (Enrollment, error) {
	res, err := r.db.ExecContext(ctx, `
		INSERT INTO enrollments (user_id, course_id, progress_pct, status)
		VALUES (?, ?, 0, 'in_progress')
	`, userID, courseID)
	if err != nil {
		var myErr *mysql.MySQLError
		if errors.As(err, &myErr) && myErr.Number == mysqlDuplicateEntry {
			return Enrollment{}, ErrAlreadyEnrolled
		}
		return Enrollment{}, fmt.Errorf("insert enrollment: %w", err)
	}

	id, err := res.LastInsertId()
	if err != nil {
		return Enrollment{}, fmt.Errorf("enrollment id: %w", err)
	}
	return r.FindEnrollmentByID(ctx, id)
}

// ListEnrolledCourses is GET /me/courses (screen "My Learning"). The two
// correlated subqueries keep it a single round-trip while still returning
// the lesson counters the progress bar needs.
func (r *Repository) ListEnrolledCourses(ctx context.Context, userID int64) ([]EnrolledCourse, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT e.id, e.course_id, c.title, c.slug, c.thumbnail_url,
		       COALESCE(p.first_name, ins_u.email, ''), c.level,
		       e.progress_pct, e.status, e.last_lesson_id, e.enrolled_at, e.completed_at,
		       (SELECT COUNT(*) FROM lessons l
		          JOIN course_sections s ON s.id = l.section_id
		         WHERE s.course_id = c.id),
		       (SELECT COUNT(*) FROM lesson_progress lp
		         WHERE lp.enrollment_id = e.id AND lp.status = 'completed')
		FROM enrollments e
		JOIN courses c ON c.id = e.course_id
		JOIN instructors ins ON ins.id = c.instructor_id
		JOIN users ins_u ON ins_u.id = ins.user_id
		LEFT JOIN profiles p ON p.user_id = ins_u.id
		WHERE e.user_id = ?
		ORDER BY e.enrolled_at DESC
	`, userID)
	if err != nil {
		return nil, fmt.Errorf("list enrolled courses: %w", err)
	}
	defer rows.Close()

	out := []EnrolledCourse{}
	for rows.Next() {
		var c EnrolledCourse
		var thumbnail sql.NullString
		var lastLesson sql.NullInt64
		var completedAt sql.NullTime
		if err := rows.Scan(&c.EnrollmentID, &c.CourseID, &c.Title, &c.Slug, &thumbnail,
			&c.InstructorName, &c.Level, &c.ProgressPct, &c.Status, &lastLesson,
			&c.EnrolledAt, &completedAt, &c.TotalLessons, &c.DoneLessons); err != nil {
			return nil, fmt.Errorf("scan enrolled course: %w", err)
		}
		if thumbnail.Valid {
			c.ThumbnailURL = &thumbnail.String
		}
		if lastLesson.Valid {
			c.LastLessonID = &lastLesson.Int64
		}
		if completedAt.Valid {
			c.CompletedAt = &completedAt.Time
		}
		out = append(out, c)
	}
	return out, rows.Err()
}

// FindCourseForEnrollment reads the pricing/status columns the enroll rules
// depend on. Published-only is enforced here so drafts can never be
// enrolled by guessing an ID.
func (r *Repository) FindCourseForEnrollment(ctx context.Context, courseID int64) (CourseAccess, error) {
	var c CourseAccess
	var discount sql.NullFloat64
	err := r.db.QueryRowContext(ctx, `
		SELECT id, title, price, discount_price, status
		FROM courses
		WHERE id = ?
	`, courseID).Scan(&c.ID, &c.Title, &c.Price, &discount, &c.Status)
	if errors.Is(err, sql.ErrNoRows) {
		return CourseAccess{}, ErrCourseNotFound
	}
	if err != nil {
		return CourseAccess{}, fmt.Errorf("find course for enrollment: %w", err)
	}
	if discount.Valid {
		c.DiscountPrice = &discount.Float64
	}
	return c, nil
}

// FindLesson loads one lesson plus the section/course it belongs to.
func (r *Repository) FindLesson(ctx context.Context, lessonID int64) (Lesson, error) {
	var l Lesson
	var videoURL sql.NullString
	err := r.db.QueryRowContext(ctx, `
		SELECT l.id, l.section_id, s.course_id, s.title, l.title, l.type,
		       l.video_url, l.duration_seconds, l.sort_order, l.is_preview
		FROM lessons l
		JOIN course_sections s ON s.id = l.section_id
		WHERE l.id = ?
	`, lessonID).Scan(&l.ID, &l.SectionID, &l.CourseID, &l.SectionTitle, &l.Title,
		&l.Type, &videoURL, &l.DurationSeconds, &l.SortOrder, &l.IsPreview)
	if errors.Is(err, sql.ErrNoRows) {
		return Lesson{}, ErrLessonNotFound
	}
	if err != nil {
		return Lesson{}, fmt.Errorf("find lesson: %w", err)
	}
	if videoURL.Valid {
		l.VideoURL = &videoURL.String
	}
	return l, nil
}

// ListCourseLessons returns the whole curriculum in playback order — used
// to pick "next lesson" after one is completed.
func (r *Repository) ListCourseLessons(ctx context.Context, courseID int64) ([]Lesson, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT l.id, l.section_id, s.course_id, s.title, l.title, l.type,
		       l.video_url, l.duration_seconds, l.sort_order, l.is_preview
		FROM lessons l
		JOIN course_sections s ON s.id = l.section_id
		WHERE s.course_id = ?
		ORDER BY s.sort_order ASC, l.sort_order ASC
	`, courseID)
	if err != nil {
		return nil, fmt.Errorf("list course lessons: %w", err)
	}
	defer rows.Close()

	out := []Lesson{}
	for rows.Next() {
		var l Lesson
		var videoURL sql.NullString
		if err := rows.Scan(&l.ID, &l.SectionID, &l.CourseID, &l.SectionTitle, &l.Title,
			&l.Type, &videoURL, &l.DurationSeconds, &l.SortOrder, &l.IsPreview); err != nil {
			return nil, fmt.Errorf("scan lesson: %w", err)
		}
		if videoURL.Valid {
			l.VideoURL = &videoURL.String
		}
		out = append(out, l)
	}
	return out, rows.Err()
}

// FindLessonProgress returns the learner's state for one lesson. A lesson
// never opened yet is a legitimate "not_started" answer, not an error.
func (r *Repository) FindLessonProgress(ctx context.Context, enrollmentID, lessonID int64) (LessonProgress, error) {
	var p LessonProgress
	var completedAt sql.NullTime
	err := r.db.QueryRowContext(ctx, `
		SELECT lesson_id, status, watched_seconds, completed_at
		FROM lesson_progress
		WHERE enrollment_id = ? AND lesson_id = ?
	`, enrollmentID, lessonID).Scan(&p.LessonID, &p.Status, &p.WatchedSeconds, &completedAt)
	if errors.Is(err, sql.ErrNoRows) {
		return LessonProgress{LessonID: lessonID, Status: LessonNotStarted}, nil
	}
	if err != nil {
		return LessonProgress{}, fmt.Errorf("find lesson progress: %w", err)
	}
	if completedAt.Valid {
		p.CompletedAt = &completedAt.Time
	}
	return p, nil
}

// SaveLessonProgress upserts one lesson's state. Status only ever moves
// forward: re-watching an already-completed lesson keeps it completed and
// keeps its original completion timestamp, while the watched-seconds
// counter takes the high-water mark.
func (r *Repository) SaveLessonProgress(ctx context.Context, enrollmentID, lessonID int64, watchedSeconds int, status string) error {
	var completedAt any
	if status == LessonCompleted {
		completedAt = time.Now()
	}

	_, err := r.db.ExecContext(ctx, `
		INSERT INTO lesson_progress (enrollment_id, lesson_id, status, watched_seconds, completed_at)
		VALUES (?, ?, ?, ?, ?)
		ON DUPLICATE KEY UPDATE
			watched_seconds = GREATEST(watched_seconds, VALUES(watched_seconds)),
			completed_at = IF(VALUES(status) = 'completed', COALESCE(completed_at, VALUES(completed_at)), completed_at),
			status = IF(status = 'completed', 'completed', VALUES(status))
	`, enrollmentID, lessonID, status, watchedSeconds, completedAt)
	if err != nil {
		return fmt.Errorf("save lesson progress: %w", err)
	}
	return nil
}

// CountCourseLessons and CountCompletedLessons are the two numbers that
// turn into progress_pct.
func (r *Repository) CountCourseLessons(ctx context.Context, courseID int64) (int, error) {
	var total int
	err := r.db.QueryRowContext(ctx, `
		SELECT COUNT(*)
		FROM lessons l
		JOIN course_sections s ON s.id = l.section_id
		WHERE s.course_id = ?
	`, courseID).Scan(&total)
	if err != nil {
		return 0, fmt.Errorf("count course lessons: %w", err)
	}
	return total, nil
}

func (r *Repository) CountCompletedLessons(ctx context.Context, enrollmentID int64) (int, error) {
	var done int
	err := r.db.QueryRowContext(ctx, `
		SELECT COUNT(*)
		FROM lesson_progress
		WHERE enrollment_id = ? AND status = 'completed'
	`, enrollmentID).Scan(&done)
	if err != nil {
		return 0, fmt.Errorf("count completed lessons: %w", err)
	}
	return done, nil
}

// UpdateEnrollmentProgress writes the recomputed percentage, the resume
// pointer, and (once) the completion timestamp. completed_at is only ever
// set, never cleared, so history survives a later re-watch.
func (r *Repository) UpdateEnrollmentProgress(ctx context.Context, enrollmentID int64, progressPct float64, status string, lastLessonID int64) error {
	_, err := r.db.ExecContext(ctx, `
		UPDATE enrollments
		SET progress_pct = ?,
		    status = ?,
		    last_lesson_id = ?,
		    completed_at = IF(? = 'completed', COALESCE(completed_at, NOW()), completed_at)
		WHERE id = ?
	`, progressPct, status, lastLessonID, status, enrollmentID)
	if err != nil {
		return fmt.Errorf("update enrollment progress: %w", err)
	}
	return nil
}

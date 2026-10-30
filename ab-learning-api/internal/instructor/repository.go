package instructor

import (
	"database/sql"
	"errors"
	"strings"
)

var (
	ErrNotFound = errors.New("not found")
	ErrBadRef   = errors.New("referenced record does not exist")
)

type Repository struct{ db *sql.DB }

func NewRepository(db *sql.DB) *Repository { return &Repository{db: db} }

// InstructorID returns the instructors.id for a user, creating the profile
// row on first use.
func (r *Repository) InstructorID(userID int64) (int64, error) {
	var id int64
	err := r.db.QueryRow(`SELECT id FROM instructors WHERE user_id = ?`, userID).Scan(&id)
	if errors.Is(err, sql.ErrNoRows) {
		res, err := r.db.Exec(`INSERT INTO instructors (user_id) VALUES (?)`, userID)
		if err != nil {
			return 0, err
		}
		return res.LastInsertId()
	}
	return id, err
}

const courseCols = `
	c.id, c.title, c.slug, COALESCE(c.description,''), COALESCE(c.thumbnail_url,''), c.price, c.discount_price,
	c.level, c.language, c.status, COALESCE(c.rejected_reason,''), c.category_id, cat.slug,
	c.student_count, c.rating_avg,
	(SELECT COUNT(*) FROM lessons l JOIN course_sections s ON s.id = l.section_id WHERE s.course_id = c.id),
	c.duration_minutes, c.created_at, c.updated_at`

func scanCourse(sc interface{ Scan(...any) error }) (Course, error) {
	var c Course
	var d sql.NullFloat64
	err := sc.Scan(&c.ID, &c.Title, &c.Slug, &c.Description, &c.ThumbnailURL, &c.Price, &d,
		&c.Level, &c.Language, &c.Status, &c.RejectedReason, &c.CategoryID, &c.Category,
		&c.StudentCount, &c.RatingAvg, &c.LessonCount, &c.DurationMin, &c.CreatedAt, &c.UpdatedAt)
	if d.Valid {
		v := d.Float64
		c.DiscountPrice = &v
	}
	return c, err
}

func (r *Repository) ListCourses(instrID int64, status string) ([]Course, error) {
	q := `SELECT ` + courseCols + ` FROM courses c JOIN categories cat ON cat.id = c.category_id WHERE c.instructor_id = ?`
	args := []any{instrID}
	if status != "" {
		q += ` AND c.status = ?`
		args = append(args, status)
	}
	rows, err := r.db.Query(q+` ORDER BY c.updated_at DESC, c.id DESC`, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []Course{}
	for rows.Next() {
		c, err := scanCourse(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, c)
	}
	return out, rows.Err()
}

func (r *Repository) GetCourse(instrID, id int64) (Course, error) {
	c, err := scanCourse(r.db.QueryRow(`SELECT `+courseCols+` FROM courses c JOIN categories cat ON cat.id = c.category_id
		WHERE c.id = ? AND c.instructor_id = ?`, id, instrID))
	if errors.Is(err, sql.ErrNoRows) {
		return Course{}, ErrNotFound
	}
	if err != nil {
		return Course{}, err
	}
	c.Sections, err = r.sections(id)
	return c, err
}

func (r *Repository) sections(courseID int64) ([]Section, error) {
	rows, err := r.db.Query(`
		SELECT s.id, s.course_id, s.title, s.sort_order,
		       l.id, l.title, l.type, COALESCE(l.video_url,''), l.duration_seconds, l.is_preview, l.sort_order
		FROM course_sections s LEFT JOIN lessons l ON l.section_id = s.id
		WHERE s.course_id = ? ORDER BY s.sort_order, s.id, l.sort_order, l.id`, courseID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []Section{}
	idx := map[int64]int{}
	for rows.Next() {
		var s Section
		var lid, dur, lsort sql.NullInt64
		var ltitle, ltype, lurl sql.NullString
		var prev sql.NullBool
		if err := rows.Scan(&s.ID, &s.CourseID, &s.Title, &s.SortOrder, &lid, &ltitle, &ltype, &lurl, &dur, &prev, &lsort); err != nil {
			return nil, err
		}
		i, ok := idx[s.ID]
		if !ok {
			s.Lessons = []Lesson{}
			out = append(out, s)
			i = len(out) - 1
			idx[s.ID] = i
		}
		if lid.Valid {
			out[i].Lessons = append(out[i].Lessons, Lesson{ID: lid.Int64, SectionID: s.ID, Title: ltitle.String,
				Type: ltype.String, VideoURL: lurl.String, DurationSeconds: int(dur.Int64),
				IsPreview: prev.Bool, SortOrder: int(lsort.Int64)})
		}
	}
	return out, rows.Err()
}

func (r *Repository) CreateCourse(instrID int64, in CourseInput, slug string) (int64, error) {
	var discount any
	if in.DiscountPrice != nil {
		discount = *in.DiscountPrice
	}
	res, err := r.db.Exec(`INSERT INTO courses (instructor_id, category_id, title, slug, description, level, language,
		thumbnail_url, price, discount_price, status) VALUES (?,?,?,?,?,?,?,?,?,?, 'draft')`,
		instrID, in.CategoryID, in.Title, slug, in.Description, in.Level, in.Language, nullStr(in.ThumbnailURL), in.Price, discount)
	if err != nil {
		if isFKError(err) {
			return 0, ErrBadRef
		}
		return 0, err
	}
	return res.LastInsertId()
}

func (r *Repository) UpdateCourse(id int64, in CourseInput) error {
	var discount any
	if in.DiscountPrice != nil {
		discount = *in.DiscountPrice
	}
	_, err := r.db.Exec(`UPDATE courses SET category_id=?, title=?, description=?, level=?, language=?, thumbnail_url=?,
		price=?, discount_price=? WHERE id=?`,
		in.CategoryID, in.Title, in.Description, in.Level, in.Language, nullStr(in.ThumbnailURL), in.Price, discount, id)
	if isFKError(err) {
		return ErrBadRef
	}
	return err
}

func (r *Repository) DeleteCourse(id int64) error {
	_, err := r.db.Exec(`DELETE FROM courses WHERE id = ?`, id)
	return err
}

func (r *Repository) SetStatus(id int64, status string) error {
	_, err := r.db.Exec(`UPDATE courses SET status = ?, rejected_reason = NULL WHERE id = ?`, status, id)
	return err
}

// CourseMeta is the ownership/state info used to guard builder writes.
type CourseMeta struct {
	ID, InstructorID int64
	Status           string
}

func (r *Repository) CourseMeta(id int64) (CourseMeta, error) {
	var m CourseMeta
	err := r.db.QueryRow(`SELECT id, instructor_id, status FROM courses WHERE id = ?`, id).Scan(&m.ID, &m.InstructorID, &m.Status)
	if errors.Is(err, sql.ErrNoRows) {
		return m, ErrNotFound
	}
	return m, err
}

func (r *Repository) CourseMetaBySection(sectionID int64) (CourseMeta, error) {
	var m CourseMeta
	err := r.db.QueryRow(`SELECT c.id, c.instructor_id, c.status FROM course_sections s JOIN courses c ON c.id = s.course_id
		WHERE s.id = ?`, sectionID).Scan(&m.ID, &m.InstructorID, &m.Status)
	if errors.Is(err, sql.ErrNoRows) {
		return m, ErrNotFound
	}
	return m, err
}

func (r *Repository) CourseMetaByLesson(lessonID int64) (CourseMeta, error) {
	var m CourseMeta
	err := r.db.QueryRow(`SELECT c.id, c.instructor_id, c.status FROM lessons l JOIN course_sections s ON s.id = l.section_id
		JOIN courses c ON c.id = s.course_id WHERE l.id = ?`, lessonID).Scan(&m.ID, &m.InstructorID, &m.Status)
	if errors.Is(err, sql.ErrNoRows) {
		return m, ErrNotFound
	}
	return m, err
}

func (r *Repository) CreateSection(in SectionInput) (Section, error) {
	if in.SortOrder <= 0 {
		_ = r.db.QueryRow(`SELECT COALESCE(MAX(sort_order),0)+1 FROM course_sections WHERE course_id = ?`, in.CourseID).Scan(&in.SortOrder)
	}
	res, err := r.db.Exec(`INSERT INTO course_sections (course_id, title, sort_order) VALUES (?,?,?)`, in.CourseID, in.Title, in.SortOrder)
	if err != nil {
		return Section{}, err
	}
	id, _ := res.LastInsertId()
	return Section{ID: id, CourseID: in.CourseID, Title: in.Title, SortOrder: in.SortOrder, Lessons: []Lesson{}}, nil
}

func (r *Repository) UpdateSection(id int64, in SectionInput) error {
	if in.SortOrder > 0 {
		_, err := r.db.Exec(`UPDATE course_sections SET title=?, sort_order=? WHERE id=?`, in.Title, in.SortOrder, id)
		return err
	}
	_, err := r.db.Exec(`UPDATE course_sections SET title=? WHERE id=?`, in.Title, id)
	return err
}

func (r *Repository) DeleteSection(id int64) error {
	_, err := r.db.Exec(`DELETE FROM course_sections WHERE id = ?`, id)
	return err
}

func (r *Repository) CreateLesson(in LessonInput) (Lesson, error) {
	if in.SortOrder <= 0 {
		_ = r.db.QueryRow(`SELECT COALESCE(MAX(sort_order),0)+1 FROM lessons WHERE section_id = ?`, in.SectionID).Scan(&in.SortOrder)
	}
	res, err := r.db.Exec(`INSERT INTO lessons (section_id, title, type, video_url, duration_seconds, is_preview, sort_order)
		VALUES (?,?,?,?,?,?,?)`, in.SectionID, in.Title, in.Type, nullStr(in.VideoURL), in.DurationSeconds, in.IsPreview, in.SortOrder)
	if err != nil {
		return Lesson{}, err
	}
	id, _ := res.LastInsertId()
	return Lesson{ID: id, SectionID: in.SectionID, Title: in.Title, Type: in.Type, VideoURL: in.VideoURL,
		DurationSeconds: in.DurationSeconds, IsPreview: in.IsPreview, SortOrder: in.SortOrder}, nil
}

func (r *Repository) UpdateLesson(id int64, in LessonInput) error {
	_, err := r.db.Exec(`UPDATE lessons SET title=?, type=?, video_url=?, duration_seconds=?, is_preview=?,
		sort_order = IF(? > 0, ?, sort_order) WHERE id=?`,
		in.Title, in.Type, nullStr(in.VideoURL), in.DurationSeconds, in.IsPreview, in.SortOrder, in.SortOrder, id)
	return err
}

func (r *Repository) DeleteLesson(id int64) error {
	_, err := r.db.Exec(`DELETE FROM lessons WHERE id = ?`, id)
	return err
}

// RecomputeDuration keeps courses.duration_minutes in sync with its lessons.
func (r *Repository) RecomputeDuration(courseID int64) {
	_, _ = r.db.Exec(`UPDATE courses SET duration_minutes = COALESCE((
		SELECT CEIL(SUM(l.duration_seconds)/60) FROM lessons l JOIN course_sections s ON s.id = l.section_id
		WHERE s.course_id = courses.id), 0) WHERE id = ?`, courseID)
}

// SubmitReadiness returns problems that block submitting a course for review.
func (r *Repository) SubmitReadiness(courseID int64) (lessons int, videoMissing int, err error) {
	err = r.db.QueryRow(`SELECT COUNT(*), COALESCE(SUM(l.type='video' AND (l.video_url IS NULL OR l.video_url='')),0)
		FROM lessons l JOIN course_sections s ON s.id = l.section_id WHERE s.course_id = ?`, courseID).Scan(&lessons, &videoMissing)
	return
}

func (r *Repository) Dashboard(instrID int64) (Dashboard, error) {
	var d Dashboard
	if err := r.db.QueryRow(`SELECT COALESCE(SUM(oi.price),0) FROM order_items oi
		JOIN orders o ON o.id = oi.order_id AND o.status = 'paid'
		JOIN courses c ON c.id = oi.course_id WHERE c.instructor_id = ?`, instrID).Scan(&d.RevenueTotal); err != nil {
		return d, err
	}
	if err := r.db.QueryRow(`SELECT COUNT(*), COALESCE(SUM(status='published'),0),
		COALESCE(SUM(IF(status='published', student_count, 0)),0),
		COALESCE(AVG(IF(status='published' AND rating_avg > 0, rating_avg, NULL)),0)
		FROM courses WHERE instructor_id = ?`, instrID).Scan(&d.CoursesTotal, &d.CoursesPublished, &d.StudentsTotal, &d.RatingAvg); err != nil {
		return d, err
	}
	if err := r.db.QueryRow(`SELECT COALESCE(AVG(e.progress_pct),0) FROM enrollments e
		JOIN courses c ON c.id = e.course_id WHERE c.instructor_id = ?`, instrID).Scan(&d.CompletionAvgPct); err != nil {
		return d, err
	}
	rows, err := r.db.Query(`SELECT id, title, student_count, rating_avg FROM courses
		WHERE instructor_id = ? AND status = 'published' ORDER BY student_count DESC LIMIT 3`, instrID)
	if err != nil {
		return d, err
	}
	defer rows.Close()
	d.TopCourses = []TopCourse{}
	for rows.Next() {
		var t TopCourse
		if err := rows.Scan(&t.ID, &t.Title, &t.StudentCount, &t.RatingAvg); err != nil {
			return d, err
		}
		d.TopCourses = append(d.TopCourses, t)
	}
	return d, rows.Err()
}

func (r *Repository) Revenue(instrID int64) (Revenue, error) {
	var rev Revenue
	if err := r.db.QueryRow(`SELECT COALESCE(SUM(gross_amount),0), COALESCE(SUM(platform_fee),0), COALESCE(SUM(net_amount),0),
		COALESCE(SUM(IF(status='pending', net_amount, 0)),0), COALESCE(SUM(IF(status='paid', net_amount, 0)),0)
		FROM creator_payouts WHERE instructor_id = ?`, instrID).Scan(&rev.Gross, &rev.PlatformFee, &rev.Net, &rev.Pending, &rev.PaidOut); err != nil {
		return rev, err
	}
	rows, err := r.db.Query(`SELECT id, DATE_FORMAT(period_start,'%Y-%m-%d'), DATE_FORMAT(period_end,'%Y-%m-%d'),
		gross_amount, platform_fee, net_amount, status, paid_at FROM creator_payouts
		WHERE instructor_id = ? ORDER BY period_start DESC`, instrID)
	if err != nil {
		return rev, err
	}
	defer rows.Close()
	rev.Payouts = []Payout{}
	for rows.Next() {
		var p Payout
		var paid sql.NullTime
		if err := rows.Scan(&p.ID, &p.PeriodStart, &p.PeriodEnd, &p.Gross, &p.PlatformFee, &p.Net, &p.Status, &paid); err != nil {
			return rev, err
		}
		if paid.Valid {
			t := paid.Time
			p.PaidAt = &t
		}
		rev.Payouts = append(rev.Payouts, p)
	}
	return rev, rows.Err()
}

func nullStr(s string) any {
	if s == "" {
		return nil
	}
	return s
}

// isFKError detects MySQL error 1452 (foreign key constraint fails).
func isFKError(err error) bool {
	return err != nil && strings.Contains(err.Error(), "Error 1452")
}

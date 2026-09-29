package courses

import (
	"database/sql"
	"errors"
	"strings"

	"github.com/ablearning/api/internal/database"
)

var ErrNotFound = errors.New("course not found")

type Repository struct{ db *sql.DB }

func NewRepository(db *sql.DB) *Repository { return &Repository{db: db} }

const courseSelect = `
	SELECT c.id, c.title, c.slug, COALESCE(c.description,''), COALESCE(c.thumbnail_url,''),
	       c.price, c.discount_price, c.rating_avg, c.student_count, c.level, c.status,
	       cat.slug, i.id, TRIM(CONCAT(COALESCE(p.first_name,''),' ',COALESCE(p.last_name,'')))
	FROM courses c
	JOIN categories cat ON cat.id = c.category_id
	JOIN instructors i ON i.id = c.instructor_id
	LEFT JOIN profiles p ON p.user_id = i.user_id`

func scanCourse(sc interface{ Scan(...any) error }) (Course, error) {
	var c Course
	var discount sql.NullFloat64
	err := sc.Scan(&c.ID, &c.Title, &c.Slug, &c.Description, &c.ThumbnailURL, &c.Price, &discount,
		&c.RatingAvg, &c.StudentCount, &c.Level, &c.Status, &c.Category, &c.Instructor.ID, &c.Instructor.DisplayName)
	if discount.Valid {
		v := discount.Float64
		c.DiscountPrice = &v
	}
	return c, err
}

func (r *Repository) List(f ListFilter) ([]Course, error) {
	where := []string{"c.status = 'published'"}
	var args []any
	if f.Category != "" {
		where = append(where, "cat.slug = ?")
		args = append(args, f.Category)
	}
	if f.Level != "" {
		where = append(where, "c.level = ?")
		args = append(args, f.Level)
	}
	if f.Query != "" {
		where = append(where, "(c.title LIKE ? OR c.description LIKE ?)")
		args = append(args, database.Like(f.Query), database.Like(f.Query))
	}
	args = append(args, f.Limit, f.Offset)
	rows, err := r.db.Query(courseSelect+" WHERE "+strings.Join(where, " AND ")+
		" ORDER BY c.student_count DESC, c.id DESC LIMIT ? OFFSET ?", args...)
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

func (r *Repository) Get(id int64) (Course, error) {
	c, err := scanCourse(r.db.QueryRow(courseSelect+" WHERE c.id = ? AND c.status = 'published'", id))
	if errors.Is(err, sql.ErrNoRows) {
		return Course{}, ErrNotFound
	}
	return c, err
}

func (r *Repository) Curriculum(courseID int64) ([]Section, error) {
	rows, err := r.db.Query(`
		SELECT s.id, s.title, l.id, l.title, l.type, l.duration_seconds, COALESCE(l.video_url,''), l.is_preview
		FROM course_sections s
		LEFT JOIN lessons l ON l.section_id = s.id
		WHERE s.course_id = ?
		ORDER BY s.sort_order, s.id, l.sort_order, l.id`, courseID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	sections := []Section{}
	idx := map[int64]int{}
	for rows.Next() {
		var sid int64
		var stitle string
		var lid sql.NullInt64
		var ltitle, ltype, lurl sql.NullString
		var dur sql.NullInt64
		var preview sql.NullBool
		if err := rows.Scan(&sid, &stitle, &lid, &ltitle, &ltype, &dur, &lurl, &preview); err != nil {
			return nil, err
		}
		i, ok := idx[sid]
		if !ok {
			sections = append(sections, Section{ID: sid, Title: stitle, Lessons: []Lesson{}})
			i = len(sections) - 1
			idx[sid] = i
		}
		if lid.Valid {
			sections[i].Lessons = append(sections[i].Lessons, Lesson{
				ID: lid.Int64, Title: ltitle.String, Type: ltype.String,
				DurationSeconds: int(dur.Int64), VideoURL: lurl.String, IsPreview: preview.Bool,
			})
		}
	}
	return sections, rows.Err()
}

type Category struct {
	ID     int64  `json:"id"`
	NameTH string `json:"name_th"`
	NameEN string `json:"name_en"`
	Slug   string `json:"slug"`
}

func (r *Repository) Categories() ([]Category, error) {
	rows, err := r.db.Query(`SELECT id, name_th, name_en, slug FROM categories ORDER BY id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []Category{}
	for rows.Next() {
		var c Category
		if err := rows.Scan(&c.ID, &c.NameTH, &c.NameEN, &c.Slug); err != nil {
			return nil, err
		}
		out = append(out, c)
	}
	return out, rows.Err()
}

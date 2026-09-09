package courses

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"strings"
)

var ErrNotFound = errors.New("course not found")

type Repository struct {
	db *sql.DB
}

func NewRepository(db *sql.DB) *Repository {
	return &Repository{db: db}
}

const baseSelect = `
	SELECT c.id, c.title, c.slug, c.description, c.thumbnail_url, c.price,
	       c.discount_price, c.rating_avg, c.student_count, c.level, c.status,
	       COALESCE(p.first_name, u.email, ''), cat.name_en
	FROM courses c
	JOIN instructors ins ON ins.id = c.instructor_id
	JOIN users u ON u.id = ins.user_id
	LEFT JOIN profiles p ON p.user_id = u.id
	JOIN categories cat ON cat.id = c.category_id
`

//	func scanCourse(scanner interface{ Scan(...any) error }) (Course, error) {
//		var c Course
//		var discount sql.NullFloat64
//		err := scanner.Scan(&c.ID, &c.Title, &c.Slug, &c.Description, &c.ThumbnailURL,
//			&c.Price, &discount, &c.RatingAvg, &c.StudentCount, &c.Level, &c.Status,
//			&c.InstructorName, &c.CategoryName)
//		if discount.Valid {
//			c.DiscountPrice = &discount.Float64
//		}
//		return c, err
//	}
func scanCourse(scanner interface{ Scan(...any) error }) (Course, error) {
	var c Course
	var discount sql.NullFloat64
	var thumbnail sql.NullString
	err := scanner.Scan(&c.ID, &c.Title, &c.Slug, &c.Description, &thumbnail,
		&c.Price, &discount, &c.RatingAvg, &c.StudentCount, &c.Level, &c.Status,
		&c.InstructorName, &c.CategoryName)
	if discount.Valid {
		c.DiscountPrice = &discount.Float64
	}
	if thumbnail.Valid {
		c.ThumbnailURL = &thumbnail.String
	}
	return c, err
}

// List implements GET /api/v1/courses (screen 09 — Explore) with optional
// category/level filters and simple offset pagination.
func (repo *Repository) List(ctx context.Context, params ListParams) ([]Course, error) {
	query := baseSelect + ` WHERE c.status = 'published'`
	args := []any{}

	if params.Category != "" {
		query += ` AND cat.slug = ?`
		args = append(args, params.Category)
	}
	if params.Level != "" {
		query += ` AND c.level = ?`
		args = append(args, params.Level)
	}

	if params.Page < 1 {
		params.Page = 1
	}
	if params.Limit < 1 || params.Limit > 100 {
		params.Limit = 20
	}
	offset := (params.Page - 1) * params.Limit

	query += ` ORDER BY c.created_at DESC LIMIT ? OFFSET ?`
	args = append(args, params.Limit, offset)

	rows, err := repo.db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("list courses: %w", err)
	}
	defer rows.Close()

	var out []Course
	for rows.Next() {
		c, err := scanCourse(rows)
		if err != nil {
			return nil, fmt.Errorf("scan course row: %w", err)
		}
		out = append(out, c)
	}
	if out == nil {
		out = []Course{}
	}
	return out, rows.Err()
}

// Search implements GET /api/v1/search?q= (screen 10) — a simple LIKE
// match on title; swap for full-text search (or an external index) once
// the catalog is large enough for it to matter.
func (repo *Repository) Search(ctx context.Context, q string, limit int) ([]Course, error) {
	if limit < 1 {
		limit = 20
	}
	rows, err := repo.db.QueryContext(ctx, baseSelect+`
		WHERE c.status = 'published' AND c.title LIKE ?
		ORDER BY c.rating_avg DESC
		LIMIT ?
	`, "%"+strings.TrimSpace(q)+"%", limit)
	if err != nil {
		return nil, fmt.Errorf("search courses: %w", err)
	}
	defer rows.Close()

	var out []Course
	for rows.Next() {
		c, err := scanCourse(rows)
		if err != nil {
			return nil, fmt.Errorf("scan course row: %w", err)
		}
		out = append(out, c)
	}
	if out == nil {
		out = []Course{}
	}
	return out, rows.Err()
}

func (repo *Repository) FindByID(ctx context.Context, id int64) (Course, error) {
	row := repo.db.QueryRowContext(ctx, baseSelect+` WHERE c.id = ?`, id)
	c, err := scanCourse(row)
	if errors.Is(err, sql.ErrNoRows) {
		return Course{}, ErrNotFound
	}
	if err != nil {
		return Course{}, fmt.Errorf("find course: %w", err)
	}
	return c, nil
}

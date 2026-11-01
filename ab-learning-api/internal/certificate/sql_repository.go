package certificate

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
	"strings"

	"database/sql"
)

var ErrEnrollmentIncomplete = errors.New("certificate requires a completed enrollment")

type SQLRepository struct {
	db *sql.DB
}

type Record struct {
	ID              int64  `json:"id"`
	CertificateCode string `json:"certificate_code"`
	CourseName      string `json:"course_name"`
	PDFURL          string `json:"pdf_url"`
	IssuedAt        string `json:"issued_at"`
}

func NewSQLRepository(db *sql.DB) *SQLRepository {
	return &SQLRepository{db: db}
}

func (r *SQLRepository) ListForUser(ctx context.Context, userID int64) ([]Record, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT c.id, c.certificate_code, co.title, c.issued_at
		FROM certificates c
		JOIN enrollments e ON e.id = c.enrollment_id
		JOIN courses co ON co.id = e.course_id
		WHERE e.user_id = ?
		ORDER BY c.issued_at DESC, c.id DESC
	`, userID)
	if err != nil {
		return nil, fmt.Errorf("list certificates: %w", err)
	}
	defer rows.Close()

	records := make([]Record, 0)
	for rows.Next() {
		var record Record
		var issuedAt sql.NullTime
		if err := rows.Scan(&record.ID, &record.CertificateCode, &record.CourseName, &issuedAt); err != nil {
			return nil, fmt.Errorf("scan certificate: %w", err)
		}
		if issuedAt.Valid {
			record.IssuedAt = issuedAt.Time.UTC().Format("2006-01-02T15:04:05Z")
		}
		record.PDFURL = fmt.Sprintf("/api/v1/certificates/%d/download", record.ID)
		records = append(records, record)
	}
	return records, rows.Err()
}

func (r *SQLRepository) GetForUser(ctx context.Context, userID, certificateID int64) (Record, error) {
	var record Record
	var issuedAt sql.NullTime
	err := r.db.QueryRowContext(ctx, `
		SELECT c.id, c.certificate_code, co.title, c.issued_at
		FROM certificates c
		JOIN enrollments e ON e.id = c.enrollment_id
		JOIN courses co ON co.id = e.course_id
		WHERE e.user_id = ? AND c.id = ?
	`, userID, certificateID).Scan(&record.ID, &record.CertificateCode, &record.CourseName, &issuedAt)
	if errors.Is(err, sql.ErrNoRows) {
		return Record{}, sql.ErrNoRows
	}
	if err != nil {
		return Record{}, fmt.Errorf("get certificate: %w", err)
	}
	if issuedAt.Valid {
		record.IssuedAt = issuedAt.Time.UTC().Format("2006-01-02T15:04:05Z")
	}
	record.PDFURL = fmt.Sprintf("/api/v1/certificates/%d/download", record.ID)
	return record, nil
}

func (r *SQLRepository) IssueForEnrollment(ctx context.Context, enrollmentID int64) (int64, error) {
	var status string
	err := r.db.QueryRowContext(ctx,
		`SELECT status FROM enrollments WHERE id = ?`, enrollmentID,
	).Scan(&status)
	if errors.Is(err, sql.ErrNoRows) || (err == nil && status != "completed") {
		return 0, ErrEnrollmentIncomplete
	}
	if err != nil {
		return 0, fmt.Errorf("load certificate enrollment: %w", err)
	}

	var randomCode [16]byte
	if _, err := rand.Read(randomCode[:]); err != nil {
		return 0, fmt.Errorf("generate certificate code: %w", err)
	}
	code := "AB-" + strings.ToUpper(hex.EncodeToString(randomCode[:]))
	result, err := r.db.ExecContext(ctx, `
		INSERT INTO certificates (enrollment_id, certificate_code)
		VALUES (?, ?)
		ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id)
	`, enrollmentID, code)
	if err != nil {
		return 0, fmt.Errorf("issue certificate: %w", err)
	}
	id, err := result.LastInsertId()
	if err != nil {
		return 0, fmt.Errorf("read certificate id: %w", err)
	}
	if id == 0 {
		return 0, errors.New("certificate issuer returned an empty id")
	}
	return id, nil
}

package admin

import (
	"database/sql"
	"encoding/json"
	"errors"
	"strings"

	"github.com/ablearning/api/internal/database"
)

var (
	ErrNotFound = errors.New("not found")
	ErrState    = errors.New("invalid state for this action")
)

type Repository struct{ db *sql.DB }

func NewRepository(db *sql.DB) *Repository { return &Repository{db: db} }

func (r *Repository) Dashboard() (Dashboard, error) {
	var d Dashboard
	err := r.db.QueryRow(`SELECT
		(SELECT COUNT(*) FROM users),
		(SELECT COUNT(*) FROM users u JOIN roles r ON r.id=u.role_id WHERE r.code='LEARNER'),
		(SELECT COUNT(*) FROM users u JOIN roles r ON r.id=u.role_id WHERE r.code='INSTRUCTOR'),
		(SELECT COUNT(*) FROM courses WHERE status='published'),
		(SELECT COUNT(*) FROM courses WHERE status='pending_review'),
		COALESCE((SELECT SUM(amount) FROM payments WHERE status='success'),0)
		  - COALESCE((SELECT SUM(amount) FROM refunds WHERE status='processed'),0),
		COALESCE((SELECT SUM(grand_total) FROM orders WHERE status IN ('paid','refunded')),0),
		(SELECT COUNT(*) FROM reports WHERE status='open')`).
		Scan(&d.UsersTotal, &d.Learners, &d.Instructors, &d.CoursesPublished, &d.CoursesPending, &d.Revenue, &d.GMV, &d.OpenReports)
	return d, err
}

// ---- moderation ----------------------------------------------------------

func (r *Repository) ModerationList(status string) ([]ModerationCourse, error) {
	q := `SELECT c.id, c.title, TRIM(CONCAT(COALESCE(p.first_name,''),' ',COALESCE(p.last_name,''))), cat.slug, c.price,
		c.status, COALESCE(c.rejected_reason,''),
		(SELECT COUNT(*) FROM lessons l JOIN course_sections s ON s.id=l.section_id WHERE s.course_id=c.id),
		(SELECT COUNT(*) FROM reports rp WHERE rp.target_type='course' AND rp.target_id=c.id AND rp.status='open'),
		c.updated_at
		FROM courses c JOIN instructors i ON i.id=c.instructor_id
		LEFT JOIN profiles p ON p.user_id=i.user_id JOIN categories cat ON cat.id=c.category_id `
	var args []any
	if status == "reported" {
		q += `WHERE EXISTS (SELECT 1 FROM reports rp WHERE rp.target_type='course' AND rp.target_id=c.id AND rp.status='open') `
	} else {
		q += `WHERE c.status = ? `
		args = append(args, status)
	}
	rows, err := r.db.Query(q+`ORDER BY c.updated_at DESC LIMIT 200`, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []ModerationCourse{}
	for rows.Next() {
		var m ModerationCourse
		if err := rows.Scan(&m.ID, &m.Title, &m.Instructor, &m.Category, &m.Price, &m.Status, &m.RejectedReason,
			&m.LessonCount, &m.OpenReports, &m.UpdatedAt); err != nil {
			return nil, err
		}
		out = append(out, m)
	}
	return out, rows.Err()
}

// Moderate transitions a pending_review course to published/rejected and
// writes the audit log atomically.
func (r *Repository) Moderate(courseID, adminID int64, approve bool, reason string) error {
	tx, err := r.db.Begin()
	if err != nil {
		return err
	}
	defer tx.Rollback()
	var status string
	if err := tx.QueryRow(`SELECT status FROM courses WHERE id = ? FOR UPDATE`, courseID).Scan(&status); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return ErrNotFound
		}
		return err
	}
	if status != "pending_review" {
		return ErrState
	}
	action := "course.approve"
	if approve {
		_, err = tx.Exec(`UPDATE courses SET status='published', published_at=NOW(), rejected_reason=NULL WHERE id=?`, courseID)
	} else {
		action = "course.reject"
		_, err = tx.Exec(`UPDATE courses SET status='rejected', rejected_reason=? WHERE id=?`, reason, courseID)
	}
	if err != nil {
		return err
	}
	if err := audit(tx, adminID, action, "course", courseID, map[string]any{"reason": reason}); err != nil {
		return err
	}
	return tx.Commit()
}

func audit(tx *sql.Tx, actor int64, action, targetType string, targetID int64, meta map[string]any) error {
	b, _ := json.Marshal(meta)
	_, err := tx.Exec(`INSERT INTO audit_logs (actor_id, action, target_type, target_id, metadata) VALUES (?,?,?,?,?)`,
		actor, action, targetType, targetID, string(b))
	return err
}

// ---- users ---------------------------------------------------------------

const userCols = `u.id, u.email, r.code, u.status, COALESCE(p.first_name,''), COALESCE(p.last_name,''), u.created_at, u.last_login_at`
const userFrom = ` FROM users u JOIN roles r ON r.id=u.role_id LEFT JOIN profiles p ON p.user_id=u.id `

func scanUser(sc interface{ Scan(...any) error }) (User, error) {
	var u User
	var last sql.NullTime
	err := sc.Scan(&u.ID, &u.Email, &u.Role, &u.Status, &u.FirstName, &u.LastName, &u.CreatedAt, &last)
	if last.Valid {
		t := last.Time
		u.LastLoginAt = &t
	}
	return u, err
}

func (r *Repository) ListUsers(f UserFilter) ([]User, error) {
	where := []string{"1=1"}
	var args []any
	if f.Role != "" {
		where = append(where, "r.code = ?")
		args = append(args, f.Role)
	}
	if f.Status != "" {
		where = append(where, "u.status = ?")
		args = append(args, f.Status)
	}
	if f.Query != "" {
		where = append(where, "(u.email LIKE ? OR p.first_name LIKE ? OR p.last_name LIKE ?)")
		l := database.Like(f.Query)
		args = append(args, l, l, l)
	}
	args = append(args, f.Limit, f.Offset)
	rows, err := r.db.Query(`SELECT `+userCols+userFrom+` WHERE `+strings.Join(where, " AND ")+` ORDER BY u.id DESC LIMIT ? OFFSET ?`, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []User{}
	for rows.Next() {
		u, err := scanUser(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, u)
	}
	return out, rows.Err()
}

func (r *Repository) GetUser(id int64) (UserDetail, error) {
	u, err := scanUser(r.db.QueryRow(`SELECT `+userCols+userFrom+` WHERE u.id = ?`, id))
	if errors.Is(err, sql.ErrNoRows) {
		return UserDetail{}, ErrNotFound
	}
	if err != nil {
		return UserDetail{}, err
	}
	d := UserDetail{User: u}
	err = r.db.QueryRow(`SELECT COUNT(*), COALESCE(SUM(grand_total),0) FROM orders WHERE user_id = ? AND status IN ('paid','refunded')`, id).
		Scan(&d.OrdersCount, &d.TotalSpent)
	return d, err
}

// UpdateUser applies role/status changes and audits them.
func (r *Repository) UpdateUser(id, adminID int64, in UserUpdate) error {
	tx, err := r.db.Begin()
	if err != nil {
		return err
	}
	defer tx.Rollback()
	var exists int
	if err := tx.QueryRow(`SELECT COUNT(*) FROM users WHERE id = ? FOR UPDATE`, id).Scan(&exists); err != nil {
		return err
	}
	if exists == 0 {
		return ErrNotFound
	}
	meta := map[string]any{}
	if in.Role != nil {
		res, err := tx.Exec(`UPDATE users SET role_id = (SELECT id FROM roles WHERE code = ?) WHERE id = ?`, *in.Role, id)
		if err != nil {
			return err
		}
		if n, _ := res.RowsAffected(); n == 0 {
			// role code unknown -> subquery NULL violates NOT NULL and errors above; unchanged value is fine
		}
		meta["role"] = *in.Role
	}
	if in.Status != nil {
		if _, err := tx.Exec(`UPDATE users SET status = ? WHERE id = ?`, *in.Status, id); err != nil {
			return err
		}
		meta["status"] = *in.Status
	}
	if err := audit(tx, adminID, "user.update", "user", id, meta); err != nil {
		return err
	}
	return tx.Commit()
}

func (r *Repository) RoleExists(code string) (bool, error) {
	var n int
	err := r.db.QueryRow(`SELECT COUNT(*) FROM roles WHERE code = ? AND code <> 'GUEST'`, code).Scan(&n)
	return n > 0, err
}

func (r *Repository) Suspend(id, adminID int64, reason string) error {
	tx, err := r.db.Begin()
	if err != nil {
		return err
	}
	defer tx.Rollback()
	res, err := tx.Exec(`UPDATE users SET status='suspended' WHERE id = ?`, id)
	if err != nil {
		return err
	}
	if n, _ := res.RowsAffected(); n == 0 {
		var c int
		_ = tx.QueryRow(`SELECT COUNT(*) FROM users WHERE id = ?`, id).Scan(&c)
		if c == 0 {
			return ErrNotFound
		}
	}
	if err := audit(tx, adminID, "user.suspend", "user", id, map[string]any{"reason": reason}); err != nil {
		return err
	}
	return tx.Commit()
}

// ---- payments ------------------------------------------------------------

func (r *Repository) ListPayments(status string) ([]Payment, error) {
	q := `SELECT p.id, o.order_code, u.email, p.amount,
		COALESCE((SELECT SUM(rf.amount) FROM refunds rf WHERE rf.payment_id=p.id AND rf.status='processed'),0),
		p.method, p.status, o.status, p.paid_at
		FROM payments p JOIN orders o ON o.id=p.order_id JOIN users u ON u.id=o.user_id `
	var args []any
	if status != "" {
		q += `WHERE p.status = ? `
		args = append(args, status)
	}
	rows, err := r.db.Query(q+`ORDER BY p.id DESC LIMIT 200`, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []Payment{}
	for rows.Next() {
		var p Payment
		var paid sql.NullTime
		if err := rows.Scan(&p.ID, &p.OrderCode, &p.UserEmail, &p.Amount, &p.RefundedAmount, &p.Method, &p.Status, &p.OrderStatus, &paid); err != nil {
			return nil, err
		}
		if paid.Valid {
			t := paid.Time
			p.PaidAt = &t
		}
		out = append(out, p)
	}
	return out, rows.Err()
}

// Refund records a processed refund. Row-locks the payment so concurrent
// requests cannot refund more than was paid. (Actual gateway money movement
// is a Phase 4 concern — this records the platform-side state.)
func (r *Repository) Refund(paymentID, adminID int64, req RefundRequest) (RefundResult, error) {
	tx, err := r.db.Begin()
	if err != nil {
		return RefundResult{}, err
	}
	defer tx.Rollback()

	var orderID int64
	var amount float64
	var status string
	err = tx.QueryRow(`SELECT order_id, amount, status FROM payments WHERE id = ? FOR UPDATE`, paymentID).Scan(&orderID, &amount, &status)
	if errors.Is(err, sql.ErrNoRows) {
		return RefundResult{}, ErrNotFound
	}
	if err != nil {
		return RefundResult{}, err
	}
	if status != "success" {
		return RefundResult{}, ErrState
	}
	var already float64
	if err := tx.QueryRow(`SELECT COALESCE(SUM(amount),0) FROM refunds WHERE payment_id = ? AND status='processed'`, paymentID).Scan(&already); err != nil {
		return RefundResult{}, err
	}
	remaining := amount - already
	refund := remaining
	if req.Amount != nil {
		refund = *req.Amount
	}
	if refund <= 0 || refund > remaining+1e-9 {
		return RefundResult{}, ErrState
	}
	res, err := tx.Exec(`INSERT INTO refunds (payment_id, amount, reason, status, processed_by) VALUES (?,?,?,'processed',?)`,
		paymentID, refund, req.Reason, adminID)
	if err != nil {
		return RefundResult{}, err
	}
	rid, _ := res.LastInsertId()
	total := already + refund
	orderStatus := "paid"
	if total >= amount-1e-9 {
		orderStatus = "refunded"
		if _, err := tx.Exec(`UPDATE orders SET status='refunded' WHERE id = ?`, orderID); err != nil {
			return RefundResult{}, err
		}
	}
	if err := audit(tx, adminID, "payment.refund", "payment", paymentID, map[string]any{"amount": refund, "reason": req.Reason}); err != nil {
		return RefundResult{}, err
	}
	if err := tx.Commit(); err != nil {
		return RefundResult{}, err
	}
	return RefundResult{RefundID: rid, PaymentID: paymentID, Amount: refund, TotalRefunded: total, OrderStatus: orderStatus}, nil
}

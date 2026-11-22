package payments

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"strings"

	"github.com/go-sql-driver/mysql"
)

const mysqlDuplicateEntry = 1062

type SQLRepository struct{ db *sql.DB }

func NewRepository(db *sql.DB) *SQLRepository { return &SQLRepository{db: db} }

func placeholders(n int) string {
	return strings.TrimSuffix(strings.Repeat("?,", n), ",")
}

func int64Args(ids []int64) []any {
	a := make([]any, len(ids))
	for i, id := range ids {
		a[i] = id
	}
	return a
}

func isDuplicate(err error) bool {
	var me *mysql.MySQLError
	return errors.As(err, &me) && me.Number == mysqlDuplicateEntry
}

func (r *SQLRepository) CoursesForSale(ctx context.Context, ids []int64) ([]CourseLine, error) {
	rows, err := r.db.QueryContext(ctx,
		`SELECT id, title, price, discount_price, status FROM courses WHERE id IN (`+placeholders(len(ids))+`)`,
		int64Args(ids)...)
	if err != nil {
		return nil, fmt.Errorf("load courses: %w", err)
	}
	defer rows.Close()
	var out []CourseLine
	for rows.Next() {
		var l CourseLine
		var price float64
		var discount sql.NullFloat64
		if err := rows.Scan(&l.ID, &l.Title, &price, &discount, &l.Status); err != nil {
			return nil, err
		}
		l.Price = price
		if discount.Valid { // NULL means "no discount"; 0 means free
			l.Price = discount.Float64
		}
		out = append(out, l)
	}
	return out, rows.Err()
}

func (r *SQLRepository) OwnedCourses(ctx context.Context, userID int64, ids []int64) ([]int64, error) {
	args := append([]any{userID}, int64Args(ids)...)
	rows, err := r.db.QueryContext(ctx,
		`SELECT course_id FROM enrollments WHERE user_id = ? AND course_id IN (`+placeholders(len(ids))+`)`, args...)
	if err != nil {
		return nil, fmt.Errorf("load enrollments: %w", err)
	}
	defer rows.Close()
	var out []int64
	for rows.Next() {
		var id int64
		if err := rows.Scan(&id); err != nil {
			return nil, err
		}
		out = append(out, id)
	}
	return out, rows.Err()
}

func (r *SQLRepository) FindCoupon(ctx context.Context, code string) (*Coupon, error) {
	var c Coupon
	var courseID sql.NullInt64
	var maxUses sql.NullInt64
	var used sql.NullInt64
	var expires sql.NullTime
	err := r.db.QueryRowContext(ctx,
		`SELECT id, code, discount_type, discount_value, course_id, max_uses, used_count, expires_at
		   FROM coupons WHERE code = ?`, code).
		Scan(&c.ID, &c.Code, &c.Type, &c.Value, &courseID, &maxUses, &used, &expires)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, ErrBadCoupon
	}
	if err != nil {
		return nil, fmt.Errorf("load coupon: %w", err)
	}
	if courseID.Valid {
		v := courseID.Int64
		c.CourseID = &v
	}
	if maxUses.Valid {
		v := int(maxUses.Int64)
		c.MaxUses = &v
	}
	c.UsedCount = int(used.Int64)
	if expires.Valid {
		t := expires.Time
		c.ExpiresAt = &t
	}
	return &c, nil
}

func (r *SQLRepository) FindOrderByIdempotency(ctx context.Context, userID int64, key string) (*Order, error) {
	var code string
	err := r.db.QueryRowContext(ctx,
		`SELECT order_code FROM orders WHERE user_id = ? AND idempotency_key = ?`, userID, key).Scan(&code)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("find order by key: %w", err)
	}
	return r.GetOrder(ctx, userID, code)
}

func (r *SQLRepository) CreateOrder(ctx context.Context, n NewOrder) error {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback() }()

	res, err := tx.ExecContext(ctx,
		`INSERT INTO orders (order_code, idempotency_key, user_id, coupon_id, subtotal, discount_total, grand_total, status)
		 VALUES (?, ?, ?, ?, ?, ?, ?, 'pending')`,
		n.Code, n.IdempotencyKey, n.UserID, n.CouponID, n.Subtotal, n.Discount, n.Grand)
	if err != nil {
		if isDuplicate(err) {
			return ErrDuplicateOrder
		}
		return fmt.Errorf("insert order: %w", err)
	}
	orderID, err := res.LastInsertId()
	if err != nil {
		return err
	}
	for _, it := range n.Items {
		if _, err := tx.ExecContext(ctx,
			`INSERT INTO order_items (order_id, course_id, price) VALUES (?, ?, ?)`, orderID, it.ID, it.Price); err != nil {
			return fmt.Errorf("insert order item: %w", err)
		}
	}
	if _, err := tx.ExecContext(ctx,
		`INSERT INTO payments (order_id, method, provider, provider_ref, amount, status) VALUES (?, ?, ?, ?, ?, 'pending')`,
		orderID, n.Method, n.Provider, n.ProviderRef, n.Grand); err != nil {
		return fmt.Errorf("insert payment: %w", err)
	}
	return tx.Commit()
}

func (r *SQLRepository) GetOrder(ctx context.Context, userID int64, code string) (*Order, error) {
	o := Order{}
	err := r.db.QueryRowContext(ctx,
		`SELECT o.id, o.user_id, o.order_code, o.status, o.subtotal, o.discount_total, o.grand_total, o.created_at,
		        COALESCE(p.method, ''), COALESCE(p.status, '')
		   FROM orders o LEFT JOIN payments p ON p.order_id = o.id
		  WHERE o.order_code = ? AND o.user_id = ?`, code, userID).
		Scan(&o.ID, &o.UserID, &o.Code, &o.Status, &o.Subtotal, &o.DiscountTotal, &o.GrandTotal, &o.CreatedAt,
			&o.Method, &o.PaymentStatus)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, ErrOrderNotFound
	}
	if err != nil {
		return nil, fmt.Errorf("load order: %w", err)
	}
	if o.Items, err = r.items(ctx, o.ID); err != nil {
		return nil, err
	}
	return &o, nil
}

func (r *SQLRepository) items(ctx context.Context, orderID int64) ([]OrderItem, error) {
	rows, err := r.db.QueryContext(ctx,
		`SELECT oi.course_id, c.title, oi.price FROM order_items oi
		   JOIN courses c ON c.id = oi.course_id WHERE oi.order_id = ? ORDER BY oi.id`, orderID)
	if err != nil {
		return nil, fmt.Errorf("load order items: %w", err)
	}
	defer rows.Close()
	out := []OrderItem{}
	for rows.Next() {
		var it OrderItem
		if err := rows.Scan(&it.CourseID, &it.Title, &it.Price); err != nil {
			return nil, err
		}
		out = append(out, it)
	}
	return out, rows.Err()
}

func (r *SQLRepository) ListOrders(ctx context.Context, userID int64) ([]Order, error) {
	rows, err := r.db.QueryContext(ctx,
		`SELECT o.order_code FROM orders o WHERE o.user_id = ? ORDER BY o.id DESC LIMIT 100`, userID)
	if err != nil {
		return nil, fmt.Errorf("list orders: %w", err)
	}
	var codes []string
	for rows.Next() {
		var c string
		if err := rows.Scan(&c); err != nil {
			_ = rows.Close()
			return nil, err
		}
		codes = append(codes, c)
	}
	if err := rows.Err(); err != nil {
		_ = rows.Close()
		return nil, err
	}
	_ = rows.Close()
	out := make([]Order, 0, len(codes))
	for _, c := range codes {
		o, err := r.GetOrder(ctx, userID, c)
		if err != nil {
			return nil, err
		}
		out = append(out, *o)
	}
	return out, nil
}

func (r *SQLRepository) ApplyEvent(ctx context.Context, provider string, ev Event, raw []byte) (bool, error) {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return false, err
	}
	defer func() { _ = tx.Rollback() }()

	// The unique (provider, event_id) key is the idempotency guard.
	if _, err := tx.ExecContext(ctx,
		`INSERT INTO payment_events (provider, event_id, event_type, order_code, payload) VALUES (?, ?, ?, ?, ?)`,
		provider, ev.ID, ev.Type, ev.OrderCode, string(raw)); err != nil {
		if isDuplicate(err) {
			return false, nil
		}
		return false, fmt.Errorf("record event: %w", err)
	}

	var orderID int64
	var status string
	var couponID sql.NullInt64
	err = tx.QueryRowContext(ctx,
		`SELECT id, status, coupon_id FROM orders WHERE order_code = ? FOR UPDATE`, ev.OrderCode).
		Scan(&orderID, &status, &couponID)
	if errors.Is(err, sql.ErrNoRows) {
		return false, ErrOrderNotFound
	}
	if err != nil {
		return false, fmt.Errorf("lock order: %w", err)
	}

	// Only a pending order can change state; a late/duplicate event for an
	// order that is already settled is recorded and ignored.
	if status == "pending" {
		if ev.Type == EventSucceeded {
			if _, err := tx.ExecContext(ctx,
				`UPDATE payments SET status = 'success', paid_at = NOW() WHERE order_id = ?`, orderID); err != nil {
				return false, fmt.Errorf("mark payment: %w", err)
			}
			if _, err := tx.ExecContext(ctx, `UPDATE orders SET status = 'paid' WHERE id = ?`, orderID); err != nil {
				return false, fmt.Errorf("mark order: %w", err)
			}
			if _, err := tx.ExecContext(ctx,
				`INSERT IGNORE INTO enrollments (user_id, course_id)
				 SELECT o.user_id, oi.course_id FROM order_items oi JOIN orders o ON o.id = oi.order_id
				  WHERE oi.order_id = ?`, orderID); err != nil {
				return false, fmt.Errorf("enroll: %w", err)
			}
			if couponID.Valid {
				if _, err := tx.ExecContext(ctx,
					`UPDATE coupons SET used_count = used_count + 1 WHERE id = ?`, couponID.Int64); err != nil {
					return false, fmt.Errorf("count coupon: %w", err)
				}
			}
		} else {
			if _, err := tx.ExecContext(ctx,
				`UPDATE payments SET status = 'failed' WHERE order_id = ?`, orderID); err != nil {
				return false, fmt.Errorf("mark payment: %w", err)
			}
			if _, err := tx.ExecContext(ctx, `UPDATE orders SET status = 'failed' WHERE id = ?`, orderID); err != nil {
				return false, fmt.Errorf("mark order: %w", err)
			}
		}
	}
	if err := tx.Commit(); err != nil {
		return false, err
	}
	return true, nil
}

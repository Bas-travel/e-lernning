package database

import (
	"database/sql"
	"log"

	"github.com/ablearning/api/internal/security"
)

// DevPassword is the shared password of every seeded demo account.
// Seeding only runs when SEED_DEV=true — never enable it in production.
const DevPassword = "Password123!"

// SeedDev inserts demo accounts + catalog data if the users table is empty.
func SeedDev(db *sql.DB) error {
	var n int
	if err := db.QueryRow(`SELECT COUNT(*) FROM users`).Scan(&n); err != nil {
		return err
	}
	if n > 0 {
		return nil
	}
	hash, err := security.HashPassword(DevPassword)
	if err != nil {
		return err
	}
	tx, err := db.Begin()
	if err != nil {
		return err
	}
	defer tx.Rollback()

	roleID := func(code string) int64 {
		var id int64
		if err := tx.QueryRow(`SELECT id FROM roles WHERE code = ?`, code).Scan(&id); err != nil {
			panic(err)
		}
		return id
	}
	catID := func(slug string) int64 {
		var id int64
		if err := tx.QueryRow(`SELECT id FROM categories WHERE slug = ?`, slug).Scan(&id); err != nil {
			panic(err)
		}
		return id
	}
	exec := func(q string, args ...any) int64 {
		res, err := tx.Exec(q, args...)
		if err != nil {
			panic(err)
		}
		id, _ := res.LastInsertId()
		return id
	}
	user := func(email, role, first, last string) int64 {
		id := exec(`INSERT INTO users (role_id, email, password_hash, status, email_verified_at) VALUES (?, ?, ?, 'active', NOW())`,
			roleID(role), email, hash)
		exec(`INSERT INTO profiles (user_id, first_name, last_name) VALUES (?, ?, ?)`, id, first, last)
		return id
	}

	var seedErr error
	func() {
		defer func() {
			if r := recover(); r != nil {
				seedErr = r.(error)
			}
		}()

		learner := user("learner@ablearning.co", "LEARNER", "Anan", "Learner")
		learner2 := user("somchai@example.com", "LEARNER", "Somchai", "Jaidee")
		learner3 := user("malee@example.com", "LEARNER", "Malee", "Suksan")
		instrUser := user("instructor@ablearning.co", "INSTRUCTOR", "Nina", "Sato")
		corpAdmin := user("corpadmin@ablearning.co", "CORP_ADMIN", "Corp", "Admin")
		corpManager := user("corpmanager@ablearning.co", "CORP_MANAGER", "Corp", "Manager")
		employerUser := user("employer@ablearning.co", "EMPLOYER", "Emma", "Employer")
		admin := user("admin@ablearning.co", "ADMIN", "Site", "Admin")
		_ = admin

		instr := exec(`INSERT INTO instructors (user_id, headline, expertise, rating_avg, total_students, verified_at)
			VALUES (?, 'Senior Flutter & Go engineer', '["Flutter","Go"]', 4.80, 1284, NOW())`, instrUser)

		type lesson struct {
			title string
			typ   string
			secs  int
		}
		type course struct {
			title, slug, desc, cat, level, status string
			price, discount                       float64
			students                              int
			rating                                float64
			lessons                               []lesson
		}
		courses := []course{
			{"Flutter for Beginners", "flutter-for-beginners", "Build your first cross-platform app with Flutter.", "programming", "beginner", "published", 1290, 0, 12450, 4.8,
				[]lesson{{"Welcome & Setup", "video", 252}, {"Your First Widget", "video", 725}, {"State Management Basics", "video", 920}, {"Section Quiz", "quiz", 0}}},
			{"UX Research Fundamentals", "ux-research-fundamentals", "Plan, run and synthesize user research.", "design", "beginner", "published", 990, 0, 8320, 4.6,
				[]lesson{{"What is UX research?", "video", 400}, {"Interviewing users", "video", 860}}},
			{"Go Backend Essentials", "go-backend-essentials", "Production-ready Go services with clean architecture.", "programming", "intermediate", "published", 1590, 0, 6103, 4.9,
				[]lesson{{"Project layout", "video", 600}, {"HTTP handlers", "video", 900}, {"MySQL access", "video", 1100}}},
			{"Data Storytelling with SQL", "data-storytelling-sql", "From raw tables to a story stakeholders act on.", "data", "intermediate", "published", 890, 0, 4210, 4.5,
				[]lesson{{"Joins & windows", "video", 780}}},
			{"Growth Marketing Playbook", "growth-marketing-playbook", "Funnels, channels and growth experiments.", "marketing", "beginner", "pending_review", 1090, 0, 0, 0,
				[]lesson{{"Full-funnel thinking", "video", 640}, {"Choosing channels", "video", 700}}},
			{"Advanced Dart Patterns", "advanced-dart-patterns", "Work in progress.", "programming", "advanced", "draft", 1490, 0, 0, 0, nil},
		}
		courseIDs := map[string]int64{}
		for _, c := range courses {
			var discount any
			if c.discount > 0 {
				discount = c.discount
			}
			var publishedAt any
			if c.status == "published" {
				publishedAt = "2026-08-01 09:00:00"
			}
			id := exec(`INSERT INTO courses (instructor_id, category_id, title, slug, description, level, language, price, discount_price,
				duration_minutes, rating_avg, rating_count, student_count, status, published_at)
				VALUES (?, ?, ?, ?, ?, ?, 'th', ?, ?, ?, ?, ?, ?, ?, ?)`,
				instr, catID(c.cat), c.title, c.slug, c.desc, c.level, c.price, discount,
				len(c.lessons)*12, c.rating, c.students/10, c.students, c.status, publishedAt)
			courseIDs[c.slug] = id
			if len(c.lessons) > 0 {
				sec := exec(`INSERT INTO course_sections (course_id, title, sort_order) VALUES (?, 'Section 1', 1)`, id)
				for i, l := range c.lessons {
					exec(`INSERT INTO lessons (section_id, title, type, duration_seconds, sort_order, is_preview) VALUES (?, ?, ?, ?, ?, ?)`,
						sec, l.title, l.typ, l.secs, i+1, i == 0)
				}
			}
		}

		exec(`INSERT INTO enrollments (user_id, course_id, progress_pct, status) VALUES (?, ?, 62, 'in_progress'), (?, ?, 20, 'in_progress'), (?, ?, 100, 'completed')`,
			learner, courseIDs["flutter-for-beginners"], learner, courseIDs["ux-research-fundamentals"], learner2, courseIDs["go-backend-essentials"])

		order := func(code string, user int64, course string, price float64, orderStatus, method, payStatus string) {
			oid := exec(`INSERT INTO orders (order_code, user_id, subtotal, discount_total, grand_total, status) VALUES (?, ?, ?, 0, ?, ?)`,
				code, user, price, price, orderStatus)
			exec(`INSERT INTO order_items (order_id, course_id, price) VALUES (?, ?, ?)`, oid, courseIDs[course], price)
			var paidAt any
			if payStatus == "success" {
				paidAt = "2026-09-01 10:00:00"
			}
			exec(`INSERT INTO payments (order_id, method, provider_ref, amount, status, paid_at) VALUES (?, ?, ?, ?, ?, ?)`,
				oid, method, "demo-"+code, price, payStatus, paidAt)
		}
		order("ORD-0001", learner, "flutter-for-beginners", 1290, "paid", "promptpay", "success")
		order("ORD-0002", learner, "ux-research-fundamentals", 990, "paid", "card", "success")
		order("ORD-0003", learner2, "go-backend-essentials", 1590, "paid", "promptpay", "success")
		order("ORD-0004", learner3, "data-storytelling-sql", 890, "pending", "card", "pending")

		exec(`INSERT INTO creator_payouts (instructor_id, period_start, period_end, gross_amount, platform_fee, net_amount, status, paid_at) VALUES
			(?, '2026-06-01', '2026-06-30', 17625.00, 3525.00, 14100.00, 'paid', '2026-07-05 00:00:00'),
			(?, '2026-07-01', '2026-07-31', 19875.00, 3975.00, 15900.00, 'paid', '2026-08-05 00:00:00'),
			(?, '2026-08-01', '2026-08-31', 22750.00, 4550.00, 18200.00, 'paid', '2026-09-05 00:00:00'),
			(?, '2026-09-01', '2026-09-30', 15375.00, 3075.00, 12300.00, 'pending', NULL)`, instr, instr, instr, instr)

		// --- Corporate: one organization with staff, a learning path ---------
		org := exec(`INSERT INTO organizations (name, employee_count, training_budget) VALUES ('Acme Co., Ltd.', 4, 500000)`)
		exec(`INSERT INTO organization_users (organization_id, user_id, department, role_in_org) VALUES
			(?, ?, 'HR', 'admin'), (?, ?, 'Engineering', 'manager'),
			(?, ?, 'Engineering', 'employee'), (?, ?, 'Sales', 'employee')`,
			org, corpAdmin, org, corpManager, org, learner, org, learner2)
		lp := exec(`INSERT INTO learning_paths (organization_id, name, goal, deadline) VALUES (?, 'Mobile Onboarding', 'Ship a first Flutter app', '2026-12-31')`, org)
		exec(`INSERT INTO learning_path_courses (learning_path_id, course_id) VALUES (?, ?), (?, ?)`,
			lp, courseIDs["flutter-for-beginners"], lp, courseIDs["ux-research-fundamentals"])

		// --- Employer: company, two jobs, applications ----------------------
		emp := exec(`INSERT INTO employers (user_id, company_name, website) VALUES (?, 'Emma Tech', 'https://example.com')`, employerUser)
		jobA := exec(`INSERT INTO jobs (employer_id, title, description, location, is_remote, employment_type, status) VALUES (?, 'Flutter Developer', 'Build mobile apps', 'Bangkok', 1, 'full_time', 'open')`, emp)
		exec(`INSERT INTO jobs (employer_id, title, description, location, employment_type, status) VALUES (?, 'UX Researcher', 'Run user studies', 'Bangkok', 'contract', 'closed')`, emp)
		pf1 := exec(`INSERT INTO portfolios (user_id, headline) VALUES (?, 'Mobile developer')`, learner)
		pf2 := exec(`INSERT INTO portfolios (user_id, headline) VALUES (?, 'Backend developer')`, learner2)
		exec(`INSERT INTO job_applications (job_id, user_id, portfolio_id, match_score, status) VALUES (?, ?, ?, 88.5, 'shortlisted'), (?, ?, ?, 71.0, 'submitted')`,
			jobA, learner, pf1, jobA, learner2, pf2)

		exec(`INSERT INTO reports (reporter_id, target_type, target_id, reason) VALUES (?, 'course', ?, 'Content appears outdated')`,
			learner3, courseIDs["data-storytelling-sql"])
	}()
	if seedErr != nil {
		return seedErr
	}
	if err := tx.Commit(); err != nil {
		return err
	}
	log.Printf("dev seed applied (all demo accounts use password %q)", DevPassword)
	return nil
}

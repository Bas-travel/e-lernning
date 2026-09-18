-- ============================================================
-- AB LEARNING — Seed data (dev/demo only)
-- Auto-run after 01_schema.sql by the MySQL container's
-- docker-entrypoint-initdb.d mechanism (files run in filename order).
--
-- Seed learner account matches the Flutter app's mock login exactly, so
-- flipping lib/core/di/providers.dart from MockApiClient to DioApiClient
-- keeps working with the same credentials, zero UI changes needed:
--   email:    learner@ablearning.com
--   password: password123
-- ============================================================

SET NAMES utf8mb4;

-- ---- Roles (§01.1 of the source spec) ----
INSERT INTO roles (code, name_th, name_en) VALUES
  ('LEARNER',      'ผู้เรียน',        'Learner'),
  ('INSTRUCTOR',   'ผู้สอน',          'Instructor'),
  ('CORP_ADMIN',   'ผู้ดูแลองค์กร',    'Corporate Admin'),
  ('CORP_MANAGER', 'ผู้จัดการองค์กร',  'Corporate Manager'),
  ('EMPLOYER',     'นายจ้าง',        'Employer'),
  ('ADMIN',        'ผู้ดูแลระบบ',      'Super Admin');

-- ---- Categories (§09 Mock Data Set V1) ----
INSERT INTO categories (name_th, name_en, slug) VALUES
  ('การเขียนโปรแกรม', 'Programming',      'programming'),
  ('ปัญญาประดิษฐ์',    'AI',               'ai'),
  ('ข้อมูล',           'Data',             'data'),
  ('การตลาด',          'Marketing',        'marketing'),
  ('ธุรกิจ',           'Business',         'business');

-- ---- Instructor account: Dr. Krit (Backend / Cloud) ----
INSERT INTO users (role_id, email, password_hash, status)
VALUES (
  (SELECT id FROM roles WHERE code = 'INSTRUCTOR'),
  'krit@ablearning.com',
  '$2a$10$KEHWsSP8QLjM1eUg7dXMpeQwJG79pLJqgjVXWeF2WyQarGh5UKKbW', -- password123
  'active'
);
SET @krit_user_id = LAST_INSERT_ID();

INSERT INTO profiles (user_id, first_name, last_name, title)
VALUES (@krit_user_id, 'Krit', 'Anantasin', 'Backend & Cloud Instructor');

INSERT INTO instructors (user_id, headline, expertise, rating_avg, total_students, verified_at)
VALUES (@krit_user_id, 'Backend & Cloud Architecture', '["Go","MySQL","Docker","Kubernetes"]', 4.90, 8421, NOW());
SET @krit_instructor_id = LAST_INSERT_ID();

-- ---- Instructor account: Bank (AI / Data) ----
INSERT INTO users (role_id, email, password_hash, status)
VALUES (
  (SELECT id FROM roles WHERE code = 'INSTRUCTOR'),
  'bank@ablearning.com',
  '$2a$10$KEHWsSP8QLjM1eUg7dXMpeQwJG79pLJqgjVXWeF2WyQarGh5UKKbW',
  'active'
);
SET @bank_user_id = LAST_INSERT_ID();

INSERT INTO profiles (user_id, first_name, last_name, title)
VALUES (@bank_user_id, 'Bank', 'Thanakit', 'AI & Data Instructor');

INSERT INTO instructors (user_id, headline, expertise, rating_avg, total_students, verified_at)
VALUES (@bank_user_id, 'Applied AI for Business', '["AI","Data","Prompt Engineering"]', 4.90, 3120, NOW());
SET @bank_instructor_id = LAST_INSERT_ID();

-- ---- Seed learner account: Anan Suksawat (matches Flutter mock) ----
INSERT INTO users (role_id, email, password_hash, status)
VALUES (
  (SELECT id FROM roles WHERE code = 'LEARNER'),
  'learner@ablearning.com',
  '$2a$10$KEHWsSP8QLjM1eUg7dXMpeQwJG79pLJqgjVXWeF2WyQarGh5UKKbW', -- password123
  'active'
);
SET @learner_user_id = LAST_INSERT_ID();

INSERT INTO profiles (user_id, first_name, last_name, title, location)
VALUES (@learner_user_id, 'Anan', 'Suksawat', 'Backend Developer', 'Bangkok');

INSERT INTO wallets (user_id, coin_balance, cash_balance)
VALUES (@learner_user_id, 2450, 850.00);

-- ---- Courses (a slice of §09's 15-course catalog) ----
INSERT INTO courses (instructor_id, category_id, title, slug, description, level, price, discount_price, duration_minutes, rating_avg, rating_count, student_count, status, published_at)
VALUES
  (@krit_instructor_id,
   (SELECT id FROM categories WHERE slug='programming'),
   'Go Backend Professional', 'go-backend-professional',
   'เรียนรู้การออกแบบ REST API ด้วย Go เชื่อมต่อ MySQL และ deploy สู่ production จริง',
   'intermediate', 4990.00, 2990.00, 1110, 4.90, 2140, 8421, 'published', NOW()),
  (@bank_instructor_id,
   (SELECT id FROM categories WHERE slug='ai'),
   'AI for Business', 'ai-for-business',
   'ประยุกต์ใช้ AI เพื่อสร้างมูลค่าทางธุรกิจ ตั้งแต่ automation ถึง decision support',
   'beginner', 1990.00, NULL, 480, 4.90, 890, 3120, 'published', NOW());

SET @go_backend_id = (SELECT id FROM courses WHERE slug = 'go-backend-professional');
SET @ai_business_id = (SELECT id FROM courses WHERE slug = 'ai-for-business');

-- Curriculum for Go Backend Professional
INSERT INTO course_sections (course_id, title, sort_order) VALUES
  (@go_backend_id, 'Introduction', 1),
  (@go_backend_id, 'REST API', 2);
SET @section_intro_id = (SELECT id FROM course_sections WHERE course_id = @go_backend_id AND sort_order = 1);
SET @section_api_id = (SELECT id FROM course_sections WHERE course_id = @go_backend_id AND sort_order = 2);

INSERT INTO lessons (section_id, title, type, duration_seconds, sort_order, is_preview) VALUES
  (@section_intro_id, 'Welcome & Setup', 'video', 480, 1, 1),
  (@section_api_id, 'REST API with Go', 'video', 1475, 1, 0),
  (@section_api_id, 'JWT Authentication', 'video', 1082, 2, 0);

-- The seed learner is mid-way through Go Backend Professional, so
-- screen 08's "Continue Learning" rail has something to show.
INSERT INTO enrollments (user_id, course_id, progress_pct, status, enrolled_at)
VALUES (@learner_user_id, @go_backend_id, 68.00, 'in_progress', NOW());

-- ---- Live session (screen 08 "Live coming up" rail) ----
INSERT INTO live_sessions (course_id, instructor_id, title, scheduled_at, duration_minutes, status)
VALUES (@ai_business_id, @bank_instructor_id, 'AI for Business — Live Q&A', DATE_ADD(NOW(), INTERVAL 2 HOUR), 60, 'upcoming');

-- ---- A paid order, so Instructor Revenue and Admin Revenue KPIs are non-zero ----
INSERT INTO orders (order_code, user_id, subtotal, discount_total, grand_total, status)
VALUES ('ORD-10001', @learner_user_id, 4990.00, 2000.00, 2990.00, 'paid');
SET @order1_id = LAST_INSERT_ID();

INSERT INTO order_items (order_id, course_id, price) VALUES (@order1_id, @go_backend_id, 2990.00);

INSERT INTO payments (order_id, method, provider_ref, amount, status, paid_at)
VALUES (@order1_id, 'promptpay', 'PPAY-TEST-001', 2990.00, 'success', NOW());

-- ============================================================
-- Phase 2 seed data — one account per remaining role, plus enough
-- supporting rows for each role's dashboard to return real, non-empty data.
-- All four use the same password as the learner account: password123
-- ============================================================

-- ---- Corporate: ABC Technology + a Corp Admin account ----
INSERT INTO organizations (name, employee_count, training_budget)
VALUES ('ABC Technology', 500, 500000.00);
SET @abc_org_id = LAST_INSERT_ID();

INSERT INTO users (role_id, email, password_hash, status)
VALUES (
  (SELECT id FROM roles WHERE code = 'CORP_ADMIN'),
  'corp@ablearning.com',
  '$2a$10$KEHWsSP8QLjM1eUg7dXMpeQwJG79pLJqgjVXWeF2WyQarGh5UKKbW', -- password123
  'active'
);
SET @corp_user_id = LAST_INSERT_ID();

INSERT INTO profiles (user_id, first_name, last_name, title)
VALUES (@corp_user_id, 'Siriwan', 'Kittipong', 'HR Director');

INSERT INTO organization_users (organization_id, user_id, department, role_in_org, status)
VALUES (@abc_org_id, @corp_user_id, 'Human Resources', 'admin', 'active');

-- The seed learner also works at ABC Technology — gives the Corp Admin
-- dashboard a real "active learner" with a real enrollment to aggregate.
INSERT INTO organization_users (organization_id, user_id, department, role_in_org, status)
VALUES (@abc_org_id, @learner_user_id, 'Engineering', 'employee', 'active');

-- ---- Employer: TechCorp Thailand + an Employer account ----
INSERT INTO users (role_id, email, password_hash, status)
VALUES (
  (SELECT id FROM roles WHERE code = 'EMPLOYER'),
  'employer@ablearning.com',
  '$2a$10$KEHWsSP8QLjM1eUg7dXMpeQwJG79pLJqgjVXWeF2WyQarGh5UKKbW',
  'active'
);
SET @employer_user_id = LAST_INSERT_ID();

INSERT INTO profiles (user_id, first_name, last_name, title)
VALUES (@employer_user_id, 'Pakorn', 'Srisawat', 'Talent Acquisition Manager');

INSERT INTO employers (user_id, company_name, website)
VALUES (@employer_user_id, 'TechCorp Thailand', 'https://techcorp.example.com');
SET @techcorp_employer_id = LAST_INSERT_ID();

INSERT INTO jobs (employer_id, title, description, requirements, skill_tags, location, is_remote, salary_min, salary_max, employment_type, status)
VALUES
  (@techcorp_employer_id, 'Backend Developer',
   'ร่วมทีมพัฒนา Backend สำหรับแพลตฟอร์ม e-commerce ที่มีผู้ใช้กว่า 2 ล้านคน',
   'Go, PostgreSQL, Docker', '["Go","PostgreSQL","Docker"]', 'Bangkok', 1, 45000, 65000, 'full_time', 'open'),
  (@techcorp_employer_id, 'Cloud Engineer',
   'ดูแลระบบ Cloud infrastructure และ CI/CD pipeline',
   'AWS, Kubernetes', '["AWS","Kubernetes"]', 'Bangkok', 0, 55000, 80000, 'full_time', 'open');
SET @job1_id = (SELECT id FROM jobs WHERE employer_id = @techcorp_employer_id ORDER BY id LIMIT 1);

-- The seed learner applies to the first job — gives the Employer dashboard
-- a real application + match score to display.
INSERT INTO portfolios (user_id, headline, summary)
VALUES (@learner_user_id, 'Backend Developer', 'Go, SQL, Docker enthusiast building real projects.');
SET @learner_portfolio_id = LAST_INSERT_ID();

INSERT INTO job_applications (job_id, user_id, portfolio_id, match_score, status)
VALUES (@job1_id, @learner_user_id, @learner_portfolio_id, 92.00, 'submitted');

-- ---- Admin account ----
INSERT INTO users (role_id, email, password_hash, status)
VALUES (
  (SELECT id FROM roles WHERE code = 'ADMIN'),
  'admin@ablearning.com',
  '$2a$10$KEHWsSP8QLjM1eUg7dXMpeQwJG79pLJqgjVXWeF2WyQarGh5UKKbW',
  'active'
);
SET @admin_user_id = LAST_INSERT_ID();

INSERT INTO profiles (user_id, first_name, last_name, title)
VALUES (@admin_user_id, 'System', 'Administrator', 'Super Admin');

-- A pending-review course — gives the Admin Moderation queue something
-- real to show/approve/reject.
INSERT INTO courses (instructor_id, category_id, title, slug, description, level, price, duration_minutes, status)
VALUES (
  @bank_instructor_id,
  (SELECT id FROM categories WHERE slug='ai'),
  'Prompt Engineering', 'prompt-engineering',
  'เทคนิคการเขียน prompt อย่างมืออาชีพสำหรับงานจริง',
  'beginner', 1490.00, 240, 'pending_review'
);


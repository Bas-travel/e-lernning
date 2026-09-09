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

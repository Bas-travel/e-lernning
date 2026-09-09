-- ============================================================
-- AB LEARNING — MySQL 8 Schema V1
-- Generated from ER diagram (03-er-diagram.md)
-- Charset: utf8mb4 throughout for Thai + English + emoji support
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- IDENTITY
-- ============================================================

CREATE TABLE roles (
  id            TINYINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  code          VARCHAR(30) NOT NULL UNIQUE,      -- GUEST, LEARNER, INSTRUCTOR, CORP_ADMIN, CORP_MANAGER, EMPLOYER, ADMIN
  name_th       VARCHAR(100) NOT NULL,
  name_en       VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE users (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  role_id       TINYINT UNSIGNED NOT NULL,
  email         VARCHAR(190) UNIQUE,
  phone         VARCHAR(20) UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  status        ENUM('active','suspended','deactivated') NOT NULL DEFAULT 'active',
  email_verified_at DATETIME NULL,
  last_login_at DATETIME NULL,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (role_id) REFERENCES roles(id),
  INDEX idx_users_role (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE profiles (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id       BIGINT UNSIGNED NOT NULL UNIQUE,
  first_name    VARCHAR(100),
  last_name     VARCHAR(100),
  avatar_url    VARCHAR(500),
  bio           TEXT,
  title         VARCHAR(150),
  location      VARCHAR(150),
  date_of_birth DATE,
  gender        ENUM('male','female','other','undisclosed') DEFAULT 'undisclosed',
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE otp_verifications (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id       BIGINT UNSIGNED NOT NULL,
  code          VARCHAR(6) NOT NULL,
  purpose       ENUM('register','login','reset_password') NOT NULL,
  expires_at    DATETIME NOT NULL,
  consumed_at   DATETIME NULL,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE password_resets (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id       BIGINT UNSIGNED NOT NULL,
  token         VARCHAR(255) NOT NULL UNIQUE,
  expires_at    DATETIME NOT NULL,
  used_at       DATETIME NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE user_preferences (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id       BIGINT UNSIGNED NOT NULL UNIQUE,
  interests     JSON,          -- ["Programming","AI","Data"]
  level         ENUM('beginner','intermediate','advanced'),
  goal          ENUM('get_job','upskill','career_change','freelance','business'),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- CATALOG
-- ============================================================

CREATE TABLE categories (
  id            INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name_th       VARCHAR(100) NOT NULL,
  name_en       VARCHAR(100) NOT NULL,
  slug          VARCHAR(120) NOT NULL UNIQUE,
  icon          VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE instructors (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id       BIGINT UNSIGNED NOT NULL UNIQUE,
  headline      VARCHAR(200),
  expertise     JSON,          -- ["Backend","Cloud"]
  rating_avg    DECIMAL(3,2) DEFAULT 0,
  total_students INT UNSIGNED DEFAULT 0,
  verified_at   DATETIME NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE courses (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  instructor_id BIGINT UNSIGNED NOT NULL,
  category_id   INT UNSIGNED NOT NULL,
  title         VARCHAR(200) NOT NULL,
  slug          VARCHAR(220) NOT NULL UNIQUE,
  description   TEXT,
  level         ENUM('beginner','intermediate','advanced') DEFAULT 'beginner',
  language      VARCHAR(10) DEFAULT 'th',
  thumbnail_url VARCHAR(500),
  price         DECIMAL(10,2) NOT NULL DEFAULT 0,
  discount_price DECIMAL(10,2) NULL,
  duration_minutes INT UNSIGNED DEFAULT 0,
  rating_avg    DECIMAL(3,2) DEFAULT 0,
  rating_count  INT UNSIGNED DEFAULT 0,
  student_count INT UNSIGNED DEFAULT 0,
  status        ENUM('draft','pending_review','published','rejected','archived') NOT NULL DEFAULT 'draft',
  rejected_reason VARCHAR(500) NULL,
  published_at  DATETIME NULL,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (instructor_id) REFERENCES instructors(id),
  FOREIGN KEY (category_id) REFERENCES categories(id),
  INDEX idx_courses_status (status),
  INDEX idx_courses_category (category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE course_sections (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  course_id     BIGINT UNSIGNED NOT NULL,
  title         VARCHAR(200) NOT NULL,
  sort_order    INT UNSIGNED NOT NULL DEFAULT 0,
  FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE lessons (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  section_id    BIGINT UNSIGNED NOT NULL,
  title         VARCHAR(200) NOT NULL,
  type          ENUM('video','article','quiz','project') NOT NULL DEFAULT 'video',
  video_url     VARCHAR(500),
  duration_seconds INT UNSIGNED DEFAULT 0,
  resource_urls JSON,
  sort_order    INT UNSIGNED NOT NULL DEFAULT 0,
  is_preview    TINYINT(1) NOT NULL DEFAULT 0,
  FOREIGN KEY (section_id) REFERENCES course_sections(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- LEARNING
-- ============================================================

CREATE TABLE enrollments (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id       BIGINT UNSIGNED NOT NULL,
  course_id     BIGINT UNSIGNED NOT NULL,
  progress_pct  DECIMAL(5,2) NOT NULL DEFAULT 0,
  status        ENUM('in_progress','completed','dropped') NOT NULL DEFAULT 'in_progress',
  last_lesson_id BIGINT UNSIGNED NULL,
  enrolled_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  completed_at  DATETIME NULL,
  UNIQUE KEY uq_enrollment (user_id, course_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (course_id) REFERENCES courses(id),
  FOREIGN KEY (last_lesson_id) REFERENCES lessons(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE lesson_progress (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  enrollment_id BIGINT UNSIGNED NOT NULL,
  lesson_id     BIGINT UNSIGNED NOT NULL,
  status        ENUM('not_started','in_progress','completed') NOT NULL DEFAULT 'not_started',
  watched_seconds INT UNSIGNED DEFAULT 0,
  completed_at  DATETIME NULL,
  UNIQUE KEY uq_progress (enrollment_id, lesson_id),
  FOREIGN KEY (enrollment_id) REFERENCES enrollments(id) ON DELETE CASCADE,
  FOREIGN KEY (lesson_id) REFERENCES lessons(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE quizzes (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  course_id     BIGINT UNSIGNED NOT NULL,
  lesson_id     BIGINT UNSIGNED NULL,
  title         VARCHAR(200) NOT NULL,
  pass_score_pct DECIMAL(5,2) NOT NULL DEFAULT 70,
  FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  FOREIGN KEY (lesson_id) REFERENCES lessons(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE quiz_questions (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  quiz_id       BIGINT UNSIGNED NOT NULL,
  question      TEXT NOT NULL,
  choices       JSON NOT NULL,   -- [{"id":"a","text":"..."}]
  correct_choice VARCHAR(10) NOT NULL,
  skill_tag     VARCHAR(100),
  sort_order    INT UNSIGNED DEFAULT 0,
  FOREIGN KEY (quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE quiz_attempts (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  quiz_id       BIGINT UNSIGNED NOT NULL,
  user_id       BIGINT UNSIGNED NOT NULL,
  answers       JSON NOT NULL,   -- {"q1":"b","q2":"a"}
  score_pct     DECIMAL(5,2) NOT NULL,
  passed        TINYINT(1) NOT NULL,
  skill_breakdown JSON,          -- {"API Knowledge":90,"Auth":70}
  attempted_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (quiz_id) REFERENCES quizzes(id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE certificates (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  enrollment_id BIGINT UNSIGNED NOT NULL UNIQUE,
  certificate_code VARCHAR(40) NOT NULL UNIQUE,
  pdf_url       VARCHAR(500),
  issued_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (enrollment_id) REFERENCES enrollments(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE reviews (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  course_id     BIGINT UNSIGNED NOT NULL,
  user_id       BIGINT UNSIGNED NOT NULL,
  rating        TINYINT UNSIGNED NOT NULL,   -- 1-5
  comment       TEXT,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_review (course_id, user_id),
  FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- COMMERCE
-- ============================================================

CREATE TABLE coupons (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  code          VARCHAR(40) NOT NULL UNIQUE,
  discount_type ENUM('percent','fixed') NOT NULL,
  discount_value DECIMAL(10,2) NOT NULL,
  course_id     BIGINT UNSIGNED NULL,        -- NULL = platform-wide
  max_uses      INT UNSIGNED NULL,
  used_count    INT UNSIGNED DEFAULT 0,
  expires_at    DATETIME NULL,
  FOREIGN KEY (course_id) REFERENCES courses(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE orders (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  order_code    VARCHAR(30) NOT NULL UNIQUE,
  user_id       BIGINT UNSIGNED NOT NULL,
  coupon_id     BIGINT UNSIGNED NULL,
  subtotal      DECIMAL(10,2) NOT NULL,
  discount_total DECIMAL(10,2) NOT NULL DEFAULT 0,
  grand_total   DECIMAL(10,2) NOT NULL,
  status        ENUM('pending','paid','failed','refunded','cancelled') NOT NULL DEFAULT 'pending',
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (coupon_id) REFERENCES coupons(id),
  INDEX idx_orders_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE order_items (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  order_id      BIGINT UNSIGNED NOT NULL,
  course_id     BIGINT UNSIGNED NOT NULL,
  price         DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (course_id) REFERENCES courses(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE payments (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  order_id      BIGINT UNSIGNED NOT NULL UNIQUE,
  method        ENUM('promptpay','card','stripe','wallet') NOT NULL,
  provider_ref  VARCHAR(150),
  amount        DECIMAL(10,2) NOT NULL,
  status        ENUM('pending','success','failed') NOT NULL DEFAULT 'pending',
  paid_at       DATETIME NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE refunds (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  payment_id    BIGINT UNSIGNED NOT NULL,
  amount        DECIMAL(10,2) NOT NULL,
  reason        VARCHAR(500),
  status        ENUM('requested','processed','rejected') NOT NULL DEFAULT 'requested',
  processed_by  BIGINT UNSIGNED NULL,   -- admin user_id
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE,
  FOREIGN KEY (processed_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- LIVE
-- ============================================================

CREATE TABLE live_sessions (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  course_id     BIGINT UNSIGNED NULL,
  instructor_id BIGINT UNSIGNED NOT NULL,
  title         VARCHAR(200) NOT NULL,
  scheduled_at  DATETIME NOT NULL,
  duration_minutes INT UNSIGNED DEFAULT 60,
  stream_url    VARCHAR(500),
  replay_url    VARCHAR(500),
  price         DECIMAL(10,2) DEFAULT 0,
  status        ENUM('upcoming','live','ended','cancelled') NOT NULL DEFAULT 'upcoming',
  FOREIGN KEY (course_id) REFERENCES courses(id),
  FOREIGN KEY (instructor_id) REFERENCES instructors(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE live_attendees (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  live_session_id BIGINT UNSIGNED NOT NULL,
  user_id       BIGINT UNSIGNED NOT NULL,
  joined_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_attendee (live_session_id, user_id),
  FOREIGN KEY (live_session_id) REFERENCES live_sessions(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE live_questions (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  live_session_id BIGINT UNSIGNED NOT NULL,
  user_id       BIGINT UNSIGNED NOT NULL,
  question      TEXT NOT NULL,
  upvotes       INT UNSIGNED DEFAULT 0,
  answered      TINYINT(1) DEFAULT 0,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (live_session_id) REFERENCES live_sessions(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- COMMUNITY
-- ============================================================

CREATE TABLE communities (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name          VARCHAR(150) NOT NULL,
  description   TEXT,
  cover_url     VARCHAR(500)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE community_posts (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  community_id  BIGINT UNSIGNED NULL,
  user_id       BIGINT UNSIGNED NOT NULL,
  title         VARCHAR(200),
  content       TEXT NOT NULL,
  image_url     VARCHAR(500),
  course_tag_id BIGINT UNSIGNED NULL,
  like_count    INT UNSIGNED DEFAULT 0,
  comment_count INT UNSIGNED DEFAULT 0,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (community_id) REFERENCES communities(id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (course_tag_id) REFERENCES courses(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE comments (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  post_id       BIGINT UNSIGNED NOT NULL,
  user_id       BIGINT UNSIGNED NOT NULL,
  content       TEXT NOT NULL,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (post_id) REFERENCES community_posts(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE likes (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  post_id       BIGINT UNSIGNED NOT NULL,
  user_id       BIGINT UNSIGNED NOT NULL,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_like (post_id, user_id),
  FOREIGN KEY (post_id) REFERENCES community_posts(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- CAREER
-- ============================================================

CREATE TABLE skills (
  id            INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name          VARCHAR(100) NOT NULL UNIQUE,
  category      VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE skill_assessments (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  title         VARCHAR(200) NOT NULL,
  category      VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE skill_questions (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  assessment_id BIGINT UNSIGNED NOT NULL,
  skill_id      INT UNSIGNED NOT NULL,
  question      TEXT NOT NULL,
  choices       JSON NOT NULL,
  correct_choice VARCHAR(10) NOT NULL,
  FOREIGN KEY (assessment_id) REFERENCES skill_assessments(id) ON DELETE CASCADE,
  FOREIGN KEY (skill_id) REFERENCES skills(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE skill_results (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id       BIGINT UNSIGNED NOT NULL,
  assessment_id BIGINT UNSIGNED NOT NULL,
  overall_score DECIMAL(5,2) NOT NULL,
  breakdown     JSON NOT NULL,   -- {"Backend":80,"Database":65,"Cloud":48}
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (assessment_id) REFERENCES skill_assessments(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE career_paths (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  title         VARCHAR(200) NOT NULL,
  description   TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE career_path_skills (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  career_path_id BIGINT UNSIGNED NOT NULL,
  skill_id      INT UNSIGNED NOT NULL,
  required_level ENUM('beginner','intermediate','advanced') DEFAULT 'intermediate',
  FOREIGN KEY (career_path_id) REFERENCES career_paths(id) ON DELETE CASCADE,
  FOREIGN KEY (skill_id) REFERENCES skills(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE portfolios (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id       BIGINT UNSIGNED NOT NULL UNIQUE,
  headline      VARCHAR(200),
  summary       TEXT,
  resume_url    VARCHAR(500),
  social_links  JSON,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE portfolio_projects (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  portfolio_id  BIGINT UNSIGNED NOT NULL,
  title         VARCHAR(200) NOT NULL,
  description   TEXT,
  skill_tags    JSON,
  project_url   VARCHAR(500),
  image_url     VARCHAR(500),
  FOREIGN KEY (portfolio_id) REFERENCES portfolios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- JOBS
-- ============================================================

CREATE TABLE employers (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id       BIGINT UNSIGNED NOT NULL UNIQUE,
  company_name  VARCHAR(200) NOT NULL,
  logo_url      VARCHAR(500),
  website       VARCHAR(255),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE jobs (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  employer_id   BIGINT UNSIGNED NOT NULL,
  title         VARCHAR(200) NOT NULL,
  description   TEXT,
  requirements  TEXT,
  skill_tags    JSON,
  location      VARCHAR(150),
  is_remote     TINYINT(1) DEFAULT 0,
  salary_min    DECIMAL(10,2),
  salary_max    DECIMAL(10,2),
  employment_type ENUM('full_time','part_time','contract','internship') DEFAULT 'full_time',
  status        ENUM('open','closed') DEFAULT 'open',
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (employer_id) REFERENCES employers(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE job_applications (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  job_id        BIGINT UNSIGNED NOT NULL,
  user_id       BIGINT UNSIGNED NOT NULL,
  portfolio_id  BIGINT UNSIGNED NOT NULL,
  match_score   DECIMAL(5,2),
  status        ENUM('submitted','reviewed','shortlisted','rejected','hired') DEFAULT 'submitted',
  applied_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_application (job_id, user_id),
  FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (portfolio_id) REFERENCES portfolios(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- CORPORATE
-- ============================================================

CREATE TABLE organizations (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name          VARCHAR(200) NOT NULL,
  logo_url      VARCHAR(500),
  employee_count INT UNSIGNED DEFAULT 0,
  training_budget DECIMAL(12,2) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE organization_users (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  organization_id BIGINT UNSIGNED NOT NULL,
  user_id       BIGINT UNSIGNED NOT NULL,
  department    VARCHAR(150),
  role_in_org   ENUM('admin','manager','employee') DEFAULT 'employee',
  status        ENUM('active','inactive') DEFAULT 'active',
  UNIQUE KEY uq_org_user (organization_id, user_id),
  FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE learning_paths (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  organization_id BIGINT UNSIGNED NOT NULL,
  name          VARCHAR(200) NOT NULL,
  goal          VARCHAR(300),
  deadline      DATE NULL,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE learning_path_courses (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  learning_path_id BIGINT UNSIGNED NOT NULL,
  course_id     BIGINT UNSIGNED NOT NULL,
  FOREIGN KEY (learning_path_id) REFERENCES learning_paths(id) ON DELETE CASCADE,
  FOREIGN KEY (course_id) REFERENCES courses(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- learning path <-> employee assignment
CREATE TABLE learning_path_assignments (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  learning_path_id BIGINT UNSIGNED NOT NULL,
  organization_user_id BIGINT UNSIGNED NOT NULL,
  progress_pct  DECIMAL(5,2) DEFAULT 0,
  UNIQUE KEY uq_assignment (learning_path_id, organization_user_id),
  FOREIGN KEY (learning_path_id) REFERENCES learning_paths(id) ON DELETE CASCADE,
  FOREIGN KEY (organization_user_id) REFERENCES organization_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- PLATFORM
-- ============================================================

CREATE TABLE notifications (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id       BIGINT UNSIGNED NOT NULL,
  type          VARCHAR(50) NOT NULL,     -- course_update, live_reminder, order_paid, ...
  title         VARCHAR(200) NOT NULL,
  body          VARCHAR(500),
  is_read       TINYINT(1) DEFAULT 0,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_notif_user_read (user_id, is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE wallets (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id       BIGINT UNSIGNED NOT NULL UNIQUE,
  coin_balance  BIGINT UNSIGNED DEFAULT 0,
  cash_balance  DECIMAL(12,2) DEFAULT 0,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE wallet_transactions (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  wallet_id     BIGINT UNSIGNED NOT NULL,
  type          ENUM('topup','withdraw','purchase','refund','reward') NOT NULL,
  amount        DECIMAL(12,2) NOT NULL,
  balance_after DECIMAL(12,2) NOT NULL,
  reference     VARCHAR(150),
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (wallet_id) REFERENCES wallets(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE subscriptions (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id       BIGINT UNSIGNED NOT NULL,
  plan          VARCHAR(50) NOT NULL,
  status        ENUM('active','cancelled','expired') DEFAULT 'active',
  started_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expires_at    DATETIME NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE creator_payouts (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  instructor_id BIGINT UNSIGNED NOT NULL,
  period_start  DATE NOT NULL,
  period_end    DATE NOT NULL,
  gross_amount  DECIMAL(12,2) NOT NULL,
  platform_fee  DECIMAL(12,2) NOT NULL,
  net_amount    DECIMAL(12,2) NOT NULL,
  status        ENUM('pending','paid') DEFAULT 'pending',
  paid_at       DATETIME NULL,
  FOREIGN KEY (instructor_id) REFERENCES instructors(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE reports (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  reporter_id   BIGINT UNSIGNED NOT NULL,
  target_type   ENUM('course','post','comment','user') NOT NULL,
  target_id     BIGINT UNSIGNED NOT NULL,
  reason        VARCHAR(500) NOT NULL,
  status        ENUM('open','reviewed','dismissed') DEFAULT 'open',
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (reporter_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE audit_logs (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  actor_id      BIGINT UNSIGNED NULL,
  action        VARCHAR(100) NOT NULL,     -- e.g. course.approve, user.suspend
  target_type   VARCHAR(50),
  target_id     BIGINT UNSIGNED,
  metadata      JSON,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (actor_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- AI (supports screen 21 AI Tutor)
-- ============================================================

CREATE TABLE ai_conversations (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id       BIGINT UNSIGNED NOT NULL,
  course_id     BIGINT UNSIGNED NULL,
  lesson_id     BIGINT UNSIGNED NULL,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (course_id) REFERENCES courses(id),
  FOREIGN KEY (lesson_id) REFERENCES lessons(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE ai_messages (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  conversation_id BIGINT UNSIGNED NOT NULL,
  role          ENUM('user','assistant') NOT NULL,
  content       TEXT NOT NULL,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (conversation_id) REFERENCES ai_conversations(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- GAMIFICATION (screen 29)
-- ============================================================

CREATE TABLE user_points (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id       BIGINT UNSIGNED NOT NULL UNIQUE,
  level         INT UNSIGNED DEFAULT 1,
  xp            BIGINT UNSIGNED DEFAULT 0,
  streak_days   INT UNSIGNED DEFAULT 0,
  last_activity_date DATE NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE badges (
  id            INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name          VARCHAR(100) NOT NULL,
  description   VARCHAR(255),
  icon_url      VARCHAR(500)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE achievements (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id       BIGINT UNSIGNED NOT NULL,
  badge_id      INT UNSIGNED NOT NULL,
  earned_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_achievement (user_id, badge_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (badge_id) REFERENCES badges(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;

-- Seed SQL for AB LEARNING (matches db/seed/seeds.json)
-- Run: mysql -u root -p ablearning < seed.sql

USE ablearning;

-- Roles
INSERT INTO roles (id, code, name, created_at) VALUES
('r-1','LEARNER','Learner',NOW()),
('r-2','INSTRUCTOR','Instructor',NOW()),
('r-3','ADMIN','Administrator',NOW()),
('r-4','EMPLOYER','Employer',NOW()),
('r-5','CORP_ADMIN','Corp Admin',NOW())
ON DUPLICATE KEY UPDATE code=VALUES(code);

-- Users
INSERT INTO users (id,email,role_id,created_at) VALUES
('u-1','anan@example.com','r-1','2026-09-06 08:00:00'),
('u-2','krit@example.com','r-2','2026-09-06 08:05:00'),
('u-3','nicha@example.com','r-1','2026-09-06 08:10:00'),
('u-4','bank@example.com','r-1','2026-09-06 08:11:00'),
('u-5','tida@example.com','r-2','2026-09-06 08:12:00'),
('u-6','emma@example.com','r-1','2026-09-06 08:13:00'),
('u-7','corpadmin@example.com','r-5','2026-09-06 08:14:00'),
('u-8','employer1@example.com','r-4','2026-09-06 08:15:00'),
('u-9','user9@example.com','r-1','2026-09-06 08:16:00'),
('u-10','user10@example.com','r-1','2026-09-06 08:17:00'),
('u-11','admin@example.com','r-3','2026-09-06 08:18:00'),
('u-12','instructor2@example.com','r-2','2026-09-06 08:20:00')
ON DUPLICATE KEY UPDATE email=VALUES(email);

-- Profiles
INSERT INTO profiles (id,user_id,display_name,bio,created_at) VALUES
('p-1','u-1','อนันต์','Learner interested in backend and DevOps.','2026-09-06 08:00:00'),
('p-2','u-2','Dr. Krit','Senior Go instructor.','2026-09-06 08:05:00'),
('p-3','u-3','นิชา','Product designer.','2026-09-06 08:10:00')
ON DUPLICATE KEY UPDATE display_name=VALUES(display_name);

-- Instructors
INSERT INTO instructors (id,user_id,headline,rating,created_at) VALUES
('i-1','u-2','Go Backend Expert',4.9,'2026-09-06 08:05:00'),
('i-2','u-5','AI & Data',4.8,'2026-09-06 08:12:00'),
('i-3','u-12','Flutter Instructor',4.7,'2026-09-06 08:20:00')
ON DUPLICATE KEY UPDATE headline=VALUES(headline);

-- Organizations
INSERT INTO organizations (id,name,created_at) VALUES
('org-1','Acme Corp',NOW()),
('org-2','Beta Solutions',NOW()),
('org-3','Gamma Enterprise',NOW())
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- Categories
INSERT INTO categories (id,name,created_at) VALUES
('c-1','Programming',NOW()),
('c-2','AI & Data',NOW()),
('c-3','Design',NOW()),
('c-4','Marketing',NOW()),
('c-5','Business',NOW())
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- Courses (15)
INSERT INTO courses (id,instructor_id,category_id,title,price,status,created_at) VALUES
('course-1','i-1','c-1','Go Backend Professional',2990.00,'published','2026-09-06 09:00:00'),
('course-2','i-2','c-2','AI for Business',1990.00,'published','2026-09-06 09:05:00'),
('course-3','i-3','c-1','Flutter Professional',2490.00,'published','2026-09-06 09:10:00'),
('course-4','i-1','c-1','Go Masterclass: REST & APIs',1990.00,'published','2026-09-06 09:12:00'),
('course-5','i-2','c-2','Prompt Engineering',1490.00,'published','2026-09-06 09:14:00'),
('course-6','i-3','c-3','UX/UI Essentials',1690.00,'published','2026-09-06 09:16:00'),
('course-7','i-1','c-1','SQL Masterclass',1290.00,'published','2026-09-06 09:18:00'),
('course-8','i-2','c-2','Data Analytics with Python',1990.00,'published','2026-09-06 09:20:00'),
('course-9','i-3','c-3','Design Systems',1590.00,'published','2026-09-06 09:22:00'),
('course-10','i-1','c-1','Backend Security',1990.00,'published','2026-09-06 09:24:00'),
('course-11','i-2','c-2','Machine Learning Basics',2490.00,'published','2026-09-06 09:26:00'),
('course-12','i-3','c-1','Advanced Flutter Animations',1890.00,'published','2026-09-06 09:28:00'),
('course-13','i-1','c-5','Startup Fundraising 101',990.00,'published','2026-09-06 09:30:00'),
('course-14','i-2','c-4','Digital Marketing',1590.00,'published','2026-09-06 09:32:00'),
('course-15','i-3','c-3','Portfolio Building',1290.00,'published','2026-09-06 09:34:00')
ON DUPLICATE KEY UPDATE title=VALUES(title), price=VALUES(price);

-- Enrollments
INSERT INTO enrollments (id,user_id,course_id,status,progress,started_at,created_at) VALUES
('enr-1','u-1','course-1','in_progress',68.00,'2026-08-20 08:00:00','2026-08-20 08:00:00'),
('enr-2','u-3','course-3','completed',100.00,'2026-06-01 10:00:00','2026-06-01 10:00:00'),
('enr-3','u-4','course-2','in_progress',12.50,'2026-09-01 11:00:00','2026-09-01 11:00:00')
ON DUPLICATE KEY UPDATE status=VALUES(status), progress=VALUES(progress);

-- Orders
INSERT INTO orders (id,user_id,total_amount,status,created_at) VALUES
('ord-1','u-1',2990.00,'paid','2026-08-20 08:05:00'),
('ord-2','u-3',2490.00,'paid','2026-06-01 10:05:00')
ON DUPLICATE KEY UPDATE total_amount=VALUES(total_amount);

-- Payments
INSERT INTO payments (id,order_id,method,amount,status,paid_at) VALUES
('pay-1','ord-1','card',2990.00,'succeeded','2026-08-20 08:06:00'),
('pay-2','ord-2','card',2490.00,'succeeded','2026-06-01 10:06:00')
ON DUPLICATE KEY UPDATE status=VALUES(status);

-- Live sessions
INSERT INTO live_sessions (id,course_id,title,start_at,created_at) VALUES
('live-1','course-2','AI for Business — Live Q&A','2026-09-08 18:00:00','2026-09-01 09:00:00'),
('live-2','course-3','Flutter — Live Workshop','2026-09-10 19:00:00','2026-09-02 09:00:00'),
('live-3','course-1','Go Backend — Live Q&A','2026-09-12 20:00:00','2026-09-03 09:00:00'),
('live-4','course-5','Prompt Engineering — AMA','2026-09-09 17:00:00','2026-09-01 10:00:00'),
('live-5','course-8','Data Analytics — Office Hours','2026-09-11 16:00:00','2026-09-02 10:00:00')
ON DUPLICATE KEY UPDATE title=VALUES(title);

-- Community posts
INSERT INTO community_posts (id,user_id,content,posted_at) VALUES
('post-1','u-1','มีใครลองทำ project นี้แล้ว แชร์ได้ไหมครับ?','2026-08-21 09:00:00'),
('post-2','u-3','แนะนำ resource สำหรับ UX/UI หน่อยครับ','2026-08-22 10:00:00'),
('post-3','u-4','กำลังเตรียมสอบ Cert ใครมี tips บ้าง','2026-08-23 11:00:00'),
('post-4','u-6','ใครจะเข้าร่วม Live Q&A บ้างครับ?','2026-09-01 12:00:00'),
('post-5','u-1','แชร์โค้ดตัวอย่าง REST API ที่ใช้ในคอร์ส','2026-08-25 13:00:00'),
('post-6','u-9','หางานสาย Data มีใครแนะนำบริษัทไหม','2026-08-26 14:00:00'),
('post-7','u-10','ใครทำ Portfolio สวยๆ แชร์หน่อย','2026-08-27 15:00:00'),
('post-8','u-4','ถามเรื่อง career path ในสาย backend','2026-08-28 16:00:00'),
('post-9','u-1','อยากให้มี subtitle ภาษาไทยในวิดีโอครับ','2026-08-29 17:00:00'),
('post-10','u-6','ขอคูปองลดราคาคอร์สหน่อยจ้า','2026-08-30 18:00:00')
ON DUPLICATE KEY UPDATE content=VALUES(content);

-- Skills
INSERT INTO skills (id,name,created_at) VALUES
('skill-1','API Design',NOW()),
('skill-2','Database',NOW()),
('skill-3','Authentication',NOW()),
('skill-4','Flutter',NOW()),
('skill-5','Data Analysis',NOW()),
('skill-6','UX Design',NOW()),
('skill-7','Prompt Engineering',NOW()),
('skill-8','Deployment',NOW())
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- Employers
INSERT INTO employers (id,name,created_at) VALUES
('emp-1','TechCorp',NOW()),
('emp-2','DataWorks',NOW()),
('emp-3','DesignStudio',NOW()),
('emp-4','Marketize',NOW()),
('emp-5','FinServe',NOW())
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- Jobs
INSERT INTO jobs (id,employer_id,title,location,created_at) VALUES
('job-1','emp-1','Backend Engineer','Bangkok',NOW()),
('job-2','emp-2','Data Analyst','Remote',NOW()),
('job-3','emp-3','Product Designer','Chiang Mai',NOW()),
('job-4','emp-4','Digital Marketer','Bangkok',NOW()),
('job-5','emp-5','SRE','Remote',NOW()),
('job-6','emp-1','Golang Developer','Bangkok',NOW()),
('job-7','emp-2','Machine Learning Engineer','Remote',NOW()),
('job-8','emp-3','UX Researcher','Bangkok',NOW()),
('job-9','emp-4','Growth Analyst','Bangkok',NOW()),
('job-10','emp-5','Cloud Engineer','Remote',NOW())
ON DUPLICATE KEY UPDATE title=VALUES(title);

-- Done

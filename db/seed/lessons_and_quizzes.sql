USE ablearning;

-- Course sections
INSERT INTO course_sections (id, course_id, title, position, created_at) VALUES
('sec-1','course-1','Introduction',1,NOW()),
('sec-2','course-1','REST API',2,NOW()),
('sec-3','course-3','Getting Started',1,NOW()),
('sec-4','course-3','State Management',2,NOW()),
('sec-5','course-2','Foundations',1,NOW())
ON DUPLICATE KEY UPDATE title=VALUES(title);

-- Lessons
INSERT INTO lessons (id, section_id, title, duration_seconds, created_at) VALUES
('ls-1','sec-1','Welcome & Setup',480,NOW()),
('ls-2','sec-1','Course Overview',300,NOW()),
('ls-3','sec-2','Designing RESTful APIs',900,NOW()),
('ls-4','sec-2','Routing & Handlers in Go',1200,NOW()),
('ls-5','sec-3','Flutter Project Setup',600,NOW()),
('ls-6','sec-4','State with Riverpod',1400,NOW()),
('ls-7','sec-5','Intro to AI Concepts',800,NOW())
ON DUPLICATE KEY UPDATE title=VALUES(title);

-- Create a quiz record (tied to a course) and questions
INSERT INTO quizzes (id, course_id, title, created_at) VALUES
('quiz-1','course-1','API Knowledge Quiz',NOW())
ON DUPLICATE KEY UPDATE title=VALUES(title);

INSERT INTO quiz_questions (id, quiz_id, question, metadata) VALUES
('q-1','quiz-1','HTTP status code 200 means what?', JSON_OBJECT('choices', JSON_ARRAY(JSON_OBJECT('id','a','text','Error'), JSON_OBJECT('id','b','text','Success'), JSON_OBJECT('id','c','text','Redirect'), JSON_OBJECT('id','d','text','Unauthorized')), 'correct','b')),
('q-2','quiz-1','Which method is idempotent?', JSON_OBJECT('choices', JSON_ARRAY(JSON_OBJECT('id','a','text','POST'), JSON_OBJECT('id','b','text','PATCH'), JSON_OBJECT('id','c','text','PUT'), JSON_OBJECT('id','d','text','CONNECT')), 'correct','c'))
ON DUPLICATE KEY UPDATE question=VALUES(question), metadata=VALUES(metadata);

-- Quiz attempts
INSERT INTO quiz_attempts (id, quiz_id, user_id, score, taken_at) VALUES
('qa-1','quiz-1','u-1',85,'2026-08-21 10:00:00'),
('qa-2','quiz-1','u-3',92,'2026-06-02 11:00:00')
ON DUPLICATE KEY UPDATE score=VALUES(score);

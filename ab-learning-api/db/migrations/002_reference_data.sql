-- Reference data required in every environment (not demo data).
INSERT INTO roles (code, name_th, name_en) VALUES
  ('GUEST',        'ผู้เยี่ยมชม',        'Guest'),
  ('LEARNER',      'ผู้เรียน',           'Learner'),
  ('INSTRUCTOR',   'ผู้สอน',            'Instructor'),
  ('CORP_ADMIN',   'ผู้ดูแลองค์กร',      'Corporate Admin'),
  ('CORP_MANAGER', 'ผู้จัดการองค์กร',     'Corporate Manager'),
  ('EMPLOYER',     'นายจ้าง',           'Employer'),
  ('ADMIN',        'ผู้ดูแลระบบ',        'Admin');

INSERT INTO categories (name_th, name_en, slug, icon) VALUES
  ('การเขียนโปรแกรม', 'Programming', 'programming', 'code'),
  ('ดีไซน์',          'Design',      'design',      'palette'),
  ('ธุรกิจ',          'Business',    'business',    'briefcase'),
  ('ข้อมูล',          'Data',        'data',        'chart'),
  ('การตลาด',         'Marketing',   'marketing',   'megaphone');

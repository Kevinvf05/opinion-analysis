-- ============================================
-- TEACHER OPINION ANALYSIS SYSTEM - SEED DATA
-- Safe to run after schema.sql
-- ============================================

-- Wrap everything so we don't half-seed on error
BEGIN;

-- ---------- 1) Users ----------
-- Admin (password: Admin123!)
WITH admin_user AS (
  INSERT INTO users (email, password_hash, first_name, last_name, role, is_active, last_login)
  VALUES (
    'admin@uaem.mx',
    '6ca13d52ca70c883e0f0bb101e425a89e8624de51db2d2392593af6a84118090',  -- SHA256 of 'Admin123!'
    'System', 'Admin', 'admin', TRUE, NOW()
  )
  RETURNING id
),
-- Professor (with matching professors row later) (password: Prof123!)
prof_user AS (
  INSERT INTO users (email, password_hash, first_name, last_name, role, is_active)
  VALUES (
    'alberto.garcia@uaem.mx',
    '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92',  -- SHA256 of 'Prof123!'
    'Alberto', 'Garcia', 'professor', TRUE
  )
  RETURNING id
),
-- Another Professor (password: Prof123!)
prof2_user AS (
  INSERT INTO users (email, password_hash, first_name, last_name, role, is_active)
  VALUES (
    'maria.lopez@uaem.mx',
    '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92',  -- SHA256 of 'Prof123!'
    'Maria', 'Lopez', 'professor', TRUE
  )
  RETURNING id
),
-- Student (with matching students row later) (matricula: A01700001, name: Juan Perez - no password)
stud_user AS (
  INSERT INTO users (email, password_hash, first_name, last_name, role, matricula, is_active)
  VALUES (
    NULL,
    'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',  -- SHA256 of empty string
    'Juan', 'Perez', 'student', 'A01700001', TRUE
  )
  RETURNING id
),
-- Another Student (matricula: A01700002, name: Ana Ruiz - no password)
stud2_user AS (
  INSERT INTO users (email, password_hash, first_name, last_name, role, matricula, is_active)
  VALUES (
    NULL,
    'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',  -- SHA256 of empty string
    'Ana', 'Ruiz', 'student', 'A01700002', TRUE
  )
  RETURNING id
)

-- ---------- 2) Admins ----------
, admin_row AS (
  INSERT INTO admins (user_id, department, permissions)
  SELECT id, 'IT', '{"can_manage_users": true, "can_view_reports": true, "can_edit_catalog": true}'::jsonb
  FROM admin_user
  RETURNING id
)

-- ---------- 3) Professors ----------
, prof_row AS (
  INSERT INTO professors (user_id, email, department, office, phone, specialization, status)
  SELECT id, 'alberto.garcia@uaem.mx', 'Computer Science', 'B-204', '+52-55-5555-0001',
         'Data Mining, NLP', 'active'
  FROM prof_user
  RETURNING id, user_id
),
prof2_row AS (
  INSERT INTO professors (user_id, email, department, office, phone, specialization, status)
  SELECT id, 'maria.lopez@uaem.mx', 'Mathematics', 'C-101', '+52-55-5555-0002',
         'Statistics, Probability', 'active'
  FROM prof2_user
  RETURNING id, user_id
)

-- ---------- 4) Students ----------
, stud_row AS (
  INSERT INTO students (user_id, matricula, semester, career, "group", has_completed_survey, status)
  SELECT id, 'A01700001', 3, 'Computer Engineering', '302', FALSE, 'active'
  FROM stud_user
  RETURNING id, user_id
),
stud2_row AS (
  INSERT INTO students (user_id, matricula, semester, career, "group", has_completed_survey, status)
  SELECT id, 'A01700002', 5, 'Data Science', '501', FALSE, 'active'
  FROM stud2_user
  RETURNING id, user_id
)

-- ---------- 5) Subjects ----------
, subj_cs AS (
  INSERT INTO subjects (name, code, professor_id, semester, credits, description, is_active)
  SELECT 'Introduction to Data Science', 'CS101', pr.id, 3, 8, 'Foundations of data wrangling, EDA, and basics of ML.', TRUE
  FROM prof_row pr
  RETURNING id, professor_id
),
subj_ml AS (
  INSERT INTO subjects (name, code, professor_id, semester, credits, description, is_active)
  SELECT 'Machine Learning I', 'CS201', pr.id, 5, 10, 'Supervised learning, model evaluation, and regularization.', TRUE
  FROM prof_row pr
  RETURNING id, professor_id
),
subj_stats AS (
  INSERT INTO subjects (name, code, professor_id, semester, credits, description, is_active)
  SELECT 'Applied Statistics', 'MA150', pr2.id, 3, 8, 'Descriptive stats, probability, and inference.', TRUE
  FROM prof2_row pr2
  RETURNING id, professor_id
)

-- ---------- 6) Group Classes ----------
, grp1 AS (
  INSERT INTO group_classes (subject_id, professor_id, group_name, semester_period, schedule, classroom, max_students, current_students, is_active)
  SELECT s.id, s.professor_id, 'A', '2025-1', 'Mon/Wed 10:00-11:30', 'LAB-DS', 30, 0, TRUE
  FROM subj_cs s
  RETURNING id, subject_id, professor_id
),
grp2 AS (
  INSERT INTO group_classes (subject_id, professor_id, group_name, semester_period, schedule, classroom, max_students, current_students, is_active)
  SELECT s.id, s.professor_id, 'B', '2025-1', 'Tue/Thu 12:00-13:30', 'ROOM-201', 30, 0, TRUE
  FROM subj_ml s
  RETURNING id, subject_id, professor_id
),
grp3 AS (
  INSERT INTO group_classes (subject_id, professor_id, group_name, semester_period, schedule, classroom, max_students, current_students, is_active)
  SELECT s.id, s.professor_id, 'A', '2025-1', 'Mon/Wed 08:00-09:30', 'ROOM-105', 30, 0, TRUE
  FROM subj_stats s
  RETURNING id, subject_id, professor_id
)

-- Final SELECT to complete the CTE chain
SELECT 1;

-- ---------- 7) Enrollment (student_subjects) ----------
INSERT INTO student_subjects (student_id, subject_id)
SELECT st.id, s.id FROM stud_row st, subj_cs s
UNION ALL
SELECT st.id, s.id FROM stud_row st, subj_stats s
UNION ALL
SELECT st2.id, s.id FROM stud2_row st2, subj_ml s;

-- ---------- 8) Surveys (note: surveys.student_id & professor_id reference users.id) ----------
-- Juan Perez evaluates Prof. Alberto Garcia for CS101
INSERT INTO surveys (student_id, professor_id, subject_id, status, created_at)
SELECT 
  (SELECT user_id FROM stud_row LIMIT 1), 
  (SELECT user_id FROM prof_row LIMIT 1), 
  (SELECT id FROM subj_cs LIMIT 1), 
  'completed', NOW();

-- ---------- 9) Comments on survey ----------
INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT id, 'Great introduction, clear explanations and helpful labs.', 'positive', 0.94, NOW()
FROM surveys WHERE status = 'completed' LIMIT 1;

-- ---------- 10) Evaluations (aggregated per professor) ----------
-- Simple illustrative row (your app may compute this)
INSERT INTO evaluations (professor_id, student_id, comment, sentiment, sentiment_score, average_score, total_score,
                         positive_count, neutral_count, negative_count, created_at)
SELECT pr.id, 'A01700001', 'Overall strong teaching performance for CS101.', 'positive', 0.90, 4.6, 23, 5, 0, 1, NOW()
FROM prof_row pr;

-- ---------- 11) Subject Ratings (per subject & professor) ----------
INSERT INTO subject_ratings (professor_id, subject_id, average_score, total_evaluations,
                             score_5_count, score_4_count, score_3_count, score_2_count, score_1_count,
                             positive_percentage, neutral_percentage, negative_percentage, last_updated)
SELECT pr.id, s.id, 4.6, 6, 4, 2, 0, 0, 0, 85.0, 10.0, 5.0, NOW()
FROM prof_row pr, subj_cs s;

-- A second rating entry for a different subject/prof
INSERT INTO subject_ratings (professor_id, subject_id, average_score, total_evaluations,
                             score_5_count, score_4_count, score_3_count, score_2_count, score_1_count,
                             positive_percentage, neutral_percentage, negative_percentage, last_updated)
SELECT pr.id, s.id, 4.3, 4, 2, 2, 0, 0, 0, 75.0, 20.0, 5.0, NOW()
FROM prof2_row pr, subj_stats s;

-- ---------- 12) Activity Logs ----------
-- Admin creates professor and subjects
INSERT INTO activity_logs (user_id, user_type, action_type, description, target_id, target_type, ip_address, user_agent, created_at)
SELECT (SELECT user_id FROM admin_row LIMIT 1), 'admin', 'create', 'Created professor Alberto Garcia', (SELECT id FROM prof_row LIMIT 1), 'professor', '127.0.0.1', 'seed-script/1.0', NOW();

INSERT INTO activity_logs (user_id, user_type, action_type, description, target_id, target_type, ip_address, user_agent, created_at)
SELECT (SELECT user_id FROM admin_row LIMIT 1), 'admin', 'create', 'Created subject CS101', (SELECT id FROM subj_cs LIMIT 1), 'subject', '127.0.0.1', 'seed-script/1.0', NOW();

-- Student completes survey
INSERT INTO activity_logs (user_id, user_type, action_type, description, target_id, target_type, ip_address, user_agent, created_at)
SELECT (SELECT user_id FROM stud_row LIMIT 1), 'student', 'complete_survey', 'Completed survey for CS101', (SELECT id FROM subj_cs LIMIT 1), 'subject', '127.0.0.1', 'seed-script/1.0', NOW();

COMMIT;

-- ============================================
-- QUICK CHECKS (optional)
-- SELECT * FROM users;
-- SELECT * FROM admins;
-- SELECT * FROM professors;
-- SELECT * FROM students;
-- SELECT * FROM subjects;
-- SELECT * FROM group_classes;
-- SELECT * FROM student_subjects;
-- SELECT * FROM surveys;
-- SELECT * FROM comments;
-- SELECT * FROM evaluations;
-- SELECT * FROM subject_ratings;
-- SELECT * FROM activity_logs;
-- SELECT * FROM professor_statistics;
-- SELECT * FROM subject_statistics;
-- SELECT * FROM student_survey_progress;
-- ============================================

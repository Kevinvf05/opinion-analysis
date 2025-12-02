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
    '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9',  -- SHA256 of 'admin123'
    'System', 'Admin', 'admin', TRUE, NOW()
  )
  RETURNING id
),
-- Professor (with matching professors row later) (password: Prof123!)
prof_user AS (
  INSERT INTO users (email, password_hash, first_name, last_name, role, is_active)
  VALUES (
    'alberto.garcia@uaem.mx',
    'cffa965d9faa1d453f2d336294b029a7f84f485f75ce2a2c723065453b12b03b',  -- SHA256 of 'profesor123'
    'Alberto', 'Garcia', 'professor', TRUE
  )
  RETURNING id
),
-- Another Professor (password: Prof123!)
prof2_user AS (
  INSERT INTO users (email, password_hash, first_name, last_name, role, is_active)
  VALUES (
    'maria.lopez@uaem.mx',
    'cffa965d9faa1d453f2d336294b029a7f84f485f75ce2a2c723065453b12b03b',  -- SHA256 of 'profesor123'
    'Maria', 'Lopez', 'professor', TRUE
  )
  RETURNING id
),
-- Student (with matching students row later) (matricula: A01700001, name: Juan Perez - no password)
stud_user AS (
  INSERT INTO users (email, password_hash, first_name, last_name, role, matricula, is_active)
  VALUES (
    NULL,
    '2e63a1090735f47213fea3b974418e3e42437325f313b3d3d2f6238cc22298f9',  -- SHA256 of 'estudiante123'
    'Juan', 'Perez', 'student', 'A01700001', TRUE
  )
  RETURNING id
),
-- Another Student (matricula: A01700002, name: Ana Ruiz - no password)
stud2_user AS (
  INSERT INTO users (email, password_hash, first_name, last_name, role, matricula, is_active)
  VALUES (
    NULL,
    '2e63a1090735f47213fea3b974418e3e42437325f313b3d3d2f6238cc22298f9',  -- SHA256 of 'estudiante123'
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

COMMIT;

-- ---------- 7) Enrollment (student_subjects) ----------
INSERT INTO student_subjects (student_id, subject_id)
SELECT s.id, subj.id 
FROM students s, subjects subj 
WHERE s.matricula = 'A01700001' AND subj.code = 'CS101'
UNION ALL
SELECT s.id, subj.id 
FROM students s, subjects subj 
WHERE s.matricula = 'A01700001' AND subj.code = 'MA150'
UNION ALL
SELECT s.id, subj.id 
FROM students s, subjects subj 
WHERE s.matricula = 'A01700002' AND subj.code = 'CS201';

-- ---------- 8) Surveys (note: surveys.student_id & professor_id reference users.id) ----------
-- Survey 1: Juan Perez evaluates Prof. Alberto Garcia for CS101
INSERT INTO surveys (student_id, professor_id, subject_id, status, created_at)
SELECT 
  u1.id, 
  u2.id, 
  subj.id, 
  'completed', 
  NOW() - INTERVAL '5 days'
FROM users u1, users u2, subjects subj
WHERE u1.matricula = 'A01700001' 
  AND u2.email = 'alberto.garcia@uaem.mx'
  AND subj.code = 'CS101';

-- Survey 2: Ana Ruiz evaluates Prof. Alberto Garcia for CS201
INSERT INTO surveys (student_id, professor_id, subject_id, status, created_at)
SELECT 
  u1.id, 
  u2.id, 
  subj.id, 
  'completed', 
  NOW() - INTERVAL '3 days'
FROM users u1, users u2, subjects subj
WHERE u1.matricula = 'A01700002' 
  AND u2.email = 'alberto.garcia@uaem.mx'
  AND subj.code = 'CS201';

-- Survey 3: Juan Perez evaluates Prof. Maria Lopez for MA150
INSERT INTO surveys (student_id, professor_id, subject_id, status, created_at)
SELECT 
  u1.id, 
  u2.id, 
  subj.id, 
  'completed', 
  NOW() - INTERVAL '2 days'
FROM users u1, users u2, subjects subj
WHERE u1.matricula = 'A01700001' 
  AND u2.email = 'maria.lopez@uaem.mx'
  AND subj.code = 'MA150';

-- Survey 4: Ana Ruiz evaluates Prof. Maria Lopez for MA150
INSERT INTO surveys (student_id, professor_id, subject_id, status, created_at)
SELECT 
  u1.id, 
  u2.id, 
  subj.id, 
  'completed', 
  NOW() - INTERVAL '1 day'
FROM users u1, users u2, subjects subj
WHERE u1.matricula = 'A01700002' 
  AND u2.email = 'maria.lopez@uaem.mx'
  AND subj.code = 'MA150';

-- ---------- 9) Comments on surveys ----------
-- POSITIVE comments for Alberto Garcia (CS101)
INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT 1, 'El profesor explica muy bien los conceptos y siempre está dispuesto a ayudar. Las clases son dinámicas y el material es excelente.', 'positive', 0.94, NOW() - INTERVAL '5 days';

INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT 1, 'Excelente dominio de la materia. Los ejemplos prácticos ayudan mucho a entender la teoría. Muy recomendado.', 'positive', 0.91, NOW() - INTERVAL '5 days';

INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT 1, 'Me gusta cómo hace las clases interactivas, siempre aprendes algo nuevo y útil. Gran profesor.', 'positive', 0.88, NOW() - INTERVAL '5 days';

-- NEUTRAL comments for Alberto Garcia (CS201)
INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT 2, 'La materia es interesante pero a veces el ritmo es muy rápido. Sería bueno tener más tiempo para practicar en clase.', 'neutral', 0.78, NOW() - INTERVAL '3 days';

INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT 2, 'El contenido está bien pero las explicaciones podrían ser más detalladas. Las tareas son muy demandantes.', 'neutral', 0.72, NOW() - INTERVAL '3 days';

INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT 2, 'Regular. Algunos temas son confusos y no siempre hay tiempo para resolver todas las dudas. Podría mejorar.', 'neutral', 0.65, NOW() - INTERVAL '3 days';

-- NEGATIVE comment for Alberto Garcia (CS201)
INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT 2, 'Las clases son demasiado rápidas y no explica bien los conceptos difíciles. Me cuesta seguir el ritmo y hay poca retroalimentación.', 'negative', 0.85, NOW() - INTERVAL '3 days';

-- POSITIVE comments for Maria Lopez (MA150)
INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT 3, 'Profesora muy dedicada y paciente. Explica los conceptos matemáticos de forma clara y accesible. Excelente maestra.', 'positive', 0.96, NOW() - INTERVAL '2 days';

INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT 3, 'Me encanta su metodología de enseñanza. Siempre disponible para resolver dudas y los ejemplos son muy útiles.', 'positive', 0.93, NOW() - INTERVAL '2 days';

INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT 3, 'Hace que las matemáticas sean menos intimidantes. Sus explicaciones son claras y bien estructuradas.', 'positive', 0.89, NOW() - INTERVAL '2 days';

-- NEUTRAL comment for Maria Lopez (MA150)
INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT 3, 'Buena profesora en general, aunque a veces los ejercicios en clase son repetitivos. Podría variar más los ejemplos.', 'neutral', 0.70, NOW() - INTERVAL '2 days';

-- Additional comments for Maria Lopez from Ana Ruiz (Survey 4)
-- POSITIVE comment
INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT 4, 'La profesora López es muy buena explicando. Me ayudó a mejorar mis calificaciones en matemáticas.', 'positive', 0.92, NOW() - INTERVAL '1 day';

-- NEUTRAL comment
INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT 4, 'Las clases están bien organizadas pero a veces siento que falta más práctica con problemas complejos.', 'neutral', 0.68, NOW() - INTERVAL '1 day';

-- NEGATIVE comment
INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT 4, 'A veces es difícil entender los temas porque va muy rápido y no siempre responde las preguntas en clase.', 'negative', 0.82, NOW() - INTERVAL '1 day';

-- ---------- 10) Evaluations (aggregated per professor) ----------
-- Simple illustrative row (your app may compute this)
INSERT INTO evaluations (professor_id, student_id, comment, sentiment, sentiment_score, average_score, total_score,
                         positive_count, neutral_count, negative_count, created_at)
SELECT pr.id, 'A01700001', 'Overall strong teaching performance for CS101.', 'positive', 0.90, 4.6, 23, 5, 0, 1, NOW()
FROM professors pr
WHERE pr.email = 'alberto.garcia@uaem.mx';

-- ---------- 11) Subject Ratings (per subject & professor) ----------
INSERT INTO subject_ratings (professor_id, subject_id, average_score, total_evaluations,
                             score_5_count, score_4_count, score_3_count, score_2_count, score_1_count,
                             positive_percentage, neutral_percentage, negative_percentage, last_updated)
SELECT pr.id, s.id, 4.6, 6, 4, 2, 0, 0, 0, 85.0, 10.0, 5.0, NOW()
FROM professors pr, subjects s
WHERE pr.email = 'alberto.garcia@uaem.mx' AND s.code = 'CS101';

-- A second rating entry for a different subject/prof
INSERT INTO subject_ratings (professor_id, subject_id, average_score, total_evaluations,
                             score_5_count, score_4_count, score_3_count, score_2_count, score_1_count,
                             positive_percentage, neutral_percentage, negative_percentage, last_updated)
SELECT pr.id, s.id, 4.3, 4, 2, 2, 0, 0, 0, 75.0, 20.0, 5.0, NOW()
FROM professors pr, subjects s
WHERE pr.email = 'maria.lopez@uaem.mx' AND s.code = 'MA150';

-- ---------- 12) Activity Logs ----------
-- Admin creates professor and subjects
INSERT INTO activity_logs (user_id, user_type, action_type, description, target_id, target_type, ip_address, user_agent, created_at)
SELECT u.id, 'admin', 'create', 'Created professor Alberto Garcia', pr.id, 'professor', '127.0.0.1', 'seed-script/1.0', NOW()
FROM users u, professors pr
WHERE u.email = 'admin@uaem.mx' AND pr.email = 'alberto.garcia@uaem.mx';

INSERT INTO activity_logs (user_id, user_type, action_type, description, target_id, target_type, ip_address, user_agent, created_at)
SELECT u.id, 'admin', 'create', 'Created subject CS101', s.id, 'subject', '127.0.0.1', 'seed-script/1.0', NOW()
FROM users u, subjects s
WHERE u.email = 'admin@uaem.mx' AND s.code = 'CS101';

-- Student completes survey
INSERT INTO activity_logs (user_id, user_type, action_type, description, target_id, target_type, ip_address, user_agent, created_at)
SELECT u.id, 'student', 'complete_survey', 'Completed survey for CS101', s.id, 'subject', '127.0.0.1', 'seed-script/1.0', NOW()
FROM users u, subjects s
WHERE u.matricula = 'A01700001' AND s.code = 'CS101';

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

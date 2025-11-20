-- ============================================
-- UAEM EVALUATION SYSTEM - SIMPLE SEED DATA
-- Run after schema.sql
-- ============================================

BEGIN;

-- ---------- 1) USERS ----------
-- Admin (email: admin@uaem.mx, password: Admin123!)
INSERT INTO users (email, password_hash, first_name, last_name, role, is_active, last_login)
VALUES ('admin@uaem.mx', '3eb3fe66b31e3b4d10fa70b5cad49c7112294af6ae4e476a1c405155d45aa121', 'System', 'Admin', 'admin', TRUE, NOW());

-- Professors (email/password: alberto.garcia@uaem.mx / Prof123! and maria.lopez@uaem.mx / Prof123!)
INSERT INTO users (email, password_hash, first_name, last_name, role, is_active)
VALUES 
  ('alberto.garcia@uaem.mx', '2b780b5401d1dce22f0077b7772aca9761c87c4749398a2eb58c2ad3fe558ebc', 'Alberto', 'Garcia', 'professor', TRUE),
  ('maria.lopez@uaem.mx', '2b780b5401d1dce22f0077b7772aca9761c87c4749398a2eb58c2ad3fe558ebc', 'Maria', 'Lopez', 'professor', TRUE);

-- Students (login with matricula + name: A01700001/Juan Perez, A01700002/Ana Ruiz, etc.)
INSERT INTO users (email, password_hash, first_name, last_name, role, matricula, is_active)
VALUES 
  (NULL, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 'Juan', 'Perez', 'student', 'A01700001', TRUE),
  (NULL, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 'Ana', 'Ruiz', 'student', 'A01700002', TRUE),
  (NULL, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 'Carlos', 'Martinez', 'student', 'A01700003', TRUE),
  (NULL, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 'Laura', 'Gonzalez', 'student', 'A01700004', TRUE),
  (NULL, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 'Miguel', 'Rodriguez', 'student', 'A01700005', TRUE),
  (NULL, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 'Sofia', 'Hernandez', 'student', 'A01700006', TRUE),
  (NULL, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 'Diego', 'Ramirez', 'student', 'A01700007', TRUE);

-- ---------- 2) ADMINS ----------
INSERT INTO admins (user_id, department, permissions)
SELECT id, 'IT', '{"can_manage_users": true, "can_view_reports": true, "can_edit_catalog": true}'::jsonb
FROM users WHERE email = 'admin@uaem.mx';

-- ---------- 3) PROFESSORS ----------
INSERT INTO professors (user_id, email, department, office, phone, specialization, status)
SELECT id, 'alberto.garcia@uaem.mx', 'Computer Science', 'B-204', '+52-55-5555-0001', 'Data Mining, NLP', 'active'
FROM users WHERE email = 'alberto.garcia@uaem.mx';

INSERT INTO professors (user_id, email, department, office, phone, specialization, status)
SELECT id, 'maria.lopez@uaem.mx', 'Mathematics', 'C-101', '+52-55-5555-0002', 'Statistics, Probability', 'active'
FROM users WHERE email = 'maria.lopez@uaem.mx';

-- ---------- 4) STUDENTS ----------
INSERT INTO students (user_id, matricula, semester, career, "group", has_completed_survey, status)
SELECT id, 'A01700001', 3, 'Computer Engineering', '302', TRUE, 'active'
FROM users WHERE matricula = 'A01700001';

INSERT INTO students (user_id, matricula, semester, career, "group", has_completed_survey, status)
SELECT id, 'A01700002', 5, 'Data Science', '501', TRUE, 'active'
FROM users WHERE matricula = 'A01700002';

INSERT INTO students (user_id, matricula, semester, career, "group", has_completed_survey, status)
SELECT id, 'A01700003', 3, 'Computer Engineering', '302', TRUE, 'active'
FROM users WHERE matricula = 'A01700003';

INSERT INTO students (user_id, matricula, semester, career, "group", has_completed_survey, status)
SELECT id, 'A01700004', 5, 'Data Science', '501', TRUE, 'active'
FROM users WHERE matricula = 'A01700004';

INSERT INTO students (user_id, matricula, semester, career, "group", has_completed_survey, status)
SELECT id, 'A01700005', 3, 'Computer Engineering', '302', TRUE, 'active'
FROM users WHERE matricula = 'A01700005';

INSERT INTO students (user_id, matricula, semester, career, "group", has_completed_survey, status)
SELECT id, 'A01700006', 5, 'Data Science', '501', FALSE, 'active'
FROM users WHERE matricula = 'A01700006';

INSERT INTO students (user_id, matricula, semester, career, "group", has_completed_survey, status)
SELECT id, 'A01700007', 3, 'Computer Engineering', '302', FALSE, 'active'
FROM users WHERE matricula = 'A01700007';

-- ---------- 5) SUBJECTS ----------
INSERT INTO subjects (name, code, professor_id, semester, credits, description, is_active)
SELECT 'Introduction to Data Science', 'CS101', p.id, 3, 8, 'Foundations of data wrangling, EDA, and basics of ML.', TRUE
FROM professors p WHERE p.email = 'alberto.garcia@uaem.mx';

INSERT INTO subjects (name, code, professor_id, semester, credits, description, is_active)
SELECT 'Machine Learning I', 'CS201', p.id, 5, 10, 'Supervised learning, model evaluation, and regularization.', TRUE
FROM professors p WHERE p.email = 'alberto.garcia@uaem.mx';

INSERT INTO subjects (name, code, professor_id, semester, credits, description, is_active)
SELECT 'Applied Statistics', 'MA150', p.id, 3, 8, 'Descriptive stats, probability, and inference.', TRUE
FROM professors p WHERE p.email = 'maria.lopez@uaem.mx';

-- ---------- 6) GROUP CLASSES ----------
INSERT INTO group_classes (subject_id, professor_id, group_name, semester_period, schedule, classroom, max_students, current_students, is_active)
SELECT s.id, s.professor_id, 'A', '2025-1', 'Mon/Wed 10:00-11:30', 'LAB-DS', 30, 0, TRUE
FROM subjects s WHERE s.code = 'CS101';

INSERT INTO group_classes (subject_id, professor_id, group_name, semester_period, schedule, classroom, max_students, current_students, is_active)
SELECT s.id, s.professor_id, 'B', '2025-1', 'Tue/Thu 12:00-13:30', 'ROOM-201', 30, 0, TRUE
FROM subjects s WHERE s.code = 'CS201';

INSERT INTO group_classes (subject_id, professor_id, group_name, semester_period, schedule, classroom, max_students, current_students, is_active)
SELECT s.id, s.professor_id, 'A', '2025-1', 'Mon/Wed 08:00-09:30', 'ROOM-105', 30, 0, TRUE
FROM subjects s WHERE s.code = 'MA150';

-- ---------- 7) STUDENT ENROLLMENT ----------
INSERT INTO student_subjects (student_id, subject_id)
SELECT st.id, subj.id
FROM students st, subjects subj
WHERE st.matricula = 'A01700001' AND subj.code IN ('CS101', 'MA150');

INSERT INTO student_subjects (student_id, subject_id)
SELECT st.id, subj.id
FROM students st, subjects subj
WHERE st.matricula = 'A01700002' AND subj.code = 'CS201';

INSERT INTO student_subjects (student_id, subject_id)
SELECT st.id, subj.id
FROM students st, subjects subj
WHERE st.matricula = 'A01700003' AND subj.code IN ('CS101', 'MA150');

INSERT INTO student_subjects (student_id, subject_id)
SELECT st.id, subj.id
FROM students st, subjects subj
WHERE st.matricula = 'A01700004' AND subj.code = 'CS201';

INSERT INTO student_subjects (student_id, subject_id)
SELECT st.id, subj.id
FROM students st, subjects subj
WHERE st.matricula = 'A01700005' AND subj.code IN ('CS101', 'MA150');

INSERT INTO student_subjects (student_id, subject_id)
SELECT st.id, subj.id
FROM students st, subjects subj
WHERE st.matricula = 'A01700006' AND subj.code = 'CS201';

INSERT INTO student_subjects (student_id, subject_id)
SELECT st.id, subj.id
FROM students st, subjects subj
WHERE st.matricula = 'A01700007' AND subj.code = 'CS101';

-- ---------- 8) SURVEYS ----------
INSERT INTO surveys (student_id, professor_id, subject_id, status, created_at)
SELECT u_stud.id, u_prof.id, subj.id, 'completed', NOW() - INTERVAL '10 days'
FROM users u_stud, users u_prof, subjects subj
WHERE u_stud.matricula = 'A01700001' 
  AND u_prof.email = 'alberto.garcia@uaem.mx'
  AND subj.code = 'CS101';

INSERT INTO surveys (student_id, professor_id, subject_id, status, created_at)
SELECT u_stud.id, u_prof.id, subj.id, 'completed', NOW() - INTERVAL '8 days'
FROM users u_stud, users u_prof, subjects subj
WHERE u_stud.matricula = 'A01700002' 
  AND u_prof.email = 'alberto.garcia@uaem.mx'
  AND subj.code = 'CS201';

INSERT INTO surveys (student_id, professor_id, subject_id, status, created_at)
SELECT u_stud.id, u_prof.id, subj.id, 'completed', NOW() - INTERVAL '7 days'
FROM users u_stud, users u_prof, subjects subj
WHERE u_stud.matricula = 'A01700003' 
  AND u_prof.email = 'alberto.garcia@uaem.mx'
  AND subj.code = 'CS101';

INSERT INTO surveys (student_id, professor_id, subject_id, status, created_at)
SELECT u_stud.id, u_prof.id, subj.id, 'completed', NOW() - INTERVAL '5 days'
FROM users u_stud, users u_prof, subjects subj
WHERE u_stud.matricula = 'A01700004' 
  AND u_prof.email = 'maria.lopez@uaem.mx'
  AND subj.code = 'MA150';

INSERT INTO surveys (student_id, professor_id, subject_id, status, created_at)
SELECT u_stud.id, u_prof.id, subj.id, 'completed', NOW() - INTERVAL '3 days'
FROM users u_stud, users u_prof, subjects subj
WHERE u_stud.matricula = 'A01700005' 
  AND u_prof.email = 'alberto.garcia@uaem.mx'
  AND subj.code = 'CS101';

-- PENDING SURVEYS for Sofia Hernandez (A01700006) and Diego Ramirez (A01700007)
INSERT INTO surveys (student_id, professor_id, subject_id, status, created_at)
SELECT u_stud.id, u_prof.id, subj.id, 'pending', NOW()
FROM users u_stud, users u_prof, subjects subj
WHERE u_stud.matricula = 'A01700006' 
  AND u_prof.email = 'alberto.garcia@uaem.mx'
  AND subj.code = 'CS201';

INSERT INTO surveys (student_id, professor_id, subject_id, status, created_at)
SELECT u_stud.id, u_prof.id, subj.id, 'pending', NOW()
FROM users u_stud, users u_prof, subjects subj
WHERE u_stud.matricula = 'A01700007' 
  AND u_prof.email = 'alberto.garcia@uaem.mx'
  AND subj.code = 'CS101';

-- ---------- 9) COMMENTS ----------
-- Survey 1: Juan Perez -> Alberto Garcia (CS101) - POSITIVE
INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT sv.id, 'Excelente introducción, explicaciones muy claras y laboratorios muy útiles.', 'positive', 0.94, NOW() - INTERVAL '10 days'
FROM surveys sv
WHERE sv.status = 'completed' 
ORDER BY sv.id LIMIT 1;

-- Survey 2: Ana Ruiz -> Alberto Garcia (CS201) - POSITIVE
INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT sv.id, 'Excelente profesor! Muy conocedor y con un estilo de enseñanza muy dinámico.', 'positive', 0.96, NOW() - INTERVAL '8 days'
FROM surveys sv
WHERE sv.status = 'completed' 
ORDER BY sv.id LIMIT 1 OFFSET 1;

-- Survey 3: Carlos Martinez -> Alberto Garcia (CS101) - NEUTRAL
INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT sv.id, 'Buena clase pero a veces avanza demasiado rápido. Más ejemplos serían útiles.', 'neutral', 0.72, NOW() - INTERVAL '7 days'
FROM surveys sv
WHERE sv.status = 'completed' 
ORDER BY sv.id LIMIT 1 OFFSET 2;

-- Survey 4: Laura Gonzalez -> Maria Lopez (MA150) - NEGATIVE
INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT sv.id, 'Las clases podrían ser más dinámicas. A veces es difícil mantener la concentración.', 'negative', 0.78, NOW() - INTERVAL '5 days'
FROM surveys sv
WHERE sv.status = 'completed' 
ORDER BY sv.id LIMIT 1 OFFSET 3;

-- Survey 5: Miguel Rodriguez -> Alberto Garcia (CS101) - POSITIVE
INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT sv.id, 'El mejor profesor que he tenido! Hace que los temas complejos sean fáciles de entender.', 'positive', 0.98, NOW() - INTERVAL '3 days'
FROM surveys sv
WHERE sv.status = 'completed' 
ORDER BY sv.id LIMIT 1 OFFSET 4;

-- ---------- 10) EVALUATIONS ----------
INSERT INTO evaluations (professor_id, student_id, comment, sentiment, sentiment_score, average_score, total_score,
                         positive_count, neutral_count, negative_count, created_at)
SELECT p.id, 'A01700001', 'En general, buen desempeño docente en CS101.', 'positive', 0.90, 4.6, 23, 5, 0, 1, NOW()
FROM professors p WHERE p.email = 'alberto.garcia@uaem.mx';

-- ---------- 11) SUBJECT RATINGS ----------
INSERT INTO subject_ratings (professor_id, subject_id, average_score, total_evaluations,
                             score_5_count, score_4_count, score_3_count, score_2_count, score_1_count,
                             positive_percentage, neutral_percentage, negative_percentage, last_updated)
SELECT p.id, s.id, 4.6, 6, 4, 2, 0, 0, 0, 85.0, 10.0, 5.0, NOW()
FROM professors p, subjects s
WHERE p.email = 'alberto.garcia@uaem.mx' AND s.code = 'CS101';

INSERT INTO subject_ratings (professor_id, subject_id, average_score, total_evaluations,
                             score_5_count, score_4_count, score_3_count, score_2_count, score_1_count,
                             positive_percentage, neutral_percentage, negative_percentage, last_updated)
SELECT p.id, s.id, 4.3, 4, 2, 2, 0, 0, 0, 75.0, 20.0, 5.0, NOW()
FROM professors p, subjects s
WHERE p.email = 'maria.lopez@uaem.mx' AND s.code = 'MA150';

-- ---------- 12) ACTIVITY LOGS ----------
INSERT INTO activity_logs (user_id, user_type, action_type, description, target_id, target_type, ip_address, user_agent, created_at)
SELECT u.id, 'admin', 'create', 'Created professor Alberto Garcia', p.id, 'professor', '127.0.0.1', 'seed-script/1.0', NOW() - INTERVAL '30 days'
FROM users u, professors p
WHERE u.email = 'admin@uaem.mx' AND p.email = 'alberto.garcia@uaem.mx';

INSERT INTO activity_logs (user_id, user_type, action_type, description, target_id, target_type, ip_address, user_agent, created_at)
SELECT u.id, 'admin', 'create', 'Created professor Maria Lopez', p.id, 'professor', '127.0.0.1', 'seed-script/1.0', NOW() - INTERVAL '30 days'
FROM users u, professors p
WHERE u.email = 'admin@uaem.mx' AND p.email = 'maria.lopez@uaem.mx';

INSERT INTO activity_logs (user_id, user_type, action_type, description, target_id, target_type, ip_address, user_agent, created_at)
SELECT u.id, 'admin', 'create', 'Created subject CS101', s.id, 'subject', '127.0.0.1', 'seed-script/1.0', NOW() - INTERVAL '25 days'
FROM users u, subjects s
WHERE u.email = 'admin@uaem.mx' AND s.code = 'CS101';

INSERT INTO activity_logs (user_id, user_type, action_type, description, target_id, target_type, ip_address, user_agent, created_at)
SELECT u.id, 'admin', 'create', 'Created subject CS201', s.id, 'subject', '127.0.0.1', 'seed-script/1.0', NOW() - INTERVAL '25 days'
FROM users u, subjects s
WHERE u.email = 'admin@uaem.mx' AND s.code = 'CS201';

INSERT INTO activity_logs (user_id, user_type, action_type, description, target_id, target_type, ip_address, user_agent, created_at)
SELECT u.id, 'admin', 'create', 'Created subject MA150', s.id, 'subject', '127.0.0.1', 'seed-script/1.0', NOW() - INTERVAL '25 days'
FROM users u, subjects s
WHERE u.email = 'admin@uaem.mx' AND s.code = 'MA150';

INSERT INTO activity_logs (user_id, user_type, action_type, description, target_id, target_type, ip_address, user_agent, created_at)
SELECT u.id, 'student', 'complete_survey', 'Completed survey for CS101', s.id, 'subject', '127.0.0.1', 'seed-script/1.0', NOW() - INTERVAL '10 days'
FROM users u, subjects s
WHERE u.matricula = 'A01700001' AND s.code = 'CS101';

INSERT INTO activity_logs (user_id, user_type, action_type, description, target_id, target_type, ip_address, user_agent, created_at)
SELECT u.id, 'student', 'complete_survey', 'Completed survey for CS201', s.id, 'subject', '127.0.0.1', 'seed-script/1.0', NOW() - INTERVAL '8 days'
FROM users u, subjects s
WHERE u.matricula = 'A01700002' AND s.code = 'CS201';

INSERT INTO activity_logs (user_id, user_type, action_type, description, target_id, target_type, ip_address, user_agent, created_at)
SELECT u.id, 'student', 'complete_survey', 'Completed survey for CS101', s.id, 'subject', '127.0.0.1', 'seed-script/1.0', NOW() - INTERVAL '7 days'
FROM users u, subjects s
WHERE u.matricula = 'A01700003' AND s.code = 'CS101';

INSERT INTO activity_logs (user_id, user_type, action_type, description, target_id, target_type, ip_address, user_agent, created_at)
SELECT u.id, 'student', 'complete_survey', 'Completed survey for MA150', s.id, 'subject', '127.0.0.1', 'seed-script/1.0', NOW() - INTERVAL '5 days'
FROM users u, subjects s
WHERE u.matricula = 'A01700004' AND s.code = 'MA150';

INSERT INTO activity_logs (user_id, user_type, action_type, description, target_id, target_type, ip_address, user_agent, created_at)
SELECT u.id, 'student', 'complete_survey', 'Completed survey for CS101', s.id, 'subject', '127.0.0.1', 'seed-script/1.0', NOW() - INTERVAL '3 days'
FROM users u, subjects s
WHERE u.matricula = 'A01700005' AND s.code = 'CS101';

INSERT INTO activity_logs (user_id, user_type, action_type, description, target_id, target_type, ip_address, user_agent, created_at)
SELECT u.id, 'admin', 'login', 'Admin logged in to the system', NULL, NULL, '127.0.0.1', 'Mozilla/5.0', NOW() - INTERVAL '2 hours'
FROM users u
WHERE u.email = 'admin@uaem.mx';

INSERT INTO activity_logs (user_id, user_type, action_type, description, target_id, target_type, ip_address, user_agent, created_at)
SELECT u.id, 'professor', 'login', 'Professor logged in to the system', NULL, NULL, '127.0.0.1', 'Mozilla/5.0', NOW() - INTERVAL '6 hours'
FROM users u
WHERE u.email = 'alberto.garcia@uaem.mx';

INSERT INTO activity_logs (user_id, user_type, action_type, description, target_id, target_type, ip_address, user_agent, created_at)
SELECT u.id, 'professor', 'login', 'Professor logged in to the system', NULL, NULL, '127.0.0.1', 'Mozilla/5.0', NOW() - INTERVAL '12 hours'
FROM users u
WHERE u.email = 'maria.lopez@uaem.mx';

INSERT INTO activity_logs (user_id, user_type, action_type, description, target_id, target_type, ip_address, user_agent, created_at)
SELECT u.id, 'student', 'login', 'Student logged in to the system', NULL, NULL, '127.0.0.1', 'Mozilla/5.0', NOW() - INTERVAL '1 hour'
FROM users u
WHERE u.matricula = 'A01700001';

INSERT INTO activity_logs (user_id, user_type, action_type, description, target_id, target_type, ip_address, user_agent, created_at)
SELECT u.id, 'student', 'login', 'Student logged in to the system', NULL, NULL, '127.0.0.1', 'Mozilla/5.0', NOW() - INTERVAL '3 hours'
FROM users u
WHERE u.matricula = 'A01700002';

COMMIT;

-- ============================================
-- VERIFICATION QUERIES (optional - uncomment to run)
-- ============================================
-- SELECT 'USERS' as table_name, COUNT(*) as count FROM users
-- UNION ALL SELECT 'ADMINS', COUNT(*) FROM admins
-- UNION ALL SELECT 'PROFESSORS', COUNT(*) FROM professors
-- UNION ALL SELECT 'STUDENTS', COUNT(*) FROM students
-- UNION ALL SELECT 'SUBJECTS', COUNT(*) FROM subjects
-- UNION ALL SELECT 'GROUP_CLASSES', COUNT(*) FROM group_classes
-- UNION ALL SELECT 'STUDENT_SUBJECTS', COUNT(*) FROM student_subjects
-- UNION ALL SELECT 'SURVEYS', COUNT(*) FROM surveys
-- UNION ALL SELECT 'COMMENTS', COUNT(*) FROM comments
-- UNION ALL SELECT 'EVALUATIONS', COUNT(*) FROM evaluations
-- UNION ALL SELECT 'SUBJECT_RATINGS', COUNT(*) FROM subject_ratings
-- UNION ALL SELECT 'ACTIVITY_LOGS', COUNT(*) FROM activity_logs;
-- ============================================

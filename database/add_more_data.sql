-- ========================================
-- ADD MORE TEST DATA
-- 5 new students, 5 new surveys, and activity logs
-- ========================================

BEGIN;

-- ========================================
-- ADD 5 NEW STUDENTS
-- ========================================

-- Student 1: Juan García
INSERT INTO users (email, password_hash, first_name, last_name, role, is_active, created_at, last_login)
VALUES (
    'juan.garcia@estudiante.uaem.mx',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYfYGEujnea', -- Password: Student123!
    'Juan',
    'García',
    'student',
    true,
    NOW() - INTERVAL '30 days',
    NOW() - INTERVAL '2 days'
);

INSERT INTO students (user_id, matricula, semester, career, group_name)
VALUES (
    (SELECT id FROM users WHERE email = 'juan.garcia@estudiante.uaem.mx'),
    '2021030101',
    6,
    'Ingeniería en Computación',
    '601-A'
);

-- Student 2: María López
INSERT INTO users (email, password_hash, first_name, last_name, role, is_active, created_at, last_login)
VALUES (
    'maria.lopez@estudiante.uaem.mx',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYfYGEujnea',
    'María',
    'López',
    'student',
    true,
    NOW() - INTERVAL '25 days',
    NOW() - INTERVAL '1 day'
);

INSERT INTO students (user_id, matricula, semester, career, group_name)
VALUES (
    (SELECT id FROM users WHERE email = 'maria.lopez@estudiante.uaem.mx'),
    '2021030102',
    6,
    'Ingeniería en Computación',
    '601-A'
);

-- Student 3: Carlos Hernández
INSERT INTO users (email, password_hash, first_name, last_name, role, is_active, created_at, last_login)
VALUES (
    'carlos.hernandez@estudiante.uaem.mx',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYfYGEujnea',
    'Carlos',
    'Hernández',
    'student',
    true,
    NOW() - INTERVAL '20 days',
    NOW() - INTERVAL '3 hours'
);

INSERT INTO students (user_id, matricula, semester, career, group_name)
VALUES (
    (SELECT id FROM users WHERE email = 'carlos.hernandez@estudiante.uaem.mx'),
    '2021030103',
    6,
    'Ingeniería en Computación',
    '601-A'
);

-- Student 4: Ana Martínez
INSERT INTO users (email, password_hash, first_name, last_name, role, is_active, created_at, last_login)
VALUES (
    'ana.martinez@estudiante.uaem.mx',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYfYGEujnea',
    'Ana',
    'Martínez',
    'student',
    true,
    NOW() - INTERVAL '15 days',
    NOW() - INTERVAL '5 hours'
);

INSERT INTO students (user_id, matricula, semester, career, group_name)
VALUES (
    (SELECT id FROM users WHERE email = 'ana.martinez@estudiante.uaem.mx'),
    '2021030104',
    6,
    'Ingeniería en Computación',
    '601-A'
);

-- Student 5: Luis Ramírez
INSERT INTO users (email, password_hash, first_name, last_name, role, is_active, created_at, last_login)
VALUES (
    'luis.ramirez@estudiante.uaem.mx',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYfYGEujnea',
    'Luis',
    'Ramírez',
    'student',
    true,
    NOW() - INTERVAL '10 days',
    NOW() - INTERVAL '1 hour'
);

INSERT INTO students (user_id, matricula, semester, career, group_name)
VALUES (
    (SELECT id FROM users WHERE email = 'luis.ramirez@estudiante.uaem.mx'),
    '2021030105',
    6,
    'Ingeniería en Computación',
    '601-A'
);

-- ========================================
-- ADD 5 SURVEYS WITH RATINGS AND COMMENTS
-- ========================================

-- Get professor IDs for reference
DO $$
DECLARE
    prof1_id INTEGER;
    prof2_id INTEGER;
    student1_id INTEGER;
    student2_id INTEGER;
    student3_id INTEGER;
    student4_id INTEGER;
    student5_id INTEGER;
    subject1_id INTEGER;
BEGIN
    -- Get professor IDs
    SELECT id INTO prof1_id FROM professors WHERE user_id = (SELECT id FROM users WHERE email = 'juan.perez@profesor.uaem.mx') LIMIT 1;
    SELECT id INTO prof2_id FROM professors WHERE user_id = (SELECT id FROM users WHERE email = 'maria.gonzalez@profesor.uaem.mx') LIMIT 1;
    
    -- Get subject ID
    SELECT id INTO subject1_id FROM subjects WHERE name = 'Arquitectura de Software' LIMIT 1;
    
    -- Get new student IDs
    SELECT id INTO student1_id FROM students WHERE matricula = '2021030101';
    SELECT id INTO student2_id FROM students WHERE matricula = '2021030102';
    SELECT id INTO student3_id FROM students WHERE matricula = '2021030103';
    SELECT id INTO student4_id FROM students WHERE matricula = '2021030104';
    SELECT id INTO student5_id FROM students WHERE matricula = '2021030105';
    
    -- Survey 1: Juan García evaluating Prof. Juan Pérez (POSITIVE)
    INSERT INTO surveys (student_id, professor_id, subject_id, completed, created_at, updated_at)
    VALUES (student1_id, prof1_id, subject1_id, true, NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days');
    
    INSERT INTO subject_ratings (survey_id, question_id, rating)
    VALUES 
        (currval('surveys_id_seq'), 1, 5),  -- Dominio de la materia
        (currval('surveys_id_seq'), 2, 5),  -- Claridad al explicar
        (currval('surveys_id_seq'), 3, 4),  -- Puntualidad
        (currval('surveys_id_seq'), 4, 5),  -- Disponibilidad
        (currval('surveys_id_seq'), 5, 5);  -- Material didáctico
    
    INSERT INTO comments (survey_id, comment_text, sentiment, created_at)
    VALUES (
        currval('surveys_id_seq'),
        'Excelente profesor, explica muy bien los conceptos de arquitectura. Sus clases son muy dinámicas y prácticas.',
        'positive',
        NOW() - INTERVAL '5 days'
    );
    
    -- Survey 2: María López evaluating Prof. Juan Pérez (POSITIVE)
    INSERT INTO surveys (student_id, professor_id, subject_id, completed, created_at, updated_at)
    VALUES (student2_id, prof1_id, subject1_id, true, NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days');
    
    INSERT INTO subject_ratings (survey_id, question_id, rating)
    VALUES 
        (currval('surveys_id_seq'), 1, 5),
        (currval('surveys_id_seq'), 2, 4),
        (currval('surveys_id_seq'), 3, 5),
        (currval('surveys_id_seq'), 4, 4),
        (currval('surveys_id_seq'), 5, 5);
    
    INSERT INTO comments (survey_id, comment_text, sentiment, created_at)
    VALUES (
        currval('surveys_id_seq'),
        'Me gusta mucho la forma en que enseña. Siempre responde dudas y hace las clases interesantes.',
        'positive',
        NOW() - INTERVAL '4 days'
    );
    
    -- Survey 3: Carlos Hernández evaluating Prof. María González (NEUTRAL)
    INSERT INTO surveys (student_id, professor_id, subject_id, completed, created_at, updated_at)
    VALUES (student3_id, prof2_id, subject1_id, true, NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days');
    
    INSERT INTO subject_ratings (survey_id, question_id, rating)
    VALUES 
        (currval('surveys_id_seq'), 1, 4),
        (currval('surveys_id_seq'), 2, 3),
        (currval('surveys_id_seq'), 3, 3),
        (currval('surveys_id_seq'), 4, 4),
        (currval('surveys_id_seq'), 5, 3);
    
    INSERT INTO comments (survey_id, comment_text, sentiment, created_at)
    VALUES (
        currval('surveys_id_seq'),
        'La profesora conoce bien la materia, aunque a veces las explicaciones son un poco rápidas.',
        'neutral',
        NOW() - INTERVAL '3 days'
    );
    
    -- Survey 4: Ana Martínez evaluating Prof. Juan Pérez (POSITIVE)
    INSERT INTO surveys (student_id, professor_id, subject_id, completed, created_at, updated_at)
    VALUES (student4_id, prof1_id, subject1_id, true, NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days');
    
    INSERT INTO subject_ratings (survey_id, question_id, rating)
    VALUES 
        (currval('surveys_id_seq'), 1, 5),
        (currval('surveys_id_seq'), 2, 5),
        (currval('surveys_id_seq'), 3, 4),
        (currval('surveys_id_seq'), 4, 5),
        (currval('surveys_id_seq'), 5, 4);
    
    INSERT INTO comments (survey_id, comment_text, sentiment, created_at)
    VALUES (
        currval('surveys_id_seq'),
        'Uno de los mejores profesores que he tenido. Se nota su experiencia y pasión por enseñar.',
        'positive',
        NOW() - INTERVAL '2 days'
    );
    
    -- Survey 5: Luis Ramírez evaluating Prof. María González (NEGATIVE)
    INSERT INTO surveys (student_id, professor_id, subject_id, completed, created_at, updated_at)
    VALUES (student5_id, prof2_id, subject1_id, true, NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day');
    
    INSERT INTO subject_ratings (survey_id, question_id, rating)
    VALUES 
        (currval('surveys_id_seq'), 1, 3),
        (currval('surveys_id_seq'), 2, 2),
        (currval('surveys_id_seq'), 3, 2),
        (currval('surveys_id_seq'), 4, 3),
        (currval('surveys_id_seq'), 5, 2);
    
    INSERT INTO comments (survey_id, comment_text, sentiment, created_at)
    VALUES (
        currval('surveys_id_seq'),
        'Las clases podrían mejorar. A veces no se entiende bien y falta más interacción con los estudiantes.',
        'negative',
        NOW() - INTERVAL '1 day'
    );
END $$;

-- ========================================
-- ADD ACTIVITY LOG ENTRIES
-- ========================================

-- Student logins
INSERT INTO activity_logs (user_id, action_type, description, created_at)
SELECT 
    id,
    'login',
    'Estudiante ' || first_name || ' ' || last_name || ' inició sesión',
    last_login
FROM users
WHERE email IN (
    'juan.garcia@estudiante.uaem.mx',
    'maria.lopez@estudiante.uaem.mx',
    'carlos.hernandez@estudiante.uaem.mx',
    'ana.martinez@estudiante.uaem.mx',
    'luis.ramirez@estudiante.uaem.mx'
);

-- Survey completion activities
INSERT INTO activity_logs (user_id, action_type, description, created_at)
VALUES
    (
        (SELECT user_id FROM students WHERE matricula = '2021030101'),
        'survey_completed',
        'Encuesta completada para Arquitectura de Software',
        NOW() - INTERVAL '5 days'
    ),
    (
        (SELECT user_id FROM students WHERE matricula = '2021030102'),
        'survey_completed',
        'Encuesta completada para Arquitectura de Software',
        NOW() - INTERVAL '4 days'
    ),
    (
        (SELECT user_id FROM students WHERE matricula = '2021030103'),
        'survey_completed',
        'Encuesta completada para Arquitectura de Software',
        NOW() - INTERVAL '3 days'
    ),
    (
        (SELECT user_id FROM students WHERE matricula = '2021030104'),
        'survey_completed',
        'Encuesta completada para Arquitectura de Software',
        NOW() - INTERVAL '2 days'
    ),
    (
        (SELECT user_id FROM students WHERE matricula = '2021030105'),
        'survey_completed',
        'Encuesta completada para Arquitectura de Software',
        NOW() - INTERVAL '1 day'
    );

-- Admin activity logs
INSERT INTO activity_logs (user_id, action_type, description, created_at)
VALUES
    (
        (SELECT id FROM users WHERE email = 'admin@uaem.mx'),
        'user_created',
        'Usuario Juan García creado',
        NOW() - INTERVAL '30 days'
    ),
    (
        (SELECT id FROM users WHERE email = 'admin@uaem.mx'),
        'user_created',
        'Usuario María López creado',
        NOW() - INTERVAL '25 days'
    ),
    (
        (SELECT id FROM users WHERE email = 'admin@uaem.mx'),
        'user_created',
        'Usuario Carlos Hernández creado',
        NOW() - INTERVAL '20 days'
    ),
    (
        (SELECT id FROM users WHERE email = 'admin@uaem.mx'),
        'user_created',
        'Usuario Ana Martínez creado',
        NOW() - INTERVAL '15 days'
    ),
    (
        (SELECT id FROM users WHERE email = 'admin@uaem.mx'),
        'user_created',
        'Usuario Luis Ramírez creado',
        NOW() - INTERVAL '10 days'
    ),
    (
        (SELECT id FROM users WHERE email = 'admin@uaem.mx'),
        'login',
        'Administrador inició sesión',
        NOW() - INTERVAL '1 hour'
    );

-- Professor activity logs
INSERT INTO activity_logs (user_id, action_type, description, created_at)
VALUES
    (
        (SELECT id FROM users WHERE email = 'juan.perez@profesor.uaem.mx'),
        'login',
        'Profesor Juan Pérez inició sesión',
        NOW() - INTERVAL '6 hours'
    ),
    (
        (SELECT id FROM users WHERE email = 'maria.gonzalez@profesor.uaem.mx'),
        'login',
        'Profesor María González inició sesión',
        NOW() - INTERVAL '12 hours'
    );

COMMIT;

-- ========================================
-- VERIFY THE NEW DATA
-- ========================================

-- Check total users
SELECT 'Total Users:' as info, COUNT(*) as count FROM users;

-- Check total students
SELECT 'Total Students:' as info, COUNT(*) as count FROM students;

-- Check total surveys
SELECT 'Total Surveys:' as info, COUNT(*) as count FROM surveys WHERE completed = true;

-- Check total comments
SELECT 'Total Comments:' as info, COUNT(*) as count FROM comments;

-- Check activity logs
SELECT 'Total Activity Logs:' as info, COUNT(*) as count FROM activity_logs;

-- Check comments by sentiment
SELECT sentiment, COUNT(*) as count 
FROM comments 
GROUP BY sentiment 
ORDER BY sentiment;

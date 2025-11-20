-- ============================================
-- TEACHER OPINION ANALYSIS SYSTEM - DATABASE SCHEMA
-- Updated to match Python SQLAlchemy models with unified users table
-- ============================================
-- Drop existing tables in correct order (respecting foreign keys)
DROP TABLE IF EXISTS activity_logs CASCADE;
DROP TABLE IF EXISTS subject_ratings CASCADE;
DROP TABLE IF EXISTS evaluations CASCADE;
DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS surveys CASCADE;
DROP TABLE IF EXISTS student_subjects CASCADE;
DROP TABLE IF EXISTS group_classes CASCADE;
DROP TABLE IF EXISTS subjects CASCADE;
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS professors CASCADE;
DROP TABLE IF EXISTS admins CASCADE;
DROP TABLE IF EXISTS users CASCADE;
-- ============================================
-- 1. USERS TABLE (Unified authentication for all user types)
-- ============================================
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(120) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('admin', 'professor', 'student')),
    matricula VARCHAR(20) UNIQUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_matricula ON users(matricula);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_is_active ON users(is_active);
CREATE UNIQUE INDEX idx_users_email_not_null ON users(email) WHERE email IS NOT NULL;
CREATE UNIQUE INDEX idx_users_matricula_not_null ON users(matricula) WHERE matricula IS NOT NULL;
-- ============================================
-- 2. ADMINS TABLE (Admin-specific data)
-- ============================================
CREATE TABLE admins (
    id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    department VARCHAR(100),
    permissions JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_admins_user_id ON admins(user_id);
-- ============================================
-- 3. PROFESSORS TABLE (Professor-specific data)
-- ============================================
CREATE TABLE professors (
    id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    email VARCHAR(120) UNIQUE NOT NULL,
    department VARCHAR(100),
    office VARCHAR(50),
    phone VARCHAR(20),
    specialization VARCHAR(200),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'on_leave', 'retired')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_professors_user_id ON professors(user_id);
CREATE INDEX idx_professors_email ON professors(email);
CREATE INDEX idx_professors_status ON professors(status);
-- ============================================
-- 4. STUDENTS TABLE (Student-specific data)
-- ============================================
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    matricula VARCHAR(20) UNIQUE NOT NULL,
    semester INTEGER,
    career VARCHAR(100),
    "group" VARCHAR(20),
    has_completed_survey BOOLEAN DEFAULT FALSE,
    survey_completed_at TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended', 'graduated')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_students_user_id ON students(user_id);
CREATE INDEX idx_students_matricula ON students(matricula);
CREATE INDEX idx_students_status ON students(status);
-- ============================================
-- 5. SUBJECTS TABLE (Courses/Classes)
-- ============================================
CREATE TABLE subjects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    professor_id INTEGER REFERENCES professors(id) ON DELETE SET NULL,
    semester INTEGER,
    credits INTEGER,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_subjects_code ON subjects(code);
CREATE INDEX idx_subjects_professor_id ON subjects(professor_id);
CREATE INDEX idx_subjects_is_active ON subjects(is_active);
-- ============================================
-- 6. GROUP_CLASSES TABLE (Class groups/sections)
-- ============================================
CREATE TABLE group_classes (
    id SERIAL PRIMARY KEY,
    subject_id INTEGER NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    professor_id INTEGER NOT NULL REFERENCES professors(id) ON DELETE CASCADE,
    group_name VARCHAR(20) NOT NULL,
    semester_period VARCHAR(20) NOT NULL,
    schedule VARCHAR(200),
    classroom VARCHAR(50),
    max_students INTEGER DEFAULT 30,
    current_students INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_subject_group_period UNIQUE(subject_id, group_name, semester_period)
);
CREATE INDEX idx_group_classes_subject ON group_classes(subject_id);
CREATE INDEX idx_group_classes_professor ON group_classes(professor_id);
CREATE INDEX idx_group_classes_period ON group_classes(semester_period);
CREATE INDEX idx_group_classes_active ON group_classes(is_active);
-- ============================================
-- 7. STUDENT_SUBJECTS TABLE (Student enrollment)
-- ============================================
CREATE TABLE student_subjects (
    student_id INTEGER NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    subject_id INTEGER NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (student_id, subject_id)
);
CREATE INDEX idx_student_subjects_student ON student_subjects(student_id);
CREATE INDEX idx_student_subjects_subject ON student_subjects(subject_id);
-- ============================================
-- 8. SURVEYS TABLE (Student evaluations)
-- ============================================
CREATE TABLE surveys (
    id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    professor_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject_id INTEGER NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'cancelled')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    CONSTRAINT unique_student_professor_subject UNIQUE (student_id, professor_id, subject_id)
);
CREATE INDEX idx_surveys_student_id ON surveys(student_id);
CREATE INDEX idx_surveys_professor_id ON surveys(professor_id);
CREATE INDEX idx_surveys_subject_id ON surveys(subject_id);
CREATE INDEX idx_surveys_status ON surveys(status);
-- ============================================
-- 9. COMMENTS TABLE (Survey comments with sentiment)
-- ============================================
CREATE TABLE comments (
    id SERIAL PRIMARY KEY,
    survey_id INTEGER NOT NULL REFERENCES surveys(id) ON DELETE CASCADE,
    text TEXT NOT NULL,
    sentiment VARCHAR(20) CHECK (sentiment IN ('positive', 'negative', 'neutral')),
    confidence_score FLOAT CHECK (confidence_score >= 0 AND confidence_score <= 1),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_comments_survey_id ON comments(survey_id);
CREATE INDEX idx_comments_sentiment ON comments(sentiment);
-- ============================================
-- 10. EVALUATIONS TABLE (Professor evaluations)
-- ============================================
CREATE TABLE evaluations (
    id SERIAL PRIMARY KEY,
    professor_id INTEGER NOT NULL REFERENCES professors(id) ON DELETE CASCADE,
    student_id VARCHAR(100),
    comment TEXT NOT NULL,
    sentiment VARCHAR(20) CHECK (sentiment IN ('positive', 'negative', 'neutral')),
    sentiment_score FLOAT,
    average_score FLOAT,
    total_score INTEGER,
    positive_count INTEGER DEFAULT 0,
    neutral_count INTEGER DEFAULT 0,
    negative_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_evaluations_professor_id ON evaluations(professor_id);
CREATE INDEX idx_evaluations_sentiment ON evaluations(sentiment);
-- ============================================
-- 11. SUBJECT_RATINGS TABLE (Professor ratings per subject with sentiment)
-- ============================================
CREATE TABLE subject_ratings (
    id SERIAL PRIMARY KEY,
    professor_id INTEGER NOT NULL REFERENCES professors(id) ON DELETE CASCADE,
    subject_id INTEGER NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    average_score FLOAT,
    total_evaluations INTEGER DEFAULT 0,
    score_5_count INTEGER DEFAULT 0,
    score_4_count INTEGER DEFAULT 0,
    score_3_count INTEGER DEFAULT 0,
    score_2_count INTEGER DEFAULT 0,
    score_1_count INTEGER DEFAULT 0,
    positive_percentage FLOAT DEFAULT 0.0,
    neutral_percentage FLOAT DEFAULT 0.0,
    negative_percentage FLOAT DEFAULT 0.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_professor_subject_rating UNIQUE (professor_id, subject_id)
);
CREATE INDEX idx_subject_ratings_professor ON subject_ratings(professor_id);
CREATE INDEX idx_subject_ratings_subject ON subject_ratings(subject_id);
CREATE INDEX idx_subject_ratings_average ON subject_ratings(average_score);
-- ============================================
-- 12. ACTIVITY_LOGS TABLE (Audit trail)
-- ============================================
CREATE TABLE activity_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('admin', 'professor', 'student')),
    action_type VARCHAR(50) NOT NULL,
    description VARCHAR(255) NOT NULL,
    target_id INTEGER,
    target_type VARCHAR(50),
    ip_address VARCHAR(45),
    user_agent VARCHAR(255),
    extra_data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_activity_logs_user_id ON activity_logs(user_id);
CREATE INDEX idx_activity_logs_user_type ON activity_logs(user_type);
CREATE INDEX idx_activity_logs_action_type ON activity_logs(action_type);
CREATE INDEX idx_activity_logs_created_at ON activity_logs(created_at);
-- ============================================
-- TRIGGERS AND FUNCTIONS
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_admins_updated_at BEFORE UPDATE ON admins FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_professors_updated_at BEFORE UPDATE ON professors FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_students_updated_at BEFORE UPDATE ON students FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_subjects_updated_at BEFORE UPDATE ON subjects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_group_classes_updated_at BEFORE UPDATE ON group_classes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
-- ============================================
-- VIEWS FOR REPORTING
-- ============================================
CREATE OR REPLACE VIEW professor_statistics AS
SELECT 
    p.id AS professor_id,
    u.first_name || ' ' || u.last_name AS professor_name,
    p.email,
    p.department,
    p.status,
    COUNT(DISTINCT s.id) AS total_subjects,
    COUNT(DISTINCT sr.id) AS subjects_with_ratings,
    ROUND(AVG(sr.average_score)::numeric, 2) AS overall_average_score,
    SUM(sr.total_evaluations) AS total_evaluations,
    ROUND(AVG(sr.positive_percentage)::numeric, 2) AS avg_positive_percentage,
    ROUND(AVG(sr.neutral_percentage)::numeric, 2) AS avg_neutral_percentage,
    ROUND(AVG(sr.negative_percentage)::numeric, 2) AS avg_negative_percentage
FROM professors p
INNER JOIN users u ON u.id = p.user_id
LEFT JOIN subjects s ON s.professor_id = p.id
LEFT JOIN subject_ratings sr ON sr.professor_id = p.id
WHERE p.status = 'active'
GROUP BY p.id, u.first_name, u.last_name, p.email, p.department, p.status;
CREATE OR REPLACE VIEW subject_statistics AS
SELECT 
    s.id AS subject_id,
    s.code,
    s.name,
    s.semester,
    s.credits,
    p.id AS professor_id,
    u.first_name || ' ' || u.last_name AS professor_name,
    sr.average_score,
    sr.total_evaluations,
    sr.positive_percentage,
    sr.neutral_percentage,
    sr.negative_percentage,
    COUNT(DISTINCT ss.student_id) AS enrolled_students
FROM subjects s
LEFT JOIN professors p ON p.id = s.professor_id
LEFT JOIN users u ON u.id = p.user_id
LEFT JOIN subject_ratings sr ON sr.subject_id = s.id AND sr.professor_id = p.id
LEFT JOIN student_subjects ss ON ss.subject_id = s.id
WHERE s.is_active = TRUE
GROUP BY s.id, s.code, s.name, s.semester, s.credits, p.id, u.first_name, u.last_name,
         sr.average_score, sr.total_evaluations, sr.positive_percentage, 
         sr.neutral_percentage, sr.negative_percentage;
CREATE OR REPLACE VIEW student_survey_progress AS
SELECT 
    st.id AS student_id,
    st.matricula,
    u.first_name || ' ' || u.last_name AS student_name,
    st.semester,
    st.career,
    COUNT(DISTINCT ss.subject_id) AS total_enrolled_subjects,
    COUNT(DISTINCT CASE WHEN sv.status = 'completed' THEN sv.id END) AS completed_surveys,
    COUNT(DISTINCT CASE WHEN sv.status = 'pending' THEN sv.id END) AS pending_surveys,
    st.has_completed_survey,
    st.survey_completed_at
FROM students st
INNER JOIN users u ON u.id = st.user_id
LEFT JOIN student_subjects ss ON ss.student_id = st.id
LEFT JOIN surveys sv ON sv.student_id = u.id
WHERE st.status = 'active'
GROUP BY st.id, st.matricula, u.first_name, u.last_name, st.semester, st.career,
         st.has_completed_survey, st.survey_completed_at;
-- ============================================
-- TABLE COMMENTS
-- ============================================
COMMENT ON TABLE users IS 'Unified authentication table for all user types (admin, professor, student)';
COMMENT ON TABLE admins IS 'Admin-specific data linked to users table';
COMMENT ON TABLE professors IS 'Professor-specific data linked to users table';
COMMENT ON TABLE students IS 'Student-specific data linked to users table';
COMMENT ON TABLE subjects IS 'Academic subjects/courses catalog';
COMMENT ON TABLE group_classes IS 'Class groups/sections with schedule and enrollment limits';
COMMENT ON TABLE student_subjects IS 'Student enrollment in subjects (many-to-many)';
COMMENT ON TABLE surveys IS 'Student surveys/evaluations of professors';
COMMENT ON TABLE comments IS 'Survey comments with sentiment analysis';
COMMENT ON TABLE evaluations IS 'Professor evaluations with sentiment metrics';
COMMENT ON TABLE subject_ratings IS 'Aggregated professor ratings per subject with sentiment analysis';
COMMENT ON TABLE activity_logs IS 'System activity audit log';

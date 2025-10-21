-- ============================================
-- SISTEMA DE ANÁLISIS DE OPINIÓN DOCENTE
-- Esquema actualizado con encuesta real
-- ============================================

-- Limpiar base de datos (solo para desarrollo)
DROP TABLE IF EXISTS audit_log CASCADE;
DROP TABLE IF EXISTS password_reset_tokens CASCADE;
DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS survey_responses CASCADE;
DROP TABLE IF EXISTS surveys CASCADE;
DROP TABLE IF EXISTS questions CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS teacher_subjects CASCADE;
DROP TABLE IF EXISTS subjects CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ============================================
-- 1. TABLA DE USUARIOS
-- ============================================
-- Roles: student, teacher, coordinator

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    
    -- Tipo de usuario
    role VARCHAR(20) NOT NULL CHECK (role IN ('student', 'teacher', 'coordinator')),
    name VARCHAR(100) NOT NULL,
    
    -- Credenciales (dependiendo del rol)
    email VARCHAR(100) UNIQUE,          -- Para profesores y coordinadores
    matricula VARCHAR(20) UNIQUE,       -- Para estudiantes
    password_hash VARCHAR(255) NOT NULL,
    
    -- Información adicional (estudiantes)
    career VARCHAR(100),                -- Carrera del estudiante
    semester INTEGER,                   -- Semestre actual (1-10)
    
    -- Control de cuenta
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Validación: estudiantes usan matrícula, otros usan email
    CONSTRAINT check_credentials CHECK (
        (role = 'student' AND matricula IS NOT NULL) OR
        (role IN ('teacher', 'coordinator') AND email IS NOT NULL)
    )
);

-- Índices para búsquedas rápidas
CREATE INDEX idx_users_email ON users(email) WHERE email IS NOT NULL;
CREATE INDEX idx_users_matricula ON users(matricula) WHERE matricula IS NOT NULL;
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_active ON users(is_active);

-- ============================================
-- 2. TABLA DE MATERIAS
-- ============================================

CREATE TABLE subjects (
    id SERIAL PRIMARY KEY,
    
    -- Información básica
    code VARCHAR(20) UNIQUE NOT NULL,   -- Ej: "IS501"
    name VARCHAR(150) NOT NULL,         -- Ej: "Ingeniería de Software"
    career VARCHAR(100) NOT NULL,       -- Ej: "Ingeniería en Computación"
    semester INTEGER NOT NULL CHECK (semester BETWEEN 1 AND 10),
    credits INTEGER DEFAULT 4 CHECK (credits > 0),
    
    -- Descripción (opcional)
    description TEXT,
    
    -- Control
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_subjects_code ON subjects(code);
CREATE INDEX idx_subjects_career ON subjects(career);
CREATE INDEX idx_subjects_active ON subjects(is_active);

-- ============================================
-- 3. ASIGNACIÓN PROFESOR-MATERIA-PERIODO
-- ============================================
-- Define qué profesor imparte qué materia en qué periodo

CREATE TABLE teacher_subjects (
    id SERIAL PRIMARY KEY,
    
    -- Relaciones
    teacher_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject_id INTEGER NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    
    -- Periodo académico
    semester_period VARCHAR(20) NOT NULL,  -- Formato: "2025-1", "2025-2"
    group_name VARCHAR(10) DEFAULT 'A',    -- Grupo: "A", "B", "101", etc.
    
    -- Información adicional
    schedule VARCHAR(200),                 -- Ej: "Lun-Mie 7-9am, Vie 10-12pm"
    classroom VARCHAR(50),                 -- Ej: "Lab 3", "Aula 205"
    max_students INTEGER DEFAULT 30,
    
    -- Control
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Prevenir duplicados
    CONSTRAINT unique_teacher_subject_period_group 
        UNIQUE(teacher_id, subject_id, semester_period, group_name)
);

CREATE INDEX idx_teacher_subjects_teacher ON teacher_subjects(teacher_id);
CREATE INDEX idx_teacher_subjects_subject ON teacher_subjects(subject_id);
CREATE INDEX idx_teacher_subjects_period ON teacher_subjects(semester_period);
CREATE INDEX idx_teacher_subjects_active ON teacher_subjects(is_active);

-- ============================================
-- 4. CATEGORÍAS DE LA ENCUESTA
-- ============================================
-- Las 7 dimensiones de evaluación

CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    
    -- Información de la categoría
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    display_order INTEGER NOT NULL UNIQUE,
    
    -- Control
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índice
CREATE INDEX idx_categories_order ON categories(display_order);

-- ============================================
-- 5. PREGUNTAS DE LA ENCUESTA
-- ============================================
-- Las 22 preguntas de evaluación (pregunta 23 es comentario abierto)

CREATE TABLE questions (
    id SERIAL PRIMARY KEY,
    
    -- Relación con categoría
    category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    
    -- Contenido de la pregunta
    question_number INTEGER NOT NULL UNIQUE,  -- 1-22
    text TEXT NOT NULL,
    
    -- Tipo de pregunta
    question_type VARCHAR(20) DEFAULT 'likert' CHECK (question_type IN ('likert', 'open')),
    
    -- Escala Likert (1-5)
    min_value INTEGER DEFAULT 1,
    max_value INTEGER DEFAULT 5,
    min_label VARCHAR(50) DEFAULT 'Totalmente en desacuerdo',
    max_label VARCHAR(50) DEFAULT 'Totalmente de acuerdo',
    
    -- Análisis: ¿Esta pregunta evalúa algo positivo o negativo?
    is_positive BOOLEAN DEFAULT TRUE,
    
    -- Orden de visualización
    display_order INTEGER NOT NULL,
    
    -- Control
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Validaciones
    CONSTRAINT check_likert_range CHECK (min_value < max_value),
    CONSTRAINT check_display_order CHECK (display_order > 0)
);

CREATE INDEX idx_questions_category ON questions(category_id);
CREATE INDEX idx_questions_number ON questions(question_number);
CREATE INDEX idx_questions_active ON questions(is_active);

-- ============================================
-- 6. ENCUESTAS
-- ============================================
-- Cada encuesta representa la evaluación completa de un estudiante a un profesor

CREATE TABLE surveys (
    id SERIAL PRIMARY KEY,
    
    -- Quién evalúa a quién y en qué materia
    student_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    teacher_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject_id INTEGER NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    
    -- Periodo académico
    semester_period VARCHAR(20) NOT NULL,
    
    -- Estado de la encuesta
    is_complete BOOLEAN DEFAULT FALSE,
    progress INTEGER DEFAULT 0 CHECK (progress BETWEEN 0 AND 100),
    
    -- Timestamps
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    submitted_at TIMESTAMP,
    
    -- Metadata
    ip_address VARCHAR(45),
    user_agent TEXT,
    
    -- Prevenir evaluaciones duplicadas
    CONSTRAINT unique_student_teacher_subject_period
        UNIQUE(student_id, teacher_id, subject_id, semester_period),
    
    -- Validación: submitted_at debe existir si is_complete = true
    CONSTRAINT check_submission CHECK (
        (is_complete = FALSE AND submitted_at IS NULL) OR
        (is_complete = TRUE AND submitted_at IS NOT NULL)
    )
);

CREATE INDEX idx_surveys_student ON surveys(student_id);
CREATE INDEX idx_surveys_teacher ON surveys(teacher_id);
CREATE INDEX idx_surveys_subject ON surveys(subject_id);
CREATE INDEX idx_surveys_period ON surveys(semester_period);
CREATE INDEX idx_surveys_complete ON surveys(is_complete);
CREATE INDEX idx_surveys_submitted ON surveys(submitted_at);

-- ============================================
-- 7. RESPUESTAS A PREGUNTAS (Escala Likert)
-- ============================================
-- Respuestas individuales a cada una de las 22 preguntas

CREATE TABLE survey_responses (
    id SERIAL PRIMARY KEY,
    
    -- Relaciones
    survey_id INTEGER NOT NULL REFERENCES surveys(id) ON DELETE CASCADE,
    question_id INTEGER NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    
    -- Respuesta (escala 1-5)
    response_value INTEGER NOT NULL CHECK (response_value BETWEEN 1 AND 5),
    
    -- Timestamp
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Prevenir respuestas duplicadas a la misma pregunta
    CONSTRAINT unique_survey_question
        UNIQUE(survey_id, question_id)
);

CREATE INDEX idx_responses_survey ON survey_responses(survey_id);
CREATE INDEX idx_responses_question ON survey_responses(question_id);
CREATE INDEX idx_responses_value ON survey_responses(response_value);

-- ============================================
-- 8. COMENTARIOS CUALITATIVOS
-- ============================================
-- Comentarios abiertos + análisis de sentimiento

CREATE TABLE comments (
    id SERIAL PRIMARY KEY,
    
    -- Relación con la encuesta
    survey_id INTEGER NOT NULL REFERENCES surveys(id) ON DELETE CASCADE,
    
    -- Contenido del comentario
    text TEXT NOT NULL,
    word_count INTEGER,  -- Contar palabras automáticamente
    
    -- Análisis de sentimiento (RF-4)
    sentiment VARCHAR(20) CHECK (sentiment IN ('positive', 'negative', 'neutral')),
    confidence FLOAT CHECK (confidence >= 0 AND confidence <= 1),
    processed_at TIMESTAMP,
    
    -- Revisión manual (para correcciones del coordinador)
    reviewed BOOLEAN DEFAULT FALSE,
    reviewed_by INTEGER REFERENCES users(id),
    reviewed_at TIMESTAMP,
    manual_sentiment VARCHAR(20) CHECK (manual_sentiment IN ('positive', 'negative', 'neutral')),
    review_notes TEXT,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Validaciones
    CONSTRAINT check_text_length CHECK (LENGTH(text) >= 10 AND LENGTH(text) <= 2000),
    CONSTRAINT check_review CHECK (
        (reviewed = FALSE) OR 
        (reviewed = TRUE AND reviewed_by IS NOT NULL AND reviewed_at IS NOT NULL)
    )
);

CREATE INDEX idx_comments_survey ON comments(survey_id);
CREATE INDEX idx_comments_sentiment ON comments(sentiment);
CREATE INDEX idx_comments_reviewed ON comments(reviewed);
CREATE INDEX idx_comments_created ON comments(created_at);

-- ============================================
-- 9. LOG DE AUDITORÍA (RNF-11)
-- ============================================

CREATE TABLE audit_log (
    id SERIAL PRIMARY KEY,
    
    -- Usuario que realizó la acción
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    user_email VARCHAR(100),
    user_role VARCHAR(20),
    
    -- Acción realizada
    action_type VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50),
    entity_id INTEGER,
    
    -- Detalles adicionales
    description TEXT,
    changes JSONB,  -- Para almacenar qué cambió (opcional)
    
    -- Metadata
    ip_address VARCHAR(45),
    user_agent TEXT,
    
    -- Timestamp
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_user ON audit_log(user_id);
CREATE INDEX idx_audit_action ON audit_log(action_type);
CREATE INDEX idx_audit_entity ON audit_log(entity_type, entity_id);
CREATE INDEX idx_audit_created ON audit_log(created_at);

-- ============================================
-- 10. TOKENS DE RECUPERACIÓN DE CONTRASEÑA
-- ============================================

CREATE TABLE password_reset_tokens (
    id SERIAL PRIMARY KEY,
    
    -- Usuario
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Token único (hash)
    token VARCHAR(100) UNIQUE NOT NULL,
    
    -- Expiración (30 minutos después de crear)
    expires_at TIMESTAMP NOT NULL,
    
    -- Control
    used BOOLEAN DEFAULT FALSE,
    used_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Validación
    CONSTRAINT check_token_usage CHECK (
        (used = FALSE AND used_at IS NULL) OR
        (used = TRUE AND used_at IS NOT NULL)
    )
);

CREATE INDEX idx_reset_tokens_token ON password_reset_tokens(token);
CREATE INDEX idx_reset_tokens_user ON password_reset_tokens(user_id);
CREATE INDEX idx_reset_tokens_expires ON password_reset_tokens(expires_at);

-- ============================================
-- VISTAS PARA CONSULTAS COMUNES
-- ============================================

-- Vista 1: Estadísticas por profesor
CREATE OR REPLACE VIEW teacher_statistics AS
SELECT 
    u.id AS teacher_id,
    u.name AS teacher_name,
    u.email AS teacher_email,
    COUNT(DISTINCT s.id) AS total_surveys,
    COUNT(DISTINCT s.subject_id) AS subjects_taught,
    ROUND(AVG(sr.response_value)::numeric, 2) AS overall_avg_rating,
    COUNT(c.id) AS total_comments,
    COUNT(CASE WHEN c.sentiment = 'positive' THEN 1 END) AS positive_comments,
    COUNT(CASE WHEN c.sentiment = 'negative' THEN 1 END) AS negative_comments,
    COUNT(CASE WHEN c.sentiment = 'neutral' THEN 1 END) AS neutral_comments
FROM users u
LEFT JOIN surveys s ON s.teacher_id = u.id AND s.is_complete = TRUE
LEFT JOIN survey_responses sr ON sr.survey_id = s.id
LEFT JOIN comments c ON c.survey_id = s.id
WHERE u.role = 'teacher'
GROUP BY u.id, u.name, u.email;

-- Vista 2: Estadísticas por materia
CREATE OR REPLACE VIEW subject_statistics AS
SELECT 
    sub.id AS subject_id,
    sub.code AS subject_code,
    sub.name AS subject_name,
    sub.career,
    ts.teacher_id,
    u.name AS teacher_name,
    ts.semester_period,
    COUNT(DISTINCT s.id) AS total_surveys,
    COUNT(DISTINCT s.student_id) AS total_students_responded,
    ROUND(AVG(sr.response_value)::numeric, 2) AS avg_rating,
    ROUND((COUNT(DISTINCT s.id)::float / NULLIF(ts.max_students, 0) * 100)::numeric, 1) AS participation_rate
FROM subjects sub
JOIN teacher_subjects ts ON ts.subject_id = sub.id
JOIN users u ON u.id = ts.teacher_id
LEFT JOIN surveys s ON s.subject_id = sub.id 
    AND s.teacher_id = ts.teacher_id 
    AND s.semester_period = ts.semester_period
    AND s.is_complete = TRUE
LEFT JOIN survey_responses sr ON sr.survey_id = s.id
GROUP BY sub.id, sub.code, sub.name, sub.career, ts.teacher_id, u.name, ts.semester_period, ts.max_students;

-- Vista 3: Promedio por categoría y profesor
CREATE OR REPLACE VIEW teacher_category_ratings AS
SELECT 
    u.id AS teacher_id,
    u.name AS teacher_name,
    cat.id AS category_id,
    cat.name AS category_name,
    s.semester_period,
    COUNT(DISTINCT s.id) AS total_surveys,
    ROUND(AVG(sr.response_value)::numeric, 2) AS avg_rating
FROM users u
JOIN surveys s ON s.teacher_id = u.id AND s.is_complete = TRUE
JOIN survey_responses sr ON sr.survey_id = s.id
JOIN questions q ON q.id = sr.question_id
JOIN categories cat ON cat.id = q.category_id
WHERE u.role = 'teacher'
GROUP BY u.id, u.name, cat.id, cat.name, s.semester_period;

-- ============================================
-- FUNCIONES Y TRIGGERS
-- ============================================

-- Función: Actualizar timestamp de updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para users
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Función: Calcular word_count automáticamente
CREATE OR REPLACE FUNCTION update_word_count()
RETURNS TRIGGER AS $$
BEGIN
    NEW.word_count = array_length(regexp_split_to_array(trim(NEW.text), '\s+'), 1);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para comments
CREATE TRIGGER calculate_word_count
    BEFORE INSERT OR UPDATE OF text ON comments
    FOR EACH ROW
    EXECUTE FUNCTION update_word_count();

-- Función: Actualizar progreso de encuesta
CREATE OR REPLACE FUNCTION update_survey_progress()
RETURNS TRIGGER AS $$
DECLARE
    total_questions INTEGER;
    answered_questions INTEGER;
    new_progress INTEGER;
BEGIN
    -- Contar preguntas activas
    SELECT COUNT(*) INTO total_questions FROM questions WHERE is_active = TRUE;
    
    -- Contar cuántas respondió
    SELECT COUNT(*) INTO answered_questions 
    FROM survey_responses 
    WHERE survey_id = NEW.survey_id;
    
    -- Calcular progreso
    IF total_questions > 0 THEN
        new_progress := ROUND((answered_questions::float / total_questions * 100)::numeric, 0);
        UPDATE surveys SET progress = new_progress WHERE id = NEW.survey_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar progreso
CREATE TRIGGER update_progress_on_response
    AFTER INSERT OR DELETE ON survey_responses
    FOR EACH ROW
    EXECUTE FUNCTION update_survey_progress();

-- ============================================
-- COMENTARIOS EN TABLAS
-- ============================================

COMMENT ON TABLE users IS 'Usuarios del sistema: estudiantes, profesores y coordinadores';
COMMENT ON TABLE subjects IS 'Catálogo de materias de la universidad';
COMMENT ON TABLE teacher_subjects IS 'Asignación de profesores a materias por periodo';
COMMENT ON TABLE categories IS 'Dimensiones de evaluación docente (7 categorías)';
COMMENT ON TABLE questions IS 'Preguntas de la encuesta de evaluación (22 preguntas Likert)';
COMMENT ON TABLE surveys IS 'Encuestas completadas por estudiantes';
COMMENT ON TABLE survey_responses IS 'Respuestas individuales a preguntas (escala 1-5)';
COMMENT ON TABLE comments IS 'Comentarios abiertos con análisis de sentimiento';
COMMENT ON TABLE audit_log IS 'Registro de auditoría de acciones del sistema';


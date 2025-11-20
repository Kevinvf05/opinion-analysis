-- ============================================
-- ADD MORE COMMENTS FOR PROFESSOR DASHBOARD
-- This adds more diverse comments for testing the professor dashboard
-- ============================================

BEGIN;

-- Add more comments for Alberto Garcia's subjects (CS101 and CS201)
-- These will be linked to existing surveys

-- Additional POSITIVE comments for CS101
INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT sv.id, 
       'El profesor Garcia explica muy bien los conceptos difíciles. Sus ejemplos son muy útiles.', 
       'positive', 
       0.95, 
       NOW() - INTERVAL '2 days'
FROM surveys sv
JOIN subjects s ON sv.subject_id = s.id
WHERE s.code = 'CS101' AND sv.status = 'completed'
ORDER BY sv.id LIMIT 1;

INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT sv.id, 
       'Excelente metodología de enseñanza. Siempre está dispuesto a ayudar.', 
       'positive', 
       0.97, 
       NOW() - INTERVAL '4 days'
FROM surveys sv
JOIN subjects s ON sv.subject_id = s.id
WHERE s.code = 'CS101' AND sv.status = 'completed'
ORDER BY sv.id LIMIT 1 OFFSET 2;

INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT sv.id, 
       'Me encanta esta clase! El contenido es interesante y bien organizado.', 
       'positive', 
       0.99, 
       NOW() - INTERVAL '6 days'
FROM surveys sv
JOIN subjects s ON sv.subject_id = s.id
WHERE s.code = 'CS101' AND sv.status = 'completed'
ORDER BY sv.id LIMIT 1 OFFSET 4;

-- Additional NEUTRAL comments for CS101
INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT sv.id, 
       'La clase está bien, pero a veces el ritmo es un poco rápido para seguir.', 
       'neutral', 
       0.68, 
       NOW() - INTERVAL '8 days'
FROM surveys sv
JOIN subjects s ON sv.subject_id = s.id
WHERE s.code = 'CS101' AND sv.status = 'completed'
ORDER BY sv.id LIMIT 1 OFFSET 2;

INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT sv.id, 
       'El material es bueno pero necesito más tiempo para practicar. Sería útil tener más ejercicios.', 
       'neutral', 
       0.71, 
       NOW() - INTERVAL '12 days'
FROM surveys sv
JOIN subjects s ON sv.subject_id = s.id
WHERE s.code = 'CS101' AND sv.status = 'completed'
ORDER BY sv.id LIMIT 1 OFFSET 4;

-- Additional NEGATIVE comment for CS101
INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT sv.id, 
       'Me cuesta seguir la clase porque no tengo suficiente base previa. Necesitaría más apoyo.', 
       'negative', 
       0.81, 
       NOW() - INTERVAL '15 days'
FROM surveys sv
JOIN subjects s ON sv.subject_id = s.id
WHERE s.code = 'CS101' AND sv.status = 'completed'
ORDER BY sv.id LIMIT 1;

-- Comments for CS201 (Machine Learning I)
INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT sv.id, 
       'El profesor hace que Machine Learning sea accesible y emocionante. Gran curso!', 
       'positive', 
       0.96, 
       NOW() - INTERVAL '1 day'
FROM surveys sv
JOIN subjects s ON sv.subject_id = s.id
WHERE s.code = 'CS201' AND sv.status = 'completed'
ORDER BY sv.id LIMIT 1;

INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT sv.id, 
       'Buen contenido, pero los proyectos son muy desafiantes. Más tiempo sería útil.', 
       'neutral', 
       0.73, 
       NOW() - INTERVAL '3 days'
FROM surveys sv
JOIN subjects s ON sv.subject_id = s.id
WHERE s.code = 'CS201' AND sv.status = 'completed'
ORDER BY sv.id LIMIT 1;

-- Comments for Maria Lopez's subject (MA150)
INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT sv.id, 
       'La profesora Lopez es muy clara explicando estadística. Sus ejemplos son prácticos.', 
       'positive', 
       0.94, 
       NOW() - INTERVAL '2 days'
FROM surveys sv
JOIN subjects s ON sv.subject_id = s.id
WHERE s.code = 'MA150' AND sv.status = 'completed'
ORDER BY sv.id LIMIT 1 OFFSET 1;

INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT sv.id, 
       'Me gusta la clase pero a veces los ejercicios son muy teóricos. Preferiría más aplicaciones reales.', 
       'neutral', 
       0.70, 
       NOW() - INTERVAL '6 days'
FROM surveys sv
JOIN subjects s ON sv.subject_id = s.id
WHERE s.code = 'MA150' AND sv.status = 'completed'
ORDER BY sv.id LIMIT 1 OFFSET 3;

INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT sv.id, 
       'Excelente profesora! Hace que las matemáticas sean interesantes y fáciles de entender.', 
       'positive', 
       0.98, 
       NOW() - INTERVAL '9 days'
FROM surveys sv
JOIN subjects s ON sv.subject_id = s.id
WHERE s.code = 'MA150' AND sv.status = 'completed'
ORDER BY sv.id LIMIT 1;

COMMIT;

-- Verification query
SELECT 
    s.code as subject_code,
    s.name as subject_name,
    COUNT(c.id) as comment_count,
    SUM(CASE WHEN c.sentiment = 'positive' THEN 1 ELSE 0 END) as positive,
    SUM(CASE WHEN c.sentiment = 'neutral' THEN 1 ELSE 0 END) as neutral,
    SUM(CASE WHEN c.sentiment = 'negative' THEN 1 ELSE 0 END) as negative
FROM subjects s
LEFT JOIN surveys sv ON s.id = sv.subject_id
LEFT JOIN comments c ON sv.id = c.survey_id
WHERE s.code IN ('CS101', 'CS201', 'MA150')
GROUP BY s.code, s.name
ORDER BY s.code;

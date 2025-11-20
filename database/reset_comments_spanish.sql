-- Update ALL comments to Spanish
-- This ensures every comment in the database is in Spanish

BEGIN;

-- Delete all existing comments and re-insert with Spanish text
DELETE FROM comments;

-- Re-insert comments in Spanish for all surveys
-- Comments for Alberto Garcia's subjects (CS101 and CS201)

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

-- Additional diverse comments for Alberto Garcia (CS101)
INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT sv.id, 'El profesor Garcia explica muy bien los conceptos difíciles. Sus ejemplos son muy útiles.', 'positive', 0.95, NOW() - INTERVAL '2 days'
FROM surveys sv
JOIN subjects s ON sv.subject_id = s.id
WHERE s.code = 'CS101' AND sv.status = 'completed'
ORDER BY sv.id LIMIT 1;

INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT sv.id, 'Excelente metodología de enseñanza. Siempre está dispuesto a ayudar.', 'positive', 0.97, NOW() - INTERVAL '4 days'
FROM surveys sv
JOIN subjects s ON sv.subject_id = s.id
WHERE s.code = 'CS101' AND sv.status = 'completed'
ORDER BY sv.id LIMIT 1 OFFSET 2;

INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT sv.id, 'Me encanta esta clase! El contenido es interesante y bien organizado.', 'positive', 0.99, NOW() - INTERVAL '6 days'
FROM surveys sv
JOIN subjects s ON sv.subject_id = s.id
WHERE s.code = 'CS101' AND sv.status = 'completed'
ORDER BY sv.id LIMIT 1 OFFSET 4;

INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT sv.id, 'La clase está bien, pero a veces el ritmo es un poco rápido para seguir.', 'neutral', 0.68, NOW() - INTERVAL '8 days'
FROM surveys sv
JOIN subjects s ON sv.subject_id = s.id
WHERE s.code = 'CS101' AND sv.status = 'completed'
ORDER BY sv.id LIMIT 1 OFFSET 2;

INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT sv.id, 'El material es bueno pero necesito más tiempo para practicar. Sería útil tener más ejercicios.', 'neutral', 0.71, NOW() - INTERVAL '12 days'
FROM surveys sv
JOIN subjects s ON sv.subject_id = s.id
WHERE s.code = 'CS101' AND sv.status = 'completed'
ORDER BY sv.id LIMIT 1 OFFSET 4;

INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT sv.id, 'Me cuesta seguir la clase porque no tengo suficiente base previa. Necesitaría más apoyo.', 'negative', 0.81, NOW() - INTERVAL '15 days'
FROM surveys sv
JOIN subjects s ON sv.subject_id = s.id
WHERE s.code = 'CS101' AND sv.status = 'completed'
ORDER BY sv.id LIMIT 1;

-- Comments for CS201 (Machine Learning I)
INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT sv.id, 'El profesor hace que Machine Learning sea accesible y emocionante. Gran curso!', 'positive', 0.96, NOW() - INTERVAL '1 day'
FROM surveys sv
JOIN subjects s ON sv.subject_id = s.id
WHERE s.code = 'CS201' AND sv.status = 'completed'
ORDER BY sv.id LIMIT 1;

INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT sv.id, 'Buen contenido, pero los proyectos son muy desafiantes. Más tiempo sería útil.', 'neutral', 0.73, NOW() - INTERVAL '3 days'
FROM surveys sv
JOIN subjects s ON sv.subject_id = s.id
WHERE s.code = 'CS201' AND sv.status = 'completed'
ORDER BY sv.id LIMIT 1;

-- Comments for Maria Lopez's subject (MA150)
INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT sv.id, 'La profesora Lopez es muy clara explicando estadística. Sus ejemplos son prácticos.', 'positive', 0.94, NOW() - INTERVAL '2 days'
FROM surveys sv
JOIN subjects s ON sv.subject_id = s.id
WHERE s.code = 'MA150' AND sv.status = 'completed'
ORDER BY sv.id LIMIT 1 OFFSET 1;

INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT sv.id, 'Me gusta la clase pero a veces los ejercicios son muy teóricos. Preferiría más aplicaciones reales.', 'neutral', 0.70, NOW() - INTERVAL '6 days'
FROM surveys sv
JOIN subjects s ON sv.subject_id = s.id
WHERE s.code = 'MA150' AND sv.status = 'completed'
ORDER BY sv.id LIMIT 1 OFFSET 3;

INSERT INTO comments (survey_id, text, sentiment, confidence_score, created_at)
SELECT sv.id, 'Excelente profesora! Hace que las matemáticas sean interesantes y fáciles de entender.', 'positive', 0.98, NOW() - INTERVAL '9 days'
FROM surveys sv
JOIN subjects s ON sv.subject_id = s.id
WHERE s.code = 'MA150' AND sv.status = 'completed'
ORDER BY sv.id LIMIT 1;

COMMIT;

-- Show all comments to verify
SELECT 
    c.id,
    s.code as subject_code,
    c.sentiment,
    LEFT(c.text, 60) as comment_preview
FROM comments c
JOIN surveys sv ON c.survey_id = sv.id
JOIN subjects s ON sv.subject_id = s.id
ORDER BY c.created_at DESC;

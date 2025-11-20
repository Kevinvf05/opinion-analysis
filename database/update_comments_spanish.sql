-- ============================================
-- UPDATE COMMENTS TO SPANISH
-- This updates all existing English comments to Spanish
-- ============================================

BEGIN;

-- Update the seed_data_simple.sql comments (the first 5 comments)
-- These updates target comments by their survey_id order

-- Comment 1: Juan Perez -> Alberto Garcia (CS101) - POSITIVE
UPDATE comments 
SET text = 'Excelente introducción, explicaciones muy claras y laboratorios muy útiles.'
WHERE id = (SELECT c.id FROM comments c 
            JOIN surveys sv ON c.survey_id = sv.id 
            WHERE sv.status = 'completed' 
            ORDER BY c.id LIMIT 1);

-- Comment 2: Ana Ruiz -> Alberto Garcia (CS201) - POSITIVE  
UPDATE comments 
SET text = 'Excelente profesor! Muy conocedor y con un estilo de enseñanza muy dinámico.'
WHERE id = (SELECT c.id FROM comments c 
            JOIN surveys sv ON c.survey_id = sv.id 
            WHERE sv.status = 'completed' 
            ORDER BY c.id LIMIT 1 OFFSET 1);

-- Comment 3: Carlos Martinez -> Alberto Garcia (CS101) - NEUTRAL
UPDATE comments 
SET text = 'Buena clase pero a veces avanza demasiado rápido. Más ejemplos serían útiles.'
WHERE id = (SELECT c.id FROM comments c 
            JOIN surveys sv ON c.survey_id = sv.id 
            WHERE sv.status = 'completed' 
            ORDER BY c.id LIMIT 1 OFFSET 2);

-- Comment 4: Laura Gonzalez -> Maria Lopez (MA150) - NEGATIVE
UPDATE comments 
SET text = 'Las clases podrían ser más dinámicas. A veces es difícil mantener la concentración.'
WHERE id = (SELECT c.id FROM comments c 
            JOIN surveys sv ON c.survey_id = sv.id 
            WHERE sv.status = 'completed' 
            ORDER BY c.id LIMIT 1 OFFSET 3);

-- Comment 5: Miguel Rodriguez -> Alberto Garcia (CS101) - POSITIVE
UPDATE comments 
SET text = 'El mejor profesor que he tenido! Hace que los temas complejos sean fáciles de entender.'
WHERE id = (SELECT c.id FROM comments c 
            JOIN surveys sv ON c.survey_id = sv.id 
            WHERE sv.status = 'completed' 
            ORDER BY c.id LIMIT 1 OFFSET 4);

-- Update any remaining comments that might be in English
UPDATE comments 
SET text = 'El profesor Garcia explica muy bien los conceptos difíciles. Sus ejemplos son muy útiles.'
WHERE text LIKE '%explains very well%' OR text LIKE '%difficult concepts%';

UPDATE comments 
SET text = 'Excelente metodología de enseñanza. Siempre está dispuesto a ayudar.'
WHERE text LIKE '%teaching methodology%' OR text LIKE '%willing to help%';

UPDATE comments 
SET text = 'Me encanta esta clase! El contenido es interesante y bien organizado.'
WHERE text LIKE '%love this class%' OR text LIKE '%well organized%';

UPDATE comments 
SET text = 'La clase está bien, pero a veces el ritmo es un poco rápido para seguir.'
WHERE text LIKE '%class is okay%' OR text LIKE '%pace is a bit fast%';

UPDATE comments 
SET text = 'El material es bueno pero necesito más tiempo para practicar. Sería útil tener más ejercicios.'
WHERE text LIKE '%good material%' OR text LIKE '%need more time%';

UPDATE comments 
SET text = 'Me cuesta seguir la clase porque no tengo suficiente base previa. Necesitaría más apoyo.'
WHERE text LIKE '%hard to follow%' OR text LIKE '%background knowledge%';

UPDATE comments 
SET text = 'El profesor hace que Machine Learning sea accesible y emocionante. Gran curso!'
WHERE text LIKE '%Machine Learning%' AND text LIKE '%accessible%';

UPDATE comments 
SET text = 'Buen contenido, pero los proyectos son muy desafiantes. Más tiempo sería útil.'
WHERE text LIKE '%Good content%' AND text LIKE '%projects are challenging%';

UPDATE comments 
SET text = 'La profesora Lopez es muy clara explicando estadística. Sus ejemplos son prácticos.'
WHERE text LIKE '%Lopez is very clear%' OR text LIKE '%explaining statistics%';

UPDATE comments 
SET text = 'Me gusta la clase pero a veces los ejercicios son muy teóricos. Preferiría más aplicaciones reales.'
WHERE text LIKE '%exercises are too theoretical%' OR text LIKE '%real applications%';

UPDATE comments 
SET text = 'Excelente profesora! Hace que las matemáticas sean interesantes y fáciles de entender.'
WHERE text LIKE '%makes math%' OR text LIKE '%interesting and easy%';

COMMIT;

-- Verification: Show all comments in Spanish
SELECT 
    c.id,
    s.name as subject,
    c.sentiment,
    c.text
FROM comments c
JOIN surveys sv ON c.survey_id = sv.id
JOIN subjects s ON sv.subject_id = s.id
ORDER BY c.id;

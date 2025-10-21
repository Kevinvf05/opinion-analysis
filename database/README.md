# Base de Datos - Sistema de Análisis de Opinión 

---

## Diagrama Entidad-Relación (ERD)

![Diagrama ERD](./database_erd_diagram.png)

> **Nota**: Si la imagen no se visualiza, abre el archivo [database_erd_diagram.png](./database_erd_diagram.png) directamente.

---

## 🎯 Descripción General

El sistema utiliza **PostgreSQL** como gestor de base de datos relacional, con 10 tablas principales que soportan:

- ✅ Autenticación de 3 tipos de usuarios (estudiantes, profesores, coordinadores)
- ✅ Gestión de materias y asignaciones profesor-materia por periodo
- ✅ Encuestas de evaluación docente con 22 preguntas tipo Likert
- ✅ Comentarios abiertos con análisis de sentimiento automático
- ✅ Dashboards con estadísticas agregadas
- ✅ Auditoría de acciones del sistema
- ✅ Recuperación de contraseñas

---

## 📋 Tablas Principales

### **1. USERS** 👥
Almacena todos los usuarios del sistema.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | SERIAL (PK) | Identificador único |
| `role` | VARCHAR(20) | Rol: `student`, `teacher`, `coordinator` |
| `name` | VARCHAR(100) | Nombre completo |
| `email` | VARCHAR(100) | Correo (profesores/coordinadores) |
| `matricula` | VARCHAR(20) | Matrícula (estudiantes) |
| `password_hash` | VARCHAR(255) | Contraseña hasheada (bcrypt) |
| `career` | VARCHAR(100) | Carrera (estudiantes) |
| `semester` | INTEGER | Semestre actual (1-10) |
| `is_active` | BOOLEAN | Estado de la cuenta |

**Validaciones:**
- Estudiantes deben tener `matricula` (no `email`)
- Profesores/coordinadores deben tener `email` (no `matricula`)

---

### **2. SUBJECTS** 📚
Catálogo de materias de la universidad.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | SERIAL (PK) | Identificador único |
| `code` | VARCHAR(20) UNIQUE | Código de materia (ej: "IS701") |
| `name` | VARCHAR(150) | Nombre de la materia |
| `career` | VARCHAR(100) | Carrera a la que pertenece |
| `semester` | INTEGER | Semestre en que se cursa (1-10) |
| `credits` | INTEGER | Créditos académicos |

---

### **3. TEACHER_SUBJECTS** 👨‍🏫📖
Asignación de profesores a materias por periodo académico.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | SERIAL (PK) | Identificador único |
| `teacher_id` | INTEGER (FK) | Referencia a `users.id` |
| `subject_id` | INTEGER (FK) | Referencia a `subjects.id` |
| `semester_period` | VARCHAR(20) | Periodo (ej: "2025-1") |
| `group_name` | VARCHAR(10) | Grupo (ej: "A", "B") |
| `schedule` | VARCHAR(200) | Horario de clases |
| `max_students` | INTEGER | Capacidad máxima |

**Restricción:** Un profesor no puede tener la misma materia/grupo en el mismo periodo dos veces.

---

### **4. CATEGORIES** 📂
Las 7 dimensiones de evaluación docente.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | SERIAL (PK) | Identificador único |
| `name` | VARCHAR(100) UNIQUE | Nombre de la categoría |
| `description` | TEXT | Descripción detallada |
| `display_order` | INTEGER UNIQUE | Orden de visualización (1-7) |

**Categorías definidas:**
1. Dominio del contenido y preparación
2. Estrategias de enseñanza y metodología
3. Comunicación y acompañamiento
4. Clima de aula y valores
5. Evaluación del aprendizaje
6. Motivación y satisfacción
7. Espacio para comentarios abiertos

---

### **5. QUESTIONS** ❓
Las 22 preguntas de evaluación (escala Likert 1-5).

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | SERIAL (PK) | Identificador único |
| `category_id` | INTEGER (FK) | Categoría a la que pertenece |
| `question_number` | INTEGER UNIQUE | Número de pregunta (1-22) |
| `text` | TEXT | Texto de la pregunta |
| `question_type` | VARCHAR(20) | Tipo: `likert` u `open` |
| `is_positive` | BOOLEAN | ¿La pregunta evalúa algo positivo? |

**Escala Likert:**
- 1 = Totalmente en desacuerdo
- 2 = En desacuerdo
- 3 = Ni de acuerdo ni en desacuerdo
- 4 = De acuerdo
- 5 = Totalmente de acuerdo

---

### **6. SURVEYS** 📝
Encuestas completadas por estudiantes.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | SERIAL (PK) | Identificador único |
| `student_id` | INTEGER (FK) | Estudiante que evalúa |
| `teacher_id` | INTEGER (FK) | Profesor evaluado |
| `subject_id` | INTEGER (FK) | Materia evaluada |
| `semester_period` | VARCHAR(20) | Periodo académico |
| `is_complete` | BOOLEAN | ¿Encuesta completa? |
| `progress` | INTEGER | Porcentaje de avance (0-100) |
| `submitted_at` | TIMESTAMP | Fecha de envío |

**Restricción:** Un estudiante solo puede evaluar a un profesor por materia una vez por periodo.

---

### **7. SURVEY_RESPONSES** ✅
Respuestas individuales a cada pregunta.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | SERIAL (PK) | Identificador único |
| `survey_id` | INTEGER (FK) | Encuesta a la que pertenece |
| `question_id` | INTEGER (FK) | Pregunta respondida |
| `response_value` | INTEGER | Valor de respuesta (1-5) |

**Restricción:** No se puede responder la misma pregunta dos veces en una encuesta.

---

### **8. COMMENTS** 💬
Comentarios abiertos con análisis de sentimiento.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | SERIAL (PK) | Identificador único |
| `survey_id` | INTEGER (FK) | Encuesta asociada |
| `text` | TEXT | Contenido del comentario (10-2000 caracteres) |
| `word_count` | INTEGER | Número de palabras (calculado automáticamente) |
| `sentiment` | VARCHAR(20) | Clasificación: `positive`, `negative`, `neutral` |
| `confidence` | FLOAT | Confianza del modelo (0-1) |
| `reviewed` | BOOLEAN | ¿Revisado manualmente? |
| `manual_sentiment` | VARCHAR(20) | Clasificación corregida (si aplica) |

**Análisis automático:**
- Se usa un modelo de NLP (pysentimiento) para clasificar el sentimiento
- El coordinador puede revisar y corregir clasificaciones

---

### **9. AUDIT_LOG** 📋
Registro de auditoría de acciones importantes.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | SERIAL (PK) | Identificador único |
| `user_id` | INTEGER (FK) | Usuario que realizó la acción |
| `action_type` | VARCHAR(50) | Tipo de acción (ej: `CREATE_USER`) |
| `entity_type` | VARCHAR(50) | Entidad afectada (ej: `User`, `Survey`) |
| `description` | TEXT | Descripción de la acción |
| `changes` | JSONB | Cambios realizados (JSON) |

**Acciones registradas:**
- Creación/edición/eliminación de usuarios
- Exportación de reportes PDF
- Modificaciones a comentarios
- Cambios en asignaciones de materias

---

### **10. PASSWORD_RESET_TOKENS** 🔐
Tokens para recuperación de contraseña.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | SERIAL (PK) | Identificador único |
| `user_id` | INTEGER (FK) | Usuario solicitante |
| `token` | VARCHAR(100) UNIQUE | Token único (hash) |
| `expires_at` | TIMESTAMP | Fecha de expiración (30 min) |
| `used` | BOOLEAN | ¿Ya fue utilizado? |

---

## 🔍 Vistas (Views)

El sistema incluye 3 vistas para consultas comunes:

### **1. teacher_statistics**
Estadísticas agregadas por profesor.
```sql
SELECT * FROM teacher_statistics WHERE teacher_id = 2;
```

**Campos:**
- `total_surveys`: Total de encuestas recibidas
- `overall_avg_rating`: Promedio general (1-5)
- `positive_comments`: Comentarios positivos
- `negative_comments`: Comentarios negativos
- `neutral_comments`: Comentarios neutros

---

### **2. subject_statistics**
Estadísticas por materia y profesor.
```sql
SELECT * FROM subject_statistics 
WHERE semester_period = '2025-1' 
ORDER BY avg_rating DESC;
```

**Campos:**
- `avg_rating`: Promedio de evaluación
- `participation_rate`: % de estudiantes que respondieron
- `total_students_responded`: Número de respuestas

---

### **3. teacher_category_ratings**
Promedio por categoría de evaluación.
```sql
SELECT * FROM teacher_category_ratings 
WHERE teacher_id = 2 AND semester_period = '2025-1';
```

**Uso:** Dashboard del profesor (gráfica de radar por categoría)

---

## ⚡ Triggers Automáticos

### **1. update_updated_at_column**
Actualiza automáticamente el campo `updated_at` en la tabla `users`.

### **2. calculate_word_count**
Cuenta palabras del comentario y actualiza `word_count` automáticamente.

### **3. update_progress_on_response**
Actualiza el `progress` de la encuesta cada vez que se responde una pregunta.
```
Ejemplo:
- Preguntas totales: 22
- Preguntas respondidas: 11
- Progress automático: 50%
```

---

## 🛠️ Instalación y Configuración

### **Requisitos:**
- PostgreSQL 14+ instalado
- Acceso con permisos de creación de base de datos

### **Paso 1: Crear la base de datos**
```bash
# Conectarse a PostgreSQL
psql -U postgres

# Crear base de datos
CREATE DATABASE analisis_opinion;

# Crear usuario de aplicación
CREATE USER app_user WITH PASSWORD 'tu_password_seguro';
GRANT ALL PRIVILEGES ON DATABASE analisis_opinion TO app_user;

# Salir
\q
```

---

### **Paso 2: Ejecutar el esquema**
```bash
# Ejecutar schema.sql
psql -U postgres -d analisis_opinion -f schema.sql

# Verificar que se crearon las tablas
psql -U postgres -d analisis_opinion -c "\dt"
```

---

### **Paso 3: Cargar datos de prueba (opcional)**
```bash
# Ejecutar seed_data.sql
psql -U postgres -d analisis_opinion -f seed_data.sql

# Verificar datos
psql -U postgres -d analisis_opinion -c "SELECT COUNT(*) FROM users;"
```

---

## 📊 Consultas Útiles

### **Ver todas las encuestas completas:**
```sql
SELECT 
    s.id,
    u_student.name AS estudiante,
    u_teacher.name AS profesor,
    sub.name AS materia,
    s.submitted_at
FROM surveys s
JOIN users u_student ON u_student.id = s.student_id
JOIN users u_teacher ON u_teacher.id = s.teacher_id
JOIN subjects sub ON sub.id = s.subject_id
WHERE s.is_complete = TRUE
ORDER BY s.submitted_at DESC;
```

---

### **Ver comentarios sin clasificar:**
```sql
SELECT 
    c.id,
    c.text,
    u.name AS profesor
FROM comments c
JOIN surveys s ON s.id = c.survey_id
JOIN users u ON u.id = s.teacher_id
WHERE c.sentiment IS NULL
ORDER BY c.created_at DESC;
```

---

### **Promedio por categoría de un profesor:**
```sql
SELECT 
    cat.name AS categoria,
    ROUND(AVG(sr.response_value)::numeric, 2) AS promedio
FROM survey_responses sr
JOIN questions q ON q.id = sr.question_id
JOIN categories cat ON cat.id = q.category_id
JOIN surveys s ON s.id = sr.survey_id
WHERE s.teacher_id = 2 AND s.semester_period = '2025-1'
GROUP BY cat.name, cat.display_order
ORDER BY cat.display_order;
```

---

## 🔒 Seguridad

### **Contraseñas:**
- Se usa **bcrypt** con salt para hashear contraseñas
- Nunca se almacenan en texto plano

### **Anonimización:**
- Los profesores **NO** ven nombre ni matrícula del estudiante
- Solo ven metadatos no identificables (semestre, carrera)

### **Auditoría:**
- Todas las acciones importantes quedan registradas en `audit_log`
- Incluye: quién, qué, cuándo, desde dónde (IP)

---

## 📚 Referencias

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Crow's Foot Notation](https://www.vertabelo.com/blog/crow-s-foot-notation/)
- [Bcrypt Hashing](https://pypi.org/project/bcrypt/)

---

## 👥 Autores

**Equipo 2 - Ingeniería de Software**
- Luis Antonio Espín Acevedo
- Kevin Vargas Flores
- Anibal Medina Cabrera
- Cristopher Axel Diaz Martinez

---

## 📝 Changelog

### [v1.0.0] - 2025-01-XX
- ✅ Esquema inicial completo
- ✅ 10 tablas principales
- ✅ 3 vistas para estadísticas
- ✅ 3 triggers automáticos
- ✅ Datos de prueba incluidos

---

## 🐛 Troubleshooting

### **Problema: Error al ejecutar schema.sql**
```bash
# Solución: Verificar que PostgreSQL esté corriendo
sudo systemctl status postgresql

# Reiniciar si es necesario
sudo systemctl restart postgresql
```

### **Problema: Permisos denegados**
```bash
# Solución: Otorgar permisos al usuario
psql -U postgres -d analisis_opinion
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO app_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO app_user;
```

---

## 📞 Soporte

Para dudas o problemas, contactar al equipo en: [Crear issue en GitHub](../../issues)

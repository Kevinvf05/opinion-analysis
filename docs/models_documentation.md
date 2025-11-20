# Models Documentation

## Database Schema Overview

This document describes the data models used in the Sistema de Análisis de Opinión Docente.

## User Model

Represents all users in the system (students, professors, admins, coordinators).

**Table:** `users`

| Field | Type | Description |
|-------|------|-------------|
| id | Integer | Primary key |
| email | String(120) | Unique email address |
| password_hash | String(255) | Hashed password |
| first_name | String(100) | User's first name |
| last_name | String(100) | User's last name |
| role | String(20) | User role: student, professor, admin, coordinator |
| is_active | Boolean | Account status |
| created_at | DateTime | Account creation timestamp |
| updated_at | DateTime | Last update timestamp |

**Relationships:**
- `surveys_created`: Surveys created by this user (if student)
- `surveys_received`: Surveys received by this user (if professor)

**Example JSON:**
```json
{
  "id": 1,
  "email": "student@example.com",
  "firstName": "Juan",
  "lastName": "Pérez",
  "role": "student",
  "isActive": true,
  "createdAt": "2024-01-15T10:30:00",
  "updatedAt": "2024-01-20T15:45:00"
}
```

## Survey Model

Represents a student's evaluation survey for a professor in a specific subject.

**Table:** `surveys`

| Field | Type | Description |
|-------|------|-------------|
| id | Integer | Primary key |
| student_id | Integer | Foreign key to users (student) |
| professor_id | Integer | Foreign key to users (professor) |
| subject_id | Integer | Foreign key to subjects |
| status | String(20) | pending, completed, cancelled |
| created_at | DateTime | Survey creation timestamp |
| completed_at | DateTime | Survey completion timestamp |

**Relationships:**
- `student`: User who created the survey
- `professor`: User being evaluated
- `subject`: Subject being evaluated
- `comments`: Comments in this survey

**Example JSON:**
```json
{
  "id": 42,
  "studentId": 1,
  "professorId": 5,
  "subjectId": 10,
  "status": "completed",
  "createdAt": "2024-01-15T10:00:00",
  "completedAt": "2024-01-15T10:30:00",
  "commentsCount": 3
}
```

## Comment Model

Represents a comment/feedback within a survey with sentiment analysis.

**Table:** `comments`

| Field | Type | Description |
|-------|------|-------------|
| id | Integer | Primary key |
| survey_id | Integer | Foreign key to surveys |
| text | Text | Comment content |
| sentiment | String(20) | positive, negative, neutral |
| confidence_score | Float | AI confidence (0.0 to 1.0) |
| created_at | DateTime | Comment creation timestamp |

**Relationships:**
- `survey`: Survey this comment belongs to

**Example JSON:**
```json
{
  "id": 100,
  "surveyId": 42,
  "text": "Excelente profesor, explica muy bien los conceptos.",
  "sentiment": "positive",
  "confidenceScore": 0.95,
  "createdAt": "2024-01-15T10:15:00"
}
```

## Subject Model

Represents an academic subject/course.

**Table:** `subjects`

| Field | Type | Description |
|-------|------|-------------|
| id | Integer | Primary key |
| name | String(200) | Subject name |
| code | String(50) | Unique subject code |
| description | Text | Subject description |
| semester | Integer | Semester number |
| credits | Integer | Credit hours |
| created_at | DateTime | Creation timestamp |

**Relationships:**
- `surveys`: Surveys for this subject

**Example JSON:**
```json
{
  "id": 10,
  "name": "Arquitectura de Software",
  "code": "CS301",
  "description": "Introducción a patrones de diseño y arquitectura",
  "semester": 6,
  "credits": 4,
  "createdAt": "2024-01-01T00:00:00"
}
```

## Database Relationships Diagram

```
┌─────────────┐
│    User     │
│  (users)    │
└──────┬──────┘
       │
       │ 1:N (as student)
       ├──────────────────┐
       │                  │
       │ 1:N (as prof)    ▼
       │            ┌──────────┐      ┌────────────┐
       └───────────►│  Survey  │      │  Subject   │
                    │(surveys) │◄─────│ (subjects) │
                    └────┬─────┘  N:1 └────────────┘
                         │
                         │ 1:N
                         ▼
                    ┌──────────┐
                    │ Comment  │
                    │(comments)│
                    └──────────┘
```

## Using Models in Frontend

Import the model viewer components:

```jsx
import { UserCard, SurveyCard, CommentCard, SubjectCard } from '../components/common/ModelViewer';

// Display a user
<UserCard user={userData} />

// Display a survey
<SurveyCard 
  survey={surveyData} 
  student={studentData}
  professor={professorData}
  subject={subjectData}
/>

// Display a comment
<CommentCard comment={commentData} />

// Display a subject
<SubjectCard subject={subjectData} />
```

## Data Flow Example

1. **Student logs in** → User model (role: student)
2. **Student creates survey** → Survey model created (status: pending)
3. **Student adds comments** → Comment models created
4. **AI analyzes comments** → Comment.sentiment and confidence_score updated
5. **Survey submitted** → Survey.status = "completed", completed_at set
6. **Admin views dashboard** → Aggregates data from all models

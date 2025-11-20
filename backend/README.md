# UAEM Teacher Opinion Analysis System - Backend

Simple and functional Flask backend for the UAEM evaluation system.

## 📁 Project Structure

```
backend/
├── run.py                  # Main entry point - Run this to start the server
├── seed_data.py            # Database seeder with test data
├── requirements.txt        # Python dependencies
├── Dockerfile              # Docker configuration
├── .env.example            # Environment variables template
├── README.md               # This file
│
├── app/                    # Main application package
│   ├── __init__.py         # App factory and initialization
│   ├── config.py           # Configuration settings
│   │
│   ├── models/             # Database models
│   │   └── __init__.py     # User, Student, Professor, Admin models
│   │
│   ├── routes/             # API endpoints
│   │   └── __init__.py     # Authentication routes
│   │
│   └── utils/              # Utility functions
│       └── __init__.py     # Helper functions (name normalization)
│
└── tests/                  # Test suite
    └── test_login.py       # Login validation tests
```

## Features

- **User Authentication**: JWT-based authentication
- **Multiple User Roles**: Students, Professors, Admins
- **Student Login**: Uses matricula + name (NO password, NO special characters)
- **Staff Login**: Professors and Admins use email + password
- **Database**: PostgreSQL with SQLAlchemy ORM
- **CORS Enabled**: For frontend integration

## Structure

```
backend/
├── app.py              # Main application file
├── config.py           # Configuration settings
├── models.py           # Database models
├── routes.py           # API routes (authentication)
├── seed_data.py        # Sample data for testing
├── requirements.txt    # Python dependencies
├── Dockerfile          # Docker configuration
└── .env.example        # Environment variables template
```

## API Endpoints

### Authentication

- `POST /api/auth/login` - Login endpoint
- `GET /api/auth/me` - Get current user (requires token)
- `POST /api/auth/logout` - Logout (client-side token removal)

### Health Check

- `GET /api/health` - Health check endpoint
- `GET /` - API information

## Login Examples

### Student Login

```json
POST /api/auth/login
{
  "role": "student",
  "matricula": "A12345678",
  "name": "Maria Gonzalez"
}
```
**Note:** Student names are automatically cleaned of special characters (á, é, í, ', etc.)

### Staff Login (Professor/Admin)

```json
POST /api/auth/login
{
  "role": "staff",
  "email": "profesor@uaem.mx",
  "password": "profesor123"
}
```

### Response

```json
{
  "message": "Login successful",
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": {
    "id": 1,
    "email": "profesor@uaem.mx",
    "first_name": "Juan",
    "last_name": "Pérez",
    "full_name": "Juan Pérez",
    "role": "professor",
    "is_active": true,
    "department": "Ingeniería",
    "office": "A-101"
  }
}
```

## Test Credentials

### Admin
- Email: `admin@uaem.mx`
- Password: `admin123`

### Professor
- Email: `profesor@uaem.mx`
- Password: `profesor123`

### Students
1. Matricula: `A12345678`, Name: `María González`
2. Matricula: `A87654321`, Name: `Carlos Ramírez`

## Running Locally

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Set environment variables:
```bash
export DATABASE_URL=postgresql://postgres:Password123@localhost:5430/uaem_evaluation
export SECRET_KEY=your-secret-key
export FLASK_ENV=development
```

3. Run the application:
```bash
python run.py
```

4. Seed test data:
```bash
python seed_data.py
```

## Running with Docker

The backend is configured to run with Docker Compose. See the main project README.

## Environment Variables

- `DATABASE_URL`: PostgreSQL connection string
- `SECRET_KEY`: Secret key for JWT tokens
- `FLASK_ENV`: development or production

## Database Models

### User
- Unified authentication table for all user types
- Fields: id, email, password_hash, first_name, last_name, role, matricula

### Student
- Student-specific data
- Links to User table

### Professor
- Professor-specific data
- Links to User table

### Admin
- Admin-specific data
- Links to User table

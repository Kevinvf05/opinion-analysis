# UAEM Teacher Opinion Analysis System - Quick Start Guide

## 🚀 New Simple Backend Created!

The backend has been completely rebuilt with a simple, functional structure that connects seamlessly with the frontend.

## 📁 New Backend Structure

```
backend/
├── app.py              # Main Flask application
├── config.py           # Configuration settings
├── models.py           # Database models (User, Student, Professor, Admin)
├── routes.py           # Authentication routes
├── seed_data.py        # Sample data for testing
├── requirements.txt    # Python dependencies
├── Dockerfile          # Docker configuration
└── README.md           # Backend documentation
```

## 🔑 Test Credentials

### Admin
- **Email:** admin@uaem.mx
- **Password:** admin123

### Professor
- **Email:** profesor@uaem.mx
- **Password:** profesor123

### Students
1. **Matricula:** A12345678, **Name:** Maria Gonzalez (or María González)
2. **Matricula:** A87654321, **Name:** Carlos Ramirez (or Carlos Ramírez)

**Note:** Special characters in names are automatically removed for matching.

## 🐳 Running with Docker (Recommended)

### Prerequisites
- Docker Desktop installed and running
- Ports 5000, 5430, and 8080 available

### Steps

1. **Build and start all services:**
   ```bash
   docker-compose up --build -d
   ```

2. **Wait for services to be ready:**
   - Database initialization (~10 seconds)
   - Backend and frontend services

3. **⚠️ IMPORTANT: Initialize the database manually:**
   
   **Windows (PowerShell):**
   ```bash
   .\setup-database.ps1
   ```
   
   **Linux/Mac:**
   ```bash
   chmod +x setup-database.sh
   ./setup-database.sh
   ```
   
   This creates the tables and adds test data.

4. **Access the application:**
   - Frontend: http://localhost:8080/login.html
   - Backend API: http://localhost:5000
   - Database: localhost:5430

### Stopping the services:
```bash
docker-compose down
```

### Reset everything (including database):
```bash
docker-compose down -v
docker-compose up --build -d
.\setup-database.ps1  # Don't forget to reinitialize!
```

## 💻 Running Locally (Without Docker)

### Prerequisites
- Python 3.11+
- PostgreSQL 15
- Node.js (for frontend)

### Backend Setup

1. **Install dependencies:**
   ```bash
   cd backend
   pip install -r requirements.txt
   ```

2. **Set environment variables:**
   ```bash
   # Windows PowerShell
   $env:DATABASE_URL="postgresql://postgres:Password123@localhost:5430/uaem_evaluation"
   $env:SECRET_KEY="dev-secret-key"
   $env:FLASK_ENV="development"
   ```

3. **Run the backend:**
   ```bash
   python app.py
   ```

4. **Seed test data (first time only):**
   ```bash
   python seed_data.py
   ```

### Frontend Setup

1. **Serve the frontend:**
   ```bash
   cd frontend/public
   # Use any static file server, for example:
   # Python: python -m http.server 8080
   # Or open index.html in your browser
   ```

## 🔐 Login System

### Student Login
- Uses **matricula** (enrollment number) + **full name**
- **NO password required**
- **NO special characters** in name (accents like á, é, í, or symbols like ' are automatically removed)
- Format: Letter + 8 digits (e.g., A12345678)
- Name is normalized for comparison (e.g., "María González" matches "Maria Gonzalez")

### Staff Login (Professor/Admin ONLY)
- Uses **email** + **password**
- JWT token-based authentication
- Role-based redirects
- Only professors and admins can login this way (no coordinator role)

## 📡 API Endpoints

### Authentication
```
POST /api/auth/login       - Login endpoint
GET  /api/auth/me          - Get current user (requires token)
POST /api/auth/logout      - Logout
```

### Health Check
```
GET /api/health            - API health status
GET /                      - API information
```

### Example Login Request (Student)
```json
POST http://localhost:5000/api/auth/login
Content-Type: application/json

{
  "role": "student",
  "matricula": "A12345678",
  "name": "Maria Gonzalez"
}
```
**Note:** Names with accents (María) are automatically normalized to match.

### Example Login Request (Staff)
```json
POST http://localhost:5000/api/auth/login
Content-Type: application/json

{
  "role": "staff",
  "email": "profesor@uaem.mx",
  "password": "profesor123"
}
```

### Example Response
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
    "office": "A-101",
    "specialization": "Ciencias de la Computación"
  }
}
```

## 🧪 Testing the Login

1. **Open the login page:**
   - http://localhost:8080/login.html

2. **Test student login:**
   - Select "Estudiante"
   - Enter matricula: A12345678
   - Enter name: María González
   - Click "Iniciar Sesión"

3. **Test staff login:**
   - Select "Profesor/Admin"
   - Enter email: profesor@uaem.mx
   - Enter password: profesor123
   - Click "Iniciar Sesión"

4. **Check the browser console:**
   - Token should be stored in localStorage
   - User data should be saved

## 🔧 Troubleshooting

### Backend won't start
```bash
# Check if port 5000 is available
netstat -ano | findstr :5000

# Check Docker logs
docker-compose logs backend
```

### Database connection error
```bash
# Verify database is running
docker-compose ps db

# Check database logs
docker-compose logs db
```

### CORS errors in browser
- Make sure backend is running on port 5000
- Check that CORS_ORIGINS in config.py includes your frontend URL
- Verify frontend is accessing http://localhost:5000/api

### Login not working
1. Check backend logs for errors
2. Open browser DevTools > Network tab
3. Verify the API request is being sent
4. Check the response for error messages

## 📊 Database Schema

The system uses the existing database schema with these main tables:
- **users** - Unified authentication for all user types
- **students** - Student-specific data
- **professors** - Professor-specific data
- **admins** - Admin-specific data

## 🚦 Next Steps

1. ✅ Backend created and functional
2. ✅ Login system implemented
3. ✅ Frontend connected to backend
4. 🔜 Add more API endpoints (surveys, evaluations, etc.)
5. 🔜 Implement role-based dashboards
6. 🔜 Add data visualization

## 📝 Development Notes

### Adding New API Endpoints
1. Create a new Blueprint in `routes.py` or separate file
2. Register the blueprint in `app.py`
3. Use the `@token_required` decorator for protected routes

### Adding New Models
1. Define the model in `models.py` using SQLAlchemy
2. Create database migrations or run `db.create_all()`

### Environment Variables
- `DATABASE_URL` - PostgreSQL connection string
- `SECRET_KEY` - JWT secret key
- `FLASK_ENV` - development or production

## 🆘 Support

For issues or questions:
1. Check the logs: `docker-compose logs -f backend`
2. Verify all services are running: `docker-compose ps`
3. Review the backend README: `backend/README.md`

---

**Built with:** Flask, PostgreSQL, JWT, Docker
**Last Updated:** November 2025

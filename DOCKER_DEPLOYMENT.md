# Docker Deployment Guide - UAEM Opinion Analysis System

## Prerequisites
- Docker Desktop installed
- Docker Hub account (sign up at https://hub.docker.com)

## For Project Maintainers: Building and Pushing Images

### Step 1: Login to Docker Hub
```powershell
docker login
# Enter your Docker Hub username and password
```

### Step 2: Build and Tag Images
Replace `axldm09` with your actual Docker Hub username:

```powershell
# Build backend image
docker build -t YOUR_DOCKERHUB_USERNAME/uaem-backend:latest ./backend

# Build frontend image
docker build -t YOUR_DOCKERHUB_USERNAME/uaem-frontend:latest ./frontend
```

### Step 3: Push Images to Docker Hub
```powershell
docker push YOUR_DOCKERHUB_USERNAME/uaem-backend:latest
docker push YOUR_DOCKERHUB_USERNAME/uaem-frontend:latest
```

### Step 4: Update docker-compose.yml
Update the image names in `docker-compose.yml` to use your Docker Hub username:
- Change `image: uaem-backend:latest` to `image: YOUR_DOCKERHUB_USERNAME/uaem-backend:latest`
- Change `image: uaem-frontend:latest` to `image: YOUR_DOCKERHUB_USERNAME/uaem-frontend:latest`

---

## For End Users: Running the Application

### Prerequisites: Install Docker

**Ubuntu/Debian:**
```bash
# Update package index
sudo apt-get update

# Install prerequisites
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to docker group (to run without sudo)
sudo usermod -aG docker $USER
newgrp docker

# Verify installation
docker --version
docker compose version
```

**macOS:**
```bash
# Download Docker Desktop from https://www.docker.com/products/docker-desktop
# Or install with Homebrew:
brew install --cask docker

# Launch Docker Desktop from Applications folder
# Wait for Docker to start (whale icon appears in menu bar)

# Verify installation
docker --version
docker compose version
```

### Step 1: Download Required Files
Create a project directory and download these files:
```bash
mkdir uaem-opinion-system
cd uaem-opinion-system

# Create database directory
mkdir database

# Download these files:
# - docker-compose.prod.yml (to project root)
# - database/schema.sql
# - database/seed_data.sql
```

Your directory structure should look like:
```
uaem-opinion-system/
├── docker-compose.prod.yml
└── database/
    ├── schema.sql
    └── seed_data.sql
```

### Step 2: Start the Application
```bash
# Pull images and start all containers
docker compose -f docker-compose.prod.yml up -d

# Check that containers are running
docker compose -f docker-compose.prod.yml ps
```

You should see 3 containers running:
- `postgres` (database)
- `backend` (Flask API)
- `frontend` (Nginx web server)

### Step 3: Initialize the Database

Wait 10-15 seconds for PostgreSQL to fully start, then:

```bash
# Verify PostgreSQL is ready
docker compose -f docker-compose.prod.yml exec postgres pg_isready -U postgres

# Create database schema
docker compose -f docker-compose.prod.yml exec -T postgres psql -U postgres -d opinion_analysis < database/schema.sql

# Load seed data (creates demo users and surveys)
docker compose -f docker-compose.prod.yml exec -T postgres psql -U postgres -d opinion_analysis < database/seed_data.sql
```

### Step 4: Access the Application
Open your browser and go to:
- **Frontend**: http://localhost:8080
- **Backend API**: http://localhost:5000

### Step 5: Login with Demo Credentials

**Administrator:**
- Email: `admin@uaem.mx`
- Password: `admin123`

**Professors:**
- Email: `alberto.garcia@uaem.mx` / Password: `profesor123`
- Email: `maria.lopez@uaem.mx` / Password: `profesor123`

**Students:**
- Matrícula: `20230001` / Password: `estudiante123`
- Matrícula: `20230002` / Password: `estudiante123`

The system includes:
- 2 professors with real survey data
- 15 Spanish comments (6 positive, 5 neutral, 4 negative)
- 3 subjects and 4 surveys
- Complete sentiment analysis functionality

---

## Managing the Application

### View Logs
```bash
# All containers
docker compose -f docker-compose.prod.yml logs

# Specific service
docker compose -f docker-compose.prod.yml logs backend
docker compose -f docker-compose.prod.yml logs frontend
docker compose -f docker-compose.prod.yml logs postgres
```

### Stop the Application
```bash
docker compose -f docker-compose.prod.yml down
```

### Stop and Remove All Data
```bash
# WARNING: This deletes the database and all data
docker compose -f docker-compose.prod.yml down -v
```

### Restart Containers
```bash
# Restart all
docker compose -f docker-compose.prod.yml restart

# Restart specific service
docker compose -f docker-compose.prod.yml restart backend
```

---

## Troubleshooting

### Port Conflicts
If ports 5000 or 8080 are already in use, edit `docker-compose.prod.yml`:
```yaml
frontend:
  ports:
    - "9090:80"  # Change 8080 to 9090

backend:
  ports:
    - "5001:5000"  # Change 5000 to 5001
```

### Database Connection Issues
```bash
# Check database logs
docker compose -f docker-compose.prod.yml logs postgres

# Verify database exists
docker compose -f docker-compose.prod.yml exec postgres psql -U postgres -c "\l"

# Check if tables were created
docker compose -f docker-compose.prod.yml exec postgres psql -U postgres -d opinion_analysis -c "\dt"
```

### Backend Not Responding
```bash
# Check backend logs for errors
docker compose -f docker-compose.prod.yml logs backend

# Restart backend
docker compose -f docker-compose.prod.yml restart backend

# Check backend health
curl http://localhost:5000/health
```

### Images Not Found
Make sure the images are public on Docker Hub. If images are private, login first:
```bash
docker login
# Enter your Docker Hub credentials
```

### Permission Denied (Linux)
If you get permission errors, add your user to the docker group:
```bash
sudo usermod -aG docker $USER
newgrp docker
```

---

## Architecture
```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Frontend  │────▶│   Backend   │────▶│  PostgreSQL │
│   (Nginx)   │     │   (Flask)   │     │  Database   │
│  Port 8080  │     │  Port 5000  │     │  Port 5430  │
└─────────────┘     └─────────────┘     └─────────────┘
```

---

## Support
For issues or questions, contact the development team.

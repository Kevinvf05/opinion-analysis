# Build and Push Script for UAEM Opinion Analysis System
# Run this script to build and push images to Docker Hub

param(
    [Parameter(Mandatory=$true)]
    [string]$DockerHubUsername
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Building and Pushing Docker Images" -ForegroundColor Cyan
Write-Host "Docker Hub Username: $DockerHubUsername" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Check if logged in to Docker Hub
Write-Host "`nChecking Docker login status..." -ForegroundColor Yellow
$loginCheck = docker info 2>&1 | Select-String "Username"
if (-not $loginCheck) {
    Write-Host "Not logged in to Docker Hub. Please login:" -ForegroundColor Red
    docker login
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Docker login failed. Exiting." -ForegroundColor Red
        exit 1
    }
}

# Build Backend Image
Write-Host "`n[1/5] Building Backend Image..." -ForegroundColor Green
docker build -t "${DockerHubUsername}/uaem-backend:latest" ./backend
if ($LASTEXITCODE -ne 0) {
    Write-Host "Backend build failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Backend image built successfully" -ForegroundColor Green

# Build Frontend Image
Write-Host "`n[2/5] Building Frontend Image..." -ForegroundColor Green
docker build -t "${DockerHubUsername}/uaem-frontend:latest" ./frontend
if ($LASTEXITCODE -ne 0) {
    Write-Host "Frontend build failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Frontend image built successfully" -ForegroundColor Green

# Build Database Image
Write-Host "`n[3/5] Building Database Image..." -ForegroundColor Green
docker build -t "${DockerHubUsername}/uaem-database:latest" ./database
if ($LASTEXITCODE -ne 0) {
    Write-Host "Database build failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Database image built successfully" -ForegroundColor Green

# Push Backend Image
Write-Host "`n[4/5] Pushing Backend Image to Docker Hub..." -ForegroundColor Green
docker push "${DockerHubUsername}/uaem-backend:latest"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Backend push failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Backend image pushed successfully" -ForegroundColor Green

# Push Frontend Image
Write-Host "`n[5/5] Pushing Frontend Image to Docker Hub..." -ForegroundColor Green
docker push "${DockerHubUsername}/uaem-frontend:latest"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Frontend push failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Frontend image pushed successfully" -ForegroundColor Green

# Push Database Image
Write-Host "`n[6/6] Pushing Database Image to Docker Hub..." -ForegroundColor Green
docker push "${DockerHubUsername}/uaem-database:latest"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Database push failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Database image pushed successfully" -ForegroundColor Green

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "SUCCESS! Images pushed to Docker Hub" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`nYour images are now available at:" -ForegroundColor Yellow
Write-Host "  - ${DockerHubUsername}/uaem-backend:latest" -ForegroundColor White
Write-Host "  - ${DockerHubUsername}/uaem-frontend:latest" -ForegroundColor White
Write-Host "  - ${DockerHubUsername}/uaem-database:latest" -ForegroundColor White
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Update docker-compose.prod.yml with your username" -ForegroundColor White
Write-Host "2. Share ONLY docker-compose.prod.yml with end users" -ForegroundColor White
Write-Host "3. Users can run: docker compose -f docker-compose.prod.yml up -d" -ForegroundColor White

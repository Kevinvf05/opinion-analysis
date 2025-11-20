#!/bin/bash

echo "========================================="
echo "UAEM Backend - Package Verification"
echo "========================================="
echo ""

echo "Checking if backend container is running..."
if ! docker-compose ps backend | grep -q "Up"; then
    echo "❌ Backend container is not running!"
    echo "Start it with: docker-compose up -d"
    exit 1
fi
echo "✓ Backend container is running"
echo ""

echo "Installed Python version:"
docker-compose exec backend python --version
echo ""

echo "Installed pip version:"
docker-compose exec backend pip --version
echo ""

echo "========================================="
echo "All Installed Packages (pip freeze):"
echo "========================================="
docker-compose exec backend pip freeze
echo ""

echo "========================================="
echo "Package Summary (pip list):"
echo "========================================="
docker-compose exec backend pip list
echo ""

echo "========================================="
echo "Checking for broken dependencies:"
echo "========================================="
docker-compose exec backend pip check
echo ""

echo "========================================="
echo "Key Packages Check:"
echo "========================================="
docker-compose exec backend pip show flask flask-sqlalchemy flask-login flask-cors psycopg2-binary
echo ""

echo "Verification complete!"

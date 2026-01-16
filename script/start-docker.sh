#!/bin/bash
# Script untuk memulai aplikasi QParkin dengan Docker
# Untuk Linux/Mac

echo "========================================"
echo "  QParkin Docker Startup Script"
echo "========================================"
echo ""

echo "[1/4] Checking Docker..."
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker tidak terinstall atau tidak berjalan!"
    echo "Silakan install Docker terlebih dahulu."
    exit 1
fi
echo "Docker detected: OK"
echo ""

echo "[2/4] Stopping existing containers..."
docker-compose down
echo ""

echo "[3/4] Building and starting containers..."
docker-compose up -d --build
echo ""

echo "[4/4] Waiting for services to be ready..."
sleep 10
echo ""

echo "========================================"
echo "  Services Status"
echo "========================================"
docker-compose ps
echo ""

echo "========================================"
echo "  Access Information"
echo "========================================"
echo "Backend API:     http://localhost:8000"
echo "PHPMyAdmin:      http://localhost:8080"
echo "MySQL Port:      3307"
echo ""
echo "Database Credentials:"
echo "  Database: qparkin"
echo "  Username: qparkin_user"
echo "  Password: qparkin_password"
echo ""

echo "========================================"
echo "  Useful Commands"
echo "========================================"
echo "View logs:       docker-compose logs -f"
echo "Stop services:   docker-compose down"
echo "Restart:         docker-compose restart"
echo ""

echo "Setup complete! Press Enter to view logs..."
read
docker-compose logs -f


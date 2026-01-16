@echo off
REM Script untuk memulai aplikasi QParkin dengan Docker
REM Untuk Windows

echo ========================================
echo   QParkin Docker Startup Script
echo ========================================
echo.

echo [1/4] Checking Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker tidak terinstall atau tidak berjalan!
    echo Silakan install Docker Desktop terlebih dahulu.
    pause
    exit /b 1
)
echo Docker detected: OK
echo.

echo [2/4] Stopping existing containers...
docker-compose down
echo.

echo [3/4] Building and starting containers...
docker-compose up -d --build
echo.

echo [4/4] Waiting for services to be ready...
timeout /t 10 /nobreak >nul
echo.

echo ========================================
echo   Services Status
echo ========================================
docker-compose ps
echo.

echo ========================================
echo   Access Information
echo ========================================
echo Backend API:     http://localhost:8000
echo PHPMyAdmin:      http://localhost:8080
echo MySQL Port:      3307
echo.
echo Database Credentials:
echo   Database: qparkin
echo   Username: qparkin_user
echo   Password: qparkin_password
echo.

echo ========================================
echo   Useful Commands
echo ========================================
echo View logs:       docker-compose logs -f
echo Stop services:   docker-compose down
echo Restart:         docker-compose restart
echo.

echo Setup complete! Press any key to view logs...
pause >nul
docker-compose logs -f

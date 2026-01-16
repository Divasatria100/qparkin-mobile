@echo off
echo ========================================
echo Profile API Test Script
echo ========================================
echo.

REM Check if server is running
echo Checking if Laravel server is running...
curl -s http://localhost:8000/api/health >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Laravel server is not running!
    echo.
    echo Please start the server first:
    echo   cd qparkin_backend
    echo   php artisan serve
    echo.
    pause
    exit /b 1
)

echo [OK] Server is running
echo.

REM Run the test script
echo Running profile API tests...
echo.
cd qparkin_backend
php test_profile_api.php

echo.
echo ========================================
echo Test completed!
echo ========================================
pause

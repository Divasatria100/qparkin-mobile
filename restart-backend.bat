@echo off
echo ========================================
echo Restarting Backend Server
echo ========================================
echo.

cd qparkin_backend

echo Clearing cache...
php artisan config:clear
php artisan cache:clear

echo.
echo Starting server...
echo Press Ctrl+C to stop the server
echo.

php artisan serve

pause

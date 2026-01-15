@echo off
echo ========================================
echo Restarting Backend with Clean Cache
echo ========================================
echo.

echo [1/3] Clearing configuration cache...
php qparkin_backend/artisan config:clear
echo.

echo [2/3] Clearing application cache...
php qparkin_backend/artisan cache:clear
echo.

echo [3/3] Backend ready!
echo.
echo ========================================
echo Backend cache cleared successfully!
echo ========================================
echo.
echo Now run: php qparkin_backend/artisan serve
echo Or press Ctrl+C to cancel
echo.
pause
php qparkin_backend/artisan serve

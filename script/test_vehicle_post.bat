@echo off
REM Quick test script for Vehicle POST 404 fix
REM Run this from project root

echo ========================================
echo Vehicle POST 404 Fix - Test Script
echo ========================================
echo.

echo [1/4] Clearing Laravel caches...
cd qparkin_backend
call php artisan cache:clear
call php artisan config:clear
call php artisan route:clear
call php artisan optimize:clear
echo ✓ Caches cleared
echo.

echo [2/4] Verifying routes...
call php artisan route:list | findstr "kendaraan"
echo.

echo [3/4] Checking Laravel logs...
echo Last 10 lines of laravel.log:
type storage\logs\laravel.log | more +10
echo.

cd ..

echo [4/4] Ready to test Flutter app
echo.
echo Next steps:
echo 1. Run: cd qparkin_app
echo 2. Run: flutter run --dart-define=API_URL=http://192.168.x.xx:8000/api
echo 3. Test add vehicle WITHOUT photo first
echo 4. Check console for debug logs
echo 5. Test add vehicle WITH photo
echo.
echo Expected console output:
echo   [VehicleApiService] POST URL: http://192.168.x.xx:8000/api/kendaraan
echo   [VehicleApiService] Response status: 201
echo.
echo ========================================
echo Press any key to exit...
pause >nul

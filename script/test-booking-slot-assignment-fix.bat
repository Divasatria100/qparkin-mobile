@echo off
echo ========================================
echo Testing Booking Slot Assignment Fix
echo ========================================
echo.

echo Step 1: Clear Laravel cache
cd qparkin_backend
call php artisan config:clear
call php artisan cache:clear
echo.

echo Step 2: Test booking API endpoint
echo Testing POST /api/booking with:
echo   - id_parkiran: 1
echo   - id_kendaraan: 2 (Roda Dua)
echo   - waktu_mulai: 2026-01-15T19:00:00
echo   - durasi_booking: 1
echo.

curl -X POST "http://192.168.0.101:8000/api/booking" ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE" ^
  -d "{\"id_parkiran\":1,\"id_kendaraan\":2,\"waktu_mulai\":\"2026-01-15T19:00:00\",\"durasi_booking\":1}"

echo.
echo.
echo Step 3: Check Laravel logs for slot assignment
echo Last 20 lines of log:
call php artisan tail -n 20 storage/logs/laravel.log 2>nul || type storage\logs\laravel.log | findstr /C:"Finding available slot" /C:"Found available slot" /C:"Created temporary reservation" /C:"Auto-assigned slot" /C:"Failed to create reservation"

echo.
echo ========================================
echo Test Complete
echo ========================================
echo.
echo Expected Results:
echo 1. Slot should be found (ID: 61, code: UTAMA-L1-001)
echo 2. Temporary reservation should be created successfully
echo 3. Booking should return 201 with booking data
echo.
echo If still failing, check:
echo - Backend server is restarted
echo - Token is valid
echo - Database has available slots
echo.

cd ..
pause

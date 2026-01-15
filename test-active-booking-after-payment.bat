@echo off
echo ========================================
echo Testing Active Booking After Payment
echo ========================================
echo.

REM Step 1: Login
echo Step 1: Login...
curl -X POST http://localhost:8000/api/auth/login ^
  -H "Content-Type: application/json" ^
  -H "Accept: application/json" ^
  -d "{\"email\":\"user@example.com\",\"password\":\"password123\"}" ^
  -o login_response.json
echo.

REM Extract token (you need to copy this manually)
echo Please copy the token from login_response.json
set /p TOKEN="Enter your auth token: "
echo.

REM Step 2: Check active booking
echo Step 2: Checking active booking...
curl -X GET http://localhost:8000/api/booking/active ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Accept: application/json"
echo.
echo.

echo ========================================
echo Test Complete
echo ========================================
echo.
echo If you see booking data above, the fix is working!
echo If you see "No active booking found", check:
echo   1. Payment status was updated successfully
echo   2. Booking status is 'aktif' in database
echo   3. Transaksi status is 'active' or 'booked'
echo.
pause

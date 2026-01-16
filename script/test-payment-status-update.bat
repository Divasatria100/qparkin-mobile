@echo off
echo ========================================
echo Testing Payment Status Update Endpoint
echo ========================================
echo.

REM Get auth token first
echo Step 1: Login to get auth token...
curl -X POST http://localhost:8000/api/auth/login ^
  -H "Content-Type: application/json" ^
  -H "Accept: application/json" ^
  -d "{\"email\":\"user@example.com\",\"password\":\"password123\"}" ^
  -o login_response.json
echo.

REM Extract token (manual step - copy token from login_response.json)
echo Please copy the token from login_response.json and set it below:
set /p TOKEN="Enter your auth token: "
echo.

REM Get booking ID
set /p BOOKING_ID="Enter booking ID to test: "
echo.

echo Step 2: Update payment status to PAID...
curl -X PUT http://localhost:8000/api/bookings/%BOOKING_ID%/payment/status ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -H "Accept: application/json" ^
  -d "{\"payment_status\":\"PAID\"}"
echo.
echo.

echo Step 3: Check active bookings...
curl -X GET http://localhost:8000/api/booking/active ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Accept: application/json"
echo.
echo.

echo ========================================
echo Test Complete
echo ========================================
pause

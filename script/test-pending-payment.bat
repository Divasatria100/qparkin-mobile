@echo off
echo ========================================
echo Testing Pending Payment Implementation
echo ========================================
echo.

REM Set your API URL and token here
set API_URL=http://localhost:8000
set TOKEN=YOUR_AUTH_TOKEN_HERE

echo Step 1: Testing GET pending payments endpoint
echo -----------------------------------------------
curl -X GET "%API_URL%/api/booking/pending-payments" ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Accept: application/json"
echo.
echo.

echo Step 2: Testing cancel booking endpoint (ID=1)
echo -----------------------------------------------
curl -X PUT "%API_URL%/api/booking/1/cancel" ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Accept: application/json"
echo.
echo.

echo ========================================
echo Test Complete
echo ========================================
echo.
echo Next steps:
echo 1. Check if pending payments are returned
echo 2. Check if cancel booking works
echo 3. Test in Flutter app
echo.
pause

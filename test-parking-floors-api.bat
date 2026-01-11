@echo off
echo Testing GET /api/parking/floors/4 endpoint...
echo.

REM Get auth token first
echo Step 1: Getting auth token...
curl -X POST http://192.168.0.101:8000/api/login ^
  -H "Content-Type: application/json" ^
  -H "Accept: application/json" ^
  -d "{\"email\":\"user@example.com\",\"password\":\"password123\"}" ^
  -c cookies.txt ^
  -s > login_response.json

echo.
type login_response.json
echo.

REM Extract token (manual for now - check the response)
echo.
echo Step 2: Testing parking floors endpoint...
echo Please copy the token from above and test manually with:
echo.
echo curl -X GET http://192.168.0.101:8000/api/parking/floors/4 ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE" ^
  -H "Accept: application/json"
echo.

pause

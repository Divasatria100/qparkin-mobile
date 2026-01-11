@echo off
echo ========================================
echo Testing Mall API Endpoint
echo ========================================
echo.

REM Test 1: GET /api/mall (requires auth token)
echo [TEST 1] GET /api/mall - List all active malls
echo.
echo Please provide your auth token:
set /p TOKEN="Enter token: "
echo.

curl -X GET "http://localhost:8000/api/mall" ^
  -H "Accept: application/json" ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json"

echo.
echo.
echo ========================================
echo Test completed!
echo ========================================
pause

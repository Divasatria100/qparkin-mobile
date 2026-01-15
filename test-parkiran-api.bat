@echo off
echo ========================================
echo Testing Parkiran API Endpoints
echo ========================================
echo.

REM Get auth token first
echo [1/5] Getting auth token...
curl -X POST http://192.168.0.101:8000/api/login ^
  -H "Content-Type: application/json" ^
  -H "Accept: application/json" ^
  -d "{\"email\":\"user@example.com\",\"password\":\"password123\"}" ^
  -o token_response.json 2>nul

REM Extract token (simple method for Windows)
for /f "tokens=2 delims=:," %%a in ('type token_response.json ^| findstr "token"') do set TOKEN=%%a
set TOKEN=%TOKEN:"=%
set TOKEN=%TOKEN: =%

echo Token obtained: %TOKEN:~0,20%...
echo.

echo [2/5] Testing Mall 1 (Mega Mall Batam Centre)...
curl -X GET "http://192.168.0.101:8000/api/mall/1/parkiran" ^
  -H "Accept: application/json" ^
  -H "Authorization: Bearer %TOKEN%"
echo.
echo.

echo [3/5] Testing Mall 2 (One Batam Mall)...
curl -X GET "http://192.168.0.101:8000/api/mall/2/parkiran" ^
  -H "Accept: application/json" ^
  -H "Authorization: Bearer %TOKEN%"
echo.
echo.

echo [4/5] Testing Mall 3 (SNL Food Bengkong)...
curl -X GET "http://192.168.0.101:8000/api/mall/3/parkiran" ^
  -H "Accept: application/json" ^
  -H "Authorization: Bearer %TOKEN%"
echo.
echo.

echo [5/5] Testing Mall 4 (Panbil Mall)...
curl -X GET "http://192.168.0.101:8000/api/mall/4/parkiran" ^
  -H "Accept: application/json" ^
  -H "Authorization: Bearer %TOKEN%"
echo.
echo.

REM Cleanup
del token_response.json 2>nul

echo ========================================
echo Test Complete!
echo ========================================
echo.
echo All malls should now return parkiran data.
echo If you see empty data arrays, run:
echo   cd qparkin_backend
echo   php create_missing_parkiran.php
echo.
pause

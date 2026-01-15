@echo off
echo ========================================
echo Testing Panbil Mall Parkiran API
echo ========================================
echo.

REM Get auth token first
echo [1/2] Getting auth token...
curl -X POST http://192.168.0.101:8000/api/login ^
  -H "Content-Type: application/json" ^
  -H "Accept: application/json" ^
  -d "{\"email\":\"qparkin@example.com\",\"password\":\"password\"}" ^
  -o token_response.json 2>nul

REM Extract token
for /f "tokens=2 delims=:," %%a in ('type token_response.json ^| findstr "token"') do set TOKEN=%%a
set TOKEN=%TOKEN:"=%
set TOKEN=%TOKEN: =%

echo Token obtained: %TOKEN:~0,20%...
echo.

echo [2/2] Testing Panbil Mall (ID: 4) Parkiran...
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
pause

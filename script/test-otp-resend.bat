@echo off
echo ========================================
echo QParkin OTP Resend Testing Script
echo ========================================
echo.

set API_URL=http://localhost:8000/api/auth

echo [1/2] Testing Register (Send OTP)...
echo.
curl -X POST %API_URL%/register ^
  -H "Content-Type: application/json" ^
  -H "Accept: application/json" ^
  -d "{\"nama\":\"Resend Test\",\"nomor_hp\":\"082345678901\",\"pin\":\"654321\"}"
echo.
echo.

echo Tunggu 5 detik...
timeout /t 5 /nobreak >nul
echo.

echo [2/2] Testing Resend OTP...
echo.
curl -X POST %API_URL%/resend-otp ^
  -H "Content-Type: application/json" ^
  -H "Accept: application/json" ^
  -d "{\"nomor_hp\":\"082345678901\"}"
echo.
echo.

echo ========================================
echo Cek Mailtrap untuk OTP baru!
echo Email: 082345678901@qparkin.test
echo ========================================
pause

@echo off
echo ========================================
echo QParkin OTP Registration Testing Script
echo ========================================
echo.

set API_URL=http://localhost:8000/api/auth

echo [1/3] Testing Register (Send OTP)...
echo.
curl -X POST %API_URL%/register ^
  -H "Content-Type: application/json" ^
  -H "Accept: application/json" ^
  -d "{\"nama\":\"Test User\",\"nomor_hp\":\"081234567890\",\"pin\":\"123456\"}"
echo.
echo.

echo ========================================
echo.
echo Silakan cek Mailtrap untuk mendapatkan kode OTP
echo Email: 081234567890@qparkin.test
echo.
set /p OTP_CODE="Masukkan kode OTP (6 digit): "
echo.

echo [2/3] Testing Verify OTP...
echo.
curl -X POST %API_URL%/verify-otp ^
  -H "Content-Type: application/json" ^
  -H "Accept: application/json" ^
  -d "{\"nomor_hp\":\"081234567890\",\"otp_code\":\"%OTP_CODE%\"}"
echo.
echo.

echo [3/3] Testing Login with new account...
echo.
curl -X POST %API_URL%/login ^
  -H "Content-Type: application/json" ^
  -H "Accept: application/json" ^
  -d "{\"nomor_hp\":\"081234567890\",\"pin\":\"123456\"}"
echo.
echo.

echo ========================================
echo Testing Complete!
echo ========================================
pause

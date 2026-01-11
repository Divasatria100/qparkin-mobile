@echo off
REM Test script for booking parkiran ID fix
REM Tests the complete booking flow with parkiran ID fetching

echo ========================================
echo Testing Booking Parkiran ID Fix
echo ========================================
echo.

REM Test 1: Check if parkiran endpoint exists
echo [TEST 1] Testing parkiran endpoint...
curl -X GET "http://192.168.0.101:8000/api/mall/4/parkiran" ^
  -H "Accept: application/json" ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
echo.
echo.

REM Test 2: Verify booking with correct id_parkiran
echo [TEST 2] Testing booking creation with id_parkiran...
curl -X POST "http://192.168.0.101:8000/api/booking" ^
  -H "Accept: application/json" ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE" ^
  -d "{\"id_parkiran\":1,\"id_kendaraan\":2,\"waktu_mulai\":\"2026-01-12T10:00:00\",\"durasi_booking\":2}"
echo.
echo.

echo ========================================
echo Test Instructions:
echo ========================================
echo 1. Replace YOUR_TOKEN_HERE with actual auth token
echo 2. Update IP address if different (currently 192.168.0.101)
echo 3. Update mall ID (currently 4) and vehicle ID (currently 2)
echo 4. Check response for success: true
echo.
echo Expected Response for Test 1:
echo {
echo   "success": true,
echo   "data": [
echo     {
echo       "id_parkiran": 1,
echo       "nama_parkiran": "Parkiran Utama",
echo       ...
echo     }
echo   ]
echo }
echo.
echo Expected Response for Test 2:
echo {
echo   "success": true,
echo   "message": "Booking berhasil dibuat",
echo   "data": { ... }
echo }
echo.
pause

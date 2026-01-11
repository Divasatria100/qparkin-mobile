@echo off
echo ========================================
echo Testing Parkiran Fetch for Booking
echo ========================================
echo.

REM Test 1: Check if mall has parkiran in database
echo [TEST 1] Checking database for parkiran...
echo.
curl -X GET "http://192.168.0.101:8000/api/mall/4/parkiran" ^
  -H "Accept: application/json" ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
echo.
echo.

REM Test 2: Check mall details (includes parkiran)
echo [TEST 2] Checking mall details...
echo.
curl -X GET "http://192.168.0.101:8000/api/mall/4" ^
  -H "Accept: application/json" ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
echo.
echo.

REM Test 3: Check parkiran table directly
echo [TEST 3] Checking parkiran table in database...
echo Run this SQL query in your database:
echo SELECT * FROM parkiran WHERE id_mall = 4;
echo.

echo ========================================
echo INSTRUCTIONS:
echo ========================================
echo 1. Replace YOUR_TOKEN_HERE with actual auth token
echo 2. Check if parkiran exists for mall id_mall=4
echo 3. Verify id_parkiran field is present in response
echo 4. If no parkiran found, create one via admin dashboard
echo.
echo Expected Response Format:
echo {
echo   "success": true,
echo   "message": "Parking areas retrieved successfully",
echo   "data": [
echo     {
echo       "id_parkiran": 1,
echo       "nama_parkiran": "Parkiran Mall A",
echo       "lantai": 3,
echo       "kapasitas": 100,
echo       "status": "Tersedia"
echo     }
echo   ]
echo }
echo.
pause

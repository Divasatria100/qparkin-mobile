@echo off
echo ========================================
echo Testing Tarif Integration
echo ========================================
echo.

REM Test 1: Check Mall API includes tarif
echo [TEST 1] Testing Mall API with Tarif
echo.
curl -X GET "http://192.168.0.101:8000/api/mall" ^
  -H "Accept: application/json" ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE" | jq ".data[0].tarif"
echo.
echo.

REM Test 2: Check specific mall tarif
echo [TEST 2] Testing Specific Mall Tarif
echo.
curl -X GET "http://192.168.0.101:8000/api/mall/1" ^
  -H "Accept: application/json" ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE" | jq ".data.tarif"
echo.
echo.

REM Test 3: Check tarif endpoint
echo [TEST 3] Testing Tarif Endpoint
echo.
curl -X GET "http://192.168.0.101:8000/api/mall/1/tarif" ^
  -H "Accept: application/json" ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
echo.
echo.

echo ========================================
echo EXPECTED RESPONSE FORMAT:
echo ========================================
echo {
echo   "success": true,
echo   "data": [
echo     {
echo       "id_mall": 1,
echo       "nama_mall": "Grand Mall",
echo       "tarif": [
echo         {
echo           "jenis_kendaraan": "Roda Dua",
echo           "satu_jam_pertama": 2000.0,
echo           "tarif_parkir_per_jam": 1000.0
echo         },
echo         {
echo           "jenis_kendaraan": "Roda Empat",
echo           "satu_jam_pertama": 5000.0,
echo           "tarif_parkir_per_jam": 3000.0
echo         }
echo       ]
echo     }
echo   ]
echo }
echo.
echo ========================================
echo INSTRUCTIONS:
echo ========================================
echo 1. Replace YOUR_TOKEN_HERE with actual auth token
echo 2. Verify tarif array is present in response
echo 3. Check all 4 vehicle types have tarif
echo 4. Run Flutter app and test booking
echo.
pause

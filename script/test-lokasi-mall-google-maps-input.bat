@echo off
echo ========================================
echo Testing Lokasi Mall - Google Maps Input
echo ========================================
echo.

echo Test Scenarios:
echo.
echo 1. VALID COORDINATES (should work):
echo    - "1.072020040894358, 104.02393750738969"
echo    - "-6.2088, 106.8456"
echo    - "0, 0"
echo    - "1.072020 , 104.023938" (extra spaces)
echo.
echo 2. INVALID COORDINATES (should show error):
echo    - "1.072020" (missing longitude)
echo    - "1.072020 104.023938" (no comma)
echo    - "abc, def" (not numbers)
echo    - "91, 104" (latitude out of range)
echo    - "1, 181" (longitude out of range)
echo.
echo 3. MANUAL INPUT TEST:
echo    - Type latitude in Latitude field
echo    - Type longitude in Longitude field
echo    - Press Enter or click outside
echo    - Map should update automatically
echo.
echo 4. INTEGRATION TEST:
echo    - Use Google Maps input
echo    - Click on map
echo    - Use manual input
echo    - Use geolocation
echo    - All should sync properly
echo.
echo 5. SAVE TEST:
echo    - Set coordinates using any method
echo    - Click "Simpan Lokasi"
echo    - Should save successfully
echo.

echo Opening browser...
echo URL: http://localhost:8000/admin/lokasi-mall
echo.

start http://localhost:8000/admin/lokasi-mall

echo.
echo ========================================
echo Test Checklist:
echo ========================================
echo [ ] Google Maps input accepts paste
echo [ ] "Gunakan" button parses coordinates
echo [ ] Map flies to new location
echo [ ] Marker appears at correct position
echo [ ] Latitude/Longitude inputs update
echo [ ] Error messages show for invalid input
echo [ ] Manual input updates map
echo [ ] All methods work together
echo [ ] Save button works
echo [ ] Success feedback shows
echo ========================================
echo.
pause

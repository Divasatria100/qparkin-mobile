@echo off
echo ========================================
echo Testing Vehicle Type Per Floor Implementation
echo ========================================
echo.

echo Step 1: Testing Floors API
echo --------------------------
curl -X GET "http://192.168.0.101:8000/api/parking/floors/4" ^
     -H "Accept: application/json"
echo.
echo.

echo Step 2: Check Database Schema
echo ------------------------------
echo Run this SQL manually:
echo DESCRIBE parking_floors;
echo DESCRIBE parkiran;
echo.

echo Step 3: Check Existing Data
echo ----------------------------
echo Run this SQL manually:
echo SELECT pf.id_floor, pf.floor_name, pf.jenis_kendaraan, pf.total_slots
echo FROM parking_floors pf
echo WHERE pf.id_parkiran IN (SELECT id_parkiran FROM parkiran WHERE id_mall = 4);
echo.

pause

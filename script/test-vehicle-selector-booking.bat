@echo off
echo ========================================
echo Vehicle Selector Booking Page Test
echo ========================================
echo.

echo [1/3] Testing Vehicle API Endpoint...
curl -X GET "http://192.168.0.101:8000/api/kendaraan" ^
  -H "Accept: application/json" ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
echo.
echo.

echo [2/3] Checking booking_page.dart imports...
findstr /C:"vehicle_api_service" qparkin_app\lib\presentation\screens\booking_page.dart
echo.

echo [3/3] Checking vehicle_selector.dart imports...
findstr /C:"vehicle_api_service" qparkin_app\lib\presentation\widgets\vehicle_selector.dart
echo.

echo ========================================
echo Test Complete!
echo ========================================
echo.
echo Next Steps:
echo 1. Hot restart Flutter app (press 'r' in terminal)
echo 2. Navigate to booking page
echo 3. Check if vehicle selector loads data
echo 4. Verify debug logs show:
echo    [VehicleSelector] Fetching vehicles from API...
echo    [VehicleApiService] Response status: 200
echo    [VehicleSelector] Vehicles fetched successfully: X vehicles
echo.
pause

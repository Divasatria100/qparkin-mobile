@echo off
echo ========================================
echo Cleanup Incomplete Booking
echo ========================================
echo.
echo This script will clean up incomplete bookings
echo that are blocking new booking creation.
echo.

set /p VEHICLE_ID="Enter Vehicle ID (e.g., 2): "

if "%VEHICLE_ID%"=="" (
    echo Error: Vehicle ID is required
    pause
    exit /b 1
)

echo.
echo Cleaning up incomplete bookings for vehicle ID %VEHICLE_ID%...
echo.

cd qparkin_backend
php cleanup_incomplete_booking.php %VEHICLE_ID%

echo.
pause

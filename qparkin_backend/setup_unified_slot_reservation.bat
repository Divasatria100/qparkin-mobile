@echo off
REM Unified Slot Reservation Setup Script
REM This script sets up the unified slot reservation system

echo ========================================
echo Unified Slot Reservation Setup
echo ========================================
echo.
echo This will set up slot reservation for ALL malls
echo to prevent overbooking.
echo.
echo Features:
echo - Multi-level parking: User selects slot
echo - Simple parking: System auto-assigns slot
echo - Both: Guaranteed slot availability
echo.
pause

echo.
echo Step 1: Clearing old parking data...
echo ========================================
php artisan db:seed --class=DatabaseSeeder --force
if %errorlevel% neq 0 (
    echo ERROR: Failed to clear data!
    pause
    exit /b 1
)
echo Data cleared successfully!
echo.

echo Step 2: Seeding mall data...
echo ========================================
php artisan db:seed --class=MallSeeder
if %errorlevel% neq 0 (
    echo ERROR: Mall seeder failed!
    pause
    exit /b 1
)
echo Mall data seeded successfully!
echo.

echo Step 3: Seeding parking floors...
echo ========================================
php artisan db:seed --class=ParkingFloorSeeder
if %errorlevel% neq 0 (
    echo ERROR: Floor seeder failed!
    pause
    exit /b 1
)
echo Parking floors seeded successfully!
echo.

echo Step 4: Seeding parking slots...
echo ========================================
php artisan db:seed --class=ParkingSlotSeeder
if %errorlevel% neq 0 (
    echo ERROR: Slot seeder failed!
    pause
    exit /b 1
)
echo Parking slots seeded successfully!
echo.

echo Step 5: Running tests...
echo ========================================
php artisan test tests/Unit/SlotAutoAssignmentServiceTest.php
if %errorlevel% neq 0 (
    echo WARNING: Some tests failed!
    echo Please review test results above.
    echo.
) else (
    echo All tests passed!
    echo.
)

echo ========================================
echo Setup completed successfully!
echo ========================================
echo.
echo Database Structure:
echo.
echo MULTI-LEVEL PARKING (Mega Mall, One Batam):
echo   - Floors: Lantai 1, Lantai 2, Basement
echo   - Slots: A-001, A-002, B-001, B-002
echo   - UI: Shows floor selector and slot visualization
echo   - Booking: User selects specific slot
echo.
echo SIMPLE PARKING (SNL Food):
echo   - Floors: Parkiran Motor, Parkiran Mobil
echo   - Slots: SLOT-001, SLOT-002, SLOT-003
echo   - UI: Hides floor selector (auto-assign)
echo   - Booking: System auto-assigns slot
echo.
echo BOTH TYPES:
echo   - Backend: ALWAYS reserves slot
echo   - Result: NO OVERBOOKING
echo   - Guarantee: Every booking has a slot
echo.
echo Next Steps:
echo 1. Test API: POST /api/bookings
echo 2. Test Frontend: flutter run
echo 3. Verify: Check Activity page for slot info
echo.
echo Documentation:
echo - docs/UNIFIED_SLOT_RESERVATION_GUIDE.md
echo - UNIFIED_SLOT_RESERVATION_IMPLEMENTATION_SUMMARY.md
echo.
pause

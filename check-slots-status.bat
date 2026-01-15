@echo off
echo ========================================
echo Check Parking Slots Status
echo ========================================
echo.

cd qparkin_backend
php check_slots_status.php %1

cd ..
pause

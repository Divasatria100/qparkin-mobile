@echo off
echo ========================================
echo Running Biaya Estimasi Migration
echo ========================================
echo.

cd qparkin_backend

echo Step 1: Running migration...
php artisan migrate --path=database/migrations/2025_01_15_000002_add_biaya_estimasi_to_booking.php
if %errorlevel% neq 0 (
    echo.
    echo Migration failed! Trying SQL file...
    echo.
    mysql -u root -p qparkin_db < add_biaya_estimasi_column.sql
)

echo.
echo ========================================
echo Migration Complete!
echo ========================================
echo.
echo The biaya_estimasi column has been added to the booking table.
echo Now booking costs will be calculated automatically from tarif parkir.
echo.
pause

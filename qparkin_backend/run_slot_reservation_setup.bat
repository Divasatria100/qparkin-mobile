@echo off
REM Slot Reservation Feature Setup Script
REM This script runs migrations and seeders for slot reservation feature

echo ========================================
echo Slot Reservation Feature Setup
echo ========================================
echo.

echo Step 1: Running migrations...
php artisan migrate --path=database/migrations/2025_12_05_100005_add_slot_reservation_feature_flag_to_mall_table.php
if %errorlevel% neq 0 (
    echo ERROR: Migration failed!
    pause
    exit /b 1
)
echo Migration completed successfully!
echo.

echo Step 2: Running mall seeder...
php artisan db:seed --class=MallSeeder
if %errorlevel% neq 0 (
    echo ERROR: Seeder failed!
    pause
    exit /b 1
)
echo Seeder completed successfully!
echo.

echo ========================================
echo Setup completed successfully!
echo ========================================
echo.
echo Mall data with slot reservation feature flag has been seeded.
echo.
echo Malls with slot reservation ENABLED:
echo - Mega Mall Batam Centre
echo - One Batam Mall
echo.
echo Malls with slot reservation DISABLED:
echo - SNL Food Bengkong (for testing gradual rollout)
echo.
pause

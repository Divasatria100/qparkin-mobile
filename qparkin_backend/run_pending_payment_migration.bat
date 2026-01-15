@echo off
echo ========================================
echo Adding pending_payment status to booking table
echo ========================================
echo.

REM Set your MySQL credentials here
set DB_HOST=localhost
set DB_PORT=3306
set DB_NAME=qparkin
set DB_USER=root
set DB_PASS=

echo Running SQL query...
echo.

mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASS% %DB_NAME% < add_pending_payment_status.sql

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo SUCCESS: Status 'pending_payment' added!
    echo ========================================
    echo.
    echo Now marking migration as complete...
    php artisan migrate --pretend
    echo.
    echo To mark as complete in migrations table, run:
    echo INSERT INTO migrations (migration, batch^) VALUES ('2025_01_15_000001_add_pending_payment_status_to_booking', 5^);
) else (
    echo.
    echo ========================================
    echo ERROR: Failed to add status
    echo ========================================
)

echo.
pause

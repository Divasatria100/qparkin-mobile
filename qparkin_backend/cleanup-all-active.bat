@echo off
echo ========================================
echo Cleanup All Active Transactions
echo ========================================
echo.
echo This will delete ALL active transactions!
echo.

cd /d "%~dp0"
php cleanup_all_active.php

pause

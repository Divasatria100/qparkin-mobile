@echo off
echo ========================================
echo Check Active Transactions
echo ========================================
echo.
echo This script shows all active transactions
echo and bookings in the system.
echo.

cd qparkin_backend
php check_active_transactions.php

echo.
pause

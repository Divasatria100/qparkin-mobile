@echo off
echo ========================================
echo Testing Lokasi Mall Feature
echo ========================================
echo.

echo [1] Checking database structure...
php qparkin_backend/artisan db:show --table=mall

echo.
echo [2] Checking if latitude and longitude columns exist...
php qparkin_backend/artisan tinker --execute="echo 'Columns: ' . implode(', ', Schema::getColumnListing('mall'));"

echo.
echo [3] Testing route accessibility...
echo Visit: http://localhost:8000/admin/lokasi-mall
echo.

echo [4] Sample SQL to check data:
echo SELECT id_mall, nama_mall, latitude, longitude FROM mall;
echo.

echo ========================================
echo Test completed!
echo ========================================
pause

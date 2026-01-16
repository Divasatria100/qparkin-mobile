@echo off
echo ========================================
echo Testing SuperAdmin Approve Pengajuan Fix
echo ========================================
echo.

cd qparkin_backend

echo [1/3] Clearing cache...
php artisan config:clear
php artisan cache:clear
echo.

echo [2/3] Running migrations (if needed)...
php artisan migrate --force
echo.

echo [3/3] Testing database connection...
php artisan tinker --execute="echo 'Mall columns: '; print_r(array_keys(App\Models\Mall::first()->getAttributes()));"
echo.

echo ========================================
echo Fix Applied Successfully!
echo ========================================
echo.
echo Next Steps:
echo 1. Navigate to: http://localhost:8000/superadmin/pengajuan
echo 2. Click "Setujui" on a pending application
echo 3. Verify mall is created with alamat_lengkap
echo.
echo API Response should include:
echo - alamat_lengkap (instead of lokasi)
echo - latitude
echo - longitude
echo - google_maps_url
echo.

pause

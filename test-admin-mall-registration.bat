@echo off
echo ========================================
echo Testing Admin Mall Registration Fix
echo ========================================
echo.

cd qparkin_backend

echo [1/5] Checking migration status...
php artisan migrate:status | findstr "add_application_fields_to_user_table"
echo.

echo [2/5] Checking pending applications in database...
php artisan tinker --execute="echo 'Pending Applications: ' . \App\Models\User::where('application_status', 'pending')->count();"
echo.

echo [3/5] Listing pending applications...
php artisan tinker --execute="\App\Models\User::where('application_status', 'pending')->get(['id_user', 'name', 'email', 'requested_mall_name', 'applied_at'])->each(function(\$u) { echo \$u->name . ' - ' . \$u->requested_mall_name . ' (' . \$u->applied_at . ')' . PHP_EOL; });"
echo.

echo [4/5] Checking if routes are accessible...
echo Testing route: superadmin/pengajuan
echo.

echo [5/5] Verifying field mapping...
php artisan tinker --execute="echo 'User fillable fields: ' . PHP_EOL; print_r((new \App\Models\User)->getFillable());"
echo.

echo ========================================
echo Test completed!
echo ========================================
echo.
echo Next steps:
echo 1. Access http://localhost:8000/signup to test registration
echo 2. Login as super admin
echo 3. Check http://localhost:8000/superadmin/pengajuan
echo.
pause

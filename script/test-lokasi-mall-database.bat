@echo off
echo ========================================
echo Testing Lokasi Mall - Database Backend
echo ========================================
echo.

echo Step 1: Check Database Migration
echo ---------------------------------
cd qparkin_backend
php artisan migrate:status | findstr "add_location_coordinates_to_mall_table"
echo.

echo Step 2: Check Database Schema
echo ------------------------------
echo Checking if latitude and longitude columns exist...
php artisan tinker --execute="echo Schema::hasColumn('mall', 'latitude') ? 'latitude: EXISTS' : 'latitude: NOT FOUND'; echo PHP_EOL; echo Schema::hasColumn('mall', 'longitude') ? 'longitude: EXISTS' : 'longitude: NOT FOUND';"
echo.

echo Step 3: Check Model Configuration
echo ----------------------------------
echo Checking Mall model fillable and casts...
php artisan tinker --execute="$mall = new App\Models\Mall(); echo 'Fillable: '; print_r($mall->getFillable()); echo PHP_EOL; echo 'Casts: '; print_r($mall->getCasts());"
echo.

echo Step 4: Check Routes
echo --------------------
php artisan route:list --name=lokasi-mall
echo.

echo Step 5: Test Database Query
echo ---------------------------
echo Fetching mall data with coordinates...
php artisan tinker --execute="$mall = App\Models\Mall::first(); if($mall) { echo 'Mall: ' . $mall->nama_mall . PHP_EOL; echo 'Latitude: ' . ($mall->latitude ?? 'NULL') . PHP_EOL; echo 'Longitude: ' . ($mall->longitude ?? 'NULL') . PHP_EOL; echo 'Has Valid Coords: ' . ($mall->hasValidCoordinates() ? 'YES' : 'NO') . PHP_EOL; } else { echo 'No mall found in database' . PHP_EOL; }"
echo.

echo Step 6: Test Validation
echo -----------------------
echo Testing coordinate validation...
echo Valid coordinates: -6.2088, 106.8456
echo Invalid latitude: 91 (should fail)
echo Invalid longitude: 181 (should fail)
echo.

cd ..

echo ========================================
echo Manual Testing Instructions:
echo ========================================
echo.
echo 1. Open browser: http://localhost:8000/admin/lokasi-mall
echo 2. Login as admin mall
echo 3. Paste coordinates: "1.072020, 104.023938"
echo 4. Click "Gunakan"
echo 5. Click "Simpan Lokasi"
echo 6. Check database:
echo    SELECT id_mall, nama_mall, latitude, longitude, updated_at FROM mall;
echo.
echo 7. Verify precision (should have 8 decimal places):
echo    SELECT CHAR_LENGTH(CAST(latitude AS CHAR)) as lat_length FROM mall;
echo.

echo ========================================
echo Database Checklist:
echo ========================================
echo [ ] Migration executed
echo [ ] Columns exist (latitude, longitude)
echo [ ] Precision correct (DECIMAL 10,8 and 11,8)
echo [ ] Model fillable includes coordinates
echo [ ] Model casts to decimal:8
echo [ ] Routes registered
echo [ ] Controller method works
echo [ ] Validation rules applied
echo [ ] CSRF protection enabled
echo [ ] Authorization middleware active
echo ========================================
echo.
pause

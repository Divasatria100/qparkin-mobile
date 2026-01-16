@echo off
echo ========================================
echo Vehicle Type Per Floor - Complete Test
echo ========================================
echo.

echo [1/5] Testing Database Schema...
echo.
php -r "require 'qparkin_backend/vendor/autoload.php'; $app = require_once 'qparkin_backend/bootstrap/app.php'; $kernel = $app->make(Illuminate\Contracts\Console\Kernel::class); $kernel->bootstrap(); $pdo = DB::connection()->getPdo(); echo 'Connected to database: ' . $pdo->getAttribute(PDO::ATTR_CONNECTION_STATUS) . PHP_EOL; $stmt = $pdo->query('DESCRIBE parking_floors'); echo PHP_EOL . 'parking_floors columns:' . PHP_EOL; while($row = $stmt->fetch(PDO::FETCH_ASSOC)) { if($row['Field'] == 'jenis_kendaraan') echo '  ✓ ' . $row['Field'] . ' (' . $row['Type'] . ')' . PHP_EOL; } $stmt = $pdo->query('DESCRIBE parkiran'); echo PHP_EOL . 'parkiran columns (should NOT have jenis_kendaraan):' . PHP_EOL; $found = false; while($row = $stmt->fetch(PDO::FETCH_ASSOC)) { if($row['Field'] == 'jenis_kendaraan') { echo '  ✗ jenis_kendaraan still exists!' . PHP_EOL; $found = true; } } if(!$found) echo '  ✓ jenis_kendaraan removed successfully' . PHP_EOL;"
echo.

echo [2/5] Testing API Endpoint - Get Floors...
echo.
curl -X GET "http://192.168.0.101:8000/api/parking/floors/4" ^
  -H "Accept: application/json" ^
  -H "Content-Type: application/json"
echo.
echo.

echo [3/5] Testing Create Parkiran with Mixed Vehicle Types...
echo.
echo Creating test parkiran with:
echo   - Lantai 1: Roda Dua (Motor)
echo   - Lantai 2: Roda Empat (Mobil)
echo   - Lantai 3: Roda Empat (Mobil)
echo.
echo NOTE: This requires admin authentication. Run manually via browser if needed.
echo.

echo [4/5] Checking Flutter Model...
echo.
findstr /C:"jenisKendaraan" qparkin_app\lib\data\models\parking_floor_model.dart
echo.

echo [5/5] Checking BookingProvider Implementation...
echo.
findstr /C:"loadFloorsForVehicle" qparkin_app\lib\logic\providers\booking_provider.dart
echo.

echo ========================================
echo Test Complete!
echo ========================================
echo.
echo Next Steps:
echo 1. Run migrations: cd qparkin_backend ^&^& php artisan migrate
echo 2. Create test parkiran via admin dashboard
echo 3. Test mobile app with different vehicle types
echo.
pause

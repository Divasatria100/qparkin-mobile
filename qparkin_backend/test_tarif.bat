@echo off
echo ========================================
echo Testing Fitur Tarif Parkir
echo ========================================
echo.

echo [1] Checking tarif data in database...
php artisan tinker --execute="echo 'Total Tarif: ' . App\Models\TarifParkir::count();"
echo.

echo [2] Listing all tarif...
php artisan tinker --execute="App\Models\TarifParkir::all()->each(function($t) { echo $t->jenis_kendaraan . ' (Mall ' . $t->id_mall . '): Rp ' . number_format($t->satu_jam_pertama, 0) . ' / Rp ' . number_format($t->tarif_parkir_per_jam, 0) . PHP_EOL; });"
echo.

echo [3] Checking routes...
php artisan route:list --name=tarif
echo.

echo ========================================
echo Test completed!
echo ========================================
pause

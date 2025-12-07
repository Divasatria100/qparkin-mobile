@echo off
echo ========================================
echo Testing Fitur Riwayat Tarif
echo ========================================
echo.

echo [1] Checking riwayat_tarif table...
php artisan tinker --execute="echo Schema::hasTable('riwayat_tarif') ? 'Table EXISTS' : 'Table NOT FOUND';"
echo.

echo [2] Counting riwayat records...
php artisan tinker --execute="echo 'Total Riwayat: ' . App\Models\RiwayatTarif::count();"
echo.

echo [3] Simulating tarif update (creating test riwayat)...
php artisan tinker --execute="$tarif = App\Models\TarifParkir::first(); if($tarif) { App\Models\RiwayatTarif::create(['id_tarif' => $tarif->id_tarif, 'id_mall' => $tarif->id_mall, 'id_user' => 1, 'jenis_kendaraan' => $tarif->jenis_kendaraan, 'tarif_lama_jam_pertama' => $tarif->satu_jam_pertama, 'tarif_lama_per_jam' => $tarif->tarif_parkir_per_jam, 'tarif_baru_jam_pertama' => $tarif->satu_jam_pertama + 1000, 'tarif_baru_per_jam' => $tarif->tarif_parkir_per_jam + 500, 'keterangan' => 'Test perubahan tarif']); echo 'Test riwayat created!'; } else { echo 'No tarif found'; }"
echo.

echo [4] Listing riwayat records...
php artisan tinker --execute="App\Models\RiwayatTarif::latest()->take(5)->get()->each(function($r) { echo $r->jenis_kendaraan . ' - ' . $r->created_at->format('d M Y H:i') . ' - Lama: Rp' . number_format($r->tarif_lama_jam_pertama, 0) . ' -> Baru: Rp' . number_format($r->tarif_baru_jam_pertama, 0) . PHP_EOL; });"
echo.

echo ========================================
echo Test completed!
echo ========================================
echo.
echo Now you can:
echo 1. Login to admin panel
echo 2. Go to Tarif menu
echo 3. Edit any tarif
echo 4. Check the Riwayat Perubahan Tarif table
echo.
pause

<?php

/**
 * Script untuk mengecek data tarif di database
 * 
 * Usage: php test_tarif_data.php
 */

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\Mall;
use App\Models\TarifParkir;
use App\Models\AdminMall;

echo "========================================\n";
echo "Checking Tarif Data in Database\n";
echo "========================================\n\n";

// Get all active malls
$malls = Mall::where('status', 'active')->get();

echo "Found " . $malls->count() . " active malls\n\n";

$jenisKendaraan = ['Roda Dua', 'Roda Tiga', 'Roda Empat', 'Lebih dari Enam'];

foreach ($malls as $mall) {
    echo "Mall: {$mall->nama_mall} (ID: {$mall->id_mall})\n";
    echo str_repeat("-", 60) . "\n";
    
    $tarifs = TarifParkir::where('id_mall', $mall->id_mall)
        ->orderBy('jenis_kendaraan')
        ->get();
    
    if ($tarifs->count() === 0) {
        echo "  ❌ NO TARIF DATA FOUND!\n";
        echo "  → Run: php check_and_create_tarif.php\n\n";
        continue;
    }
    
    echo "  Found " . $tarifs->count() . " tarif(s):\n\n";
    
    foreach ($jenisKendaraan as $jenis) {
        $tarif = $tarifs->firstWhere('jenis_kendaraan', $jenis);
        
        if ($tarif) {
            echo "  ✅ {$jenis}\n";
            echo "     ID: {$tarif->id_tarif}\n";
            echo "     Jam 1: Rp " . number_format($tarif->satu_jam_pertama, 0, ',', '.') . "\n";
            echo "     Per Jam: Rp " . number_format($tarif->tarif_parkir_per_jam, 0, ',', '.') . "\n";
            echo "     Edit URL: /admin/tarif/{$tarif->id_tarif}/edit\n\n";
        } else {
            echo "  ❌ {$jenis} - MISSING!\n\n";
        }
    }
    
    echo "\n";
}

echo "========================================\n";
echo "Summary\n";
echo "========================================\n";

$totalTarifs = TarifParkir::count();
$expectedTarifs = $malls->count() * 4; // 4 vehicle types per mall

echo "Total tarifs in database: {$totalTarifs}\n";
echo "Expected tarifs: {$expectedTarifs} ({$malls->count()} malls × 4 types)\n";

if ($totalTarifs < $expectedTarifs) {
    echo "\n⚠️  WARNING: Missing " . ($expectedTarifs - $totalTarifs) . " tarif(s)\n";
    echo "→ Run: php check_and_create_tarif.php\n";
} else {
    echo "\n✅ All tarifs are present!\n";
}

echo "\n";

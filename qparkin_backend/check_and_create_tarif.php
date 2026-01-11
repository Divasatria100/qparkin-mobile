<?php

/**
 * Script untuk mengecek dan membuat tarif parkir jika belum ada
 * 
 * Usage: php check_and_create_tarif.php
 */

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\Mall;
use App\Models\TarifParkir;

echo "========================================\n";
echo "Checking and Creating Tarif Parkir\n";
echo "========================================\n\n";

// Get all active malls
$malls = Mall::where('status', 'active')->get();

echo "Found " . $malls->count() . " active malls\n\n";

$jenisKendaraan = ['Roda Dua', 'Roda Tiga', 'Roda Empat', 'Lebih dari Enam'];
$defaultTarif = [
    'Roda Dua' => ['satu_jam_pertama' => 2000, 'tarif_parkir_per_jam' => 1000],
    'Roda Tiga' => ['satu_jam_pertama' => 3000, 'tarif_parkir_per_jam' => 2000],
    'Roda Empat' => ['satu_jam_pertama' => 5000, 'tarif_parkir_per_jam' => 3000],
    'Lebih dari Enam' => ['satu_jam_pertama' => 15000, 'tarif_parkir_per_jam' => 8000],
];

foreach ($malls as $mall) {
    echo "Checking mall: {$mall->nama_mall} (ID: {$mall->id_mall})\n";
    
    $existingTarifs = TarifParkir::where('id_mall', $mall->id_mall)->get();
    echo "  Existing tarifs: " . $existingTarifs->count() . "\n";
    
    foreach ($jenisKendaraan as $jenis) {
        $tarif = $existingTarifs->firstWhere('jenis_kendaraan', $jenis);
        
        if (!$tarif) {
            echo "  ❌ Missing tarif for: $jenis - Creating...\n";
            
            TarifParkir::create([
                'id_mall' => $mall->id_mall,
                'jenis_kendaraan' => $jenis,
                'satu_jam_pertama' => $defaultTarif[$jenis]['satu_jam_pertama'],
                'tarif_parkir_per_jam' => $defaultTarif[$jenis]['tarif_parkir_per_jam'],
            ]);
            
            echo "  ✅ Created tarif for: $jenis\n";
        } else {
            echo "  ✅ Tarif exists for: $jenis (ID: {$tarif->id_tarif})\n";
        }
    }
    
    echo "\n";
}

echo "========================================\n";
echo "Done!\n";
echo "========================================\n";

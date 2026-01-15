<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\Mall;
use App\Models\Parkiran;

echo "=== Creating Missing Parkiran for Malls ===\n\n";

$malls = Mall::with('parkiran')->where('status', 'active')->get();

$created = 0;
$skipped = 0;

foreach ($malls as $mall) {
    echo "Checking Mall: {$mall->nama_mall} (ID: {$mall->id_mall})\n";
    
    if ($mall->parkiran->count() > 0) {
        echo "  ✅ Already has {$mall->parkiran->count()} parkiran(s) - SKIPPED\n\n";
        $skipped++;
        continue;
    }
    
    // Create default parkiran for this mall
    try {
        $parkiran = new Parkiran();
        $parkiran->id_mall = $mall->id_mall;
        $parkiran->nama_parkiran = 'Area Parkir ' . $mall->nama_mall;
        $parkiran->kode_parkiran = 'P' . str_pad($mall->id_mall, 3, '0', STR_PAD_LEFT);
        $parkiran->kapasitas = 100; // Default capacity
        $parkiran->jumlah_lantai = 1; // Default 1 floor
        $parkiran->status = 'Tersedia';
        $parkiran->save();
        
        echo "  ✅ Created parkiran: {$parkiran->nama_parkiran} (ID: {$parkiran->id_parkiran})\n";
        echo "     Kode: {$parkiran->kode_parkiran}\n";
        echo "     Kapasitas: {$parkiran->kapasitas}\n";
        echo "     Jumlah Lantai: {$parkiran->jumlah_lantai}\n";
        echo "     Status: {$parkiran->status}\n\n";
        
        $created++;
    } catch (\Exception $e) {
        echo "  ❌ Failed to create parkiran: {$e->getMessage()}\n\n";
    }
}

echo "\n=== Summary ===\n";
echo "Total malls checked: {$malls->count()}\n";
echo "Parkiran created: $created\n";
echo "Malls skipped (already have parkiran): $skipped\n";

if ($created > 0) {
    echo "\n✅ SUCCESS! Created $created parkiran(s).\n";
    echo "Admin mall can now edit these parkiran in the dashboard.\n";
} else {
    echo "\nℹ️  No parkiran created. All malls already have parkiran.\n";
}

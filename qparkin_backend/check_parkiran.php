<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\Mall;

echo "=== Checking Mall and Parkiran Data ===\n\n";

$malls = Mall::with('parkiran')->where('status', 'active')->get();

if ($malls->isEmpty()) {
    echo "❌ No active malls found!\n";
    exit(1);
}

foreach ($malls as $mall) {
    echo "Mall: {$mall->nama_mall} (ID: {$mall->id_mall})\n";
    echo "  Status: {$mall->status}\n";
    echo "  Parkiran count: {$mall->parkiran->count()}\n";
    
    if ($mall->parkiran->count() > 0) {
        foreach ($mall->parkiran as $parkiran) {
            echo "    ✅ {$parkiran->nama_parkiran} (ID: {$parkiran->id_parkiran})\n";
            echo "       Status: {$parkiran->status}\n";
            echo "       Lantai: {$parkiran->lantai}\n";
            echo "       Kapasitas: {$parkiran->kapasitas}\n";
        }
    } else {
        echo "    ⚠️  NO PARKIRAN FOUND - Admin must create parkiran first!\n";
    }
    echo "\n";
}

echo "\n=== Summary ===\n";
echo "Total active malls: {$malls->count()}\n";
echo "Malls with parkiran: " . $malls->filter(fn($m) => $m->parkiran->count() > 0)->count() . "\n";
echo "Malls without parkiran: " . $malls->filter(fn($m) => $m->parkiran->count() === 0)->count() . "\n";

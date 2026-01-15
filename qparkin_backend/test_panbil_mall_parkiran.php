<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\Mall;

echo "=== Testing Panbil Mall Parkiran ===\n\n";

$mall = Mall::with('parkiran')->find(4);

if (!$mall) {
    echo "❌ Panbil Mall (ID: 4) not found!\n";
    exit(1);
}

echo "Mall: {$mall->nama_mall} (ID: {$mall->id_mall})\n";
echo "Status: {$mall->status}\n";
echo "Parkiran count: {$mall->parkiran->count()}\n\n";

if ($mall->parkiran->count() === 0) {
    echo "❌ NO PARKIRAN FOUND!\n";
    echo "This is why booking fails.\n";
    exit(1);
}

echo "Parkiran details:\n";
foreach ($mall->parkiran as $parkiran) {
    echo "  - ID: {$parkiran->id_parkiran}\n";
    echo "    Nama: {$parkiran->nama_parkiran}\n";
    echo "    Kode: {$parkiran->kode_parkiran}\n";
    echo "    Kapasitas: {$parkiran->kapasitas}\n";
    echo "    Status: {$parkiran->status}\n";
    echo "\n";
}

echo "✅ Panbil Mall has parkiran - booking should work!\n";

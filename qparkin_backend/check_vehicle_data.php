<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\Kendaraan;

echo "=== Checking Vehicle Data ===\n\n";

// Get all vehicles
$vehicles = Kendaraan::all();

if ($vehicles->isEmpty()) {
    echo "❌ No vehicles found in database\n";
    exit(1);
}

echo "Found {$vehicles->count()} vehicles:\n\n";

foreach ($vehicles as $vehicle) {
    echo "Vehicle ID: {$vehicle->id_kendaraan}\n";
    echo "  - Plat: {$vehicle->plat_nomor}\n";
    echo "  - Jenis: " . ($vehicle->jenis_kendaraan ?? 'NULL') . "\n";
    echo "  - Merk: {$vehicle->merk_kendaraan}\n";
    echo "  - User ID: {$vehicle->id_user}\n";
    
    if (empty($vehicle->jenis_kendaraan)) {
        echo "  ⚠️  WARNING: jenis_kendaraan is NULL or empty!\n";
    }
    echo "\n";
}

// Check specific vehicle ID 2 (from error log)
echo "\n=== Checking Vehicle ID 2 (from error) ===\n";
$vehicle = Kendaraan::find(2);

if ($vehicle) {
    echo "✅ Vehicle found\n";
    echo "  - Plat: {$vehicle->plat_nomor}\n";
    echo "  - Jenis: " . ($vehicle->jenis_kendaraan ?? 'NULL') . "\n";
    echo "  - Merk: {$vehicle->merk_kendaraan}\n";
    
    if (empty($vehicle->jenis_kendaraan)) {
        echo "\n❌ PROBLEM: jenis_kendaraan is NULL or empty!\n";
        echo "This is why SlotAutoAssignmentService is failing.\n";
    } else {
        echo "\n✅ jenis_kendaraan is set: {$vehicle->jenis_kendaraan}\n";
    }
} else {
    echo "❌ Vehicle ID 2 not found\n";
}

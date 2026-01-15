<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\Kendaraan;

echo "=== Verifying Vehicle Data (using 'jenis' field) ===\n\n";

// Get all vehicles
$vehicles = Kendaraan::all();

if ($vehicles->isEmpty()) {
    echo "❌ No vehicles found in database\n";
    exit(1);
}

echo "Found {$vehicles->count()} vehicles:\n\n";

$hasNullJenis = false;

foreach ($vehicles as $vehicle) {
    echo "Vehicle ID: {$vehicle->id_kendaraan}\n";
    echo "  - Plat: {$vehicle->plat}\n";
    echo "  - Jenis: " . ($vehicle->jenis ?? 'NULL') . "\n";
    echo "  - Merk: {$vehicle->merk}\n";
    echo "  - User ID: {$vehicle->id_user}\n";
    
    if (empty($vehicle->jenis)) {
        echo "  ⚠️  WARNING: jenis is NULL or empty!\n";
        $hasNullJenis = true;
    } else {
        echo "  ✅ jenis is set\n";
    }
    echo "\n";
}

// Check specific vehicle ID 2 (from error log)
echo "\n=== Checking Vehicle ID 2 (from error) ===\n";
$vehicle = Kendaraan::find(2);

if ($vehicle) {
    echo "✅ Vehicle found\n";
    echo "  - Plat: {$vehicle->plat}\n";
    echo "  - Jenis: " . ($vehicle->jenis ?? 'NULL') . "\n";
    echo "  - Merk: {$vehicle->merk}\n";
    
    if (empty($vehicle->jenis)) {
        echo "\n❌ PROBLEM: jenis is NULL or empty!\n";
        echo "This vehicle needs to have jenis field set.\n";
        echo "Valid values: 'Mobil' or 'Motor'\n";
    } else {
        echo "\n✅ jenis is set: {$vehicle->jenis}\n";
        echo "SlotAutoAssignmentService should work now.\n";
    }
} else {
    echo "❌ Vehicle ID 2 not found\n";
}

if ($hasNullJenis) {
    echo "\n⚠️  Some vehicles have NULL jenis field.\n";
    echo "Run fix_vehicle_jenis.php to fix this issue.\n";
}

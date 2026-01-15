<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\ParkingFloor;
use App\Models\Kendaraan;

echo "=== Checking Vehicle Type Mismatch ===\n\n";

// Check vehicle types in kendaraan table
echo "Vehicle types in 'kendaraan' table:\n";
$vehicleTypes = Kendaraan::select('jenis')->distinct()->get();
foreach ($vehicleTypes as $type) {
    echo "  - {$type->jenis}\n";
}

echo "\nVehicle types in 'parking_floors' table:\n";
$floorTypes = ParkingFloor::select('jenis_kendaraan')->distinct()->get();
foreach ($floorTypes as $type) {
    echo "  - {$type->jenis_kendaraan}\n";
}

echo "\n=== Analysis ===\n";
echo "The values don't match!\n";
echo "- kendaraan.jenis uses: 'Roda Dua', 'Roda Empat'\n";
echo "- parking_floors.jenis_kendaraan uses: 'Motor', 'Mobil'\n";
echo "\nWe need to normalize these values.\n";

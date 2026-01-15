<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\Kendaraan;
use App\Models\ParkingSlot;
use App\Models\ParkingFloor;

echo "=== Checking Vehicle Type Matching ===\n\n";

// Get vehicle types from kendaraan
echo "Vehicle types in 'kendaraan' table:\n";
$vehicleTypes = Kendaraan::select('jenis')->distinct()->get();
foreach ($vehicleTypes as $type) {
    $count = Kendaraan::where('jenis', $type->jenis)->count();
    echo "  - '{$type->jenis}': {$count} vehicles\n";
}

// Get vehicle types from parking_slots
echo "\nVehicle types in 'parking_slots' table:\n";
$slotTypes = ParkingSlot::select('jenis_kendaraan')->distinct()->get();
foreach ($slotTypes as $type) {
    $count = ParkingSlot::where('jenis_kendaraan', $type->jenis_kendaraan)->count();
    echo "  - '{$type->jenis_kendaraan}': {$count} slots\n";
}

// Get vehicle types from parking_floors
echo "\nVehicle types in 'parking_floors' table:\n";
$floorTypes = ParkingFloor::select('jenis_kendaraan')->distinct()->get();
foreach ($floorTypes as $type) {
    $count = ParkingFloor::where('jenis_kendaraan', $type->jenis_kendaraan)->count();
    echo "  - '{$type->jenis_kendaraan}': {$count} floors\n";
}

echo "\n=== Analysis ===\n";
echo "For slot assignment to work, these values MUST match:\n";
echo "  kendaraan.jenis == parking_slots.jenis_kendaraan\n\n";

// Check specific vehicle ID 2
$vehicle = Kendaraan::find(2);
if ($vehicle) {
    echo "Vehicle ID 2 has jenis: '{$vehicle->jenis}'\n";
    
    $matchingSlots = ParkingSlot::where('jenis_kendaraan', $vehicle->jenis)
        ->where('status', 'available')
        ->count();
    
    echo "Matching available slots: {$matchingSlots}\n\n";
    
    if ($matchingSlots == 0) {
        echo "❌ PROBLEM: No slots match vehicle type '{$vehicle->jenis}'!\n";
        echo "This is why booking fails.\n";
    } else {
        echo "✅ Slots exist for this vehicle type.\n";
    }
}

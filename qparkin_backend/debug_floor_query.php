<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\ParkingFloor;
use Illuminate\Support\Facades\DB;

echo "=== Debug Floor Query ===\n\n";

$idParkiran = 1;

echo "Query 1: All floors for parkiran {$idParkiran}\n";
$allFloors = ParkingFloor::where('id_parkiran', $idParkiran)->get();
echo "Result: {$allFloors->count()} floors\n\n";

echo "Query 2: Active floors\n";
$activeFloors = ParkingFloor::where('id_parkiran', $idParkiran)
    ->where('status', 'active')
    ->get();
echo "Result: {$activeFloors->count()} floors\n\n";

echo "Query 3: Active floors with available_slots > 0\n";
$availableFloors = ParkingFloor::where('id_parkiran', $idParkiran)
    ->where('status', 'active')
    ->where('available_slots', '>', 0)
    ->get();
echo "Result: {$availableFloors->count()} floors\n\n";

if ($availableFloors->isEmpty()) {
    echo "❌ PROBLEM: No floors match the query criteria!\n";
    echo "This is why SlotAutoAssignmentService returns null.\n\n";
    
    echo "Checking each condition:\n";
    foreach ($allFloors as $floor) {
        echo "Floor {$floor->id_floor}:\n";
        echo "  - status: '{$floor->status}' (needs 'active')\n";
        echo "  - available_slots: {$floor->available_slots} (needs > 0)\n";
        
        if ($floor->status !== 'active') {
            echo "  ❌ Status is not 'active'\n";
        }
        if ($floor->available_slots <= 0) {
            echo "  ❌ available_slots is not > 0\n";
        }
        echo "\n";
    }
} else {
    echo "✅ Floors found! SlotAutoAssignmentService should work.\n";
    foreach ($availableFloors as $floor) {
        echo "Floor {$floor->id_floor}: {$floor->nama_lantai} ({$floor->jenis_kendaraan})\n";
    }
}

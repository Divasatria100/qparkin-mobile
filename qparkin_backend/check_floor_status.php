<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\ParkingFloor;

echo "=== Checking Floor Status for Parkiran ID 1 ===\n\n";

$floors = ParkingFloor::where('id_parkiran', 1)->get();

foreach ($floors as $floor) {
    echo "Floor: {$floor->nama_lantai}\n";
    echo "  - Status: " . ($floor->status ?? 'NULL') . "\n";
    echo "  - Jenis: {$floor->jenis_kendaraan}\n";
    echo "  - Available Slots: {$floor->available_slots}\n";
    echo "\n";
}

echo "=== Analysis ===\n";
echo "SlotAutoAssignmentService looks for floors with status = 'active'\n";
echo "If floors don't have 'active' status, no slots will be found!\n";

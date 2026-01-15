<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\Parkiran;
use App\Models\ParkingFloor;
use App\Models\ParkingSlot;

echo "=== Checking Parking Slots for Panbil Mall (Parkiran ID: 1) ===\n\n";

// Get parkiran
$parkiran = Parkiran::find(1);

if (!$parkiran) {
    echo "❌ Parkiran ID 1 not found\n";
    exit(1);
}

echo "✅ Parkiran found: {$parkiran->nama_parkiran}\n";
echo "   Mall ID: {$parkiran->id_mall}\n";
echo "   Status: {$parkiran->status}\n\n";

// Get floors
$floors = ParkingFloor::where('id_parkiran', 1)->get();

if ($floors->isEmpty()) {
    echo "❌ No parking floors found for this parkiran\n";
    echo "This is why booking fails - no floors = no slots!\n";
    exit(1);
}

echo "Found {$floors->count()} parking floors:\n\n";

$totalSlots = 0;
$availableSlots = 0;

foreach ($floors as $floor) {
    echo "Floor: {$floor->nama_lantai}\n";
    echo "  - Jenis Kendaraan: {$floor->jenis_kendaraan}\n";
    echo "  - Total Slots: {$floor->total_slots}\n";
    echo "  - Available Slots: {$floor->available_slots}\n";
    
    // Get actual slots
    $slots = ParkingSlot::where('id_floor', $floor->id_floor)->get();
    echo "  - Actual slot records: {$slots->count()}\n";
    
    if ($slots->isEmpty()) {
        echo "  ⚠️  WARNING: No slot records in parking_slots table!\n";
    } else {
        $available = $slots->where('status', 'Tersedia')->count();
        echo "  - Available slot records: {$available}\n";
        $availableSlots += $available;
    }
    
    $totalSlots += $slots->count();
    echo "\n";
}

echo "=== Summary ===\n";
echo "Total slot records: {$totalSlots}\n";
echo "Available slot records: {$availableSlots}\n\n";

if ($totalSlots == 0) {
    echo "❌ PROBLEM: No parking slots exist in database!\n";
    echo "Solution: Run slot generation script or create slots manually.\n";
} elseif ($availableSlots == 0) {
    echo "⚠️  PROBLEM: All slots are occupied or not available!\n";
    echo "Check slot statuses and bookings.\n";
} else {
    echo "✅ Slots exist and are available for booking.\n";
}

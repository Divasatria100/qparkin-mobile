<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\ParkingSlot;
use App\Models\ParkingFloor;
use Carbon\Carbon;

echo "=== Debug Slot Query (Fixed) ===\n\n";

$idParkiran = 1;
$jenisKendaraan = 'Roda Dua';

// Get floor
$floor = ParkingFloor::where('id_parkiran', $idParkiran)
    ->where('jenis_kendaraan', $jenisKendaraan)
    ->first();

if (!$floor) {
    echo "❌ No floor found\n";
    exit(1);
}

echo "Floor: {$floor->id_floor}\n\n";

// Test the FIXED query
echo "Testing FIXED query (without reserved_from/reserved_until):\n";
$slot = ParkingSlot::where('id_floor', $floor->id_floor)
    ->where('jenis_kendaraan', $jenisKendaraan)
    ->where('status', 'available')
    ->whereDoesntHave('reservations', function ($query) {
        $query->where('status', 'active')
              ->where('expires_at', '>', Carbon::now());
    })
    ->first();

if ($slot) {
    echo "✅ SUCCESS! Found slot: {$slot->slot_code} (ID: {$slot->id_slot})\n";
} else {
    echo "❌ FAILED! No slot found\n";
    
    // Debug why
    $availableSlots = ParkingSlot::where('id_floor', $floor->id_floor)
        ->where('jenis_kendaraan', $jenisKendaraan)
        ->where('status', 'available')
        ->get();
    
    echo "\nAvailable slots before reservation check: {$availableSlots->count()}\n";
    
    if ($availableSlots->count() > 0) {
        $firstSlot = $availableSlots->first();
        $activeReservations = $firstSlot->reservations()
            ->where('status', 'active')
            ->where('expires_at', '>', Carbon::now())
            ->count();
        
        echo "First slot ({$firstSlot->slot_code}) has {$activeReservations} active reservations\n";
    }
}

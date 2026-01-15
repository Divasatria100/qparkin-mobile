<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\ParkingSlot;
use App\Models\ParkingFloor;
use Carbon\Carbon;

echo "=== Debug Slot Query ===\n\n";

$idParkiran = 1;
$jenisKendaraan = 'Roda Dua';
$waktuMulai = '2026-01-15 18:30:00';
$durasiBooking = 1;

$startTime = Carbon::parse($waktuMulai);
$endTime = $startTime->copy()->addHours($durasiBooking);

echo "Parameters:\n";
echo "  - Vehicle Type: {$jenisKendaraan}\n";
echo "  - Start: {$startTime}\n";
echo "  - End: {$endTime}\n\n";

// Get floor
$floor = ParkingFloor::where('id_parkiran', $idParkiran)
    ->where('jenis_kendaraan', $jenisKendaraan)
    ->first();

if (!$floor) {
    echo "❌ No floor found for vehicle type {$jenisKendaraan}\n";
    exit(1);
}

echo "Floor found: {$floor->id_floor} ({$floor->nama_lantai})\n\n";

// Query 1: All slots on this floor
echo "Query 1: All slots on floor {$floor->id_floor}\n";
$allSlots = ParkingSlot::where('id_floor', $floor->id_floor)->get();
echo "Result: {$allSlots->count()} slots\n\n";

// Query 2: Slots matching vehicle type
echo "Query 2: Slots matching vehicle type '{$jenisKendaraan}'\n";
$typeSlots = ParkingSlot::where('id_floor', $floor->id_floor)
    ->where('jenis_kendaraan', $jenisKendaraan)
    ->get();
echo "Result: {$typeSlots->count()} slots\n\n";

// Query 3: Available slots
echo "Query 3: Available slots\n";
$availableSlots = ParkingSlot::where('id_floor', $floor->id_floor)
    ->where('jenis_kendaraan', $jenisKendaraan)
    ->where('status', 'available')
    ->get();
echo "Result: {$availableSlots->count()} slots\n\n";

// Query 4: Without reservations
echo "Query 4: Slots without active reservations\n";
$unreservedSlots = ParkingSlot::where('id_floor', $floor->id_floor)
    ->where('jenis_kendaraan', $jenisKendaraan)
    ->where('status', 'available')
    ->whereDoesntHave('reservations', function ($query) use ($startTime, $endTime) {
        $query->where('status', 'active')
            ->where(function ($q) use ($startTime, $endTime) {
                $q->whereBetween('reserved_from', [$startTime, $endTime])
                  ->orWhereBetween('reserved_until', [$startTime, $endTime])
                  ->orWhere(function ($q2) use ($startTime, $endTime) {
                      $q2->where('reserved_from', '<=', $startTime)
                         ->where('reserved_until', '>=', $endTime);
                  });
            });
    })
    ->get();
echo "Result: {$unreservedSlots->count()} slots\n\n";

if ($unreservedSlots->isEmpty()) {
    echo "❌ PROBLEM: No slots pass all criteria!\n\n";
    
    if ($availableSlots->isEmpty()) {
        echo "Issue: No available slots (all occupied/reserved/maintenance)\n";
    } else {
        echo "Issue: All available slots have conflicting reservations\n";
        echo "Checking reservations...\n\n";
        
        foreach ($availableSlots->take(3) as $slot) {
            $reservations = $slot->reservations()
                ->where('status', 'active')
                ->get();
            
            echo "Slot {$slot->slot_code}:\n";
            echo "  - Reservations: {$reservations->count()}\n";
            foreach ($reservations as $res) {
                echo "    * {$res->reserved_from} to {$res->reserved_until}\n";
            }
        }
    }
} else {
    echo "✅ Found {$unreservedSlots->count()} available slots!\n";
    echo "First slot: {$unreservedSlots->first()->slot_code} (ID: {$unreservedSlots->first()->id_slot})\n";
}

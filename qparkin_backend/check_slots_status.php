<?php
/**
 * Check Slots Status
 * Debug script to see slot availability and reservations
 */

require __DIR__.'/vendor/autoload.php';
use Illuminate\Support\Facades\DB;

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

echo "========================================\n";
echo "Parking Slots Status Check\n";
echo "========================================\n\n";

// Get parkiran ID from command line or use default
$idParkiran = $argv[1] ?? 1;

echo "Checking slots for Parkiran ID: {$idParkiran}\n\n";

// Get floors
$floors = DB::table('parking_floors')
    ->where('id_parkiran', $idParkiran)
    ->get();

if ($floors->isEmpty()) {
    echo "✗ No floors found for this parkiran\n";
    exit(1);
}

echo "Found " . $floors->count() . " floor(s):\n\n";

foreach ($floors as $floor) {
    echo "Floor: {$floor->floor_name} (ID: {$floor->id_floor})\n";
    echo "  Floor Number: {$floor->floor_number}\n";
    echo "  Status: {$floor->status}\n";
    echo "  Available slots: {$floor->available_slots}\n\n";
    
    // Get slots for this floor
    $slots = DB::table('parking_slots')
        ->where('id_floor', $floor->id_floor)
        ->get();
    
    if ($slots->isEmpty()) {
        echo "  ✗ No slots found\n\n";
        continue;
    }
    
    $statusCounts = [
        'available' => 0,
        'occupied' => 0,
        'reserved' => 0,
        'maintenance' => 0,
    ];
    
    foreach ($slots as $slot) {
        $statusCounts[$slot->status] = ($statusCounts[$slot->status] ?? 0) + 1;
    }
    
    echo "  Slot Status Summary:\n";
    foreach ($statusCounts as $status => $count) {
        if ($count > 0) {
            echo "    - {$status}: {$count}\n";
        }
    }
    echo "\n";
    
    // Show first 5 slots as examples
    echo "  Sample Slots:\n";
    $sampleSlots = $slots->take(5);
    foreach ($sampleSlots as $slot) {
        echo "    - {$slot->slot_code}: {$slot->status}\n";
    }
    echo "\n";
}

// Check active reservations
echo "========================================\n";
echo "Active Reservations\n";
echo "========================================\n\n";

$reservations = DB::table('slot_reservations')
    ->where('status', 'active')
    ->where('expires_at', '>', now())
    ->get();

if ($reservations->isEmpty()) {
    echo "✓ No active reservations\n";
} else {
    echo "Found " . $reservations->count() . " active reservation(s):\n\n";
    foreach ($reservations as $res) {
        echo "  Reservation ID: {$res->reservation_id}\n";
        echo "    Slot ID: {$res->id_slot}\n";
        echo "    User ID: {$res->id_user}\n";
        echo "    Status: {$res->status}\n";
        echo "    Expires: {$res->expires_at}\n\n";
    }
}

// Check active bookings
echo "========================================\n";
echo "Active Bookings\n";
echo "========================================\n\n";

$bookings = DB::table('booking')
    ->join('transaksi_parkir', 'booking.id_transaksi', '=', 'transaksi_parkir.id_transaksi')
    ->where('booking.status', 'aktif')
    ->select('booking.*', 'transaksi_parkir.id_slot', 'transaksi_parkir.id_user')
    ->get();

if ($bookings->isEmpty()) {
    echo "✓ No active bookings\n";
} else {
    echo "Found " . $bookings->count() . " active booking(s):\n\n";
    foreach ($bookings as $booking) {
        echo "  Booking ID: {$booking->id_transaksi}\n";
        echo "    Slot ID: {$booking->id_slot}\n";
        echo "    User ID: {$booking->id_user}\n";
        echo "    Status: {$booking->status}\n";
        echo "    Start: {$booking->waktu_mulai}\n";
        echo "    End: {$booking->waktu_selesai}\n\n";
    }
}

echo "========================================\n";
echo "Check Complete\n";
echo "========================================\n";


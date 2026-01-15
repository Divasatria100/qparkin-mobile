<?php

/**
 * Test Booking Response - Verify backend returns correct ID values
 * 
 * This script tests the booking creation and verifies the response
 * contains proper id_booking and id_transaksi values.
 */

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\TransaksiParkir;
use App\Models\Booking;
use Illuminate\Support\Facades\DB;

echo "=== BOOKING RESPONSE TEST ===\n\n";

// Test parameters
$userId = 5; // Your test user ID
$idKendaraan = 2; // Your test vehicle ID

echo "1. Checking for active transactions...\n";
$activeTransaksi = TransaksiParkir::where('id_user', $userId)
    ->where('id_kendaraan', $idKendaraan)
    ->whereNull('waktu_keluar')
    ->first();

if ($activeTransaksi) {
    echo "   ❌ Found active transaction ID: {$activeTransaksi->id_transaksi}\n";
    echo "   Please run cleanup first: php qparkin_backend/cleanup_simple.php {$idKendaraan}\n\n";
    exit(1);
}

echo "   ✅ No active transactions\n\n";

echo "2. Checking last booking in database...\n";
$lastBooking = Booking::orderBy('id_transaksi', 'desc')->first();

if ($lastBooking) {
    echo "   Last booking ID: {$lastBooking->id_transaksi}\n";
    echo "   Status: {$lastBooking->status}\n";
    echo "   Created: {$lastBooking->dibooking_pada}\n\n";
    
    // Check if this booking has proper values
    if ($lastBooking->id_transaksi > 0) {
        echo "   ✅ Booking has valid ID\n";
    } else {
        echo "   ❌ Booking has invalid ID (0)\n";
    }
    
    // Load relationships
    $lastBooking->load(['transaksiParkir', 'slot.floor']);
    
    if ($lastBooking->transaksiParkir) {
        echo "   ✅ TransaksiParkir relationship loaded\n";
        echo "      Transaksi ID: {$lastBooking->transaksiParkir->id_transaksi}\n";
    } else {
        echo "   ❌ TransaksiParkir relationship NOT loaded\n";
    }
    
    if ($lastBooking->slot) {
        echo "   ✅ Slot relationship loaded\n";
        echo "      Slot Code: {$lastBooking->slot->slot_code}\n";
    } else {
        echo "   ❌ Slot relationship NOT loaded\n";
    }
} else {
    echo "   No bookings found in database\n";
}

echo "\n3. Testing Booking model primary key...\n";
$booking = new Booking();
echo "   Primary key: {$booking->getKeyName()}\n";
echo "   Table: {$booking->getTable()}\n";
echo "   Timestamps: " . ($booking->timestamps ? 'enabled' : 'disabled') . "\n";

echo "\n4. Checking database schema...\n";
try {
    $columns = DB::select("DESCRIBE booking");
    echo "   Booking table columns:\n";
    foreach ($columns as $column) {
        $key = $column->Key === 'PRI' ? ' (PRIMARY KEY)' : '';
        $extra = $column->Extra ? " [{$column->Extra}]" : '';
        echo "   - {$column->Field}: {$column->Type}{$key}{$extra}\n";
    }
} catch (\Exception $e) {
    echo "   ❌ Error: {$e->getMessage()}\n";
}

echo "\n=== TEST COMPLETE ===\n";
echo "\nNext steps:\n";
echo "1. Clean up any incomplete transactions: php qparkin_backend/cleanup_simple.php {$idKendaraan}\n";
echo "2. Restart backend: php artisan serve\n";
echo "3. Try booking from mobile app\n";
echo "4. Check backend logs for '[BookingService] Booking created successfully'\n";

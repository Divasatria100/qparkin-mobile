<?php
/**
 * Cleanup Incomplete Booking
 * 
 * This script cleans up incomplete bookings where:
 * - Booking was created but payment failed
 * - Transaksi is stuck in 'booked' status
 * - Slot is still marked as occupied
 * 
 * Usage: php cleanup_incomplete_booking.php <id_kendaraan>
 */

require __DIR__.'/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

// Get vehicle ID from command line argument
$idKendaraan = $argv[1] ?? null;

if (!$idKendaraan) {
    echo "Usage: php cleanup_incomplete_booking.php <id_kendaraan>\n";
    echo "Example: php cleanup_incomplete_booking.php 2\n";
    exit(1);
}

echo "========================================\n";
echo "Cleanup Incomplete Booking\n";
echo "========================================\n\n";

try {
    DB::beginTransaction();
    
    // 1. Find active transaksi for this vehicle (no status column)
    $transaksi = DB::table('transaksi_parkir')
        ->where('id_kendaraan', $idKendaraan)
        ->whereNull('waktu_keluar')
        ->get();
    
    if ($transaksi->isEmpty()) {
        echo "✓ No active transactions found for vehicle ID {$idKendaraan}\n";
        DB::rollBack();
        exit(0);
    }
    
    echo "Found " . $transaksi->count() . " active transaction(s):\n\n";
    
    foreach ($transaksi as $t) {
        echo "Transaction ID: {$t->id_transaksi}\n";
        echo "  Slot ID: {$t->id_slot}\n";
        echo "  Waktu Masuk: {$t->waktu_masuk}\n";
        
        // 2. Find related booking
        $booking = DB::table('booking')
            ->where('id_transaksi', $t->id_transaksi)
            ->first();
        
        if ($booking) {
            echo "  Booking ID: {$booking->id_transaksi}\n";
            echo "  Booking Status: {$booking->status}\n";
            
            // Cancel booking (use 'expired' to mark as cancelled)
            DB::table('booking')
                ->where('id_transaksi', $t->id_transaksi)
                ->update(['status' => 'expired']);
            
            echo "  ✓ Booking marked as expired\n";
        }
        
        // 3. Release slot reservation if exists
        if ($booking && $booking->reservation_id) {
            $reservation = DB::table('slot_reservations')
                ->where('reservation_id', $booking->reservation_id)
                ->first();
            
            if ($reservation) {
                DB::table('slot_reservations')
                    ->where('reservation_id', $booking->reservation_id)
                    ->update(['status' => 'expired']);
                
                echo "  ✓ Slot reservation expired\n";
            }
        }
        
        // 4. Release the slot
        if ($t->id_slot) {
            DB::table('parking_slots')
                ->where('id_slot', $t->id_slot)
                ->update(['status' => 'available']);
            
            echo "  ✓ Slot {$t->id_slot} released\n";
        }
        
        // 5. Mark transaksi as completed (set waktu_keluar)
        DB::table('transaksi_parkir')
            ->where('id_transaksi', $t->id_transaksi)
            ->update([
                'waktu_keluar' => now()
            ]);
        
        echo "  ✓ Transaction completed (waktu_keluar set)\n\n";
    }
    
    DB::commit();
    
    echo "========================================\n";
    echo "✓ Cleanup completed successfully!\n";
    echo "========================================\n";
    echo "\nYou can now create a new booking for vehicle ID {$idKendaraan}\n";
    
} catch (Exception $e) {
    DB::rollBack();
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}

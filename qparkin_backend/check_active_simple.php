<?php
/**
 * Simple Active Transactions Checker
 * Shows active transactions without complex joins
 */

require __DIR__.'/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$idKendaraan = $argv[1] ?? null;

echo "========================================\n";
echo "Active Transactions (Simple Check)\n";
echo "========================================\n\n";

try {
    $query = DB::table('transaksi_parkir')
        ->whereNull('waktu_keluar');
    
    if ($idKendaraan) {
        $query->where('id_kendaraan', $idKendaraan);
        echo "Filtering by Vehicle ID: {$idKendaraan}\n\n";
    }
    
    $transactions = $query->get();
    
    if ($transactions->isEmpty()) {
        echo "✓ No active transactions found\n";
        if ($idKendaraan) {
            echo "  Vehicle ID {$idKendaraan} has no active transactions\n";
            echo "  You can create a new booking now!\n";
        }
        exit(0);
    }
    
    echo "Found " . $transactions->count() . " active transaction(s):\n\n";
    
    foreach ($transactions as $t) {
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
        echo "Transaction ID: {$t->id_transaksi}\n";
        echo "User ID: {$t->id_user}\n";
        echo "Vehicle ID: {$t->id_kendaraan}\n";
        echo "Slot ID: {$t->id_slot}\n";
        echo "Waktu Masuk: {$t->waktu_masuk}\n";
        echo "Waktu Keluar: " . ($t->waktu_keluar ?? 'NULL (still active)') . "\n";
        
        // Check related booking
        $booking = DB::table('booking')
            ->where('id_transaksi', $t->id_transaksi)
            ->first();
        
        if ($booking) {
            echo "\nBooking Info:\n";
            echo "  Status: {$booking->status}\n";
            echo "  Start: {$booking->waktu_mulai}\n";
            echo "  End: {$booking->waktu_selesai}\n";
            
            if (strtotime($booking->waktu_selesai) < time()) {
                echo "  ⚠️  EXPIRED - Should be cleaned up!\n";
            }
        }
        echo "\n";
    }
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n";
    
    if ($idKendaraan) {
        echo "To cleanup vehicle ID {$idKendaraan}:\n";
        echo "  php cleanup_incomplete_booking.php {$idKendaraan}\n\n";
    } else {
        echo "To cleanup a specific vehicle:\n";
        echo "  php cleanup_incomplete_booking.php <id_kendaraan>\n\n";
    }
    
} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}

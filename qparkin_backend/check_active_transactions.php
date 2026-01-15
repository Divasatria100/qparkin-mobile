<?php
/**
 * Check Active Transactions
 * 
 * This script shows all active transactions and bookings
 * to help diagnose booking conflicts
 * 
 * Usage: php check_active_transactions.php [id_user]
 */

require __DIR__.'/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$idUser = $argv[1] ?? null;

echo "========================================\n";
echo "Active Transactions Report\n";
echo "========================================\n\n";

try {
    // Build simple query without complex joins
    $transactions = DB::table('transaksi_parkir as t')
        ->leftJoin('booking as b', 't.id_transaksi', '=', 'b.id_transaksi')
        ->select(
            't.id_transaksi',
            't.id_user',
            't.id_kendaraan',
            't.id_slot',
            't.status as transaksi_status',
            'b.status as booking_status',
            't.waktu_masuk',
            't.waktu_keluar',
            'b.waktu_mulai',
            'b.waktu_selesai',
            'b.reservation_id'
        )
        ->whereIn('t.status', ['booked', 'active'])
        ->whereNull('t.waktu_keluar');
    
    if ($idUser) {
        $transactions = $transactions->where('t.id_user', $idUser);
        echo "Filtering by User ID: {$idUser}\n\n";
    }
    
    $transactions = $transactions->get();
    
    if ($transactions->isEmpty()) {
        echo "✓ No active transactions found\n";
        if ($idUser) {
            echo "  User ID {$idUser} has no active bookings\n";
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
        if ($t->reservation_id) {
            echo "Reservation ID: {$t->reservation_id}\n";
        }
        echo "\nStatus:\n";
        echo "  Transaksi: {$t->transaksi_status}\n";
        echo "  Booking: " . ($t->booking_status ?? 'N/A') . "\n";
        echo "\nTiming:\n";
        echo "  Waktu Masuk: {$t->waktu_masuk}\n";
        echo "  Waktu Keluar: " . ($t->waktu_keluar ?? 'Not set') . "\n";
        if ($t->waktu_mulai) {
            echo "  Booking Start: {$t->waktu_mulai}\n";
            echo "  Booking End: {$t->waktu_selesai}\n";
        }
        echo "\n";
        
        // Check if booking is expired
        if ($t->waktu_selesai && strtotime($t->waktu_selesai) < time()) {
            echo "⚠️  WARNING: Booking has expired!\n";
            echo "   This transaction should be cleaned up.\n\n";
        }
    }
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n";
    
    echo "To cleanup a specific vehicle's incomplete booking:\n";
    echo "  php cleanup_incomplete_booking.php <id_kendaraan>\n\n";
    
    echo "Example:\n";
    echo "  php cleanup_incomplete_booking.php 2\n\n";
    
} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}

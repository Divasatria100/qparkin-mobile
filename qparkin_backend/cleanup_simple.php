<?php
/**
 * Simple Cleanup - Delete incomplete bookings
 */

require __DIR__.'/vendor/autoload.php';
use Illuminate\Support\Facades\DB;

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$idKendaraan = $argv[1] ?? null;

if (!$idKendaraan) {
    echo "Usage: php cleanup_simple.php <id_kendaraan>\n";
    exit(1);
}

echo "========================================\n";
echo "Simple Cleanup (Delete Method)\n";
echo "========================================\n\n";

try {
    DB::beginTransaction();
    
    // 1. Find active transactions
    $transactions = DB::table('transaksi_parkir')
        ->where('id_kendaraan', $idKendaraan)
        ->whereNull('waktu_keluar')
        ->get();
    
    if ($transactions->isEmpty()) {
        echo "✓ No active transactions found\n";
        DB::rollBack();
        exit(0);
    }
    
    echo "Found " . $transactions->count() . " transaction(s) to cleanup:\n\n";
    
    foreach ($transactions as $t) {
        echo "Transaction ID: {$t->id_transaksi}\n";
        
        // 2. Delete booking first (to avoid foreign key constraint)
        $deleted = DB::table('booking')
            ->where('id_transaksi', $t->id_transaksi)
            ->delete();
        
        if ($deleted > 0) {
            echo "  ✓ Booking deleted\n";
        }
        
        // 3. Release slot
        if ($t->id_slot) {
            DB::table('parking_slots')
                ->where('id_slot', $t->id_slot)
                ->update(['status' => 'available']);
            echo "  ✓ Slot {$t->id_slot} released\n";
        }
        
        // 4. Delete transaction
        DB::table('transaksi_parkir')
            ->where('id_transaksi', $t->id_transaksi)
            ->delete();
        
        echo "  ✓ Transaction deleted\n\n";
    }
    
    DB::commit();
    
    echo "========================================\n";
    echo "✓ Cleanup completed!\n";
    echo "========================================\n";
    echo "\nVehicle ID {$idKendaraan} is now free to create new bookings.\n";
    
} catch (Exception $e) {
    DB::rollBack();
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}

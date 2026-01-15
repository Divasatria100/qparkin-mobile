<?php
/**
 * Cleanup All Active Transactions
 * Delete ALL incomplete bookings and transactions
 */

require __DIR__.'/vendor/autoload.php';
use Illuminate\Support\Facades\DB;

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

echo "========================================\n";
echo "Cleanup ALL Active Transactions\n";
echo "========================================\n\n";

echo "⚠️  WARNING: This will delete ALL active transactions!\n";
echo "Are you sure? Type 'yes' to continue: ";
$handle = fopen("php://stdin", "r");
$line = fgets($handle);
fclose($handle);

if (trim($line) !== 'yes') {
    echo "\n✗ Cleanup cancelled.\n";
    exit(0);
}

echo "\n";

try {
    DB::beginTransaction();
    
    // 1. Find ALL active transactions
    $transactions = DB::table('transaksi_parkir')
        ->whereNull('waktu_keluar')
        ->get();
    
    if ($transactions->isEmpty()) {
        echo "✓ No active transactions found\n";
        DB::rollBack();
        exit(0);
    }
    
    echo "Found " . $transactions->count() . " active transaction(s) to cleanup:\n\n";
    
    $deletedBookings = 0;
    $releasedSlots = 0;
    $deletedTransactions = 0;
    
    foreach ($transactions as $t) {
        echo "Processing Transaction ID: {$t->id_transaksi}\n";
        echo "  Vehicle ID: {$t->id_kendaraan}\n";
        
        // 2. Delete booking first (to avoid foreign key constraint)
        $deleted = DB::table('booking')
            ->where('id_transaksi', $t->id_transaksi)
            ->delete();
        
        if ($deleted > 0) {
            $deletedBookings += $deleted;
            echo "  ✓ Booking deleted\n";
        }
        
        // 3. Delete any reservations for this slot
        if ($t->id_slot) {
            $deletedReservations = DB::table('slot_reservations')
                ->where('id_slot', $t->id_slot)
                ->delete();
            
            if ($deletedReservations > 0) {
                echo "  ✓ {$deletedReservations} reservation(s) deleted\n";
            }
            
            // 4. Release slot - set to available
            DB::table('parking_slots')
                ->where('id_slot', $t->id_slot)
                ->update(['status' => 'available']);
            $releasedSlots++;
            echo "  ✓ Slot {$t->id_slot} released (status: available)\n";
        }
        
        // 5. Delete transaction
        DB::table('transaksi_parkir')
            ->where('id_transaksi', $t->id_transaksi)
            ->delete();
        
        $deletedTransactions++;
        echo "  ✓ Transaction deleted\n\n";
    }
    
    DB::commit();
    
    echo "========================================\n";
    echo "✓ Cleanup completed!\n";
    echo "========================================\n\n";
    echo "Summary:\n";
    echo "  - Bookings deleted: {$deletedBookings}\n";
    echo "  - Slots released: {$releasedSlots}\n";
    echo "  - Transactions deleted: {$deletedTransactions}\n";
    echo "\nAll vehicles are now free to create new bookings.\n";
    
} catch (Exception $e) {
    DB::rollBack();
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}

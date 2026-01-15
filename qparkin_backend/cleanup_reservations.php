<?php
/**
 * Cleanup Orphaned Reservations
 * Delete reservations that don't have corresponding bookings
 */

require __DIR__.'/vendor/autoload.php';
use Illuminate\Support\Facades\DB;

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

echo "========================================\n";
echo "Cleanup Orphaned Reservations\n";
echo "========================================\n\n";

try {
    DB::beginTransaction();
    
    // Find all active reservations
    $reservations = DB::table('slot_reservations')
        ->where('status', 'active')
        ->get();
    
    if ($reservations->isEmpty()) {
        echo "✓ No active reservations found\n";
        DB::rollBack();
        exit(0);
    }
    
    echo "Found " . $reservations->count() . " active reservation(s)\n\n";
    
    $deletedCount = 0;
    $releasedSlots = [];
    
    foreach ($reservations as $res) {
        // Check if there's a booking for this reservation
        $booking = DB::table('booking')
            ->where('reservation_id', $res->reservation_id)
            ->first();
        
        if (!$booking) {
            echo "Deleting orphaned reservation: {$res->reservation_id}\n";
            echo "  Slot ID: {$res->id_slot}\n";
            
            // Delete reservation
            DB::table('slot_reservations')
                ->where('reservation_id', $res->reservation_id)
                ->delete();
            
            $deletedCount++;
            
            // Track slot to release
            if (!in_array($res->id_slot, $releasedSlots)) {
                $releasedSlots[] = $res->id_slot;
            }
        } else {
            echo "Keeping reservation {$res->reservation_id} (has booking)\n";
        }
    }
    
    // Release all slots that had orphaned reservations
    if (!empty($releasedSlots)) {
        echo "\nReleasing " . count($releasedSlots) . " slot(s)...\n";
        
        foreach ($releasedSlots as $slotId) {
            // Check if slot has any other active reservations
            $hasOtherReservations = DB::table('slot_reservations')
                ->where('id_slot', $slotId)
                ->where('status', 'active')
                ->exists();
            
            if (!$hasOtherReservations) {
                DB::table('parking_slots')
                    ->where('id_slot', $slotId)
                    ->update(['status' => 'available']);
                echo "  ✓ Slot {$slotId} released\n";
            } else {
                echo "  - Slot {$slotId} still has active reservations\n";
            }
        }
    }
    
    DB::commit();
    
    echo "\n========================================\n";
    echo "✓ Cleanup completed!\n";
    echo "========================================\n\n";
    echo "Summary:\n";
    echo "  - Reservations deleted: {$deletedCount}\n";
    echo "  - Slots released: " . count($releasedSlots) . "\n";
    
} catch (Exception $e) {
    DB::rollBack();
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}


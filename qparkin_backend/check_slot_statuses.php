<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\ParkingSlot;
use Illuminate\Support\Facades\DB;

echo "=== Checking Slot Statuses ===\n\n";

// Get distinct statuses
$statuses = ParkingSlot::select('status')
    ->distinct()
    ->get()
    ->pluck('status');

echo "Distinct status values in parking_slots:\n";
foreach ($statuses as $status) {
    $count = ParkingSlot::where('status', $status)->count();
    echo "  - '{$status}': {$count} slots\n";
}

echo "\n=== Analysis ===\n";
echo "Expected status values:\n";
echo "  - 'available' (for available slots)\n";
echo "  - 'occupied' (for occupied slots)\n";
echo "  - 'reserved' (for reserved slots)\n";
echo "  - 'maintenance' (for maintenance)\n";

echo "\n=== Fix Needed ===\n";
if (!$statuses->contains('available')) {
    echo "❌ No slots have 'available' status!\n";
    echo "SlotAutoAssignmentService looks for status = 'available'\n";
    echo "Need to update slot statuses to 'available'\n";
}

<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\Mall;

echo "=== CHECKING MALL FEATURE FLAG ===\n\n";

$mall = Mall::find(4);

if (!$mall) {
    echo "❌ Mall with ID 4 not found!\n";
    exit(1);
}

echo "Mall ID: {$mall->id_mall}\n";
echo "Nama: {$mall->nama_mall}\n";
echo "has_slot_reservation_enabled (raw): ";
var_dump($mall->has_slot_reservation_enabled);
echo "has_slot_reservation_enabled (bool): " . ($mall->has_slot_reservation_enabled ? 'true' : 'false') . "\n";
echo "Type: " . gettype($mall->has_slot_reservation_enabled) . "\n\n";

// Check if it's 0, null, or false
if ($mall->has_slot_reservation_enabled === null) {
    echo "⚠️  WARNING: Value is NULL - needs to be set to 1 or true\n";
    echo "\nTo fix, run:\n";
    echo "UPDATE mall SET has_slot_reservation_enabled = 1 WHERE id_mall = 4;\n";
} elseif ($mall->has_slot_reservation_enabled === 0 || $mall->has_slot_reservation_enabled === false) {
    echo "⚠️  WARNING: Value is 0 or false - feature is DISABLED\n";
    echo "\nTo enable, run:\n";
    echo "UPDATE mall SET has_slot_reservation_enabled = 1 WHERE id_mall = 4;\n";
} else {
    echo "✅ Feature flag is ENABLED\n";
}

echo "\n=== CHECK COMPLETE ===\n";

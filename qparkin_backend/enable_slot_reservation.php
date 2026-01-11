<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\Mall;

echo "=== ENABLING SLOT RESERVATION FEATURE ===\n\n";

$mall = Mall::find(4);

if (!$mall) {
    echo "❌ Mall with ID 4 not found!\n";
    exit(1);
}

echo "Before:\n";
echo "  - Mall: {$mall->nama_mall}\n";
echo "  - has_slot_reservation_enabled: " . ($mall->has_slot_reservation_enabled ? 'true' : 'false') . "\n\n";

// Enable the feature
$mall->has_slot_reservation_enabled = true;
$mall->save();

echo "After:\n";
echo "  - Mall: {$mall->nama_mall}\n";
echo "  - has_slot_reservation_enabled: " . ($mall->has_slot_reservation_enabled ? 'true' : 'false') . "\n\n";

echo "✅ Slot reservation feature ENABLED for {$mall->nama_mall}\n";
echo "\n=== COMPLETE ===\n";

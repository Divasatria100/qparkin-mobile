<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== BOOKING TABLE STRUCTURE ===\n\n";

$columns = DB::select('DESCRIBE booking');

foreach ($columns as $column) {
    echo "Field: {$column->Field}\n";
    echo "  Type: {$column->Type}\n";
    echo "  Null: {$column->Null}\n";
    echo "  Key: {$column->Key}\n";
    echo "  Default: {$column->Default}\n";
    echo "  Extra: {$column->Extra}\n\n";
}

echo "\n=== CHECKING FOR TIMESTAMPS ===\n";
$hasCreatedAt = false;
$hasUpdatedAt = false;

foreach ($columns as $column) {
    if ($column->Field === 'created_at') $hasCreatedAt = true;
    if ($column->Field === 'updated_at') $hasUpdatedAt = true;
}

echo "Has created_at: " . ($hasCreatedAt ? "YES" : "NO") . "\n";
echo "Has updated_at: " . ($hasUpdatedAt ? "YES" : "NO") . "\n";

if (!$hasCreatedAt || !$hasUpdatedAt) {
    echo "\n⚠️  WARNING: Table is missing timestamp columns!\n";
    echo "Laravel Model expects timestamps but table doesn't have them.\n";
    echo "\nSOLUTION: Add 'public \$timestamps = false;' to Booking model\n";
}

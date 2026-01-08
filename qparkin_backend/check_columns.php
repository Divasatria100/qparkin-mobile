<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

echo "=== Checking user table columns ===\n\n";

$columns = DB::select('DESCRIBE user');

echo "Columns in user table:\n";
foreach ($columns as $column) {
    echo "- {$column->Field} ({$column->Type}) " . ($column->Null === 'YES' ? 'NULL' : 'NOT NULL') . "\n";
}

echo "\n=== Checking for application fields ===\n";
$appFields = ['application_status', 'requested_mall_name', 'requested_mall_location', 'application_notes', 'applied_at', 'reviewed_at', 'reviewed_by'];

foreach ($appFields as $field) {
    $exists = Schema::hasColumn('user', $field);
    echo "$field: " . ($exists ? '✓ EXISTS' : '✗ MISSING') . "\n";
}

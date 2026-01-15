<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== CHECKING BOOKING TABLE STATUS COLUMN ===\n\n";

// Get column information
$result = DB::select("SHOW COLUMNS FROM booking WHERE Field = 'status'");

if (!empty($result)) {
    $column = $result[0];
    echo "Column: {$column->Field}\n";
    echo "Type: {$column->Type}\n";
    echo "Null: {$column->Null}\n";
    echo "Default: {$column->Default}\n\n";
    
    // Extract ENUM values
    if (preg_match("/^enum\((.+)\)$/", $column->Type, $matches)) {
        $enumValues = str_getcsv($matches[1], ',', "'");
        echo "Valid ENUM values:\n";
        foreach ($enumValues as $value) {
            echo "  - '$value'\n";
        }
    }
} else {
    echo "Status column not found!\n";
}

echo "\n=== CHECKING WHAT VALUE WE'RE TRYING TO INSERT ===\n";
echo "Current code tries to insert: 'confirmed'\n";
echo "\nIf 'confirmed' is not in the ENUM list above, that's the problem!\n";

<?php
require __DIR__.'/vendor/autoload.php';
use Illuminate\Support\Facades\DB;

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

echo "Checking booking table structure...\n\n";

$result = DB::select("SHOW COLUMNS FROM booking WHERE Field = 'status'");

if (!empty($result)) {
    $column = $result[0];
    echo "Column: {$column->Field}\n";
    echo "Type: {$column->Type}\n";
    echo "Null: {$column->Null}\n";
    echo "Default: {$column->Default}\n";
}

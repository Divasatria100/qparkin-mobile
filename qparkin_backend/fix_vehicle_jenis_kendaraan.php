<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\Kendaraan;
use Illuminate\Support\Facades\DB;

echo "=== Fixing Vehicle jenis_kendaraan ===\n\n";

DB::beginTransaction();

try {
    // Get all vehicles with NULL jenis_kendaraan
    $vehicles = Kendaraan::whereNull('jenis_kendaraan')
        ->orWhere('jenis_kendaraan', '')
        ->get();
    
    if ($vehicles->isEmpty()) {
        echo "✅ All vehicles already have jenis_kendaraan set\n";
        DB::rollBack();
        exit(0);
    }
    
    echo "Found {$vehicles->count()} vehicles with NULL jenis_kendaraan\n\n";
    
    foreach ($vehicles as $vehicle) {
        // Default to 'Mobil' if not set
        // In production, you should determine this based on actual vehicle data
        $jenisKendaraan = 'Mobil'; // Default
        
        echo "Updating Vehicle ID {$vehicle->id_kendaraan}:\n";
        echo "  - Plat: {$vehicle->plat_nomor}\n";
        echo "  - Setting jenis_kendaraan to: {$jenisKendaraan}\n";
        
        $vehicle->jenis_kendaraan = $jenisKendaraan;
        $vehicle->save();
        
        echo "  ✅ Updated\n\n";
    }
    
    DB::commit();
    
    echo "\n=== Fix Complete ===\n";
    echo "Updated {$vehicles->count()} vehicles\n";
    echo "All vehicles now have jenis_kendaraan set\n";
    
} catch (\Exception $e) {
    DB::rollBack();
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

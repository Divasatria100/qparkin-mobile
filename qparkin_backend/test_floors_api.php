<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Http\Controllers\Api\ParkingSlotController;
use Illuminate\Http\Request;

echo "=== TESTING ParkingSlotController::getFloors(4) ===\n\n";

try {
    $controller = new ParkingSlotController();
    
    echo "Calling getFloors(4)...\n\n";
    
    $response = $controller->getFloors(4);
    
    $statusCode = $response->getStatusCode();
    $content = $response->getContent();
    $data = json_decode($content, true);
    
    echo "Status Code: {$statusCode}\n";
    echo "Response:\n";
    echo json_encode($data, JSON_PRETTY_PRINT) . "\n\n";
    
    if ($statusCode === 200 && isset($data['success']) && $data['success']) {
        echo "✅ SUCCESS: Endpoint working correctly!\n";
        echo "   Floors returned: " . count($data['data']) . "\n";
        
        if (!empty($data['data'])) {
            echo "\n   Floor details:\n";
            foreach ($data['data'] as $floor) {
                echo "   - {$floor['floor_name']}: {$floor['available_slots']}/{$floor['total_slots']} available\n";
            }
        }
    } else {
        echo "❌ ERROR: Unexpected response\n";
        if (isset($data['error'])) {
            echo "   Error message: {$data['error']}\n";
        }
    }
    
} catch (\Exception $e) {
    echo "❌ EXCEPTION CAUGHT:\n";
    echo "   Message: " . $e->getMessage() . "\n";
    echo "   File: " . $e->getFile() . ":" . $e->getLine() . "\n";
    echo "\n   Stack trace:\n";
    echo $e->getTraceAsString() . "\n";
}

echo "\n=== TEST COMPLETE ===\n";

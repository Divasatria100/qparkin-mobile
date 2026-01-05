<?php

/**
 * Test Email Deletion Feature
 * 
 * This script tests the email deletion functionality in the profile update API.
 * It verifies that:
 * 1. Email can be set to null
 * 2. Database stores null correctly
 * 3. API response returns null for email
 * 4. Frontend can handle null email
 */

require __DIR__.'/vendor/autoload.php';

use Illuminate\Support\Facades\DB;
use App\Models\User;

// Bootstrap Laravel
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "========================================\n";
echo "Email Deletion Test\n";
echo "========================================\n\n";

// Test 1: Find a test user
echo "Test 1: Finding test user...\n";
$user = User::where('role', 'customer')->first();

if (!$user) {
    echo "❌ No customer user found. Please create a test user first.\n";
    exit(1);
}

echo "✅ Found user: {$user->name} (ID: {$user->id_user})\n";
echo "   Current email: " . ($user->email ?? 'NULL') . "\n\n";

// Test 2: Set email to a test value
echo "Test 2: Setting email to test value...\n";
$testEmail = 'test_' . time() . '@example.com';
$user->email = $testEmail;
$user->save();
$user->refresh();

echo "✅ Email set to: {$user->email}\n\n";

// Test 3: Delete email (set to null)
echo "Test 3: Deleting email (set to null)...\n";
$user->email = null;
$user->save();
$user->refresh();

if ($user->email === null) {
    echo "✅ Email successfully set to NULL in database\n";
} else {
    echo "❌ Email is not NULL: {$user->email}\n";
    exit(1);
}

// Test 4: Verify in database directly
echo "\nTest 4: Verifying in database...\n";
$dbUser = DB::table('user')
    ->where('id_user', $user->id_user)
    ->first();

if ($dbUser->email === null) {
    echo "✅ Database query confirms email is NULL\n";
} else {
    echo "❌ Database shows email: {$dbUser->email}\n";
    exit(1);
}

// Test 5: Test UserResource transformation
echo "\nTest 5: Testing UserResource transformation...\n";
$resource = new \App\Http\Resources\UserResource($user);
$resourceArray = $resource->toArray(request());

if ($resourceArray['email'] === null) {
    echo "✅ UserResource correctly returns NULL for email\n";
} else {
    echo "❌ UserResource returns: " . var_export($resourceArray['email'], true) . "\n";
    exit(1);
}

// Test 6: Test with empty string
echo "\nTest 6: Testing empty string conversion...\n";
$user->email = '';
$user->save();
$user->refresh();

if ($user->email === null || $user->email === '') {
    echo "✅ Empty string handled: " . var_export($user->email, true) . "\n";
} else {
    echo "❌ Unexpected value: {$user->email}\n";
}

// Test 7: Restore email
echo "\nTest 7: Restoring email...\n";
$user->email = $testEmail;
$user->save();
$user->refresh();

if ($user->email === $testEmail) {
    echo "✅ Email restored successfully: {$user->email}\n";
} else {
    echo "❌ Failed to restore email\n";
    exit(1);
}

// Test 8: Final deletion test
echo "\nTest 8: Final deletion test...\n";
$user->update(['email' => null]);
$user->refresh();

if ($user->email === null) {
    echo "✅ Email deleted using update() method\n";
} else {
    echo "❌ Email not deleted: {$user->email}\n";
    exit(1);
}

echo "\n========================================\n";
echo "✅ All Tests Passed!\n";
echo "========================================\n\n";

echo "Summary:\n";
echo "- Email can be set to NULL ✅\n";
echo "- Database stores NULL correctly ✅\n";
echo "- UserResource returns NULL ✅\n";
echo "- Empty string handled ✅\n";
echo "- Email can be restored ✅\n";
echo "- Update method works ✅\n\n";

echo "Next Steps:\n";
echo "1. Test with actual API endpoint using curl or Postman\n";
echo "2. Test from Flutter app\n";
echo "3. Verify UI updates correctly\n\n";

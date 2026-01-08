<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\User;

echo "=== Checking Pending Applications ===\n\n";

echo "Total users: " . User::count() . "\n";
echo "Pending applications: " . User::where('application_status', 'pending')->count() . "\n\n";

echo "All users with application_status:\n";
$users = User::whereNotNull('application_status')->get(['id_user', 'name', 'email', 'application_status', 'requested_mall_name', 'applied_at']);
foreach ($users as $user) {
    echo "ID: {$user->id_user} | {$user->name} | {$user->email} | Status: {$user->application_status} | Mall: {$user->requested_mall_name} | Applied: {$user->applied_at}\n";
}

echo "\n=== Checking Recent Registrations ===\n";
$recent = User::orderBy('created_at', 'desc')->limit(5)->get(['id_user', 'name', 'email', 'role', 'status', 'application_status', 'created_at']);
foreach ($recent as $user) {
    echo "ID: {$user->id_user} | {$user->name} | Role: {$user->role} | Status: {$user->status} | App Status: {$user->application_status} | Created: {$user->created_at}\n";
}

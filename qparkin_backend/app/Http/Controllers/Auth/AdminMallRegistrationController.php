<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rules;

class AdminMallRegistrationController extends Controller
{
    /**
     * Handle admin mall registration request
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'lowercase', 'email', 'max:255', 'unique:users'],
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
            'mall_name' => ['required', 'string', 'max:255'],
            'location' => ['required', 'string', 'max:500'],
            'latitude' => ['nullable', 'numeric'],
            'longitude' => ['nullable', 'numeric'],
            'mall_photo' => ['required', 'image', 'max:2048'], // 2MB max
        ]);

        // Store mall photo
        $photoPath = null;
        if ($request->hasFile('mall_photo')) {
            $photoPath = $request->file('mall_photo')->store('mall_photos', 'public');
        }

        // Create user with pending status
        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'role' => 'admin', // Admin mall role
            'status' => 'pending', // Pending approval
            'mall_name' => $validated['mall_name'],
            'mall_location' => $validated['location'],
            'mall_latitude' => $validated['latitude'] ?? null,
            'mall_longitude' => $validated['longitude'] ?? null,
            'mall_photo' => $photoPath,
        ]);

        // TODO: Send notification to super admin
        // TODO: Send confirmation email to user

        if ($request->expectsJson()) {
            return response()->json([
                'success' => true,
                'message' => 'Registration request submitted successfully',
                'redirect' => route('success-signup')
            ]);
        }

        return redirect()->route('success-signup');
    }
}

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
            'email' => ['required', 'string', 'lowercase', 'email', 'max:255', 'unique:user,email'],
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
            'mall_name' => ['required', 'string', 'max:255'],
            'google_maps_url' => ['required', 'url', 'max:500'],
            'mall_photo' => ['required', 'image', 'mimes:jpeg,png,jpg', 'max:2048'],
        ]);

        // Store mall photo
        $photoPath = null;
        if ($request->hasFile('mall_photo')) {
            $photoPath = $request->file('mall_photo')->store('mall_photos', 'public');
        }

        // Create user with pending application status
        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'role' => 'customer', // Tetap customer dulu, nanti diubah saat approved
            'status' => 'aktif',  // Status user aktif
            
            // Application fields (FIELD YANG BENAR):
            'application_status' => 'pending',
            'requested_mall_name' => $validated['mall_name'],
            'requested_mall_location' => $validated['google_maps_url'],
            'application_notes' => json_encode([
                'google_maps_url' => $validated['google_maps_url'],
                'photo_path' => $photoPath,
                'submitted_from' => 'web_registration',
            ]),
            'applied_at' => now(),
        ]);

        // Log untuk debugging
        \Log::info('Admin mall registration submitted', [
            'user_id' => $user->id_user,
            'email' => $user->email,
            'mall_name' => $user->requested_mall_name,
            'application_status' => $user->application_status,
        ]);

        // TODO: Send notification to super admin
        // TODO: Send confirmation email to user

        if ($request->expectsJson()) {
            return response()->json([
                'success' => true,
                'message' => 'Pengajuan registrasi berhasil dikirim. Silakan tunggu verifikasi dari admin.',
                'redirect' => route('success-signup')
            ]);
        }

        return redirect()->route('success-signup')
            ->with('success', 'Pengajuan registrasi berhasil dikirim. Silakan tunggu verifikasi dari admin.');
    }
}

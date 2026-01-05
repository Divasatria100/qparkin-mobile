<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class UserController extends Controller
{
    /**
     * Get authenticated user profile
     */
    public function profile(Request $request)
    {
        return response()->json([
            'success' => true,
            'data' => new UserResource($request->user())
        ]);
    }

    /**
     * Update authenticated user profile
     */
    public function updateProfile(Request $request)
    {
        $user = $request->user();
        
        // Log incoming request for debugging
        \Log::info('Update Profile Request', [
            'user_id' => $user->id_user,
            'request_data' => $request->all()
        ]);
        
        // Validate input
        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255',
            'email' => 'nullable|email|unique:user,email,' . $user->id_user . ',id_user',
            'phone_number' => 'nullable|string|max:20',
            'photo_url' => 'nullable|string|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 400);
        }

        $validated = $validator->validated();
        
        // Map phone_number to nomor_hp for database
        $updateData = [];
        
        if (isset($validated['name'])) {
            $updateData['name'] = $validated['name'];
        }
        
        // CRITICAL: Always update email field (even if null) to allow deletion
        // Use array_key_exists to detect null values (isset returns false for null)
        if (array_key_exists('email', $validated)) {
            // Convert empty string to null for database consistency
            $updateData['email'] = empty($validated['email']) ? null : $validated['email'];
            
            \Log::info('Email Update', [
                'user_id' => $user->id_user,
                'old_email' => $user->email,
                'new_email' => $updateData['email']
            ]);
        }
        
        if (isset($validated['phone_number'])) {
            $updateData['nomor_hp'] = $validated['phone_number'];
        }
        
        if (isset($validated['photo_url'])) {
            $updateData['avatar'] = $validated['photo_url'];
        }

        // Log update data
        \Log::info('Update Data', [
            'user_id' => $user->id_user,
            'update_data' => $updateData
        ]);

        // Update user in database
        $user->update($updateData);
        
        // Refresh user model from database to get latest data
        $user->refresh();
        
        // Log updated user data
        \Log::info('User After Update', [
            'user_id' => $user->id_user,
            'email' => $user->email,
            'name' => $user->name
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'data' => new UserResource($user)
        ]);
    }

    public function updatePin(Request $request)
    {
        // Logic update PIN
        return response()->json([
            'success' => true,
            'message' => 'PIN updated successfully'
        ]);
    }

    public function getPoin(Request $request)
    {
        return response()->json([
            'success' => true,
            'data' => [
                'poin' => 0
            ]
        ]);
    }

    public function getRiwayatPoin(Request $request)
    {
        return response()->json([
            'success' => true,
            'data' => []
        ]);
    }
}

<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function profile(Request $request)
    {
        return response()->json([
            'success' => true,
            'data' => $request->user()
        ]);
    }

    public function updateProfile(Request $request)
    {
        // Logic update profile
        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully'
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

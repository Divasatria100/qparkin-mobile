<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class ApiAuthController extends Controller
{
    public function login(Request $request)
    {
        // Validasi input
        $request->validate([
            'no_hp' => 'required|string',
            'password' => 'required'
        ]);

        // Cari user by no_hp
        $user = User::where('no_hp', $request->no_hp)->first();

        // Cek user dan password
        if (!$user) {
            return response()->json([
                'message' => 'Nomor HP tidak terdaftar.'
            ], 401);
        }

        if (!Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Password salah.'
            ], 401);
        }

        // Cek status user
        if ($user->status !== 'aktif') {
            return response()->json([
                'message' => 'Akun tidak aktif. Silakan hubungi administrator.'
            ], 403);
        }

        // Buat token
        try {
            $token = $user->createToken('qparkin-mobile')->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'Login berhasil',
                'user' => [
                    'id_user' => $user->id_user,
                    'name' => $user->name,
                    'email' => $user->email,
                    'no_hp' => $user->no_hp,
                    'role' => $user->role,
                    'saldo_poin' => $user->saldo_poin,
                ],
                'token' => $token
            ], 200);
            
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error creating token: ' . $e->getMessage()
            ], 500);
        }
    }

    public function logout(Request $request)
    {
        try {
            // Hapus token current user
            $request->user()->currentAccessToken()->delete();

            return response()->json([
                'success' => true,
                'message' => 'Logout berhasil'
            ], 200);
            
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error during logout: ' . $e->getMessage()
            ], 500);
        }
    }

    // Method untuk get user data
    public function getUser(Request $request)
    {
        return response()->json([
            'success' => true,
            'user' => $request->user()
        ]);
    }
}
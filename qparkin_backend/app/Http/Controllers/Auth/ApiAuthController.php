<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use App\Models\User;
use Google\Client as GoogleClient;

class ApiAuthController extends Controller
{
    public function login(Request $request)
    {
        // Validasi input
        $request->validate([
            'nomor_hp' => 'required|string',
            'pin' => 'required|string|size:6'
        ]);

        // Cari user by nomor_hp
        $user = User::where('nomor_hp', $request->nomor_hp)->first();

        // Cek user dan pin
        if (!$user) {
            return response()->json([
                'message' => 'Nomor HP tidak terdaftar.'
            ], 401);
        }

        if (!Hash::check($request->pin, $user->password)) {
            return response()->json([
                'message' => 'PIN salah.'
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
                    'nomor_hp' => $user->nomor_hp,
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

    public function register(Request $request)
    {
        // Validasi input
        $request->validate([
            'nama' => 'required|string|max:255',
            'nomor_hp' => 'required|string|unique:user,nomor_hp',
            'pin' => 'required|string|size:6'
        ]);

        try {
            // Cek apakah nomor_hp sudah terdaftar
            $existingUser = User::where('nomor_hp', $request->nomor_hp)->first();
            if ($existingUser) {
                return response()->json([
                    'message' => 'Nomor HP sudah terdaftar.'
                ], 409);
            }

            // Buat user baru
            $user = User::create([
                'name' => $request->nama,
                'nomor_hp' => $request->nomor_hp,
                'password' => Hash::make($request->pin),
                'role' => 'customer',
                'status' => 'aktif',
                'saldo_poin' => 0,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Registrasi berhasil'
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error during registration: ' . $e->getMessage()
            ], 500);
        }
    }

    public function googleLogin(Request $request)
    {
        // Validasi input
        $request->validate([
            'id_token' => 'required|string'
        ]);

        try {
            // Verifikasi Google ID token menggunakan Google API Client
            $client = new GoogleClient(['client_id' => config('services.google.client_id')]);
            $payload = $client->verifyIdToken($request->id_token);

            if (!$payload) {
                return response()->json([
                    'message' => 'Invalid Google token'
                ], 401);
            }

            // Cari user berdasarkan provider_id
            $user = User::where('provider', 'google')
                       ->where('provider_id', $payload['sub'])
                       ->first();

            if (!$user) {
                // Cek apakah email sudah ada
                $existingUser = User::where('email', $payload['email'])->first();

                if ($existingUser) {
                    // Link akun existing dengan Google
                    $existingUser->update([
                        'provider' => 'google',
                        'provider_id' => $payload['sub'],
                    ]);
                    $user = $existingUser;
                } else {
                    // Buat user baru
                    $user = User::create([
                        'name' => $payload['name'],
                        'email' => $payload['email'],
                        'provider' => 'google',
                        'provider_id' => $payload['sub'],
                        'role' => 'customer',
                        'status' => 'aktif',
                        'saldo_poin' => 0,
                    ]);
                }
            }

            // Cek status user
            if ($user->status !== 'aktif') {
                return response()->json([
                    'message' => 'Akun tidak aktif. Silakan hubungi administrator.'
                ], 403);
            }

            // Buat token
            $token = $user->createToken('qparkin-mobile')->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'Login Google berhasil',
                'user' => [
                    'id_user' => $user->id_user,
                    'name' => $user->name,
                    'email' => $user->email,
                    'nomor_hp' => $user->nomor_hp,
                    'role' => $user->role,
                    'saldo_poin' => $user->saldo_poin,
                ],
                'token' => $token
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error during Google login: ' . $e->getMessage()
            ], 500);
        }
    }
}

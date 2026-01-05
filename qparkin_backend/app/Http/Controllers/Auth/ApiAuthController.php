<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use App\Models\User;
use App\Models\OtpVerification;
use App\Mail\OtpMail;
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

            // Generate OTP 6 digit
            $otpCode = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

            // Hapus OTP lama untuk nomor HP ini (jika ada)
            OtpVerification::where('nomor_hp', $request->nomor_hp)->delete();

            // Simpan OTP ke database (berlaku 5 menit)
            OtpVerification::create([
                'nomor_hp' => $request->nomor_hp,
                'otp_code' => $otpCode,
                'expires_at' => now()->addMinutes(5),
                'is_verified' => false,
            ]);

            // Simpan data registrasi sementara di session/cache
            // Untuk sementara kita simpan di OTP table sebagai metadata
            // Atau bisa gunakan cache Laravel
            cache()->put(
                'register_data_' . $request->nomor_hp,
                [
                    'nama' => $request->nama,
                    'nomor_hp' => $request->nomor_hp,
                    'pin' => $request->pin,
                ],
                now()->addMinutes(10) // Cache 10 menit
            );

            // Kirim OTP via email (simulasi SMS)
            // Email dummy: nomor_hp@qparkin.test
            $dummyEmail = str_replace(['+', ' ', '-'], '', $request->nomor_hp) . '@qparkin.test';
            
            Mail::to($dummyEmail)->send(new OtpMail($otpCode, $request->nama, $request->nomor_hp));

            return response()->json([
                'success' => true,
                'message' => 'OTP telah dikirim. Silakan cek email Mailtrap.',
                'nomor_hp' => $request->nomor_hp,
                'debug_email' => $dummyEmail, // Untuk development
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error during registration: ' . $e->getMessage()
            ], 500);
        }
    }

    public function verifyOtp(Request $request)
    {
        // Validasi input
        $request->validate([
            'nomor_hp' => 'required|string',
            'otp_code' => 'required|string|size:6'
        ]);

        try {
            // Cari OTP yang belum diverifikasi
            $otpRecord = OtpVerification::where('nomor_hp', $request->nomor_hp)
                ->where('is_verified', false)
                ->latest()
                ->first();

            if (!$otpRecord) {
                return response()->json([
                    'success' => false,
                    'message' => 'Kode OTP tidak ditemukan atau sudah digunakan.'
                ], 404);
            }

            // Cek apakah OTP sudah kedaluwarsa
            if ($otpRecord->isExpired()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Kode OTP sudah kedaluwarsa. Silakan minta OTP baru.'
                ], 400);
            }

            // Verifikasi kode OTP
            if (!$otpRecord->isValid($request->otp_code)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Kode OTP salah. Silakan coba lagi.'
                ], 400);
            }

            // Ambil data registrasi dari cache
            $registerData = cache()->get('register_data_' . $request->nomor_hp);

            if (!$registerData) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data registrasi tidak ditemukan. Silakan daftar ulang.'
                ], 404);
            }

            // Buat user baru
            $user = User::create([
                'name' => $registerData['nama'],
                'nomor_hp' => $registerData['nomor_hp'],
                'password' => Hash::make($registerData['pin']),
                'role' => 'customer',
                'status' => 'aktif',
                'saldo_poin' => 0,
            ]);

            // Tandai OTP sebagai terverifikasi
            $otpRecord->update(['is_verified' => true]);

            // Hapus cache data registrasi
            cache()->forget('register_data_' . $request->nomor_hp);

            return response()->json([
                'success' => true,
                'message' => 'Verifikasi berhasil! Akun Anda telah aktif.',
                'user' => [
                    'id_user' => $user->id_user,
                    'name' => $user->name,
                    'nomor_hp' => $user->nomor_hp,
                ]
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error during verification: ' . $e->getMessage()
            ], 500);
        }
    }

    public function resendOtp(Request $request)
    {
        // Validasi input
        $request->validate([
            'nomor_hp' => 'required|string'
        ]);

        try {
            // Cek apakah ada data registrasi di cache
            $registerData = cache()->get('register_data_' . $request->nomor_hp);

            if (!$registerData) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data registrasi tidak ditemukan. Silakan daftar ulang.'
                ], 404);
            }

            // Generate OTP baru
            $otpCode = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

            // Hapus OTP lama
            OtpVerification::where('nomor_hp', $request->nomor_hp)->delete();

            // Simpan OTP baru
            OtpVerification::create([
                'nomor_hp' => $request->nomor_hp,
                'otp_code' => $otpCode,
                'expires_at' => now()->addMinutes(5),
                'is_verified' => false,
            ]);

            // Kirim OTP via email
            $dummyEmail = str_replace(['+', ' ', '-'], '', $request->nomor_hp) . '@qparkin.test';
            Mail::to($dummyEmail)->send(new OtpMail($otpCode, $registerData['nama'], $request->nomor_hp));

            return response()->json([
                'success' => true,
                'message' => 'OTP baru telah dikirim.',
                'debug_email' => $dummyEmail,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error resending OTP: ' . $e->getMessage()
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


<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class WebAuthController extends Controller
{
    public function showLoginForm()
    {
        return view('auth.signin');
    }

    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => 'required|email',
            'password' => 'required'
        ]);

        $email = $credentials['email'];
        $loginAttemptService = app(\App\Services\LoginAttemptService::class);

        // Check if account is locked (double check)
        if ($loginAttemptService->isAccountLocked($email)) {
            $lockout = $loginAttemptService->getActiveLockout($email);
            
            if ($lockout) {
                return back()->withErrors([
                    'email' => 'Akun Anda terkunci karena terlalu banyak percobaan login yang gagal. ' .
                               'Silakan coba lagi dalam ' . $lockout->getRemainingTime() . '.'
                ])->withInput($request->only('email'));
            }
        }

        $user = User::where('email', $email)->first();

        if ($user && Hash::check($credentials['password'], $user->password)) {
            // Record successful login
            $loginAttemptService->recordAttempt($email, true);

            Auth::login($user);
            $request->session()->regenerate();

            // Redirect based on role
            if ($user->isSuperAdmin()) {
                return redirect()->intended(route('superadmin.dashboard'));
            } elseif ($user->isAdminMall()) {
                return redirect()->intended(route('admin.dashboard'));
            }

            // Default redirect for other roles
            return redirect()->intended('/');
        }

        // Record failed login attempt
        $loginAttemptService->recordAttempt($email, false);

        // Check if account should be locked after this failed attempt
        if ($loginAttemptService->shouldLockAccount($email)) {
            $lockout = $loginAttemptService->lockAccount($email);
            
            return back()->withErrors([
                'email' => 'Terlalu banyak percobaan login yang gagal. Akun Anda telah dikunci selama ' . 
                           $lockout->getRemainingTime() . '. Silakan coba lagi nanti.'
            ])->withInput($request->only('email'));
        }

        // Show remaining attempts
        $remainingAttempts = $loginAttemptService->getRemainingAttempts($email);
        $errorMessage = 'Email atau password tidak cocok dengan data kami.';
        
        if ($remainingAttempts > 0 && $remainingAttempts <= 3) {
            $errorMessage .= ' Sisa percobaan: ' . $remainingAttempts . ' kali.';
        }

        return back()->withErrors([
            'email' => $errorMessage,
        ])->withInput($request->only('email'));
    }

    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        
        return redirect()->route('signin');
    }

    public function sendResetLink(Request $request)
    {
        $request->validate(['email' => 'required|email']);
        
        // Logic untuk send reset link
        return back()->with('status', 'Password reset link sent!');
    }
}

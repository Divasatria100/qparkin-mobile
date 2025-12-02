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
            'name' => 'required',
            'password' => 'required'
        ]);

        $user = User::where('name', $credentials['name'])->first();

        if ($user && Hash::check($credentials['password'], $user->password)) {
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

        return back()->withErrors([
            'name' => 'Kredensial tidak cocok dengan data kami.',
        ])->withInput($request->only('name'));
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

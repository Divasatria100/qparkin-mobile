<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class CheckRole
{
    public function handle(Request $request, Closure $next, string $role)
    {
        if (!Auth::check()) {
            return redirect()->route('login');
        }

        $user = Auth::user();
        $userRole = $user->role ?? null;

        // Map role names
        $roleMap = [
            'admin' => 'admin_mall',
            'superadmin' => 'super_admin',
        ];

        $expectedRole = $roleMap[$role] ?? $role;

        if ($userRole !== $expectedRole) {
            abort(403, 'Unauthorized access');
        }

        return $next($request);
    }
}

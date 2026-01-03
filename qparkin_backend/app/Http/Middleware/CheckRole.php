<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class CheckRole
{
    public function handle(Request $request, Closure $next, string $role)
    {
        // Middleware auth sudah handle pengecekan login, jadi tidak perlu cek lagi di sini
        // Ini mencegah redirect loop antara guest dan auth middleware
        
        $user = Auth::user();
        
        if (!$user) {
            // Jika somehow user null (seharusnya tidak terjadi karena middleware auth),
            // abort dengan 401 daripada redirect untuk menghindari loop
            abort(401, 'Unauthenticated');
        }

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

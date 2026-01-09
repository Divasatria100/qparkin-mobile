<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use App\Services\LoginAttemptService;
use Symfony\Component\HttpFoundation\Response;

class CheckLoginAttempts
{
    protected LoginAttemptService $loginAttemptService;

    public function __construct(LoginAttemptService $loginAttemptService)
    {
        $this->loginAttemptService = $loginAttemptService;
    }

    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Only check for login attempts on POST requests with email
        if ($request->isMethod('post') && $request->has('email')) {
            $email = $request->input('email');

            // Check if account is locked
            if ($this->loginAttemptService->isAccountLocked($email)) {
                $lockout = $this->loginAttemptService->getActiveLockout($email);
                
                if ($lockout) {
                    return back()->withErrors([
                        'email' => 'Akun Anda terkunci karena terlalu banyak percobaan login yang gagal. ' .
                                   'Silakan coba lagi dalam ' . $lockout->getRemainingTime() . '.'
                    ])->withInput($request->only('email'));
                }
            }

            // Add remaining attempts info to request
            $remainingAttempts = $this->loginAttemptService->getRemainingAttempts($email);
            $request->merge(['remaining_attempts' => $remainingAttempts]);
        }

        return $next($request);
    }
}

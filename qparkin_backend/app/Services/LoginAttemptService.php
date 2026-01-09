<?php

namespace App\Services;

use App\Models\LoginAttempt;
use App\Models\AccountLockout;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class LoginAttemptService
{
    // Configuration
    private const MAX_ATTEMPTS = 5;
    private const LOCKOUT_DURATION_MINUTES = 15;
    private const ATTEMPT_WINDOW_MINUTES = 15;

    /**
     * Record a login attempt
     */
    public function recordAttempt(string $email, bool $isSuccessful, ?string $ipAddress = null, ?string $userAgent = null): void
    {
        LoginAttempt::create([
            'email' => $email,
            'ip_address' => $ipAddress ?? request()->ip(),
            'user_agent' => $userAgent ?? request()->userAgent(),
            'is_successful' => $isSuccessful,
            'attempted_at' => Carbon::now(),
        ]);

        // If successful, clear any existing lockout
        if ($isSuccessful) {
            $this->clearLockout($email);
        }
    }

    /**
     * Check if account should be locked
     */
    public function shouldLockAccount(string $email): bool
    {
        $failedAttempts = LoginAttempt::getFailedAttempts($email, self::ATTEMPT_WINDOW_MINUTES);
        return $failedAttempts >= self::MAX_ATTEMPTS;
    }

    /**
     * Lock an account
     */
    public function lockAccount(string $email): AccountLockout
    {
        $lockout = AccountLockout::lockAccount($email, self::LOCKOUT_DURATION_MINUTES);

        // Log the lockout
        Log::warning('Account locked due to too many failed login attempts', [
            'email' => $email,
            'ip_address' => request()->ip(),
            'locked_until' => $lockout->locked_until,
        ]);

        return $lockout;
    }

    /**
     * Check if account is locked
     */
    public function isAccountLocked(string $email): bool
    {
        return AccountLockout::isEmailLocked($email);
    }

    /**
     * Get active lockout information
     */
    public function getActiveLockout(string $email): ?AccountLockout
    {
        return AccountLockout::getActiveLockout($email);
    }

    /**
     * Clear lockout for an email
     */
    public function clearLockout(string $email): void
    {
        AccountLockout::where('email', $email)->delete();
    }

    /**
     * Get failed attempts count
     */
    public function getFailedAttemptsCount(string $email): int
    {
        return LoginAttempt::getFailedAttempts($email, self::ATTEMPT_WINDOW_MINUTES);
    }

    /**
     * Get remaining attempts before lockout
     */
    public function getRemainingAttempts(string $email): int
    {
        $failedAttempts = $this->getFailedAttemptsCount($email);
        $remaining = self::MAX_ATTEMPTS - $failedAttempts;
        return max(0, $remaining);
    }

    /**
     * Get configuration values
     */
    public function getConfig(): array
    {
        return [
            'max_attempts' => self::MAX_ATTEMPTS,
            'lockout_duration_minutes' => self::LOCKOUT_DURATION_MINUTES,
            'attempt_window_minutes' => self::ATTEMPT_WINDOW_MINUTES,
        ];
    }

    /**
     * Cleanup old records
     */
    public function cleanup(): array
    {
        $deletedAttempts = LoginAttempt::clearOldAttempts(30);
        $deletedLockouts = AccountLockout::cleanupExpired();

        return [
            'deleted_attempts' => $deletedAttempts,
            'deleted_lockouts' => $deletedLockouts,
        ];
    }
}

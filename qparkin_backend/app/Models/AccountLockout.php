<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;
use Illuminate\Support\Str;

class AccountLockout extends Model
{
    protected $fillable = [
        'email',
        'locked_at',
        'locked_until',
        'reason',
        'unlock_token',
    ];

    protected $casts = [
        'locked_at' => 'datetime',
        'locked_until' => 'datetime',
    ];

    /**
     * Check if account is currently locked
     */
    public function isLocked(): bool
    {
        return $this->locked_until > Carbon::now();
    }

    /**
     * Get remaining lockout time in minutes
     */
    public function getRemainingMinutes(): int
    {
        if (!$this->isLocked()) {
            return 0;
        }
        return (int) Carbon::now()->diffInMinutes($this->locked_until, false);
    }

    /**
     * Get remaining lockout time in human readable format
     */
    public function getRemainingTime(): string
    {
        if (!$this->isLocked()) {
            return '0 menit';
        }
        
        $minutes = $this->getRemainingMinutes();
        
        if ($minutes >= 60) {
            $hours = floor($minutes / 60);
            $mins = $minutes % 60;
            return $hours . ' jam ' . $mins . ' menit';
        }
        
        return $minutes . ' menit';
    }

    /**
     * Check if email is locked
     */
    public static function isEmailLocked(string $email): bool
    {
        $lockout = self::where('email', $email)->first();
        
        if (!$lockout) {
            return false;
        }

        // If lockout expired, delete it
        if (!$lockout->isLocked()) {
            $lockout->delete();
            return false;
        }

        return true;
    }

    /**
     * Get active lockout for email
     */
    public static function getActiveLockout(string $email): ?self
    {
        $lockout = self::where('email', $email)->first();
        
        if (!$lockout) {
            return null;
        }

        if (!$lockout->isLocked()) {
            $lockout->delete();
            return null;
        }

        return $lockout;
    }

    /**
     * Lock an account
     */
    public static function lockAccount(string $email, int $minutes = 15, string $reason = 'Too many failed login attempts'): self
    {
        // Delete existing lockout if any
        self::where('email', $email)->delete();

        return self::create([
            'email' => $email,
            'locked_at' => Carbon::now(),
            'locked_until' => Carbon::now()->addMinutes($minutes),
            'reason' => $reason,
            'unlock_token' => Str::random(64),
        ]);
    }

    /**
     * Unlock account
     */
    public function unlock(): bool
    {
        return $this->delete();
    }

    /**
     * Clean up expired lockouts
     */
    public static function cleanupExpired(): int
    {
        return self::where('locked_until', '<', Carbon::now())->delete();
    }
}

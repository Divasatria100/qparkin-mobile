<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class LoginAttempt extends Model
{
    protected $fillable = [
        'email',
        'ip_address',
        'user_agent',
        'is_successful',
        'attempted_at',
    ];

    protected $casts = [
        'is_successful' => 'boolean',
        'attempted_at' => 'datetime',
    ];

    public $timestamps = false;

    /**
     * Get failed attempts for an email within timeframe
     */
    public static function getFailedAttempts(string $email, int $minutes = 15): int
    {
        return self::where('email', $email)
            ->where('is_successful', false)
            ->where('attempted_at', '>=', Carbon::now()->subMinutes($minutes))
            ->count();
    }

    /**
     * Clear old attempts (cleanup)
     */
    public static function clearOldAttempts(int $days = 30): int
    {
        return self::where('attempted_at', '<', Carbon::now()->subDays($days))->delete();
    }

    /**
     * Get recent attempts for email
     */
    public static function getRecentAttempts(string $email, int $limit = 10)
    {
        return self::where('email', $email)
            ->orderBy('attempted_at', 'desc')
            ->limit($limit)
            ->get();
    }
}

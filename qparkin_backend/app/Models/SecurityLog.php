<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class SecurityLog extends Model
{
    protected $fillable = [
        'type',
        'severity',
        'ip_address',
        'user_agent',
        'url',
        'method',
        'payload',
        'detected_at',
    ];

    protected $casts = [
        'detected_at' => 'datetime',
        'payload' => 'array',
    ];

    /**
     * Get logs by type
     */
    public static function getByType(string $type, int $limit = 50)
    {
        return self::where('type', $type)
            ->orderBy('detected_at', 'desc')
            ->limit($limit)
            ->get();
    }

    /**
     * Get logs by severity
     */
    public static function getBySeverity(string $severity, int $limit = 50)
    {
        return self::where('severity', $severity)
            ->orderBy('detected_at', 'desc')
            ->limit($limit)
            ->get();
    }

    /**
     * Get recent logs
     */
    public static function getRecent(int $limit = 50)
    {
        return self::orderBy('detected_at', 'desc')
            ->limit($limit)
            ->get();
    }

    /**
     * Get logs by IP
     */
    public static function getByIp(string $ip, int $limit = 50)
    {
        return self::where('ip_address', $ip)
            ->orderBy('detected_at', 'desc')
            ->limit($limit)
            ->get();
    }

    /**
     * Get statistics
     */
    public static function getStatistics(int $days = 7): array
    {
        $startDate = Carbon::now()->subDays($days);

        return [
            'total_attempts' => self::where('detected_at', '>=', $startDate)->count(),
            'by_severity' => self::where('detected_at', '>=', $startDate)
                ->selectRaw('severity, COUNT(*) as count')
                ->groupBy('severity')
                ->pluck('count', 'severity')
                ->toArray(),
            'by_type' => self::where('detected_at', '>=', $startDate)
                ->selectRaw('type, COUNT(*) as count')
                ->groupBy('type')
                ->pluck('count', 'type')
                ->toArray(),
            'top_ips' => self::where('detected_at', '>=', $startDate)
                ->selectRaw('ip_address, COUNT(*) as count')
                ->groupBy('ip_address')
                ->orderByDesc('count')
                ->limit(10)
                ->get()
                ->toArray(),
        ];
    }

    /**
     * Clean old logs
     */
    public static function cleanOldLogs(int $days = 90): int
    {
        return self::where('detected_at', '<', Carbon::now()->subDays($days))->delete();
    }
}

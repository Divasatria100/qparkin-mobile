<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Symfony\Component\HttpFoundation\Response;

class SqlInjectionDetector
{
    /**
     * SQL Injection patterns to detect
     */
    private const SQL_INJECTION_PATTERNS = [
        // Basic SQL keywords
        '/(\bUNION\b.*\bSELECT\b)/i',
        '/(\bSELECT\b.*\bFROM\b)/i',
        '/(\bINSERT\b.*\bINTO\b)/i',
        '/(\bUPDATE\b.*\bSET\b)/i',
        '/(\bDELETE\b.*\bFROM\b)/i',
        '/(\bDROP\b.*\bTABLE\b)/i',
        '/(\bCREATE\b.*\bTABLE\b)/i',
        '/(\bALTER\b.*\bTABLE\b)/i',
        '/(\bTRUNCATE\b.*\bTABLE\b)/i',
        
        // SQL comments
        '/(--|\#|\/\*|\*\/)/i',
        
        // SQL operators and functions
        '/(\bOR\b.*=.*)/i',
        '/(\bAND\b.*=.*)/i',
        '/(\'.*OR.*\'.*=.*\')/i',
        '/(\".*OR.*\".*=.*\")/i',
        '/(\bEXEC\b|\bEXECUTE\b)/i',
        '/(\bSLEEP\b|\bBENCHMARK\b)/i',
        
        // Special characters combinations
        '/(\'|\")(\s)*(OR|AND)(\s)*(\d+)(\s)*=(\s)*(\d+)/i',
        '/(\%27)|(\')|(--)|(\%23)|(#)/i',
        '/(;|\||`|&|\$|\(|\)|\[|\]|\{|\})/i',
        
        // Hex encoding
        '/(0x[0-9a-f]+)/i',
        
        // Information schema
        '/(\bINFORMATION_SCHEMA\b)/i',
        
        // Time-based blind SQL injection
        '/(\bWAITFOR\b.*\bDELAY\b)/i',
        '/(\bpg_sleep\b)/i',
    ];

    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Check all input fields
        $allInputs = $request->all();
        $detectedThreats = [];

        foreach ($allInputs as $key => $value) {
            if (is_string($value)) {
                $threats = $this->detectSqlInjection($key, $value);
                if (!empty($threats)) {
                    $detectedThreats[$key] = $threats;
                }
            }
        }

        // Log if SQL injection detected
        if (!empty($detectedThreats)) {
            $this->logSqlInjectionAttempt($request, $detectedThreats);
            
            // In production, you might want to block the request
            // return response()->json(['error' => 'Invalid input detected'], 400);
        }

        return $next($request);
    }

    /**
     * Detect SQL injection patterns in input
     */
    private function detectSqlInjection(string $fieldName, string $value): array
    {
        $threats = [];

        foreach (self::SQL_INJECTION_PATTERNS as $pattern) {
            if (preg_match($pattern, $value, $matches)) {
                $threats[] = [
                    'pattern' => $pattern,
                    'matched' => $matches[0] ?? $value,
                    'severity' => $this->calculateSeverity($pattern),
                ];
            }
        }

        return $threats;
    }

    /**
     * Calculate threat severity
     */
    private function calculateSeverity(string $pattern): string
    {
        // High severity patterns
        $highSeverity = [
            '/(\bDROP\b.*\bTABLE\b)/i',
            '/(\bTRUNCATE\b.*\bTABLE\b)/i',
            '/(\bDELETE\b.*\bFROM\b)/i',
            '/(\bEXEC\b|\bEXECUTE\b)/i',
        ];

        // Medium severity patterns
        $mediumSeverity = [
            '/(\bUNION\b.*\bSELECT\b)/i',
            '/(\bINSERT\b.*\bINTO\b)/i',
            '/(\bUPDATE\b.*\bSET\b)/i',
            '/(\bINFORMATION_SCHEMA\b)/i',
        ];

        if (in_array($pattern, $highSeverity)) {
            return 'HIGH';
        } elseif (in_array($pattern, $mediumSeverity)) {
            return 'MEDIUM';
        }

        return 'LOW';
    }

    /**
     * Log SQL injection attempt
     */
    private function logSqlInjectionAttempt(Request $request, array $threats): void
    {
        $logData = [
            'timestamp' => now()->toDateTimeString(),
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'url' => $request->fullUrl(),
            'method' => $request->method(),
            'threats_detected' => $threats,
            'all_inputs' => $request->except(['password', 'password_confirmation']),
        ];

        // Log to Laravel log
        Log::channel('security')->warning('SQL Injection Attempt Detected', $logData);

        // Also log to database for reporting
        \App\Models\SecurityLog::create([
            'type' => 'sql_injection_attempt',
            'severity' => $this->getHighestSeverity($threats),
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'url' => $request->fullUrl(),
            'method' => $request->method(),
            'payload' => json_encode($logData),
            'detected_at' => now(),
        ]);
    }

    /**
     * Get highest severity from threats
     */
    private function getHighestSeverity(array $threats): string
    {
        $severities = ['HIGH', 'MEDIUM', 'LOW'];
        
        foreach ($severities as $severity) {
            foreach ($threats as $fieldThreats) {
                foreach ($fieldThreats as $threat) {
                    if ($threat['severity'] === $severity) {
                        return $severity;
                    }
                }
            }
        }

        return 'LOW';
    }
}

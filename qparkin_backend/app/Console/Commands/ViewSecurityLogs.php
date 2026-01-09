<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\SecurityLog;

class ViewSecurityLogs extends Command
{
    protected $signature = 'security:logs 
                            {--type= : Filter by type (sql_injection_attempt, xss_attempt)}
                            {--severity= : Filter by severity (LOW, MEDIUM, HIGH)}
                            {--ip= : Filter by IP address}
                            {--limit=20 : Number of logs to display}
                            {--stats : Show statistics}';

    protected $description = 'View security logs and statistics';

    public function handle(): int
    {
        if ($this->option('stats')) {
            return $this->showStatistics();
        }

        $query = SecurityLog::query();

        // Apply filters
        if ($type = $this->option('type')) {
            $query->where('type', $type);
        }

        if ($severity = $this->option('severity')) {
            $query->where('severity', strtoupper($severity));
        }

        if ($ip = $this->option('ip')) {
            $query->where('ip_address', $ip);
        }

        $limit = (int) $this->option('limit');
        $logs = $query->orderBy('detected_at', 'desc')->limit($limit)->get();

        if ($logs->isEmpty()) {
            $this->info('No security logs found.');
            return Command::SUCCESS;
        }

        $this->info('Security Logs (' . $logs->count() . ' records)');
        $this->line('');

        foreach ($logs as $log) {
            $this->displayLog($log);
        }

        return Command::SUCCESS;
    }

    private function displayLog(SecurityLog $log): void
    {
        $severityColor = match($log->severity) {
            'HIGH' => 'red',
            'MEDIUM' => 'yellow',
            'LOW' => 'blue',
            default => 'white',
        };

        $this->line('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        $this->line('<fg=' . $severityColor . '>■</> ID: ' . $log->id . ' | Severity: <fg=' . $severityColor . '>' . $log->severity . '</>');
        $this->line('Type: ' . $log->type);
        $this->line('Time: ' . $log->detected_at->format('Y-m-d H:i:s'));
        $this->line('IP: ' . $log->ip_address);
        $this->line('URL: ' . $log->url);
        $this->line('Method: ' . $log->method);
        
        if ($log->payload) {
            $this->line('');
            $this->line('Payload:');
            $payload = is_array($log->payload) ? $log->payload : json_decode($log->payload, true);
            
            if (isset($payload['threats_detected'])) {
                foreach ($payload['threats_detected'] as $field => $threats) {
                    $this->line('  Field: <fg=cyan>' . $field . '</>');
                    foreach ($threats as $threat) {
                        $this->line('    - Matched: <fg=red>' . ($threat['matched'] ?? 'N/A') . '</>');
                        $this->line('      Severity: ' . ($threat['severity'] ?? 'N/A'));
                    }
                }
            }
            
            if (isset($payload['all_inputs'])) {
                $this->line('');
                $this->line('  All Inputs:');
                foreach ($payload['all_inputs'] as $key => $value) {
                    $displayValue = is_string($value) ? $value : json_encode($value);
                    $this->line('    ' . $key . ': ' . $displayValue);
                }
            }
        }
        
        $this->line('');
    }

    private function showStatistics(): int
    {
        $this->info('Security Statistics (Last 7 Days)');
        $this->line('');

        $stats = SecurityLog::getStatistics(7);

        $this->line('Total Attempts: <fg=yellow>' . $stats['total_attempts'] . '</>');
        $this->line('');

        if (!empty($stats['by_severity'])) {
            $this->line('By Severity:');
            foreach ($stats['by_severity'] as $severity => $count) {
                $color = match($severity) {
                    'HIGH' => 'red',
                    'MEDIUM' => 'yellow',
                    'LOW' => 'blue',
                    default => 'white',
                };
                $this->line('  <fg=' . $color . '>' . $severity . '</>: ' . $count);
            }
            $this->line('');
        }

        if (!empty($stats['by_type'])) {
            $this->line('By Type:');
            foreach ($stats['by_type'] as $type => $count) {
                $this->line('  ' . $type . ': ' . $count);
            }
            $this->line('');
        }

        if (!empty($stats['top_ips'])) {
            $this->line('Top 10 IPs:');
            foreach ($stats['top_ips'] as $ipData) {
                $this->line('  ' . $ipData['ip_address'] . ': ' . $ipData['count'] . ' attempts');
            }
        }

        return Command::SUCCESS;
    }
}

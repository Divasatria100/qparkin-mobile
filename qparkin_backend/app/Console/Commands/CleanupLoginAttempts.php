<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Services\LoginAttemptService;

class CleanupLoginAttempts extends Command
{
    protected $signature = 'login:cleanup';
    protected $description = 'Cleanup old login attempts and expired lockouts';

    public function handle(LoginAttemptService $service): int
    {
        $this->info('Cleaning up old login attempts and expired lockouts...');

        $result = $service->cleanup();

        $this->info('Deleted ' . $result['deleted_attempts'] . ' old login attempts');
        $this->info('Deleted ' . $result['deleted_lockouts'] . ' expired lockouts');
        $this->info('Cleanup completed successfully!');

        return Command::SUCCESS;
    }
}

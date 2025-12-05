<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;
use App\Models\SlotReservation;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Cleanup expired slot reservations every minute
Schedule::call(function () {
    $expiredReservations = SlotReservation::expired()->get();
    
    foreach ($expiredReservations as $reservation) {
        $reservation->expire();
    }
    
    if ($expiredReservations->count() > 0) {
        \Illuminate\Support\Facades\Log::info("Cleaned up {$expiredReservations->count()} expired slot reservations");
    }
})->everyMinute()->name('cleanup-expired-reservations');

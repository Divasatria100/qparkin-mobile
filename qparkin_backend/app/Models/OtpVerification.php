<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class OtpVerification extends Model
{
    protected $fillable = [
        'nomor_hp',
        'otp_code',
        'expires_at',
        'is_verified',
    ];

    protected $casts = [
        'expires_at' => 'datetime',
        'is_verified' => 'boolean',
    ];

    /**
     * Check if OTP is expired
     */
    public function isExpired(): bool
    {
        return now()->isAfter($this->expires_at);
    }

    /**
     * Check if OTP is valid
     */
    public function isValid(string $code): bool
    {
        return !$this->is_verified 
            && !$this->isExpired() 
            && $this->otp_code === $code;
    }
}

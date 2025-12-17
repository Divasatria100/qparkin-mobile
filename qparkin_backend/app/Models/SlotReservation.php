<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;
use Carbon\Carbon;

class SlotReservation extends Model
{
    use HasFactory;

    protected $table = 'slot_reservations';
    protected $primaryKey = 'id_reservation';

    protected $fillable = [
        'reservation_id',
        'id_slot',
        'id_user',
        'id_kendaraan',
        'id_floor',
        'status',
        'reserved_at',
        'expires_at',
        'confirmed_at'
    ];

    protected $casts = [
        'reserved_at' => 'datetime',
        'expires_at' => 'datetime',
        'confirmed_at' => 'datetime',
    ];

    /**
     * Boot method untuk auto-generate UUID
     */
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($model) {
            if (empty($model->reservation_id)) {
                $model->reservation_id = (string) Str::uuid();
            }
            
            // Set expires_at to 5 minutes from now if not set
            if (empty($model->expires_at)) {
                $model->expires_at = Carbon::now()->addMinutes(5);
            }
        });
    }

    /**
     * Relasi ke ParkingSlot
     */
    public function slot()
    {
        return $this->belongsTo(ParkingSlot::class, 'id_slot', 'id_slot');
    }

    /**
     * Relasi ke User
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'id_user', 'id_user');
    }

    /**
     * Relasi ke Kendaraan
     */
    public function kendaraan()
    {
        return $this->belongsTo(Kendaraan::class, 'id_kendaraan', 'id_kendaraan');
    }

    /**
     * Relasi ke ParkingFloor
     */
    public function floor()
    {
        return $this->belongsTo(ParkingFloor::class, 'id_floor', 'id_floor');
    }

    /**
     * Scope untuk reservasi aktif
     */
    public function scopeActive($query)
    {
        return $query->where('status', 'active')
                     ->where('expires_at', '>', Carbon::now());
    }

    /**
     * Scope untuk reservasi expired
     */
    public function scopeExpired($query)
    {
        return $query->where('status', 'active')
                     ->where('expires_at', '<=', Carbon::now());
    }

    /**
     * Check if reservation is expired
     */
    public function isExpired()
    {
        return $this->status === 'active' && Carbon::now()->greaterThan($this->expires_at);
    }

    /**
     * Check if reservation is still valid
     */
    public function isValid()
    {
        return $this->status === 'active' && Carbon::now()->lessThan($this->expires_at);
    }

    /**
     * Confirm reservation
     */
    public function confirm()
    {
        $this->update([
            'status' => 'confirmed',
            'confirmed_at' => Carbon::now()
        ]);
    }

    /**
     * Cancel reservation
     */
    public function cancel()
    {
        $this->update(['status' => 'cancelled']);
        
        // Release the slot
        $this->slot->markAsAvailable();
    }

    /**
     * Expire reservation
     */
    public function expire()
    {
        $this->update(['status' => 'expired']);
        
        // Release the slot
        $this->slot->markAsAvailable();
    }

    /**
     * Get remaining time in seconds
     */
    public function getRemainingTimeAttribute()
    {
        if ($this->isExpired()) {
            return 0;
        }
        
        return Carbon::now()->diffInSeconds($this->expires_at, false);
    }
}

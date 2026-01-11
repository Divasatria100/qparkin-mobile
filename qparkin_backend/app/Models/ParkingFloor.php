<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ParkingFloor extends Model
{
    use HasFactory;

    protected $table = 'parking_floors';
    protected $primaryKey = 'id_floor';

    protected $fillable = [
        'id_parkiran',
        'floor_name',
        'floor_number',
        'jenis_kendaraan',
        'total_slots',
        'available_slots',
        'status'
    ];

    protected $casts = [
        'floor_number' => 'integer',
        'total_slots' => 'integer',
        'available_slots' => 'integer',
    ];

    /**
     * Relasi ke Parkiran
     */
    public function parkiran()
    {
        return $this->belongsTo(Parkiran::class, 'id_parkiran', 'id_parkiran');
    }

    /**
     * Relasi ke ParkingSlots
     */
    public function slots()
    {
        return $this->hasMany(ParkingSlot::class, 'id_floor', 'id_floor');
    }

    /**
     * Relasi ke SlotReservations
     */
    public function reservations()
    {
        return $this->hasMany(SlotReservation::class, 'id_floor', 'id_floor');
    }

    /**
     * Scope untuk lantai dengan jenis kendaraan tertentu
     */
    public function scopeForVehicleType($query, $jenisKendaraan)
    {
        return $query->where('jenis_kendaraan', $jenisKendaraan);
    }

    /**
     * Scope untuk lantai aktif
     */
    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    /**
     * Scope untuk lantai dengan slot tersedia
     */
    public function scopeHasAvailableSlots($query)
    {
        return $query->where('available_slots', '>', 0);
    }

    /**
     * Get availability percentage
     */
    public function getAvailabilityPercentageAttribute()
    {
        if ($this->total_slots == 0) {
            return 0;
        }
        return round(($this->available_slots / $this->total_slots) * 100, 2);
    }
}

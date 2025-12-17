<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ParkingSlot extends Model
{
    use HasFactory;

    protected $table = 'parking_slots';
    protected $primaryKey = 'id_slot';

    protected $fillable = [
        'id_floor',
        'slot_code',
        'jenis_kendaraan',
        'status',
        'position_x',
        'position_y'
    ];

    protected $casts = [
        'position_x' => 'integer',
        'position_y' => 'integer',
    ];

    /**
     * Relasi ke ParkingFloor
     */
    public function floor()
    {
        return $this->belongsTo(ParkingFloor::class, 'id_floor', 'id_floor');
    }

    /**
     * Relasi ke TransaksiParkir
     */
    public function transaksiParkir()
    {
        return $this->hasMany(TransaksiParkir::class, 'id_slot', 'id_slot');
    }

    /**
     * Relasi ke Booking
     */
    public function bookings()
    {
        return $this->hasMany(Booking::class, 'id_slot', 'id_slot');
    }

    /**
     * Relasi ke SlotReservations
     */
    public function reservations()
    {
        return $this->hasMany(SlotReservation::class, 'id_slot', 'id_slot');
    }

    /**
     * Scope untuk slot tersedia
     */
    public function scopeAvailable($query)
    {
        return $query->where('status', 'available');
    }

    /**
     * Scope untuk filter berdasarkan jenis kendaraan
     */
    public function scopeForVehicleType($query, $jenisKendaraan)
    {
        return $query->where('jenis_kendaraan', $jenisKendaraan);
    }

    /**
     * Scope untuk slot di lantai tertentu
     */
    public function scopeOnFloor($query, $idFloor)
    {
        return $query->where('id_floor', $idFloor);
    }

    /**
     * Check if slot is available for reservation
     */
    public function isAvailableForReservation()
    {
        return $this->status === 'available';
    }

    /**
     * Mark slot as reserved
     */
    public function markAsReserved()
    {
        $this->update(['status' => 'reserved']);
    }

    /**
     * Mark slot as occupied
     */
    public function markAsOccupied()
    {
        $this->update(['status' => 'occupied']);
    }

    /**
     * Mark slot as available
     */
    public function markAsAvailable()
    {
        $this->update(['status' => 'available']);
    }
}

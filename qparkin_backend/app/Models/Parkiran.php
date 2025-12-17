<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Parkiran extends Model
{
    use HasFactory;

    protected $table = 'parkiran';
    protected $primaryKey = 'id_parkiran';
    public $timestamps = false;

    protected $fillable = [
        'id_mall',
        'nama_parkiran',
        'kode_parkiran',
        'jenis_kendaraan',
        'kapasitas',
        'status',
        'jumlah_lantai'
    ];

    protected $casts = [
        'kapasitas' => 'integer',
        'jumlah_lantai' => 'integer',
    ];

    public function mall()
    {
        return $this->belongsTo(Mall::class, 'id_mall', 'id_mall');
    }

    public function transaksiParkir()
    {
        return $this->hasMany(TransaksiParkir::class, 'id_parkiran', 'id_parkiran');
    }

    public function floors()
    {
        return $this->hasMany(ParkingFloor::class, 'id_parkiran', 'id_parkiran');
    }

    /**
     * Get total available slots across all floors
     */
    public function getTotalAvailableSlotsAttribute()
    {
        return $this->floors()->sum('available_slots');
    }

    /**
     * Get total occupied slots
     */
    public function getTotalOccupiedSlotsAttribute()
    {
        return $this->kapasitas - $this->total_available_slots;
    }

    /**
     * Get utilization percentage
     */
    public function getUtilizationPercentageAttribute()
    {
        if ($this->kapasitas == 0) {
            return 0;
        }
        return round(($this->total_occupied_slots / $this->kapasitas) * 100, 2);
    }

    /**
     * Scope for active parkiran
     */
    public function scopeActive($query)
    {
        return $query->where('status', 'Tersedia');
    }
}
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Kendaraan extends Model
{
    use HasFactory;

    protected $table = 'kendaraan';
    protected $primaryKey = 'id_kendaraan';
    public $timestamps = true; // Enable timestamps

    protected $fillable = [
        'id_user',
        'plat',
        'jenis',
        'merk',
        'tipe',
        'warna',
        'foto_path',
        'is_active'
        // last_used_at TIDAK ada di fillable - hanya diupdate oleh sistem parkir
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'last_used_at' => 'datetime',
    ];

    protected $hidden = [
        'id_user', // Hide internal user ID
    ];

    protected $appends = [
        'foto_url', // Add computed foto URL
    ];

    /**
     * Get full URL for vehicle photo
     */
    public function getFotoUrlAttribute()
    {
        if ($this->foto_path) {
            return url('storage/' . $this->foto_path);
        }
        return null;
    }

    /**
     * Relationship: Vehicle belongs to User
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'id_user', 'id_user');
    }

    /**
     * Relationship: Vehicle has many parking transactions
     */
    public function transaksiParkir()
    {
        return $this->hasMany(TransaksiParkir::class, 'id_kendaraan', 'id_kendaraan');
    }

    /**
     * Update last used timestamp - HANYA dipanggil oleh sistem parkir
     * TIDAK untuk dipanggil dari endpoint API kendaraan
     */
    public function updateLastUsed()
    {
        $this->last_used_at = now();
        $this->save();
    }

    /**
     * Scope: Get only active vehicles
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope: Get vehicles for specific user
     */
    public function scopeForUser($query, $userId)
    {
        return $query->where('id_user', $userId);
    }
}
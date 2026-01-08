<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Mall extends Model
{
    use HasFactory;

    protected $table = 'mall';
    protected $primaryKey = 'id_mall';
    public $timestamps = true; // Database sudah punya created_at/updated_at

    protected $fillable = [
        'nama_mall',
        'kode_mall',
        'kategori',
        'deskripsi',
        'lokasi',
        'latitude',
        'longitude',
        'google_maps_url',
        'provinsi',
        'kota',
        'alamat_lengkap',
        'kode_pos',
        'telepon',
        'email',
        'website',
        'kapasitas',
        'slot_mobil',
        'slot_motor',
        'slot_disabilitas',
        'tarif_jam_pertama',
        'tarif_jam_berikutnya',
        'tarif_motor',
        'tarif_maksimal_harian',
        'fasilitas',
        'jam_operasional',
        'status',
        'alamat_gmaps',
        'has_slot_reservation_enabled'
    ];

    protected $casts = [
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
        'has_slot_reservation_enabled' => 'boolean',
        'fasilitas' => 'array',
    ];

    /**
     * Generate Google Maps URL untuk navigasi eksternal
     */
    public static function generateGoogleMapsUrl($latitude, $longitude)
    {
        if ($latitude && $longitude) {
            return "https://www.google.com/maps/dir/?api=1&destination={$latitude},{$longitude}";
        }
        return null;
    }

    /**
     * Validasi koordinat
     */
    public function hasValidCoordinates()
    {
        return $this->latitude !== null 
            && $this->longitude !== null
            && $this->latitude >= -90 
            && $this->latitude <= 90
            && $this->longitude >= -180 
            && $this->longitude <= 180;
    }

    /**
     * Scope untuk mall aktif
     */
    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function adminMall()
    {
        return $this->hasMany(AdminMall::class, 'id_mall', 'id_mall');
    }

    public function parkiran()
    {
        return $this->hasMany(Parkiran::class, 'id_mall', 'id_mall');
    }

    public function tarifParkir()
    {
        return $this->hasMany(TarifParkir::class, 'id_mall', 'id_mall');
    }

    public function transaksiParkir()
    {
        return $this->hasMany(TransaksiParkir::class, 'id_mall', 'id_mall');
    }
}
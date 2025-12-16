<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Mall extends Model
{
    use HasFactory;

    protected $table = 'mall';
    protected $primaryKey = 'id_mall';
    public $timestamps = false; // Tabel mall tidak punya created_at/updated_at

    protected $fillable = [
        'nama_mall',
        'lokasi',
        'kapasitas',
        'alamat_gmaps',
        'has_slot_reservation_enabled'
    ];

    protected $casts = [
        'has_slot_reservation_enabled' => 'boolean',
    ];

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
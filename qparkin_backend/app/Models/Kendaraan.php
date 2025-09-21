<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Kendaraan extends Model
{
    use HasFactory;

    protected $table = 'kendaraan';
    protected $primaryKey = 'id_kendaraan';

    protected $fillable = [
        'id_user',
        'plat',
        'jenis',
        'merk',
        'tipe'
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'id_user', 'id_user');
    }

    public function transaksiParkir()
    {
        return $this->hasMany(TransaksiParkir::class, 'id_kendaraan', 'id_kendaraan');
    }
}
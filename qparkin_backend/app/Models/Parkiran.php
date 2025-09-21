<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Parkiran extends Model
{
    use HasFactory;

    protected $table = 'parkiran';
    protected $primaryKey = 'id_parkiran';

    protected $fillable = [
        'id_mall',
        'jenis_kendaraan',
        'kapasitas',
        'status'
    ];

    public function mall()
    {
        return $this->belongsTo(Mall::class, 'id_mall', 'id_mall');
    }

    public function transaksiParkir()
    {
        return $this->hasMany(TransaksiParkir::class, 'id_parkiran', 'id_parkiran');
    }
}
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TransaksiParkir extends Model
{
    use HasFactory;

    protected $table = 'transaksi_parkir';
    protected $primaryKey = 'id_transaksi';

    protected $fillable = [
        'id_user',
        'id_kendaraan',
        'id_mall',
        'id_parkiran',
        'jenis_transaksi',
        'waktu_masuk',
        'waktu_keluar',
        'durasi',
        'biaya',
        'penalty'
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'id_user', 'id_user');
    }

    public function kendaraan()
    {
        return $this->belongsTo(Kendaraan::class, 'id_kendaraan', 'id_kendaraan');
    }

    public function mall()
    {
        return $this->belongsTo(Mall::class, 'id_mall', 'id_mall');
    }

    public function parkiran()
    {
        return $this->belongsTo(Parkiran::class, 'id_parkiran', 'id_parkiran');
    }

    public function booking()
    {
        return $this->hasOne(Booking::class, 'id_transaksi', 'id_transaksi');
    }

    public function pembayaran()
    {
        return $this->hasOne(Pembayaran::class, 'id_transaksi', 'id_transaksi');
    }
}
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RiwayatPoin extends Model
{
    use HasFactory;

    protected $table = 'riwayat_poin';
    protected $primaryKey = 'id_poin';

    protected $fillable = [
        'id_user',
        'id_transaksi',
        'poin',
        'perubahan',
        'keterangan',
        'waktu'
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'id_user', 'id_user');
    }

    public function transaksiParkir()
    {
        return $this->belongsTo(TransaksiParkir::class, 'id_transaksi', 'id_transaksi');
    }
}
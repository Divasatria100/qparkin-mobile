<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Pembayaran extends Model
{
    use HasFactory;

    protected $table = 'pembayaran';
    protected $primaryKey = 'id_pembayaran';

    protected $fillable = [
        'id_transaksi',
        'metode',
        'nominal',
        'status',
        'waktu_bayar'
    ];

    public function transaksiParkir()
    {
        return $this->belongsTo(TransaksiParkir::class, 'id_transaksi', 'id_transaksi');
    }
}
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Booking extends Model
{
    use HasFactory;

    protected $table = 'booking';
    protected $primaryKey = 'id_transaksi';

    protected $fillable = [
        'waktu_mulai',
        'waktu_selesai',
        'durasi_booking',
        'status',
        'dibooking_pada'
    ];

    public function transaksiParkir()
    {
        return $this->belongsTo(TransaksiParkir::class, 'id_transaksi', 'id_transaksi');
    }
}
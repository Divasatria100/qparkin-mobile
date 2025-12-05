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
        'id_slot',
        'reservation_id',
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

    public function slot()
    {
        return $this->belongsTo(ParkingSlot::class, 'id_slot', 'id_slot');
    }

    public function reservation()
    {
        return $this->hasOne(SlotReservation::class, 'reservation_id', 'reservation_id');
    }
}
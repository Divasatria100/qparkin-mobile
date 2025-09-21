<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TarifParkir extends Model
{
    use HasFactory;

    protected $table = 'tarif_parkir';
    protected $primaryKey = 'id_tarif';

    protected $fillable = [
        'id_mall',
        'jenis_kendaraan',
        'satu_jam_pertama',
        'tarif_parkir_per_jam'
    ];

    public function mall()
    {
        return $this->belongsTo(Mall::class, 'id_mall', 'id_mall');
    }
}
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RiwayatTarif extends Model
{
    use HasFactory;

    protected $table = 'riwayat_tarif';
    protected $primaryKey = 'id_riwayat';

    protected $fillable = [
        'id_tarif',
        'id_mall',
        'id_user',
        'jenis_kendaraan',
        'tarif_lama_jam_pertama',
        'tarif_lama_per_jam',
        'tarif_baru_jam_pertama',
        'tarif_baru_per_jam',
        'keterangan',
    ];

    protected $casts = [
        'tarif_lama_jam_pertama' => 'decimal:2',
        'tarif_lama_per_jam' => 'decimal:2',
        'tarif_baru_jam_pertama' => 'decimal:2',
        'tarif_baru_per_jam' => 'decimal:2',
    ];

    public function tarif()
    {
        return $this->belongsTo(TarifParkir::class, 'id_tarif', 'id_tarif');
    }

    public function mall()
    {
        return $this->belongsTo(Mall::class, 'id_mall', 'id_mall');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'id_user', 'id_user');
    }
}

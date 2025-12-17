<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AdminMall extends Model
{
    use HasFactory;

    protected $table = 'admin_mall';
    protected $primaryKey = 'id_user';
    public $timestamps = false; // Tabel admin_mall tidak punya created_at/updated_at

    protected $fillable = [
        'id_user',
        'id_mall',
        'hak_akses'
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'id_user', 'id_user');
    }

    public function mall()
    {
        return $this->belongsTo(Mall::class, 'id_mall', 'id_mall');
    }
}
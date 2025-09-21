<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Customer extends Model
{
    use HasFactory;

    protected $table = 'customer';
    protected $primaryKey = 'id_user';

    protected $fillable = [
        'id_user',
        'no_hp'
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'id_user', 'id_user');
    }

    public function kendaraan()
    {
        return $this->hasMany(Kendaraan::class, 'id_user', 'id_user');
    }
}
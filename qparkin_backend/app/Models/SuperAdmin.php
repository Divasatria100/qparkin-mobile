<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SuperAdmin extends Model
{
    use HasFactory;

    protected $table = 'super_admin';
    protected $primaryKey = 'id_user';

    protected $fillable = [
        'id_user',
        'hak_akses'
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'id_user', 'id_user');
    }
}
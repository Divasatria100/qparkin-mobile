<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    use HasFactory, Notifiable;

    protected $table = 'user';
    protected $primaryKey = 'id_user';

    protected $fillable = [
        'nama',
        'email',
        'password',
        'role',
        'saldo_poin',
        'status'
    ];

    protected $hidden = [
        'password',
    ];

    protected $casts = [
        'saldo_poin' => 'integer',
    ];

    public function isSuperAdmin()
    {
        return $this->role === 'super_admin';
    }

    public function isAdminMall()
    {
        return $this->role === 'admin_mall';
    }

    public function isCustomer()
    {
        return $this->role === 'customer';
    }

    public function adminMall()
    {
        return $this->hasOne(AdminMall::class, 'id_user', 'id_user');
    }

    public function customer()
    {
        return $this->hasOne(Customer::class, 'id_user', 'id_user');
    }

    public function superAdmin()
    {
        return $this->hasOne(SuperAdmin::class, 'id_user', 'id_user');
    }
}
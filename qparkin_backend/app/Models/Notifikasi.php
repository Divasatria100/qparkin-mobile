<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Notifikasi extends Model
{
    use HasFactory;

    protected $table = 'notifikasi';
    protected $primaryKey = 'id_notifikasi';
    public $timestamps = false;

    protected $fillable = [
        'id_user',
        'pesan',
        'waktu_kirim',
        'status'
    ];

    protected $casts = [
        'waktu_kirim' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'id_user', 'id_user');
    }

    public function scopeUnread($query)
    {
        return $query->where('status', 'belum');
    }

    public function scopeRead($query)
    {
        return $query->where('status', 'terbaca');
    }

    public function markAsRead()
    {
        $this->update([
            'status' => 'terbaca'
        ]);
    }
}

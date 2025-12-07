<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Notifikasi extends Model
{
    use HasFactory;

    protected $table = 'notifikasi';
    protected $primaryKey = 'id_notifikasi';

    protected $fillable = [
        'id_user',
        'judul',
        'pesan',
        'kategori',
        'status',
        'dibaca_pada'
    ];

    protected $casts = [
        'dibaca_pada' => 'datetime',
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
        return $query->where('status', 'sudah');
    }

    public function scopeByCategory($query, $category)
    {
        if ($category && $category !== 'all') {
            return $query->where('kategori', $category);
        }
        return $query;
    }

    public function markAsRead()
    {
        $this->update([
            'status' => 'sudah',
            'dibaca_pada' => now()
        ]);
    }
}

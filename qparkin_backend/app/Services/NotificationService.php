<?php

namespace App\Services;

use App\Models\Notifikasi;
use App\Models\User;
use Illuminate\Support\Facades\Log;

class NotificationService
{
    /**
     * Mengirim notifikasi ke user
     * 
     * @param int $userId
     * @param string $pesan
     * @return bool
     */
    public function sendNotification($userId, $pesan)
    {
        // Validasi user_id tidak boleh kosong
        if (empty($userId)) {
            Log::error('NotificationService: user_id kosong');
            return false;
        }

        // Validasi pesan tidak boleh kosong
        if (empty($pesan)) {
            Log::error('NotificationService: pesan kosong');
            return false;
        }

        // Validasi user harus ada di database
        $user = User::find($userId);
        if (!$user) {
            Log::error('NotificationService: user tidak ditemukan', ['user_id' => $userId]);
            return false;
        }

        try {
            Notifikasi::create([
                'id_user' => $userId,
                'pesan' => $pesan,
                'waktu_kirim' => now(),
                'status' => 'belum'
            ]);

            Log::info('NotificationService: notifikasi berhasil dikirim', [
                'user_id' => $userId
            ]);

            return true;
        } catch (\Exception $e) {
            Log::error('NotificationService: gagal menyimpan notifikasi', [
                'error' => $e->getMessage()
            ]);
            return false;
        }
    }

    /**
     * Mengirim notifikasi ke multiple users (bulk)
     * 
     * @param array $userIds
     * @param string $pesan
     * @return array
     */
    public function sendBulkNotification(array $userIds, $pesan)
    {
        $results = [
            'success' => 0,
            'failed' => 0,
            'total' => count($userIds)
        ];

        foreach ($userIds as $userId) {
            if ($this->sendNotification($userId, $pesan)) {
                $results['success']++;
            } else {
                $results['failed']++;
            }
        }

        return $results;
    }

    /**
     * Menghitung jumlah notifikasi yang belum dibaca
     * 
     * @param int $userId
     * @return int
     */
    public function countUnreadNotifications($userId)
    {
        if (empty($userId)) {
            return 0;
        }

        return Notifikasi::where('id_user', $userId)
            ->where('status', 'belum')
            ->count();
    }

    /**
     * Menandai notifikasi sebagai sudah dibaca
     * 
     * @param int $notificationId
     * @return bool
     */
    public function markAsRead($notificationId)
    {
        if (empty($notificationId)) {
            return false;
        }

        $notification = Notifikasi::find($notificationId);
        
        if (!$notification) {
            return false;
        }

        $notification->markAsRead();
        return true;
    }

    /**
     * Validasi format data notifikasi
     * 
     * @param array $data
     * @return bool
     */
    public function validateNotificationData(array $data)
    {
        $requiredFields = ['id_user', 'pesan'];
        
        foreach ($requiredFields as $field) {
            if (!isset($data[$field]) || empty($data[$field])) {
                return false;
            }
        }

        return true;
    }
}

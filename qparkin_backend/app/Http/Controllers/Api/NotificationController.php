<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notifikasi;
use App\Services\NotificationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class NotificationController extends Controller
{
    protected $notificationService;

    public function __construct(NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    /**
     * Mengambil semua notifikasi user
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request)
    {
        $user = $request->user();
        
        $notifications = Notifikasi::where('id_user', $user->id_user)
            ->orderBy('waktu_kirim', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $notifications,
            'unread_count' => $this->notificationService->countUnreadNotifications($user->id_user)
        ]);
    }

    /**
     * Mengirim notifikasi baru
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function send(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'id_user' => 'required|integer|exists:user,id_user',
            'pesan' => 'required|string'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $result = $this->notificationService->sendNotification(
            $request->id_user,
            $request->pesan
        );

        if ($result) {
            return response()->json([
                'success' => true,
                'message' => 'Notifikasi berhasil dikirim'
            ], 201);
        }

        return response()->json([
            'success' => false,
            'message' => 'Gagal mengirim notifikasi'
        ], 500);
    }

    /**
     * Menandai notifikasi sebagai sudah dibaca
     * 
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function markAsRead(Request $request, $id)
    {
        $notification = Notifikasi::find($id);

        if (!$notification) {
            return response()->json([
                'success' => false,
                'message' => 'Notifikasi tidak ditemukan'
            ], 404);
        }

        // Pastikan notifikasi milik user yang sedang login
        if ($notification->id_user !== $request->user()->id_user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        $result = $this->notificationService->markAsRead($id);

        if ($result) {
            return response()->json([
                'success' => true,
                'message' => 'Notifikasi ditandai sebagai sudah dibaca',
                'data' => $notification->fresh()
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'Gagal menandai notifikasi'
        ], 500);
    }

    /**
     * Mengambil jumlah notifikasi yang belum dibaca
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function unreadCount(Request $request)
    {
        $user = $request->user();
        $count = $this->notificationService->countUnreadNotifications($user->id_user);

        return response()->json([
            'success' => true,
            'unread_count' => $count
        ]);
    }
}

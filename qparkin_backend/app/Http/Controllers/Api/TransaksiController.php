<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TransaksiParkir;
use App\Services\TransactionHistoryService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class TransaksiController extends Controller
{
    protected $historyService;

    public function __construct(TransactionHistoryService $historyService)
    {
        $this->historyService = $historyService;
    }

    /**
     * Mengambil semua histori transaksi user
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request)
    {
        $user = $request->user();
        
        $filters = [];
        if ($request->has('start_date') && $request->has('end_date')) {
            $filters['start_date'] = $request->start_date;
            $filters['end_date'] = $request->end_date;
        }
        
        if ($request->has('jenis_transaksi')) {
            $filters['jenis_transaksi'] = $request->jenis_transaksi;
        }

        $history = $this->historyService->getHistory($user->id_user, $filters);

        return response()->json([
            'success' => true,
            'data' => $history,
            'total' => $history->count()
        ]);
    }

    /**
     * Mengambil detail transaksi by ID
     * 
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function show(Request $request, $id)
    {
        $transaksi = TransaksiParkir::with(['kendaraan', 'mall', 'parkiran', 'user'])
            ->find($id);

        if (!$transaksi) {
            return response()->json([
                'success' => false,
                'message' => 'Transaksi tidak ditemukan'
            ], 404);
        }

        // Pastikan transaksi milik user yang sedang login
        if ($transaksi->id_user !== $request->user()->id_user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => $transaksi
        ]);
    }

    /**
     * Membuat transaksi masuk parkir
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function masuk(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'id_kendaraan' => 'required|integer|exists:kendaraan,id_kendaraan',
            'id_mall' => 'required|integer|exists:mall,id_mall',
            'id_parkiran' => 'required|integer|exists:parkiran,id_parkiran',
            'jenis_transaksi' => 'required|in:umum,booking',
            'id_slot' => 'nullable|integer|exists:parking_slots,id_slot'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();

        $transaksi = TransaksiParkir::create([
            'id_user' => $user->id_user,
            'id_kendaraan' => $request->id_kendaraan,
            'id_mall' => $request->id_mall,
            'id_parkiran' => $request->id_parkiran,
            'id_slot' => $request->id_slot,
            'jenis_transaksi' => $request->jenis_transaksi,
            'waktu_masuk' => now(),
            'waktu_keluar' => null,
            'durasi' => null,
            'biaya' => null,
            'penalty' => 0
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Transaksi masuk berhasil dicatat',
            'data' => $transaksi
        ], 201);
    }

    /**
     * Update transaksi keluar parkir
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function keluar(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'id_transaksi' => 'required|integer|exists:transaksi_parkir,id_transaksi',
            'biaya' => 'required|numeric|min:0',
            'penalty' => 'nullable|numeric|min:0'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $transaksi = TransaksiParkir::find($request->id_transaksi);

        if (!$transaksi) {
            return response()->json([
                'success' => false,
                'message' => 'Transaksi tidak ditemukan'
            ], 404);
        }

        $waktuKeluar = now();
        $durasi = $waktuKeluar->diffInMinutes($transaksi->waktu_masuk);

        $transaksi->update([
            'waktu_keluar' => $waktuKeluar,
            'durasi' => $durasi,
            'biaya' => $request->biaya,
            'penalty' => $request->penalty ?? 0
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Transaksi keluar berhasil dicatat',
            'data' => $transaksi->fresh()
        ]);
    }

    /**
     * Mengambil transaksi aktif user
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getActive(Request $request)
    {
        $user = $request->user();
        
        $activeTransaction = TransaksiParkir::where('id_user', $user->id_user)
            ->whereNull('waktu_keluar')
            ->with(['kendaraan', 'mall', 'parkiran'])
            ->first();

        return response()->json([
            'success' => true,
            'data' => $activeTransaction,
            'has_active' => $activeTransaction !== null
        ]);
    }

    /**
     * Update transaksi
     * 
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(Request $request, $id)
    {
        $transaksi = TransaksiParkir::find($id);

        if (!$transaksi) {
            return response()->json([
                'success' => false,
                'message' => 'Transaksi tidak ditemukan'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'biaya' => 'nullable|numeric|min:0',
            'penalty' => 'nullable|numeric|min:0',
            'durasi' => 'nullable|integer|min:0'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $transaksi->update($request->only(['biaya', 'penalty', 'durasi']));

        return response()->json([
            'success' => true,
            'message' => 'Transaksi berhasil diupdate',
            'data' => $transaksi->fresh()
        ]);
    }

    /**
     * Hapus transaksi
     * 
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy(Request $request, $id)
    {
        $transaksi = TransaksiParkir::find($id);

        if (!$transaksi) {
            return response()->json([
                'success' => false,
                'message' => 'Transaksi tidak ditemukan'
            ], 404);
        }

        $transaksi->delete();

        return response()->json([
            'success' => true,
            'message' => 'Transaksi berhasil dihapus'
        ]);
    }
}

<?php

namespace App\Services;

use App\Models\TransaksiParkir;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;

class TransactionHistoryService
{
    /**
     * Mengambil histori transaksi user
     * 
     * @param int $userId
     * @param array $filters
     * @return \Illuminate\Database\Eloquent\Collection
     */
    public function getHistory($userId, array $filters = [])
    {
        if (empty($userId)) {
            return collect([]);
        }

        $query = TransaksiParkir::where('id_user', $userId)
            ->with(['kendaraan', 'mall', 'parkiran']);

        // Filter by date range
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('waktu_masuk', [
                $filters['start_date'],
                $filters['end_date']
            ]);
        }

        // Filter by jenis_transaksi
        if (isset($filters['jenis_transaksi'])) {
            $query->where('jenis_transaksi', $filters['jenis_transaksi']);
        }

        return $query->orderBy('waktu_masuk', 'desc')->get();
    }

    /**
     * Filter histori berdasarkan tanggal
     * 
     * @param int $userId
     * @param string $startDate
     * @param string $endDate
     * @return \Illuminate\Database\Eloquent\Collection
     */
    public function filterByDate($userId, $startDate, $endDate)
    {
        if (empty($userId) || empty($startDate) || empty($endDate)) {
            return collect([]);
        }

        return TransaksiParkir::where('id_user', $userId)
            ->whereBetween('waktu_masuk', [$startDate, $endDate])
            ->orderBy('waktu_masuk', 'desc')
            ->get();
    }

    /**
     * Menghitung total biaya dari histori transaksi
     * 
     * @param int $userId
     * @param array $filters
     * @return float
     */
    public function calculateTotal($userId, array $filters = [])
    {
        if (empty($userId)) {
            return 0;
        }

        $query = TransaksiParkir::where('id_user', $userId);

        // Filter by date range
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('waktu_masuk', [
                $filters['start_date'],
                $filters['end_date']
            ]);
        }

        $total = $query->sum('biaya');
        $penalty = $query->sum('penalty');

        return $total + $penalty;
    }

    /**
     * Validasi data histori lengkap
     * 
     * @param array $data
     * @return bool
     */
    public function validateHistoryData(array $data)
    {
        $requiredFields = ['id_user', 'id_kendaraan', 'id_mall', 'id_parkiran', 'jenis_transaksi'];
        
        foreach ($requiredFields as $field) {
            if (!isset($data[$field]) || empty($data[$field])) {
                return false;
            }
        }

        // Validasi jenis_transaksi
        if (!in_array($data['jenis_transaksi'], ['umum', 'booking'])) {
            return false;
        }

        return true;
    }

    /**
     * Mengambil statistik transaksi user
     * 
     * @param int $userId
     * @return array
     */
    public function getStatistics($userId)
    {
        if (empty($userId)) {
            return [
                'total_transaksi' => 0,
                'total_biaya' => 0,
                'total_durasi' => 0
            ];
        }

        $transaksi = TransaksiParkir::where('id_user', $userId)->get();

        return [
            'total_transaksi' => $transaksi->count(),
            'total_biaya' => $transaksi->sum('biaya') + $transaksi->sum('penalty'),
            'total_durasi' => $transaksi->sum('durasi')
        ];
    }

    /**
     * Cek apakah user memiliki transaksi aktif
     * 
     * @param int $userId
     * @return bool
     */
    public function hasActiveTransaction($userId)
    {
        if (empty($userId)) {
            return false;
        }

        return TransaksiParkir::where('id_user', $userId)
            ->whereNull('waktu_keluar')
            ->exists();
    }
}

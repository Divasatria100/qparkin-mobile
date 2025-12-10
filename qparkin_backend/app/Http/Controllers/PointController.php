<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\RiwayatPoin;
use App\Models\User;
use Carbon\Carbon;

class PointController extends Controller
{
    /**
     * Get current point balance for authenticated user
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getBalance(Request $request)
    {
        try {
            $user = $request->user();
            
            return response()->json([
                'success' => true,
                'balance' => $user->saldo_poin ?? 0
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error fetching balance: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get point history with pagination and filtering
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getHistory(Request $request)
    {
        try {
            $user = $request->user();
            
            // Validate query parameters
            $request->validate([
                'page' => 'nullable|integer|min:1',
                'limit' => 'nullable|integer|min:1|max:100',
                'type' => 'nullable|in:tambah,kurang',
                'start_date' => 'nullable|date',
                'end_date' => 'nullable|date|after_or_equal:start_date'
            ]);

            $page = $request->input('page', 1);
            $limit = $request->input('limit', 20);
            $type = $request->input('type');
            $startDate = $request->input('start_date');
            $endDate = $request->input('end_date');

            // Build query
            $query = RiwayatPoin::where('id_user', $user->id_user);

            // Apply type filter
            if ($type) {
                $query->where('perubahan', $type);
            }

            // Apply date range filter
            if ($startDate) {
                $query->where('waktu', '>=', $startDate);
            }
            if ($endDate) {
                $query->where('waktu', '<=', $endDate . ' 23:59:59');
            }

            // Get total count before pagination
            $total = $query->count();

            // Apply pagination and ordering
            $history = $query->orderBy('waktu', 'desc')
                           ->skip(($page - 1) * $limit)
                           ->take($limit)
                           ->get();

            return response()->json([
                'success' => true,
                'data' => $history,
                'meta' => [
                    'current_page' => $page,
                    'per_page' => $limit,
                    'total' => $total,
                    'last_page' => ceil($total / $limit)
                ]
            ], 200);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $e->errors()
            ], 422);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error fetching history: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get aggregated point statistics
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getStatistics(Request $request)
    {
        try {
            $user = $request->user();
            
            // Get all history for the user
            $allHistory = RiwayatPoin::where('id_user', $user->id_user)->get();

            // Calculate total earned and used
            $totalEarned = $allHistory->where('perubahan', 'tambah')->sum('poin');
            $totalUsed = $allHistory->where('perubahan', 'kurang')->sum('poin');

            // Calculate this month's statistics
            $startOfMonth = Carbon::now()->startOfMonth();
            $endOfMonth = Carbon::now()->endOfMonth();

            $thisMonthHistory = RiwayatPoin::where('id_user', $user->id_user)
                                          ->whereBetween('waktu', [$startOfMonth, $endOfMonth])
                                          ->get();

            $thisMonthEarned = $thisMonthHistory->where('perubahan', 'tambah')->sum('poin');
            $thisMonthUsed = $thisMonthHistory->where('perubahan', 'kurang')->sum('poin');

            return response()->json([
                'success' => true,
                'statistics' => [
                    'total_earned' => $totalEarned,
                    'total_used' => $totalUsed,
                    'this_month_earned' => $thisMonthEarned,
                    'this_month_used' => $thisMonthUsed
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error fetching statistics: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Use points for payment deduction
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function usePoints(Request $request)
    {
        try {
            // Validate request
            $request->validate([
                'amount' => 'required|integer|min:1',
                'transaction_id' => 'nullable|string',
                'description' => 'nullable|string|max:255'
            ]);

            $user = $request->user();
            $amount = $request->input('amount');
            $transactionId = $request->input('transaction_id');
            $description = $request->input('description', 'Penggunaan poin untuk pembayaran');

            // Check if user has sufficient points
            if ($user->saldo_poin < $amount) {
                return response()->json([
                    'success' => false,
                    'message' => 'Saldo poin tidak mencukupi',
                    'current_balance' => $user->saldo_poin,
                    'required_amount' => $amount
                ], 400);
            }

            // Use database transaction for atomicity
            DB::beginTransaction();

            try {
                // Deduct points from user balance
                $user->saldo_poin -= $amount;
                $user->save();

                // Create history entry
                RiwayatPoin::create([
                    'id_user' => $user->id_user,
                    'id_transaksi' => $transactionId,
                    'poin' => $amount,
                    'perubahan' => 'kurang',
                    'keterangan' => $description,
                    'waktu' => Carbon::now()
                ]);

                DB::commit();

                return response()->json([
                    'success' => true,
                    'message' => 'Poin berhasil digunakan',
                    'new_balance' => $user->saldo_poin,
                    'points_used' => $amount
                ], 200);

            } catch (\Exception $e) {
                DB::rollBack();
                throw $e;
            }

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $e->errors()
            ], 422);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error using points: ' . $e->getMessage()
            ], 500);
        }
    }
}

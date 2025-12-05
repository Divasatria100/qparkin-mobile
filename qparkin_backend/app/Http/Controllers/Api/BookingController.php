<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\TransaksiParkir;
use App\Models\ParkingSlot;
use App\Models\SlotReservation;
use App\Models\Parkiran;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class BookingController extends Controller
{
    public function index(Request $request)
    {
        try {
            $userId = $request->user()->id_user;

            $bookings = Booking::whereHas('transaksiParkir', function ($query) use ($userId) {
                $query->where('id_user', $userId);
            })
            ->with(['transaksiParkir', 'slot.floor', 'reservation'])
            ->orderBy('created_at', 'desc')
            ->get();

            return response()->json([
                'success' => true,
                'data' => $bookings
            ]);
        } catch (\Exception $e) {
            Log::error('Error fetching bookings: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch bookings',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function store(Request $request)
    {
        $request->validate([
            'id_parkiran' => 'required|exists:parkiran,id_parkiran',
            'id_kendaraan' => 'required|exists:kendaraan,id_kendaraan',
            'waktu_mulai' => 'required|date',
            'durasi_booking' => 'required|integer|min:1',
            'id_slot' => 'nullable|exists:parking_slots,id_slot',
            'reservation_id' => 'nullable|string'
        ]);

        DB::beginTransaction();
        try {
            $userId = $request->user()->id_user;
            $idSlot = $request->id_slot;
            $reservationId = $request->reservation_id;

            // If reservation_id is provided, validate it
            if ($reservationId) {
                $reservation = SlotReservation::where('reservation_id', $reservationId)
                    ->where('id_user', $userId)
                    ->where('status', 'active')
                    ->first();

                if (!$reservation) {
                    DB::rollBack();
                    return response()->json([
                        'success' => false,
                        'message' => 'INVALID_RESERVATION',
                        'error' => 'Reservasi tidak valid atau sudah kadaluarsa'
                    ], 400);
                }

                if ($reservation->isExpired()) {
                    $reservation->expire();
                    DB::rollBack();
                    return response()->json([
                        'success' => false,
                        'message' => 'RESERVATION_EXPIRED',
                        'error' => 'Reservasi telah kadaluarsa'
                    ], 400);
                }

                // Use the slot from reservation
                $idSlot = $reservation->id_slot;
            }

            // If no slot provided and no reservation, auto-assign a slot
            if (!$idSlot) {
                $idSlot = $this->autoAssignSlot($request->id_parkiran, $request->id_kendaraan);
                
                if (!$idSlot) {
                    DB::rollBack();
                    return response()->json([
                        'success' => false,
                        'message' => 'NO_SLOTS_AVAILABLE',
                        'error' => 'Tidak ada slot tersedia'
                    ], 404);
                }
            }

            // Calculate end time
            $waktuMulai = Carbon::parse($request->waktu_mulai);
            $waktuSelesai = $waktuMulai->copy()->addHours($request->durasi_booking);

            // Create transaksi parkir first
            $transaksi = TransaksiParkir::create([
                'id_user' => $userId,
                'id_parkiran' => $request->id_parkiran,
                'id_kendaraan' => $request->id_kendaraan,
                'id_slot' => $idSlot,
                'waktu_masuk' => $waktuMulai,
                'status' => 'booked'
            ]);

            // Create booking
            $booking = Booking::create([
                'id_transaksi' => $transaksi->id_transaksi,
                'id_slot' => $idSlot,
                'reservation_id' => $reservationId,
                'waktu_mulai' => $waktuMulai,
                'waktu_selesai' => $waktuSelesai,
                'durasi_booking' => $request->durasi_booking,
                'status' => 'confirmed',
                'dibooking_pada' => Carbon::now()
            ]);

            // If there was a reservation, confirm it
            if ($reservationId && isset($reservation)) {
                $reservation->confirm();
            }

            // Mark slot as occupied
            $slot = ParkingSlot::find($idSlot);
            if ($slot) {
                $slot->markAsOccupied();
            }

            DB::commit();

            // Load relationships for response
            $booking->load(['transaksiParkir', 'slot.floor', 'reservation']);

            return response()->json([
                'success' => true,
                'message' => 'Booking berhasil dibuat',
                'data' => $booking
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Error creating booking: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to create booking',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function show($id)
    {
        try {
            $booking = Booking::with(['transaksiParkir', 'slot.floor', 'reservation'])
                ->findOrFail($id);

            return response()->json([
                'success' => true,
                'data' => $booking
            ]);
        } catch (\Exception $e) {
            Log::error('Error fetching booking: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Booking not found',
                'error' => $e->getMessage()
            ], 404);
        }
    }

    public function cancel($id)
    {
        DB::beginTransaction();
        try {
            $booking = Booking::findOrFail($id);

            // Update booking status
            $booking->update(['status' => 'cancelled']);

            // Update transaksi status
            if ($booking->transaksiParkir) {
                $booking->transaksiParkir->update(['status' => 'cancelled']);
            }

            // Release the slot
            if ($booking->slot) {
                $booking->slot->markAsAvailable();
            }

            // Cancel reservation if exists
            if ($booking->reservation_id) {
                $reservation = SlotReservation::where('reservation_id', $booking->reservation_id)->first();
                if ($reservation) {
                    $reservation->cancel();
                }
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Booking berhasil dibatalkan'
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Error cancelling booking: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to cancel booking',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function getActive(Request $request)
    {
        try {
            $userId = $request->user()->id_user;

            $activeBookings = Booking::whereHas('transaksiParkir', function ($query) use ($userId) {
                $query->where('id_user', $userId)
                      ->whereIn('status', ['booked', 'active']);
            })
            ->whereIn('status', ['confirmed', 'active'])
            ->with(['transaksiParkir', 'slot.floor', 'reservation'])
            ->orderBy('waktu_mulai', 'desc')
            ->get();

            return response()->json([
                'success' => true,
                'data' => $activeBookings
            ]);
        } catch (\Exception $e) {
            Log::error('Error fetching active bookings: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch active bookings',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Auto-assign an available slot when no reservation is provided
     * This is the fallback mechanism for backward compatibility
     */
    private function autoAssignSlot($idParkiran, $idKendaraan)
    {
        try {
            // Get vehicle type
            $kendaraan = \App\Models\Kendaraan::find($idKendaraan);
            if (!$kendaraan) {
                return null;
            }

            // Get floors for this parkiran
            $floors = \App\Models\ParkingFloor::where('id_parkiran', $idParkiran)
                ->active()
                ->hasAvailableSlots()
                ->get();

            foreach ($floors as $floor) {
                // Try to find an available slot on this floor
                $slot = ParkingSlot::where('id_floor', $floor->id_floor)
                    ->where('status', 'available')
                    ->where('jenis_kendaraan', $kendaraan->jenis_kendaraan)
                    ->first();

                if ($slot) {
                    return $slot->id_slot;
                }
            }

            return null;
        } catch (\Exception $e) {
            Log::error('Error auto-assigning slot: ' . $e->getMessage());
            return null;
        }
    }
}

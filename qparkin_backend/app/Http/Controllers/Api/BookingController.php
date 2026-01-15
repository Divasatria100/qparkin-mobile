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
                $idSlot = $this->autoAssignSlot(
                    $request->id_parkiran,
                    $request->id_kendaraan,
                    $request->waktu_mulai,
                    $request->durasi_booking
                );
                
                if (!$idSlot) {
                    DB::rollBack();
                    return response()->json([
                        'success' => false,
                        'message' => 'NO_SLOTS_AVAILABLE',
                        'error' => 'Tidak ada slot tersedia untuk waktu yang dipilih'
                    ], 404);
                }
                
                Log::info("Auto-assigned slot {$idSlot} for booking");
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
                'status' => 'aktif', // Changed from 'confirmed' to match ENUM values
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

            // IMPORTANT: After commit, reload the booking to get the actual saved values
            // Since id_transaksi is the primary key and set manually, we need to reload
            $booking = Booking::where('id_transaksi', $transaksi->id_transaksi)->first();
            
            if (!$booking) {
                Log::error('[BookingService] Booking created but not found after commit', [
                    'transaksi_id' => $transaksi->id_transaksi
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'Booking created but verification failed',
                    'error' => 'Internal error'
                ], 500);
            }
            
            $bookingId = $transaksi->id_transaksi; // Use transaksi ID directly
            
            Log::info('[BookingService] Booking committed', [
                'booking_id_transaksi' => $bookingId,
                'transaksi_id' => $transaksi->id_transaksi,
                'booking_exists' => $booking !== null
            ]);

            // Load relationships for response
            $booking->load([
                'transaksiParkir.parkiran.mall',
                'transaksiParkir.kendaraan',
                'slot.floor',
                'reservation'
            ]);

            // Format response with all fields mobile app expects
            $transaksiData = $booking->transaksiParkir;
            $parkiran = $transaksiData ? $transaksiData->parkiran : null;
            $mall = $parkiran ? $parkiran->mall : null;
            $kendaraan = $transaksiData ? $transaksiData->kendaraan : null;
            $slot = $booking->slot;
            $floor = $slot ? $slot->floor : null;

            $bookingData = [
                'id_transaksi' => $bookingId,
                'id_booking' => $bookingId, // Mobile app expects this field
                'id_mall' => $mall ? $mall->id_mall : null,
                'id_parkiran' => $transaksiData ? $transaksiData->id_parkiran : null,
                'id_kendaraan' => $transaksiData ? $transaksiData->id_kendaraan : null,
                'id_slot' => $booking->id_slot,
                'reservation_id' => $booking->reservation_id,
                'qr_code' => $transaksiData ? ($transaksiData->qr_code ?? '') : '',
                'waktu_mulai' => $booking->waktu_mulai,
                'waktu_selesai' => $booking->waktu_selesai,
                'durasi_booking' => $booking->durasi_booking,
                'status' => $booking->status,
                'biaya_estimasi' => 0, // TODO: Calculate from tarif
                'dibooking_pada' => $booking->dibooking_pada,
                // Additional display fields
                'nama_mall' => $mall ? $mall->nama_mall : null,
                'lokasi_mall' => $mall ? $mall->lokasi : null,
                'plat_nomor' => $kendaraan ? $kendaraan->plat_nomor : null,
                'jenis_kendaraan' => $kendaraan ? $kendaraan->jenis : null,
                'kode_slot' => $slot ? $slot->slot_code : null,
                'floor_name' => $floor ? $floor->nama_lantai : null,
                'floor_number' => $floor ? $floor->nomor_lantai : null,
                'slot_type' => $slot ? ($slot->tipe_slot ?? 'regular') : 'regular',
            ];

            Log::info('[BookingService] Booking created successfully', [
                'id_transaksi' => $bookingId,
                'id_booking' => $bookingId,
                'id_slot' => $idSlot,
                'id_mall' => $bookingData['id_mall'],
                'response_data' => $bookingData
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Booking berhasil dibuat',
                'data' => $bookingData
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            
            // Log the error with context
            Log::error('[BookingService] Error creating booking', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'user_id' => $userId ?? null,
                'id_parkiran' => $request->id_parkiran ?? null,
                'id_kendaraan' => $request->id_kendaraan ?? null
            ]);
            
            // Return user-friendly error message
            $errorMessage = $e->getMessage();
            
            // Check for specific error types
            if (str_contains($errorMessage, 'transaksi aktif')) {
                return response()->json([
                    'success' => false,
                    'message' => 'ACTIVE_BOOKING_EXISTS',
                    'error' => 'Anda masih memiliki booking aktif. Selesaikan booking sebelumnya terlebih dahulu.'
                ], 409);
            }
            
            return response()->json([
                'success' => false,
                'message' => 'Failed to create booking',
                'error' => $errorMessage
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
            ->whereIn('status', ['aktif']) // Changed from 'confirmed', 'active' to match ENUM
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
     * 
     * This method uses SlotAutoAssignmentService to:
     * 1. Find an available slot
     * 2. Create a temporary reservation to lock it
     * 3. Prevent overbooking
     * 
     * Used for malls with slot reservation disabled (simple parking)
     */
    private function autoAssignSlot($idParkiran, $idKendaraan, $waktuMulai = null, $durasiBooking = 1)
    {
        try {
            $autoAssignService = new \App\Services\SlotAutoAssignmentService();
            
            // Get user ID from request
            $userId = request()->user()->id_user;
            
            // Use provided time or default to now
            $startTime = $waktuMulai ?? now()->toDateTimeString();
            
            // Assign slot with reservation
            $slotId = $autoAssignService->assignSlot(
                $idParkiran,
                $idKendaraan,
                $userId,
                $startTime,
                $durasiBooking
            );
            
            if ($slotId) {
                Log::info("Auto-assigned slot {$slotId} for parkiran {$idParkiran}, vehicle {$idKendaraan}");
            } else {
                Log::warning("Failed to auto-assign slot for parkiran {$idParkiran}, vehicle {$idKendaraan}");
            }
            
            return $slotId;
            
        } catch (\Exception $e) {
            Log::error('Error auto-assigning slot: ' . $e->getMessage());
            return null;
        }
    }

    /**
     * Get Midtrans Snap Token for payment
     * 
     * This endpoint generates a Midtrans Snap token for the booking payment.
     * The token is used by the mobile app to open the Midtrans payment page.
     * 
     * @param int $id Booking ID (id_transaksi)
     * @return \Illuminate\Http\JsonResponse
     */
    public function getSnapToken($id)
    {
        try {
            Log::info('[Payment] Requesting snap token', ['booking_id' => $id]);
            
            // Find booking
            $booking = Booking::with(['transaksiParkir.parkiran.mall', 'transaksiParkir.kendaraan', 'transaksiParkir.user'])
                ->where('id_transaksi', $id)
                ->first();
            
            if (!$booking) {
                Log::warning('[Payment] Booking not found', ['booking_id' => $id]);
                return response()->json([
                    'success' => false,
                    'message' => 'Booking not found'
                ], 404);
            }
            
            // Check if booking is still active
            if ($booking->status !== 'aktif') {
                Log::warning('[Payment] Booking not active', [
                    'booking_id' => $id,
                    'status' => $booking->status
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'Booking is not active'
                ], 400);
            }
            
            $transaksi = $booking->transaksiParkir;
            $mall = $transaksi && $transaksi->parkiran ? $transaksi->parkiran->mall : null;
            $kendaraan = $transaksi ? $transaksi->kendaraan : null;
            $user = $transaksi ? $transaksi->user : null;
            
            // Calculate amount (for now use biaya_estimasi, later calculate from tarif)
            $amount = $booking->biaya_estimasi > 0 ? $booking->biaya_estimasi : 10000; // Default Rp 10.000
            
            // Prepare transaction details for Midtrans
            $orderId = 'BOOKING-' . $id . '-' . time();
            
            $transactionDetails = [
                'order_id' => $orderId,
                'gross_amount' => (int) $amount,
            ];
            
            $itemDetails = [
                [
                    'id' => 'PARKING-' . $id,
                    'price' => (int) $amount,
                    'quantity' => 1,
                    'name' => 'Parking at ' . ($mall ? $mall->nama_mall : 'Mall'),
                ]
            ];
            
            $customerDetails = [
                'first_name' => $user ? ($user->name ?? 'Customer') : 'Customer',
                'email' => $user ? ($user->email ?? 'customer@example.com') : 'customer@example.com',
                'phone' => $kendaraan ? $kendaraan->plat_nomor : '000000',
            ];
            
            // Check if Midtrans is configured
            $serverKey = config('services.midtrans.server_key');
            
            if (!$serverKey || $serverKey === 'your_server_key_here') {
                // MOCK MODE - Midtrans not configured
                $snapToken = 'MOCK-SNAP-TOKEN-' . $id . '-' . time();
                
                Log::info('[Payment] Snap token generated (MOCK MODE)', [
                    'booking_id' => $id,
                    'snap_token' => $snapToken,
                    'amount' => $amount,
                    'reason' => 'Midtrans not configured'
                ]);
                
                return response()->json([
                    'success' => true,
                    'snap_token' => $snapToken,
                    'order_id' => $orderId,
                    'amount' => $amount,
                    'booking_id' => $id,
                    'message' => 'Snap token generated successfully (MOCK MODE - Configure Midtrans in .env)'
                ]);
            }
            
            // PRODUCTION MODE - Use real Midtrans API
            try {
                // Configure Midtrans
                \Midtrans\Config::$serverKey = $serverKey;
                \Midtrans\Config::$isProduction = config('services.midtrans.is_production', false);
                \Midtrans\Config::$isSanitized = config('services.midtrans.is_sanitized', true);
                \Midtrans\Config::$is3ds = config('services.midtrans.is_3ds', true);
                
                // Create transaction parameters
                $params = [
                    'transaction_details' => $transactionDetails,
                    'item_details' => $itemDetails,
                    'customer_details' => $customerDetails,
                ];
                
                // Get real snap token from Midtrans
                $snapToken = \Midtrans\Snap::getSnapToken($params);
                
                Log::info('[Payment] Snap token generated (PRODUCTION MODE)', [
                    'booking_id' => $id,
                    'order_id' => $orderId,
                    'amount' => $amount,
                    'snap_token_length' => strlen($snapToken)
                ]);
                
                return response()->json([
                    'success' => true,
                    'snap_token' => $snapToken,
                    'order_id' => $orderId,
                    'amount' => $amount,
                    'booking_id' => $id,
                    'message' => 'Snap token generated successfully'
                ]);
                
            } catch (\Exception $midtransError) {
                Log::error('[Payment] Midtrans API error', [
                    'booking_id' => $id,
                    'error' => $midtransError->getMessage()
                ]);
                
                // Fallback to MOCK if Midtrans fails
                $snapToken = 'MOCK-SNAP-TOKEN-' . $id . '-' . time();
                
                return response()->json([
                    'success' => true,
                    'snap_token' => $snapToken,
                    'order_id' => $orderId,
                    'amount' => $amount,
                    'booking_id' => $id,
                    'message' => 'Snap token generated (MOCK MODE - Midtrans error: ' . $midtransError->getMessage() . ')'
                ]);
            }
            
        } catch (\Exception $e) {
            Log::error('[Payment] Error generating snap token', [
                'booking_id' => $id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Failed to generate snap token',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}

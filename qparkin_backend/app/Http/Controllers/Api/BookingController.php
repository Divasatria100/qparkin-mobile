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

            // Calculate estimated cost based on tarif parkir
            $biayaEstimasi = $this->calculateBookingCost(
                $request->id_parkiran,
                $request->id_kendaraan,
                $request->durasi_booking
            );

            // Create transaksi parkir first
            $transaksi = TransaksiParkir::create([
                'id_user' => $userId,
                'id_parkiran' => $request->id_parkiran,
                'id_kendaraan' => $request->id_kendaraan,
                'id_slot' => $idSlot,
                'waktu_masuk' => $waktuMulai,
                'status' => 'booked'
            ]);

            // Create booking with pending_payment status
            // User needs to complete payment via Midtrans before booking becomes active
            $booking = Booking::create([
                'id_transaksi' => $transaksi->id_transaksi,
                'id_slot' => $idSlot,
                'reservation_id' => $reservationId,
                'waktu_mulai' => $waktuMulai,
                'waktu_selesai' => $waktuSelesai,
                'durasi_booking' => $request->durasi_booking,
                'biaya_estimasi' => $biayaEstimasi,
                'status' => 'aktif', // Will be changed to 'pending_payment' after Midtrans integration
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
                'biaya_estimasi' => $booking->biaya_estimasi ?? $biayaEstimasi,
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

            $activeBooking = Booking::whereHas('transaksiParkir', function ($query) use ($userId) {
                $query->where('id_user', $userId)
                      ->whereIn('status', ['booked', 'active']);
            })
            ->whereIn('status', ['aktif']) // Changed from 'confirmed', 'active' to match ENUM
            ->with([
                'transaksiParkir.parkiran.mall',
                'transaksiParkir.kendaraan',
                'slot.floor',
                'reservation'
            ])
            ->orderBy('waktu_mulai', 'desc')
            ->first();

            if (!$activeBooking) {
                return response()->json([
                    'success' => true,
                    'data' => null,
                    'message' => 'No active booking found'
                ]);
            }

            // Format response with all fields mobile app expects
            $transaksiData = $activeBooking->transaksiParkir;
            $parkiran = $transaksiData ? $transaksiData->parkiran : null;
            $mall = $parkiran ? $parkiran->mall : null;
            $kendaraan = $transaksiData ? $transaksiData->kendaraan : null;
            $slot = $activeBooking->slot;
            $floor = $slot ? $slot->floor : null;

            $bookingData = [
                'id_transaksi' => $activeBooking->id_transaksi,
                'id_booking' => $activeBooking->id_transaksi,
                'id_mall' => $mall ? $mall->id_mall : null,
                'id_parkiran' => $transaksiData ? $transaksiData->id_parkiran : null,
                'id_kendaraan' => $transaksiData ? $transaksiData->id_kendaraan : null,
                'id_slot' => $activeBooking->id_slot,
                'reservation_id' => $activeBooking->reservation_id,
                'qr_code' => $transaksiData ? ($transaksiData->qr_code ?? 'BOOKING-' . $activeBooking->id_transaksi) : '',
                'waktu_masuk' => $transaksiData ? $transaksiData->waktu_masuk : $activeBooking->waktu_mulai,
                'waktu_mulai' => $activeBooking->waktu_mulai,
                'waktu_selesai' => $activeBooking->waktu_selesai,
                'durasi_booking' => $activeBooking->durasi_booking,
                'status' => $activeBooking->status,
                'biaya_estimasi' => $activeBooking->biaya_estimasi ?? 0,
                'dibooking_pada' => $activeBooking->dibooking_pada,
                // Additional display fields
                'nama_mall' => $mall ? $mall->nama_mall : null,
                'lokasi_mall' => $mall ? $mall->lokasi : null,
                'plat_nomor' => $kendaraan ? $kendaraan->plat_nomor : null,
                'jenis_kendaraan' => $kendaraan ? $kendaraan->jenis : null,
                'kode_slot' => $slot ? $slot->slot_code : null,
                'floor_name' => $floor ? $floor->nama_lantai : null,
                'floor_number' => $floor ? $floor->nomor_lantai : null,
                'slot_type' => $slot ? ($slot->tipe_slot ?? 'regular') : 'regular',
                // Tarif info for cost calculation
                'biaya_per_jam' => $activeBooking->biaya_estimasi && $activeBooking->durasi_booking > 0 
                    ? ($activeBooking->biaya_estimasi / $activeBooking->durasi_booking) 
                    : 10000,
            ];

            return response()->json([
                'success' => true,
                'data' => $bookingData
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
     * Get pending payment bookings for current user
     * 
     * Returns bookings that have been created but payment is not yet completed.
     * These bookings are in 'pending_payment' status.
     */
    public function getPendingPayments(Request $request)
    {
        try {
            $userId = $request->user()->id_user;

            $pendingBookings = Booking::whereHas('transaksiParkir', function ($query) use ($userId) {
                $query->where('id_user', $userId)
                      ->where('status', 'pending_payment');
            })
            ->with([
                'transaksiParkir.parkiran.mall',
                'transaksiParkir.kendaraan',
                'slot.floor',
                'reservation'
            ])
            ->orderBy('dibooking_pada', 'desc')
            ->get();

            // Format response with all fields mobile app expects
            $formattedBookings = $pendingBookings->map(function ($booking) {
                $transaksiData = $booking->transaksiParkir;
                $parkiran = $transaksiData ? $transaksiData->parkiran : null;
                $mall = $parkiran ? $parkiran->mall : null;
                $kendaraan = $transaksiData ? $transaksiData->kendaraan : null;
                $slot = $booking->slot;
                $floor = $slot ? $slot->floor : null;

                return [
                    'id_transaksi' => $booking->id_transaksi,
                    'id_booking' => $booking->id_transaksi,
                    'id_mall' => $mall ? $mall->id_mall : null,
                    'id_parkiran' => $transaksiData ? $transaksiData->id_parkiran : null,
                    'id_kendaraan' => $transaksiData ? $transaksiData->id_kendaraan : null,
                    'id_slot' => $booking->id_slot,
                    'reservation_id' => $booking->reservation_id,
                    'qr_code' => $transaksiData ? ($transaksiData->qr_code ?? '') : '',
                    'waktu_mulai' => $booking->waktu_mulai,
                    'waktu_selesai' => $booking->waktu_selesai,
                    'durasi_booking' => $booking->durasi_booking,
                    'status' => 'pending_payment',
                    'biaya_estimasi' => $booking->biaya_estimasi ?? 0,
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
            });

            return response()->json([
                'success' => true,
                'data' => $formattedBookings
            ]);
        } catch (\Exception $e) {
            Log::error('Error fetching pending payments: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch pending payments',
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
            
            // Calculate amount (use biaya_estimasi from booking)
            $amount = $booking->biaya_estimasi > 0 ? $booking->biaya_estimasi : 10000; // Default Rp 10.000 if not set
            
            Log::info('[Payment] Using booking cost', [
                'booking_id' => $id,
                'biaya_estimasi' => $booking->biaya_estimasi,
                'amount_used' => $amount
            ]);
            
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

    /**
     * Update payment status after Midtrans payment
     * 
     * This endpoint is called by the mobile app after payment is completed.
     * It updates the booking status from 'pending_payment' to 'aktif' when payment is successful.
     * 
     * @param Request $request
     * @param int $id Booking ID (id_transaksi)
     * @return \Illuminate\Http\JsonResponse
     */
    public function updatePaymentStatus(Request $request, $id)
    {
        $request->validate([
            'payment_status' => 'required|in:PAID,PENDING,FAILED'
        ]);

        DB::beginTransaction();
        try {
            Log::info('[Payment] Updating payment status', [
                'booking_id' => $id,
                'payment_status' => $request->payment_status
            ]);

            // Find booking
            $booking = Booking::with(['transaksiParkir'])
                ->where('id_transaksi', $id)
                ->first();

            if (!$booking) {
                Log::warning('[Payment] Booking not found', ['booking_id' => $id]);
                return response()->json([
                    'success' => false,
                    'message' => 'Booking not found'
                ], 404);
            }

            $paymentStatus = $request->payment_status;

            if ($paymentStatus === 'PAID') {
                // Update booking status to aktif
                $booking->update(['status' => 'aktif']);

                // Update transaksi status to active
                if ($booking->transaksiParkir) {
                    $booking->transaksiParkir->update([
                        'status' => 'active',
                        'waktu_masuk' => Carbon::now()
                    ]);
                }

                Log::info('[Payment] Payment successful, booking activated', [
                    'booking_id' => $id,
                    'booking_status' => 'aktif',
                    'transaksi_status' => 'active'
                ]);

                DB::commit();

                return response()->json([
                    'success' => true,
                    'message' => 'Pembayaran berhasil, booking aktif',
                    'data' => [
                        'id_booking' => $id,
                        'status' => 'aktif',
                        'payment_status' => 'PAID'
                    ]
                ]);
            } elseif ($paymentStatus === 'PENDING') {
                // Keep status as pending_payment or update to pending
                $booking->update(['status' => 'pending_payment']);

                Log::info('[Payment] Payment pending', ['booking_id' => $id]);

                DB::commit();

                return response()->json([
                    'success' => true,
                    'message' => 'Pembayaran sedang diproses',
                    'data' => [
                        'id_booking' => $id,
                        'status' => 'pending_payment',
                        'payment_status' => 'PENDING'
                    ]
                ]);
            } else {
                // Payment failed - cancel booking
                $booking->update(['status' => 'cancelled']);

                if ($booking->transaksiParkir) {
                    $booking->transaksiParkir->update(['status' => 'cancelled']);
                }

                // Release the slot
                if ($booking->slot) {
                    $booking->slot->markAsAvailable();
                }

                Log::info('[Payment] Payment failed, booking cancelled', ['booking_id' => $id]);

                DB::commit();

                return response()->json([
                    'success' => true,
                    'message' => 'Pembayaran gagal, booking dibatalkan',
                    'data' => [
                        'id_booking' => $id,
                        'status' => 'cancelled',
                        'payment_status' => 'FAILED'
                    ]
                ]);
            }
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('[Payment] Error updating payment status', [
                'booking_id' => $id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to update payment status',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Calculate booking cost based on tarif parkir
     * 
     * @param string $idParkiran Parkiran ID
     * @param string $idKendaraan Kendaraan ID
     * @param int $durasiBooking Duration in hours
     * @return float Estimated cost
     */
    private function calculateBookingCost($idParkiran, $idKendaraan, $durasiBooking)
    {
        try {
            // Get vehicle type
            $kendaraan = \App\Models\Kendaraan::find($idKendaraan);
            if (!$kendaraan) {
                Log::warning("Vehicle not found: {$idKendaraan}");
                return 10000; // Default fallback
            }

            $jenisKendaraan = $kendaraan->jenis;

            // Get tarif parkir for this parkiran and vehicle type
            $tarif = \App\Models\TarifParkir::where('id_parkiran', $idParkiran)
                ->where('jenis_kendaraan', $jenisKendaraan)
                ->first();

            if (!$tarif) {
                Log::warning("Tarif not found for parkiran {$idParkiran} and vehicle type {$jenisKendaraan}");
                return 10000; // Default fallback
            }

            // Calculate cost: first hour + additional hours
            $biayaJamPertama = $tarif->biaya_jam_pertama;
            $biayaJamBerikutnya = $tarif->biaya_jam_berikutnya;

            if ($durasiBooking <= 1) {
                return $biayaJamPertama;
            }

            $additionalHours = $durasiBooking - 1;
            $totalCost = $biayaJamPertama + ($additionalHours * $biayaJamBerikutnya);

            Log::info("Calculated booking cost: Rp {$totalCost} for {$durasiBooking} hours", [
                'parkiran' => $idParkiran,
                'vehicle_type' => $jenisKendaraan,
                'first_hour' => $biayaJamPertama,
                'additional_hours' => $additionalHours,
                'hourly_rate' => $biayaJamBerikutnya
            ]);

            return $totalCost;
        } catch (\Exception $e) {
            Log::error("Error calculating booking cost: " . $e->getMessage());
            return 10000; // Default fallback
        }
    }
}
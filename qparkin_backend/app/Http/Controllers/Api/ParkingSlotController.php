<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ParkingFloor;
use App\Models\ParkingSlot;
use App\Models\SlotReservation;
use App\Models\Parkiran;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class ParkingSlotController extends Controller
{
    /**
     * Get parking floors for a mall
     * GET /api/parking/floors/{mallId}
     */
    public function getFloors($mallId)
    {
        try {
            // Get all parkiran for this mall
            $parkiranIds = Parkiran::where('id_mall', $mallId)
                ->where('status', 'active')
                ->pluck('id_parkiran');

            if ($parkiranIds->isEmpty()) {
                return response()->json([
                    'success' => true,
                    'data' => []
                ]);
            }

            // Get floors with slot counts
            $floors = ParkingFloor::whereIn('id_parkiran', $parkiranIds)
                ->active()
                ->with('parkiran')
                ->get()
                ->map(function ($floor) {
                    // Calculate real-time slot counts
                    $totalSlots = ParkingSlot::where('id_floor', $floor->id_floor)->count();
                    $availableSlots = ParkingSlot::where('id_floor', $floor->id_floor)
                        ->where('status', 'available')
                        ->count();
                    $occupiedSlots = ParkingSlot::where('id_floor', $floor->id_floor)
                        ->where('status', 'occupied')
                        ->count();
                    $reservedSlots = ParkingSlot::where('id_floor', $floor->id_floor)
                        ->where('status', 'reserved')
                        ->count();

                    return [
                        'id_floor' => $floor->id_floor,
                        'id_mall' => $mallId,
                        'floor_number' => $floor->floor_number,
                        'floor_name' => $floor->floor_name,
                        'total_slots' => $totalSlots,
                        'available_slots' => $availableSlots,
                        'occupied_slots' => $occupiedSlots,
                        'reserved_slots' => $reservedSlots,
                        'last_updated' => Carbon::now()->toIso8601String()
                    ];
                })
                ->sortBy('floor_number')
                ->values();

            return response()->json([
                'success' => true,
                'data' => $floors
            ]);
        } catch (\Exception $e) {
            Log::error('Error fetching floors: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch parking floors',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get slots for visualization (non-interactive display)
     * GET /api/parking/slots/{floorId}/visualization
     */
    public function getSlotsForVisualization($floorId, Request $request)
    {
        try {
            $vehicleType = $request->query('vehicle_type');

            $query = ParkingSlot::where('id_floor', $floorId);

            // Filter by vehicle type if provided
            if ($vehicleType) {
                $query->where('jenis_kendaraan', $vehicleType);
            }

            $slots = $query->get()->map(function ($slot) {
                return [
                    'id_slot' => $slot->id_slot,
                    'id_floor' => $slot->id_floor,
                    'slot_code' => $slot->slot_code,
                    'status' => $slot->status,
                    'slot_type' => $slot->jenis_kendaraan === 'Disable-Friendly' ? 'disableFriendly' : 'regular',
                    'position_x' => $slot->position_x,
                    'position_y' => $slot->position_y,
                    'last_updated' => Carbon::now()->toIso8601String()
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $slots
            ]);
        } catch (\Exception $e) {
            Log::error('Error fetching slots for visualization: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch slot visualization',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Reserve a random available slot on specified floor
     * POST /api/parking/slots/reserve-random
     */
    public function reserveRandomSlot(Request $request)
    {
        $request->validate([
            'id_floor' => 'required|exists:parking_floors,id_floor',
            'id_user' => 'required|exists:users,id_user',
            'vehicle_type' => 'required|string',
            'duration_minutes' => 'integer|min:1|max:30'
        ]);

        DB::beginTransaction();
        try {
            $idFloor = $request->id_floor;
            $idUser = $request->id_user;
            $vehicleType = $request->vehicle_type;
            $durationMinutes = $request->duration_minutes ?? 5; // Default 5 minutes

            // Find available slots on this floor for the vehicle type
            $availableSlots = ParkingSlot::where('id_floor', $idFloor)
                ->where('status', 'available')
                ->where('jenis_kendaraan', $vehicleType)
                ->get();

            if ($availableSlots->isEmpty()) {
                DB::rollBack();
                return response()->json([
                    'success' => false,
                    'message' => 'NO_SLOTS_AVAILABLE',
                    'error' => 'Tidak ada slot tersedia di lantai ini untuk jenis kendaraan yang dipilih'
                ], 404);
            }

            // Select a random slot
            $randomSlot = $availableSlots->random();

            // Mark slot as reserved
            $randomSlot->markAsReserved();

            // Get floor information
            $floor = ParkingFloor::find($idFloor);

            // Create reservation
            $reservation = SlotReservation::create([
                'id_slot' => $randomSlot->id_slot,
                'id_user' => $idUser,
                'id_floor' => $idFloor,
                'status' => 'active',
                'reserved_at' => Carbon::now(),
                'expires_at' => Carbon::now()->addMinutes($durationMinutes)
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'data' => [
                    'reservation_id' => $reservation->reservation_id,
                    'slot_id' => $randomSlot->id_slot,
                    'slot_code' => $randomSlot->slot_code,
                    'floor_name' => $floor->floor_name,
                    'floor_number' => (string) $floor->floor_number,
                    'slot_type' => $randomSlot->jenis_kendaraan === 'Disable-Friendly' ? 'disableFriendly' : 'regular',
                    'reserved_at' => $reservation->reserved_at->toIso8601String(),
                    'expires_at' => $reservation->expires_at->toIso8601String()
                ],
                'message' => "Slot {$randomSlot->slot_code} berhasil direservasi untuk {$durationMinutes} menit"
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Error reserving random slot: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to reserve slot',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Clean up expired reservations
     * This should be called periodically (e.g., via scheduled task)
     */
    public function cleanupExpiredReservations()
    {
        try {
            $expiredReservations = SlotReservation::expired()->get();

            foreach ($expiredReservations as $reservation) {
                $reservation->expire();
            }

            return response()->json([
                'success' => true,
                'message' => "Cleaned up {$expiredReservations->count()} expired reservations"
            ]);
        } catch (\Exception $e) {
            Log::error('Error cleaning up expired reservations: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to cleanup expired reservations',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}

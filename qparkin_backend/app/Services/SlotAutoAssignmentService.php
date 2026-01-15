<?php

namespace App\Services;

use App\Models\ParkingSlot;
use App\Models\ParkingFloor;
use App\Models\SlotReservation;
use App\Models\Kendaraan;
use App\Models\Mall;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

/**
 * Service for auto-assigning parking slots
 * 
 * This service handles automatic slot assignment for malls where
 * slot reservation is disabled (simple parking areas).
 * 
 * Key Features:
 * - Prevents overbooking by reserving slots in background
 * - User doesn't see slot selection UI
 * - System automatically picks best available slot
 * - Guarantees slot availability when user arrives
 * 
 * Usage:
 * ```php
 * $service = new SlotAutoAssignmentService();
 * $slotId = $service->assignSlot($mallId, $vehicleId, $userId, $startTime, $duration);
 * ```
 */
class SlotAutoAssignmentService
{
    /**
     * Auto-assign a slot for a booking
     * 
     * @param int $idParkiran Parkiran ID
     * @param int $idKendaraan Vehicle ID
     * @param int $idUser User ID
     * @param string $waktuMulai Start time
     * @param int $durasiBooking Duration in hours
     * @return int|null Slot ID if successful, null if no slots available
     */
    public function assignSlot(
        int $idParkiran,
        int $idKendaraan,
        int $idUser,
        string $waktuMulai,
        int $durasiBooking
    ): ?int {
        DB::beginTransaction();
        try {
            // Get vehicle type
            $kendaraan = Kendaraan::find($idKendaraan);
            if (!$kendaraan) {
                Log::error("Vehicle not found: {$idKendaraan}");
                DB::rollBack();
                return null;
            }

            // Get available slot (use 'jenis' field, not 'jenis_kendaraan')
            $slot = $this->findAvailableSlot($idParkiran, $kendaraan->jenis, $waktuMulai, $durasiBooking);
            
            if (!$slot) {
                Log::warning("No available slots for parkiran {$idParkiran}, vehicle type {$kendaraan->jenis}");
                DB::rollBack();
                return null;
            }

            // Create temporary reservation to lock the slot
            $reservation = $this->createTemporaryReservation(
                $slot->id_slot,
                $slot->id_floor,
                $idKendaraan,
                $idUser,
                $waktuMulai,
                $durasiBooking
            );

            if (!$reservation) {
                Log::error("Failed to create reservation for slot {$slot->id_slot}");
                DB::rollBack();
                return null;
            }

            DB::commit();
            
            Log::info("Auto-assigned slot {$slot->slot_code} (ID: {$slot->id_slot}) for user {$idUser}");
            
            return $slot->id_slot;
            
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error("Error in auto-assignment: " . $e->getMessage());
            return null;
        }
    }

    /**
     * Find an available slot for the given criteria
     * 
     * @param int $idParkiran Parkiran ID
     * @param string $jenisKendaraan Vehicle type
     * @param string $waktuMulai Start time
     * @param int $durasiBooking Duration in hours
     * @return ParkingSlot|null
     */
    private function findAvailableSlot(
        int $idParkiran,
        string $jenisKendaraan,
        string $waktuMulai,
        int $durasiBooking
    ): ?ParkingSlot {
        $startTime = Carbon::parse($waktuMulai);
        $endTime = $startTime->copy()->addHours($durasiBooking);

        Log::info("Finding available slot", [
            'parkiran' => $idParkiran,
            'vehicle_type' => $jenisKendaraan,
            'start' => $startTime,
            'end' => $endTime
        ]);

        // Get floors for this parkiran
        $floors = ParkingFloor::where('id_parkiran', $idParkiran)
            ->where('status', 'active')
            ->where('available_slots', '>', 0)
            ->get();

        Log::info("Found {$floors->count()} active floors with available slots");

        foreach ($floors as $floor) {
            Log::info("Checking floor {$floor->id_floor}: {$floor->nama_lantai}, type: {$floor->jenis_kendaraan}");
            
            // Find slots that are:
            // 1. On this floor
            // 2. Match vehicle type
            // 3. Currently available
            // 4. Not reserved (no active reservations)
            $slot = ParkingSlot::where('id_floor', $floor->id_floor)
                ->where('jenis_kendaraan', $jenisKendaraan)
                ->where('status', 'available')
                ->whereDoesntHave('reservations', function ($query) {
                    // Check for active reservations (not expired)
                    $query->where('status', 'active')
                          ->where('expires_at', '>', Carbon::now());
                })
                ->first();

            if ($slot) {
                Log::info("Found available slot: {$slot->id_slot} ({$slot->slot_code})");
                return $slot;
            } else {
                Log::warning("No available slot found on floor {$floor->id_floor} for vehicle type {$jenisKendaraan}");
            }
        }

        Log::warning("No available slots found in any floor");
        return null;
    }

    /**
     * Create a temporary reservation to lock the slot
     * 
     * @param int $idSlot Slot ID
     * @param int $idFloor Floor ID
     * @param int $idKendaraan Vehicle ID
     * @param int $idUser User ID
     * @param string $waktuMulai Start time
     * @param int $durasiBooking Duration in hours
     * @return SlotReservation|null
     */
    private function createTemporaryReservation(
        int $idSlot,
        int $idFloor,
        int $idKendaraan,
        int $idUser,
        string $waktuMulai,
        int $durasiBooking
    ): ?SlotReservation {
        try {
            $startTime = Carbon::parse($waktuMulai);
            
            // Generate reservation ID
            $reservationId = 'AUTO-' . uniqid() . '-' . time();

            $reservation = SlotReservation::create([
                'reservation_id' => $reservationId,
                'id_slot' => $idSlot,
                'id_floor' => $idFloor,
                'id_kendaraan' => $idKendaraan,
                'id_user' => $idUser,
                'reserved_at' => Carbon::now(),
                'status' => 'active',
                'expires_at' => $startTime, // Expires when booking starts
            ]);

            // Update slot status
            $slot = ParkingSlot::find($idSlot);
            if ($slot) {
                $slot->status = 'reserved';
                $slot->save();
            }

            Log::info("Created temporary reservation {$reservationId} for slot {$idSlot}");

            return $reservation;
            
        } catch (\Exception $e) {
            Log::error("Error creating temporary reservation: " . $e->getMessage());
            return null;
        }
    }

    /**
     * Check if auto-assignment is needed for a mall
     * 
     * @param int $mallId Mall ID
     * @return bool True if auto-assignment should be used
     */
    public function shouldAutoAssign(int $mallId): bool
    {
        $mall = Mall::find($mallId);
        
        if (!$mall) {
            return false;
        }

        // Auto-assign if slot reservation is disabled
        return !$mall->has_slot_reservation_enabled;
    }

    /**
     * Get available slot count for a parkiran at a specific time
     * 
     * @param int $idParkiran Parkiran ID
     * @param string $jenisKendaraan Vehicle type
     * @param string $waktuMulai Start time
     * @param int $durasiBooking Duration in hours
     * @return int Number of available slots
     */
    public function getAvailableSlotCount(
        int $idParkiran,
        string $jenisKendaraan,
        string $waktuMulai,
        int $durasiBooking
    ): int {
        $startTime = Carbon::parse($waktuMulai);
        $endTime = $startTime->copy()->addHours($durasiBooking);

        $floors = ParkingFloor::where('id_parkiran', $idParkiran)
            ->where('status', 'active')
            ->get();

        $availableCount = 0;

        foreach ($floors as $floor) {
            $count = ParkingSlot::where('id_floor', $floor->id_floor)
                ->where('jenis_kendaraan', $jenisKendaraan)
                ->where('status', 'available')
                ->whereDoesntHave('reservations', function ($query) use ($startTime, $endTime) {
                    $query->where('status', 'active')
                        ->where(function ($q) use ($startTime, $endTime) {
                            $q->whereBetween('reserved_from', [$startTime, $endTime])
                              ->orWhereBetween('reserved_until', [$startTime, $endTime])
                              ->orWhere(function ($q2) use ($startTime, $endTime) {
                                  $q2->where('reserved_from', '<=', $startTime)
                                     ->where('reserved_until', '>=', $endTime);
                              });
                        });
                })
                ->count();

            $availableCount += $count;
        }

        return $availableCount;
    }
}

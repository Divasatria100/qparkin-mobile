<?php

namespace Tests\Unit;

use Tests\TestCase;
use App\Services\SlotAutoAssignmentService;
use App\Models\ParkingSlot;
use App\Models\ParkingFloor;
use App\Models\SlotReservation;
use App\Models\Kendaraan;
use App\Models\Parkiran;
use App\Models\Mall;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Carbon\Carbon;

class SlotAutoAssignmentServiceTest extends TestCase
{
    use RefreshDatabase;

    protected SlotAutoAssignmentService $service;

    protected function setUp(): void
    {
        parent::setUp();
        $this->service = new SlotAutoAssignmentService();
    }

    /** @test */
    public function it_can_auto_assign_available_slot()
    {
        // Arrange
        $mall = Mall::factory()->create(['has_slot_reservation_enabled' => false]);
        $parkiran = Parkiran::factory()->create([
            'id_mall' => $mall->id_mall,
            'jenis_kendaraan' => 'Roda Empat'
        ]);
        $floor = ParkingFloor::factory()->create([
            'id_parkiran' => $parkiran->id_parkiran,
            'total_slots' => 10,
            'available_slots' => 10
        ]);
        $slot = ParkingSlot::factory()->create([
            'id_floor' => $floor->id_floor,
            'slot_code' => 'SLOT-001',
            'jenis_kendaraan' => 'Roda Empat',
            'status' => 'available'
        ]);
        $kendaraan = Kendaraan::factory()->create(['jenis_kendaraan' => 'Roda Empat']);
        $userId = 1;
        $waktuMulai = Carbon::now()->addHours(2)->toDateTimeString();
        $durasi = 2;

        // Act
        $slotId = $this->service->assignSlot(
            $parkiran->id_parkiran,
            $kendaraan->id_kendaraan,
            $userId,
            $waktuMulai,
            $durasi
        );

        // Assert
        $this->assertNotNull($slotId);
        $this->assertEquals($slot->id_slot, $slotId);
        
        // Check reservation created
        $this->assertDatabaseHas('slot_reservations', [
            'id_slot' => $slotId,
            'id_user' => $userId,
            'status' => 'active'
        ]);
        
        // Check slot status updated
        $this->assertDatabaseHas('parking_slots', [
            'id_slot' => $slotId,
            'status' => 'reserved'
        ]);
    }

    /** @test */
    public function it_returns_null_when_no_slots_available()
    {
        // Arrange
        $mall = Mall::factory()->create(['has_slot_reservation_enabled' => false]);
        $parkiran = Parkiran::factory()->create([
            'id_mall' => $mall->id_mall,
            'jenis_kendaraan' => 'Roda Empat'
        ]);
        $floor = ParkingFloor::factory()->create([
            'id_parkiran' => $parkiran->id_parkiran,
            'total_slots' => 1,
            'available_slots' => 0
        ]);
        $slot = ParkingSlot::factory()->create([
            'id_floor' => $floor->id_floor,
            'status' => 'occupied' // No available slots
        ]);
        $kendaraan = Kendaraan::factory()->create(['jenis_kendaraan' => 'Roda Empat']);

        // Act
        $slotId = $this->service->assignSlot(
            $parkiran->id_parkiran,
            $kendaraan->id_kendaraan,
            1,
            Carbon::now()->toDateTimeString(),
            2
        );

        // Assert
        $this->assertNull($slotId);
    }

    /** @test */
    public function it_avoids_slots_with_overlapping_reservations()
    {
        // Arrange
        $mall = Mall::factory()->create(['has_slot_reservation_enabled' => false]);
        $parkiran = Parkiran::factory()->create([
            'id_mall' => $mall->id_mall,
            'jenis_kendaraan' => 'Roda Empat'
        ]);
        $floor = ParkingFloor::factory()->create([
            'id_parkiran' => $parkiran->id_parkiran,
            'total_slots' => 2
        ]);
        
        // Slot 1: Already reserved 14:00-16:00
        $slot1 = ParkingSlot::factory()->create([
            'id_floor' => $floor->id_floor,
            'slot_code' => 'SLOT-001',
            'jenis_kendaraan' => 'Roda Empat',
            'status' => 'reserved'
        ]);
        SlotReservation::factory()->create([
            'id_slot' => $slot1->id_slot,
            'reserved_from' => Carbon::parse('2025-12-06 14:00:00'),
            'reserved_until' => Carbon::parse('2025-12-06 16:00:00'),
            'status' => 'active'
        ]);
        
        // Slot 2: Available
        $slot2 = ParkingSlot::factory()->create([
            'id_floor' => $floor->id_floor,
            'slot_code' => 'SLOT-002',
            'jenis_kendaraan' => 'Roda Empat',
            'status' => 'available'
        ]);
        
        $kendaraan = Kendaraan::factory()->create(['jenis_kendaraan' => 'Roda Empat']);

        // Act: Try to book 14:00-16:00 (overlaps with slot1)
        $slotId = $this->service->assignSlot(
            $parkiran->id_parkiran,
            $kendaraan->id_kendaraan,
            2,
            '2025-12-06 14:00:00',
            2
        );

        // Assert: Should assign slot2, not slot1
        $this->assertNotNull($slotId);
        $this->assertEquals($slot2->id_slot, $slotId);
    }

    /** @test */
    public function it_correctly_identifies_malls_needing_auto_assignment()
    {
        // Arrange
        $mallWithReservation = Mall::factory()->create([
            'has_slot_reservation_enabled' => true
        ]);
        $mallWithoutReservation = Mall::factory()->create([
            'has_slot_reservation_enabled' => false
        ]);

        // Act & Assert
        $this->assertFalse($this->service->shouldAutoAssign($mallWithReservation->id_mall));
        $this->assertTrue($this->service->shouldAutoAssign($mallWithoutReservation->id_mall));
    }

    /** @test */
    public function it_can_count_available_slots_for_time_period()
    {
        // Arrange
        $mall = Mall::factory()->create(['has_slot_reservation_enabled' => false]);
        $parkiran = Parkiran::factory()->create([
            'id_mall' => $mall->id_mall,
            'jenis_kendaraan' => 'Roda Empat'
        ]);
        $floor = ParkingFloor::factory()->create([
            'id_parkiran' => $parkiran->id_parkiran,
            'total_slots' => 5
        ]);
        
        // Create 5 slots
        for ($i = 1; $i <= 5; $i++) {
            ParkingSlot::factory()->create([
                'id_floor' => $floor->id_floor,
                'slot_code' => "SLOT-00{$i}",
                'jenis_kendaraan' => 'Roda Empat',
                'status' => 'available'
            ]);
        }
        
        // Reserve 2 slots for 14:00-16:00
        $slots = ParkingSlot::where('id_floor', $floor->id_floor)->take(2)->get();
        foreach ($slots as $slot) {
            SlotReservation::factory()->create([
                'id_slot' => $slot->id_slot,
                'reserved_from' => Carbon::parse('2025-12-06 14:00:00'),
                'reserved_until' => Carbon::parse('2025-12-06 16:00:00'),
                'status' => 'active'
            ]);
        }

        // Act: Count available slots for 14:00-16:00
        $count = $this->service->getAvailableSlotCount(
            $parkiran->id_parkiran,
            'Roda Empat',
            '2025-12-06 14:00:00',
            2
        );

        // Assert: Should have 3 available (5 total - 2 reserved)
        $this->assertEquals(3, $count);
    }

    /** @test */
    public function it_prevents_overbooking_with_multiple_concurrent_requests()
    {
        // Arrange
        $mall = Mall::factory()->create(['has_slot_reservation_enabled' => false]);
        $parkiran = Parkiran::factory()->create([
            'id_mall' => $mall->id_mall,
            'jenis_kendaraan' => 'Roda Empat'
        ]);
        $floor = ParkingFloor::factory()->create([
            'id_parkiran' => $parkiran->id_parkiran,
            'total_slots' => 3
        ]);
        
        // Create only 3 slots
        for ($i = 1; $i <= 3; $i++) {
            ParkingSlot::factory()->create([
                'id_floor' => $floor->id_floor,
                'slot_code' => "SLOT-00{$i}",
                'jenis_kendaraan' => 'Roda Empat',
                'status' => 'available'
            ]);
        }
        
        $kendaraan = Kendaraan::factory()->create(['jenis_kendaraan' => 'Roda Empat']);
        $waktuMulai = '2025-12-06 14:00:00';
        $durasi = 2;

        // Act: Try to assign 5 slots (but only 3 available)
        $assignedSlots = [];
        for ($i = 1; $i <= 5; $i++) {
            $slotId = $this->service->assignSlot(
                $parkiran->id_parkiran,
                $kendaraan->id_kendaraan,
                $i,
                $waktuMulai,
                $durasi
            );
            
            if ($slotId) {
                $assignedSlots[] = $slotId;
            }
        }

        // Assert: Only 3 slots should be assigned
        $this->assertCount(3, $assignedSlots);
        
        // Check all 3 slots are reserved
        $this->assertEquals(3, SlotReservation::where('status', 'active')->count());
    }
}

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
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Carbon\Carbon;

/**
 * Unit Test untuk SlotAutoAssignmentService
 * 
 * Pengujian ini berfokus pada:
 * - Validasi slot tersedia
 * - Pencegahan booking bentrok
 * - Logika auto-assignment
 * - Perhitungan ketersediaan slot
 */
class SlotAutoAssignmentServiceTest extends TestCase
{
    use RefreshDatabase;

    protected $service;
    protected $user;
    protected $mall;
    protected $parkiran;
    protected $floor;
    protected $kendaraan;

    protected function setUp(): void
    {
        parent::setUp();
        
        $this->service = new SlotAutoAssignmentService();
        
        // Setup test data
        $this->user = User::factory()->create();
        
        $this->mall = Mall::create([
            'nama_mall' => 'Test Mall',
            'alamat_lengkap' => 'Test Location',
            'latitude' => -6.2088,
            'longitude' => 106.8456,
            'kapasitas' => 100,
            'status' => 'active',
            'has_slot_reservation_enabled' => false
        ]);
        
        $this->parkiran = Parkiran::create([
            'id_mall' => $this->mall->id_mall,
            'jenis_kendaraan' => 'Roda Empat',
            'kapasitas' => 50,
            'status' => 'Tersedia'
        ]);
        
        $this->floor = ParkingFloor::create([
            'id_parkiran' => $this->parkiran->id_parkiran,
            'floor_name' => 'Lantai 1',
            'floor_number' => 1,
            'total_slots' => 10,
            'available_slots' => 10,
            'status' => 'active'
        ]);
        
        $this->kendaraan = Kendaraan::create([
            'id_user' => $this->user->id_user,
            'plat' => 'B1234XYZ',
            'jenis' => 'Roda Empat',
            'merk' => 'Toyota',
            'tipe' => 'Avanza'
        ]);
    }

    /**
     * Test 1: Validasi slot tersedia untuk booking normal
     * 
     * Assertion: assertEquals
     * Tujuan: Memastikan service dapat menemukan dan assign slot yang tersedia
     */
    public function test_can_assign_available_slot()
    {
        // Arrange: Buat slot yang tersedia
        $slot = ParkingSlot::create([
            'id_floor' => $this->floor->id_floor,
            'slot_code' => 'A-01',
            'jenis_kendaraan' => 'Roda Empat',
            'status' => 'available'
        ]);

        // Act: Assign slot
        $assignedSlotId = $this->service->assignSlot(
            $this->parkiran->id_parkiran,
            $this->kendaraan->id_kendaraan,
            $this->user->id_user,
            now()->toDateTimeString(),
            2
        );

        // Assert: Slot berhasil di-assign
        $this->assertEquals($slot->id_slot, $assignedSlotId);
        
        // Verify reservation created
        $this->assertDatabaseHas('slot_reservations', [
            'id_slot' => $slot->id_slot,
            'id_user' => $this->user->id_user,
            'status' => 'active'
        ]);
    }

    /**
     * Test 2: Cegah booking bentrok (slot sudah direservasi)
     * 
     * Assertion: assertNull
     * Tujuan: Memastikan sistem tidak assign slot yang sudah direservasi
     */
    public function test_cannot_assign_reserved_slot()
    {
        // Arrange: Buat slot dan reservasi yang bentrok
        $slot = ParkingSlot::create([
            'id_floor' => $this->floor->id_floor,
            'slot_code' => 'A-01',
            'jenis_kendaraan' => 'Roda Empat',
            'status' => 'available'
        ]);

        $startTime = Carbon::now()->addHours(1);
        $endTime = $startTime->copy()->addHours(2);

        // Buat reservasi yang bentrok
        SlotReservation::create([
            'reservation_id' => 'TEST-001',
            'id_slot' => $slot->id_slot,
            'id_user' => $this->user->id_user,
            'reserved_from' => $startTime,
            'reserved_until' => $endTime,
            'status' => 'active',
            'expires_at' => $startTime
        ]);

        // Act: Coba assign slot pada waktu yang sama
        $assignedSlotId = $this->service->assignSlot(
            $this->parkiran->id_parkiran,
            $this->kendaraan->id_kendaraan,
            $this->user->id_user,
            $startTime->toDateTimeString(),
            2
        );

        // Assert: Tidak ada slot yang di-assign (null)
        $this->assertNull($assignedSlotId);
    }

    /**
     * Test 3: Validasi tidak ada slot tersedia
     * 
     * Assertion: assertNull
     * Tujuan: Memastikan service return null ketika tidak ada slot
     */
    public function test_returns_null_when_no_slots_available()
    {
        // Arrange: Tidak ada slot yang dibuat

        // Act: Coba assign slot
        $assignedSlotId = $this->service->assignSlot(
            $this->parkiran->id_parkiran,
            $this->kendaraan->id_kendaraan,
            $this->user->id_user,
            now()->toDateTimeString(),
            2
        );

        // Assert: Return null karena tidak ada slot
        $this->assertNull($assignedSlotId);
    }

    /**
     * Test 4: Perhitungan jumlah slot tersedia
     * 
     * Assertion: assertEquals
     * Tujuan: Memastikan perhitungan slot tersedia akurat
     */
    public function test_calculates_available_slot_count_correctly()
    {
        // Arrange: Buat 3 slot tersedia
        for ($i = 1; $i <= 3; $i++) {
            ParkingSlot::create([
                'id_floor' => $this->floor->id_floor,
                'slot_code' => "A-0{$i}",
                'jenis_kendaraan' => 'Roda Empat',
                'status' => 'available'
            ]);
        }

        // Act: Hitung slot tersedia
        $count = $this->service->getAvailableSlotCount(
            $this->parkiran->id_parkiran,
            'Roda Empat',
            now()->toDateTimeString(),
            2
        );

        // Assert: Jumlah slot = 3
        $this->assertEquals(3, $count);
    }

    /**
     * Test 5: Validasi auto-assignment berdasarkan konfigurasi mall
     * 
     * Assertion: assertTrue, assertFalse
     * Tujuan: Memastikan logika pengecekan auto-assignment benar
     */
    public function test_should_auto_assign_based_on_mall_config()
    {
        // Arrange & Act: Mall dengan slot reservation disabled
        $shouldAutoAssign = $this->service->shouldAutoAssign($this->mall->id_mall);

        // Assert: Harus auto-assign
        $this->assertTrue($shouldAutoAssign);

        // Arrange: Update mall config - enable slot reservation
        $this->mall->update(['has_slot_reservation_enabled' => true]);

        // Act: Check lagi
        $shouldNotAutoAssign = $this->service->shouldAutoAssign($this->mall->id_mall);

        // Assert: Tidak perlu auto-assign
        $this->assertFalse($shouldNotAutoAssign);
    }

    /**
     * Test 6: Validasi kendaraan tidak ditemukan
     * 
     * Assertion: assertNull
     * Tujuan: Memastikan service handle error ketika kendaraan tidak valid
     */
    public function test_returns_null_when_vehicle_not_found()
    {
        // Arrange: ID kendaraan yang tidak ada
        $invalidVehicleId = 99999;

        // Act: Coba assign slot dengan kendaraan invalid
        $assignedSlotId = $this->service->assignSlot(
            $this->parkiran->id_parkiran,
            $invalidVehicleId,
            $this->user->id_user,
            now()->toDateTimeString(),
            2
        );

        // Assert: Return null
        $this->assertNull($assignedSlotId);
    }

    /**
     * Test 7: Validasi slot dengan jenis kendaraan berbeda tidak di-assign
     * 
     * Assertion: assertNull
     * Tujuan: Memastikan slot hanya di-assign untuk jenis kendaraan yang sesuai
     */
    public function test_does_not_assign_slot_for_different_vehicle_type()
    {
        // Arrange: Buat slot untuk Roda Dua
        ParkingSlot::create([
            'id_floor' => $this->floor->id_floor,
            'slot_code' => 'M-01',
            'jenis_kendaraan' => 'Roda Dua',
            'status' => 'available'
        ]);

        // Act: Coba assign untuk kendaraan Roda Empat
        $assignedSlotId = $this->service->assignSlot(
            $this->parkiran->id_parkiran,
            $this->kendaraan->id_kendaraan, // Roda Empat
            $this->user->id_user,
            now()->toDateTimeString(),
            2
        );

        // Assert: Tidak ada slot yang di-assign
        $this->assertNull($assignedSlotId);
    }
}

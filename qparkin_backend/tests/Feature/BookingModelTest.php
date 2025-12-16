<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\Booking;
use App\Models\TransaksiParkir;
use App\Models\ParkingSlot;
use App\Models\ParkingFloor;
use App\Models\Parkiran;
use App\Models\Mall;
use App\Models\User;
use App\Models\Kendaraan;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Carbon\Carbon;

/**
 * Feature Test untuk Model Booking (CRUD Test)
 * 
 * Pengujian ini mencakup:
 * - Create: Membuat booking baru
 * - Read: Membaca data booking
 * - Update: Mengupdate status booking
 * - Delete: Menghapus booking
 */
class BookingModelTest extends TestCase
{
    use RefreshDatabase;

    protected $user;
    protected $mall;
    protected $parkiran;
    protected $floor;
    protected $slot;
    protected $kendaraan;
    protected $transaksi;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Setup test data
        $this->user = User::factory()->create();
        
        $this->mall = Mall::create([
            'nama_mall' => 'Test Mall',
            'lokasi' => 'Test Location',
            'kapasitas' => 100,
            'alamat_gmaps' => 'https://maps.google.com'
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
        
        $this->slot = ParkingSlot::create([
            'id_floor' => $this->floor->id_floor,
            'slot_code' => 'A-01',
            'jenis_kendaraan' => 'Roda Empat',
            'status' => 'available'
        ]);
        
        $this->kendaraan = Kendaraan::create([
            'id_user' => $this->user->id_user,
            'plat' => 'B1234XYZ',
            'jenis_kendaraan' => 'Roda Empat',
            'merk' => 'Toyota',
            'tipe' => 'Avanza'
        ]);
        
        $this->transaksi = TransaksiParkir::create([
            'id_user' => $this->user->id_user,
            'id_parkiran' => $this->parkiran->id_parkiran,
            'id_kendaraan' => $this->kendaraan->id_kendaraan,
            'id_slot' => $this->slot->id_slot,
            'waktu_masuk' => now(),
            'status' => 'booked'
        ]);
    }

    /**
     * Test CREATE: Membuat booking baru
     * 
     * Assertion: assertDatabaseHas
     * Tujuan: Memastikan booking dapat dibuat dan tersimpan di database
     */
    public function test_can_create_booking()
    {
        // Arrange
        $waktuMulai = Carbon::now()->addHours(1);
        $waktuSelesai = $waktuMulai->copy()->addHours(2);
        
        $bookingData = [
            'id_transaksi' => $this->transaksi->id_transaksi,
            'id_slot' => $this->slot->id_slot,
            'waktu_mulai' => $waktuMulai,
            'waktu_selesai' => $waktuSelesai,
            'durasi_booking' => 2,
            'status' => 'confirmed',
            'dibooking_pada' => now()
        ];

        // Act
        $booking = Booking::create($bookingData);

        // Assert
        $this->assertDatabaseHas('booking', [
            'id_transaksi' => $this->transaksi->id_transaksi,
            'id_slot' => $this->slot->id_slot,
            'status' => 'confirmed',
            'durasi_booking' => 2
        ]);
        
        $this->assertNotNull($booking->id_transaksi);
    }

    /**
     * Test READ: Membaca data booking
     * 
     * Assertion: assertEquals, assertNotNull
     * Tujuan: Memastikan booking dapat dibaca dari database
     */
    public function test_can_read_booking()
    {
        // Arrange: Buat booking
        $waktuMulai = Carbon::now()->addHours(1);
        $waktuSelesai = $waktuMulai->copy()->addHours(2);
        
        $booking = Booking::create([
            'id_transaksi' => $this->transaksi->id_transaksi,
            'id_slot' => $this->slot->id_slot,
            'waktu_mulai' => $waktuMulai,
            'waktu_selesai' => $waktuSelesai,
            'durasi_booking' => 2,
            'status' => 'confirmed',
            'dibooking_pada' => now()
        ]);

        // Act: Baca booking
        $foundBooking = Booking::find($booking->id_transaksi);

        // Assert
        $this->assertNotNull($foundBooking);
        $this->assertEquals($booking->id_transaksi, $foundBooking->id_transaksi);
        $this->assertEquals('confirmed', $foundBooking->status);
        $this->assertEquals(2, $foundBooking->durasi_booking);
    }

    /**
     * Test UPDATE: Mengupdate status booking
     * 
     * Assertion: assertDatabaseHas
     * Tujuan: Memastikan booking dapat diupdate
     */
    public function test_can_update_booking_status()
    {
        // Arrange: Buat booking
        $booking = Booking::create([
            'id_transaksi' => $this->transaksi->id_transaksi,
            'id_slot' => $this->slot->id_slot,
            'waktu_mulai' => now()->addHours(1),
            'waktu_selesai' => now()->addHours(3),
            'durasi_booking' => 2,
            'status' => 'confirmed',
            'dibooking_pada' => now()
        ]);

        // Act: Update status
        $booking->update(['status' => 'cancelled']);

        // Assert
        $this->assertDatabaseHas('booking', [
            'id_transaksi' => $booking->id_transaksi,
            'status' => 'cancelled'
        ]);
    }

    /**
     * Test DELETE: Menghapus booking
     * 
     * Assertion: assertDatabaseMissing
     * Tujuan: Memastikan booking dapat dihapus dari database
     */
    public function test_can_delete_booking()
    {
        // Arrange: Buat booking
        $booking = Booking::create([
            'id_transaksi' => $this->transaksi->id_transaksi,
            'id_slot' => $this->slot->id_slot,
            'waktu_mulai' => now()->addHours(1),
            'waktu_selesai' => now()->addHours(3),
            'durasi_booking' => 2,
            'status' => 'confirmed',
            'dibooking_pada' => now()
        ]);

        $bookingId = $booking->id_transaksi;

        // Act: Hapus booking
        $booking->delete();

        // Assert
        $this->assertDatabaseMissing('booking', [
            'id_transaksi' => $bookingId
        ]);
    }

    /**
     * Test: Booking dengan relasi transaksi parkir
     * 
     * Assertion: assertNotNull, assertEquals
     * Tujuan: Memastikan relasi booking dengan transaksi berfungsi
     */
    public function test_booking_has_transaksi_parkir_relation()
    {
        // Arrange & Act
        $booking = Booking::create([
            'id_transaksi' => $this->transaksi->id_transaksi,
            'id_slot' => $this->slot->id_slot,
            'waktu_mulai' => now()->addHours(1),
            'waktu_selesai' => now()->addHours(3),
            'durasi_booking' => 2,
            'status' => 'confirmed',
            'dibooking_pada' => now()
        ]);

        // Assert
        $this->assertNotNull($booking->transaksiParkir);
        $this->assertEquals($this->transaksi->id_transaksi, $booking->transaksiParkir->id_transaksi);
    }

    /**
     * Test: Booking dengan relasi slot
     * 
     * Assertion: assertNotNull, assertEquals
     * Tujuan: Memastikan relasi booking dengan slot berfungsi
     */
    public function test_booking_has_slot_relation()
    {
        // Arrange & Act
        $booking = Booking::create([
            'id_transaksi' => $this->transaksi->id_transaksi,
            'id_slot' => $this->slot->id_slot,
            'waktu_mulai' => now()->addHours(1),
            'waktu_selesai' => now()->addHours(3),
            'durasi_booking' => 2,
            'status' => 'confirmed',
            'dibooking_pada' => now()
        ]);

        // Assert
        $this->assertNotNull($booking->slot);
        $this->assertEquals($this->slot->id_slot, $booking->slot->id_slot);
        $this->assertEquals('A-01', $booking->slot->slot_code);
    }
}

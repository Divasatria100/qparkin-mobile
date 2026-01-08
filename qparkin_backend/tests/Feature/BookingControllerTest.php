<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Booking;
use App\Models\TransaksiParkir;
use App\Models\ParkingSlot;
use App\Models\ParkingFloor;
use App\Models\Parkiran;
use App\Models\Mall;
use App\Models\Kendaraan;
use App\Models\SlotReservation;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Carbon\Carbon;

/**
 * Feature Test untuk BookingController (API Test)
 * 
 * Pengujian endpoint API dengan berbagai status HTTP:
 * - 200: GET all bookings, GET detail, PUT update, DELETE
 * - 201: POST create booking
 * - 400: Validation error
 * - 404: Not Found
 * - 401: Unauthorized
 */
class BookingControllerTest extends TestCase
{
    use RefreshDatabase;

    protected $user;
    protected $mall;
    protected $parkiran;
    protected $floor;
    protected $slot;
    protected $kendaraan;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Setup authenticated user
        $this->user = User::factory()->create();
        
        // Setup test data
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
    }

    /**
     * Test a: 200 - GET all bookings
     * 
     * Assertion: assertStatus(200), assertJson
     * Tujuan: Memastikan endpoint GET /api/booking mengembalikan daftar booking
     */
    public function test_can_get_all_bookings()
    {
        // Arrange: Authenticate user
        Sanctum::actingAs($this->user);
        
        // Buat booking untuk user ini
        $transaksi = TransaksiParkir::create([
            'id_user' => $this->user->id_user,
            'id_parkiran' => $this->parkiran->id_parkiran,
            'id_kendaraan' => $this->kendaraan->id_kendaraan,
            'id_slot' => $this->slot->id_slot,
            'waktu_masuk' => now(),
            'status' => 'booked'
        ]);
        
        Booking::create([
            'id_transaksi' => $transaksi->id_transaksi,
            'id_slot' => $this->slot->id_slot,
            'waktu_mulai' => now()->addHours(1),
            'waktu_selesai' => now()->addHours(3),
            'durasi_booking' => 2,
            'status' => 'confirmed',
            'dibooking_pada' => now()
        ]);

        // Act: GET request
        $response = $this->getJson('/api/booking');

        // Assert: Status 200 dan data ada
        $response->assertStatus(200)
                 ->assertJson([
                     'success' => true
                 ])
                 ->assertJsonStructure([
                     'success',
                     'data' => [
                         '*' => [
                             'id_transaksi',
                             'id_slot',
                             'status',
                             'durasi_booking'
                         ]
                     ]
                 ]);
    }

    /**
     * Test b: 200 - GET detail booking by ID
     * 
     * Assertion: assertStatus(200), assertJson
     * Tujuan: Memastikan endpoint GET /api/booking/{id} mengembalikan detail booking
     */
    public function test_can_get_booking_detail()
    {
        // Arrange
        Sanctum::actingAs($this->user);
        
        $transaksi = TransaksiParkir::create([
            'id_user' => $this->user->id_user,
            'id_parkiran' => $this->parkiran->id_parkiran,
            'id_kendaraan' => $this->kendaraan->id_kendaraan,
            'id_slot' => $this->slot->id_slot,
            'waktu_masuk' => now(),
            'status' => 'booked'
        ]);
        
        $booking = Booking::create([
            'id_transaksi' => $transaksi->id_transaksi,
            'id_slot' => $this->slot->id_slot,
            'waktu_mulai' => now()->addHours(1),
            'waktu_selesai' => now()->addHours(3),
            'durasi_booking' => 2,
            'status' => 'confirmed',
            'dibooking_pada' => now()
        ]);

        // Act
        $response = $this->getJson("/api/booking/{$booking->id_transaksi}");

        // Assert
        $response->assertStatus(200)
                 ->assertJson([
                     'success' => true,
                     'data' => [
                         'id_transaksi' => $booking->id_transaksi,
                         'status' => 'confirmed'
                     ]
                 ]);
    }

    /**
     * Test c: 201 - POST create booking
     * 
     * Assertion: assertCreated(), assertJson, assertDatabaseHas
     * Tujuan: Memastikan endpoint POST /api/booking dapat membuat booking baru
     */
    public function test_can_create_booking()
    {
        // Arrange
        Sanctum::actingAs($this->user);
        
        $bookingData = [
            'id_parkiran' => $this->parkiran->id_parkiran,
            'id_kendaraan' => $this->kendaraan->id_kendaraan,
            'waktu_mulai' => now()->addHours(2)->toDateTimeString(),
            'durasi_booking' => 2,
            'id_slot' => $this->slot->id_slot
        ];

        // Act
        $response = $this->postJson('/api/booking', $bookingData);

        // Assert
        $response->assertCreated()
                    ->assertJson([
                        'success' => true,
                        'message' => 'Booking berhasil dibuat'
                    ])
                    ->assertJsonStructure([
                        'success',
                        'message',
                        'data' => [
                            'id_transaksi',
                            'id_slot',
                            'status'
                        ]
                    ]);
        
        $this->assertDatabaseHas('booking', [
            'id_slot' => $this->slot->id_slot,
            'status' => 'confirmed',
            'durasi_booking' => 2
        ]);
    }

    /**
     * Test d: 200 - PUT/PATCH update booking (cancel)
     * 
     * Assertion: assertStatus(200), assertJson, assertDatabaseHas
     * Tujuan: Memastikan endpoint PUT /api/booking/{id}/cancel dapat membatalkan booking
     */
    public function test_can_cancel_booking()
    {
        // Arrange
        Sanctum::actingAs($this->user);
        
        $transaksi = TransaksiParkir::create([
            'id_user' => $this->user->id_user,
            'id_parkiran' => $this->parkiran->id_parkiran,
            'id_kendaraan' => $this->kendaraan->id_kendaraan,
            'id_slot' => $this->slot->id_slot,
            'waktu_masuk' => now(),
            'status' => 'booked'
        ]);
        
        $booking = Booking::create([
            'id_transaksi' => $transaksi->id_transaksi,
            'id_slot' => $this->slot->id_slot,
            'waktu_mulai' => now()->addHours(1),
            'waktu_selesai' => now()->addHours(3),
            'durasi_booking' => 2,
            'status' => 'confirmed',
            'dibooking_pada' => now()
        ]);

        // Act
        $response = $this->putJson("/api/booking/{$booking->id_transaksi}/cancel");

        // Assert
        $response->assertStatus(200)
                 ->assertJson([
                     'success' => true,
                     'message' => 'Booking berhasil dibatalkan'
                 ]);
        
        $this->assertDatabaseHas('booking', [
            'id_transaksi' => $booking->id_transaksi,
            'status' => 'cancelled'
        ]);
    }

    /**
     * Test e: 200 - DELETE booking (via cancel endpoint)
     * Note: Aplikasi menggunakan soft delete via status 'cancelled'
     * 
     * Assertion: assertStatus(200), assertDatabaseHas
     * Tujuan: Memastikan booking dapat di-cancel (soft delete)
     */
    public function test_can_delete_booking_via_cancel()
    {
        // Arrange
        Sanctum::actingAs($this->user);
        
        $transaksi = TransaksiParkir::create([
            'id_user' => $this->user->id_user,
            'id_parkiran' => $this->parkiran->id_parkiran,
            'id_kendaraan' => $this->kendaraan->id_kendaraan,
            'id_slot' => $this->slot->id_slot,
            'waktu_masuk' => now(),
            'status' => 'booked'
        ]);
        
        $booking = Booking::create([
            'id_transaksi' => $transaksi->id_transaksi,
            'id_slot' => $this->slot->id_slot,
            'waktu_mulai' => now()->addHours(1),
            'waktu_selesai' => now()->addHours(3),
            'durasi_booking' => 2,
            'status' => 'confirmed',
            'dibooking_pada' => now()
        ]);

        // Act: Cancel = soft delete
        $response = $this->putJson("/api/booking/{$booking->id_transaksi}/cancel");

        // Assert
        $response->assertStatus(200);
        
        // Verify status changed to cancelled (soft delete)
        $this->assertDatabaseHas('booking', [
            'id_transaksi' => $booking->id_transaksi,
            'status' => 'cancelled'
        ]);
    }

    /**
     * Test f: 400 - Validation error (data tidak lengkap)
     * 
     * Assertion: assertStatus(400), assertJsonValidationErrors
     * Tujuan: Memastikan validasi input berfungsi
     */
    public function test_create_booking_validation_error()
    {
        // Arrange
        Sanctum::actingAs($this->user);
        
        // Data tidak lengkap (missing required fields)
        $invalidData = [
            'id_parkiran' => $this->parkiran->id_parkiran,
            // Missing: id_kendaraan, waktu_mulai, durasi_booking
        ];

        // Act
        $response = $this->postJson('/api/booking', $invalidData);

        // Assert
        $response->assertStatus(422) // Laravel validation returns 422
                 ->assertJsonValidationErrors(['id_kendaraan', 'waktu_mulai', 'durasi_booking']);
    }

    /**
     * Test g: 404 - Not Found (ID tidak tersedia)
     * 
     * Assertion: assertNotFound(), assertJson
     * Tujuan: Memastikan endpoint mengembalikan 404 untuk ID yang tidak ada
     */
    public function test_get_booking_not_found()
    {
        // Arrange
        Sanctum::actingAs($this->user);
        
        $nonExistentId = 99999;

        // Act
        $response = $this->getJson("/api/booking/{$nonExistentId}");

        // Assert
        $response->assertNotFound()
                 ->assertJson([
                     'success' => false,
                     'message' => 'Booking not found'
                 ]);
    }

    /**
     * Test h: 401 - Unauthorized (akses tanpa autentikasi)
     * 
     * Assertion: assertStatus(401)
     * Tujuan: Memastikan endpoint protected memerlukan autentikasi
     */
    public function test_booking_requires_authentication()
    {
        // Arrange: Tidak ada autentikasi (no Sanctum::actingAs)

        // Act: Coba akses endpoint protected
        $response = $this->getJson('/api/booking');

        // Assert: Unauthorized
        $response->assertStatus(401);
    }

    /**
     * Test tambahan: 400 - Invalid reservation ID
     * 
     * Assertion: assertStatus(400), assertJson
     * Tujuan: Memastikan validasi reservation ID berfungsi
     */
    public function test_create_booking_with_invalid_reservation()
    {
        // Arrange
        Sanctum::actingAs($this->user);
        
        $bookingData = [
            'id_parkiran' => $this->parkiran->id_parkiran,
            'id_kendaraan' => $this->kendaraan->id_kendaraan,
            'waktu_mulai' => now()->addHours(2)->toDateTimeString(),
            'durasi_booking' => 2,
            'reservation_id' => 'INVALID-RESERVATION-ID'
        ];

        // Act
        $response = $this->postJson('/api/booking', $bookingData);

        // Assert
        $response->assertStatus(400)
                 ->assertJson([
                     'success' => false,
                     'message' => 'INVALID_RESERVATION'
                 ]);
    }

    /**
     * Test tambahan: 404 - No slots available
     * 
     * Assertion: assertStatus(404), assertJson
     * Tujuan: Memastikan sistem menangani kondisi slot penuh
     */
    public function test_create_booking_no_slots_available()
    {
        // Arrange
        Sanctum::actingAs($this->user);
        
        // Mark slot as occupied
        $this->slot->update(['status' => 'occupied']);
        
        $bookingData = [
            'id_parkiran' => $this->parkiran->id_parkiran,
            'id_kendaraan' => $this->kendaraan->id_kendaraan,
            'waktu_mulai' => now()->addHours(2)->toDateTimeString(),
            'durasi_booking' => 2
            // No id_slot provided, will try auto-assign
        ];

        // Act
        $response = $this->postJson('/api/booking', $bookingData);

        // Assert
        $response->assertStatus(404)
                 ->assertJson([
                     'success' => false,
                     'message' => 'NO_SLOTS_AVAILABLE'
                 ]);
    }
}

<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\TransaksiParkir;
use App\Models\Booking;
use App\Models\ParkingSlot;
use App\Models\ParkingFloor;
use App\Models\Parkiran;
use App\Models\Mall;
use App\Models\Kendaraan;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;

/**
 * Feature Test untuk TransaksiController (QR Controller)
 * 
 * Pengujian untuk fitur QR Masuk/Keluar:
 * - Scan QR valid (berhasil)
 * - Scan QR expired/tidak valid (gagal)
 */
class TransaksiControllerTest extends TestCase
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
    }

    /**
     * Test: Scan QR valid untuk masuk (berhasil)
     * 
     * Assertion: assertCreated(), assertJson
     * Tujuan: Memastikan QR valid dapat digunakan untuk check-in
     */
    public function test_can_scan_qr_masuk_with_valid_booking()
    {
        // Arrange
        Sanctum::actingAs($this->user);
        
        // Buat booking aktif
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
            'waktu_mulai' => now(),
            'waktu_selesai' => now()->addHours(2),
            'durasi_booking' => 2,
            'status' => 'confirmed',
            'dibooking_pada' => now()
        ]);
        
        $qrData = [
            'id_transaksi' => $transaksi->id_transaksi,
            'qr_code' => 'VALID-QR-CODE-123'
        ];

        // Act
        $response = $this->postJson('/api/transaksi/masuk', $qrData);

        // Assert
        $response->assertCreated()
                 ->assertJson([
                     'success' => true,
                     'message' => 'Entry recorded successfully'
                 ]);
    }

    /**
     * Test: Scan QR untuk keluar (berhasil)
     * 
     * Assertion: assertStatus(200), assertJson
     * Tujuan: Memastikan QR valid dapat digunakan untuk check-out
     */
    public function test_can_scan_qr_keluar_with_valid_booking()
    {
        // Arrange
        Sanctum::actingAs($this->user);
        
        // Buat transaksi yang sudah masuk
        $transaksi = TransaksiParkir::create([
            'id_user' => $this->user->id_user,
            'id_parkiran' => $this->parkiran->id_parkiran,
            'id_kendaraan' => $this->kendaraan->id_kendaraan,
            'id_slot' => $this->slot->id_slot,
            'waktu_masuk' => now()->subHours(1),
            'status' => 'active'
        ]);
        
        $qrData = [
            'id_transaksi' => $transaksi->id_transaksi,
            'qr_code' => 'VALID-QR-CODE-123'
        ];

        // Act
        $response = $this->postJson('/api/transaksi/keluar', $qrData);

        // Assert
        $response->assertStatus(200)
                 ->assertJson([
                     'success' => true,
                     'message' => 'Exit recorded successfully'
                 ]);
    }

    /**
     * Test: Scan QR expired/tidak valid (gagal)
     * 
     * Assertion: assertStatus(201) - EXPECTED TO FAIL
     * Tujuan: Memastikan QR expired tidak dapat digunakan
     * 
     * CATATAN: Test ini akan FAIL karena TransaksiController masih stub
     * dan belum mengimplementasikan validasi QR expired.
     * Ini adalah expected behavior untuk menunjukkan fitur belum lengkap.
     */
    public function test_cannot_scan_expired_qr()
    {
        // Arrange
        Sanctum::actingAs($this->user);
        
        // Buat booking yang sudah expired
        $transaksi = TransaksiParkir::create([
            'id_user' => $this->user->id_user,
            'id_parkiran' => $this->parkiran->id_parkiran,
            'id_kendaraan' => $this->kendaraan->id_kendaraan,
            'id_slot' => $this->slot->id_slot,
            'waktu_masuk' => now()->subDays(2),
            'status' => 'expired'
        ]);
        
        $qrData = [
            'id_transaksi' => $transaksi->id_transaksi,
            'qr_code' => 'EXPIRED-QR-CODE'
        ];

        // Act
        $response = $this->postJson('/api/transaksi/masuk', $qrData);

        // Assert - EXPECTED TO FAIL
        // Controller stub akan return 201 success, padahal seharusnya 400 error
        $response->assertStatus(400)
                 ->assertJson([
                     'success' => false,
                     'message' => 'QR Code expired or invalid'
                 ]);
    }

    /**
     * Test: Scan QR tidak valid (QR code tidak ditemukan)
     * 
     * Assertion: assertStatus(404) - EXPECTED TO FAIL
     * Tujuan: Memastikan QR yang tidak ada di database ditolak
     * 
     * CATATAN: Test ini akan FAIL karena TransaksiController masih stub
     * dan belum mengimplementasikan validasi QR invalid.
     * Ini adalah expected behavior untuk menunjukkan fitur belum lengkap.
     */
    public function test_cannot_scan_invalid_qr()
    {
        // Arrange
        Sanctum::actingAs($this->user);
        
        $qrData = [
            'id_transaksi' => 99999, // ID tidak ada
            'qr_code' => 'INVALID-QR-CODE'
        ];

        // Act
        $response = $this->postJson('/api/transaksi/masuk', $qrData);

        // Assert - EXPECTED TO FAIL
        // Controller stub akan return 201 success, padahal seharusnya 404 not found
        $response->assertStatus(404)
                 ->assertJson([
                     'success' => false,
                     'message' => 'QR Code not found'
                 ]);
    }

    /**
     * Test: Get active transaksi
     * 
     * Assertion: assertStatus(200), assertJson
     * Tujuan: Memastikan endpoint dapat mengembalikan transaksi aktif
     */
    public function test_can_get_active_transaksi()
    {
        // Arrange
        Sanctum::actingAs($this->user);
        
        // Buat transaksi aktif
        TransaksiParkir::create([
            'id_user' => $this->user->id_user,
            'id_parkiran' => $this->parkiran->id_parkiran,
            'id_kendaraan' => $this->kendaraan->id_kendaraan,
            'id_slot' => $this->slot->id_slot,
            'waktu_masuk' => now(),
            'status' => 'active'
        ]);

        // Act
        $response = $this->getJson('/api/transaksi/active');

        // Assert
        $response->assertStatus(200)
                 ->assertJson([
                     'success' => true
                 ]);
    }

    /**
     * Test: Get all transaksi
     * 
     * Assertion: assertStatus(200), assertJsonStructure
     * Tujuan: Memastikan endpoint dapat mengembalikan semua transaksi user
     */
    public function test_can_get_all_transaksi()
    {
        // Arrange
        Sanctum::actingAs($this->user);

        // Act
        $response = $this->getJson('/api/transaksi');

        // Assert
        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'success',
                     'data'
                 ]);
    }

    /**
     * Test: Unauthorized access
     * 
     * Assertion: assertStatus(401)
     * Tujuan: Memastikan endpoint memerlukan autentikasi
     */
    public function test_transaksi_requires_authentication()
    {
        // Arrange: No authentication

        // Act
        $response = $this->getJson('/api/transaksi');

        // Assert
        $response->assertStatus(401);
    }
}

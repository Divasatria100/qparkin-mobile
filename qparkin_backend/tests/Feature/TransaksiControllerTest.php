<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\TransaksiParkir;
use App\Models\Kendaraan;
use App\Models\Mall;
use App\Models\Parkiran;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;

class TransaksiControllerTest extends TestCase
{
    use RefreshDatabase;

    protected $testUser;
    protected $testMall;
    protected $testKendaraan;
    protected $testParkiran;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Setup data untuk testing
        $this->testUser = User::factory()->create();
        $this->testMall = Mall::factory()->create([
            'kapasitas' => 500
        ]);
        $this->testKendaraan = Kendaraan::factory()->create([
            'id_user' => $this->testUser->id_user
        ]);
        $this->testParkiran = Parkiran::factory()->create([
            'id_mall' => $this->testMall->id_mall,
            'kapasitas' => 100
        ]);
    }

    /**
     * Test Case a: 200 - GET /api/transaksi
     * 
     * Controller: TransaksiController
     * Method: index()
     * Endpoint: GET /api/transaksi
     * Skenario: Mengambil semua histori transaksi user
     * Status HTTP: 200 OK
     * Assertion: assertStatus(200), assertJson(), assertJsonCount()
     * Tujuan: Memastikan endpoint return HTTP 200 dan data transaksi
     */
    public function test_200_dapat_mengambil_semua_transaksi()
    {
        Sanctum::actingAs($this->testUser);

        // Buat 3 kendaraan berbeda untuk 3 transaksi (menghindari trigger transaksi aktif)
        $kendaraan1 = Kendaraan::factory()->create(['id_user' => $this->testUser->id_user]);
        $kendaraan2 = Kendaraan::factory()->create(['id_user' => $this->testUser->id_user]);
        $kendaraan3 = Kendaraan::factory()->create(['id_user' => $this->testUser->id_user]);
        
        // Buat 3 transaksi untuk user (semua sudah selesai)
        TransaksiParkir::factory()->create([
            'id_user' => $this->testUser->id_user,
            'id_kendaraan' => $kendaraan1->id_kendaraan,
            'id_mall' => $this->testMall->id_mall,
            'id_parkiran' => $this->testParkiran->id_parkiran,
            'waktu_keluar' => now()->subHours(1),
            'durasi' => 60,
            'biaya' => 10000
        ]);
        
        TransaksiParkir::factory()->create([
            'id_user' => $this->testUser->id_user,
            'id_kendaraan' => $kendaraan2->id_kendaraan,
            'id_mall' => $this->testMall->id_mall,
            'id_parkiran' => $this->testParkiran->id_parkiran,
            'waktu_keluar' => now()->subHours(2),
            'durasi' => 90,
            'biaya' => 15000
        ]);
        
        TransaksiParkir::factory()->create([
            'id_user' => $this->testUser->id_user,
            'id_kendaraan' => $kendaraan3->id_kendaraan,
            'id_mall' => $this->testMall->id_mall,
            'id_parkiran' => $this->testParkiran->id_parkiran,
            'waktu_keluar' => now()->subHours(3),
            'durasi' => 120,
            'biaya' => 20000
        ]);

        $response = $this->getJson('/api/transaksi');

        // Assertion 1: Status 200 OK
        $response->assertStatus(200);
        
        // Assertion 2: Response berisi success true
        $response->assertJson([
            'success' => true
        ]);
        
        // Assertion 3: Data berisi 3 transaksi
        $response->assertJsonCount(3, 'data');
        
        // Assertion 4: Structure sesuai
        $response->assertJsonStructure([
            'success',
            'data' => [
                '*' => [
                    'id_transaksi',
                    'id_user',
                    'id_kendaraan',
                    'id_mall',
                    'id_parkiran'
                ]
            ],
            'total'
        ]);
    }

    /**
     * Test Case b: 200 - GET /api/transaksi/{id}
     * 
     * Controller: TransaksiController
     * Method: show()
     * Endpoint: GET /api/transaksi/{id}
     * Skenario: Mengambil detail transaksi by ID
     * Status HTTP: 200 OK
     * Assertion: assertOk(), assertJson()
     * Tujuan: Memastikan endpoint return HTTP 200 dan detail transaksi
     */
    public function test_200_dapat_mengambil_detail_transaksi_by_id()
    {
        Sanctum::actingAs($this->testUser);

        $transaksi = TransaksiParkir::factory()->create([
            'id_user' => $this->testUser->id_user,
            'id_kendaraan' => $this->testKendaraan->id_kendaraan,
            'id_mall' => $this->testMall->id_mall,
            'id_parkiran' => $this->testParkiran->id_parkiran,
            'biaya' => 15000
        ]);

        $response = $this->getJson("/api/transaksi/{$transaksi->id_transaksi}");

        // Assertion 1: Status 200 OK
        $response->assertOk();
        
        // Assertion 2: Response berisi data transaksi
        $response->assertJson([
            'success' => true,
            'data' => [
                'id_transaksi' => $transaksi->id_transaksi,
                'biaya' => '15000.00'
            ]
        ]);
    }

    /**
     * Test Case c: 201 - POST /api/transaksi/masuk
     * 
     * Controller: TransaksiController
     * Method: masuk()
     * Endpoint: POST /api/transaksi/masuk
     * Skenario: Membuat transaksi masuk parkir baru
     * Status HTTP: 201 Created
     * Assertion: assertCreated(), assertDatabaseHas()
     * Tujuan: Memastikan endpoint return HTTP 201 Created
     */
    public function test_201_dapat_membuat_transaksi_masuk()
    {
        Sanctum::actingAs($this->testUser);

        $data = [
            'id_kendaraan' => $this->testKendaraan->id_kendaraan,
            'id_mall' => $this->testMall->id_mall,
            'id_parkiran' => $this->testParkiran->id_parkiran,
            'jenis_transaksi' => 'umum'
        ];

        $response = $this->postJson('/api/transaksi/masuk', $data);

        // Assertion 1: Status 201 Created
        $response->assertCreated();
        
        // Assertion 2: Response berisi success message
        $response->assertJson([
            'success' => true,
            'message' => 'Transaksi masuk berhasil dicatat'
        ]);
        
        // Assertion 3: Data tersimpan di database
        $this->assertDatabaseHas('transaksi_parkir', [
            'id_user' => $this->testUser->id_user,
            'id_kendaraan' => $this->testKendaraan->id_kendaraan,
            'jenis_transaksi' => 'umum'
        ]);
    }

    /**
     * Test Case d: 200 - PUT /api/transaksi/{id}
     * 
     * Controller: TransaksiController
     * Method: update()
     * Endpoint: PUT /api/transaksi/{id}
     * Skenario: Update data transaksi
     * Status HTTP: 200 OK
     * Assertion: assertStatus(200), assertDatabaseHas()
     * Tujuan: Memastikan endpoint return HTTP 200 dan data ter-update
     */
    public function test_200_dapat_update_transaksi()
    {
        Sanctum::actingAs($this->testUser);

        $transaksi = TransaksiParkir::factory()->create([
            'id_user' => $this->testUser->id_user,
            'id_kendaraan' => $this->testKendaraan->id_kendaraan,
            'id_mall' => $this->testMall->id_mall,
            'id_parkiran' => $this->testParkiran->id_parkiran,
            'biaya' => 10000
        ]);

        $updateData = [
            'biaya' => 25000,
            'penalty' => 5000,
            'durasi' => 150
        ];

        $response = $this->putJson("/api/transaksi/{$transaksi->id_transaksi}", $updateData);

        // Assertion 1: Status 200 OK
        $response->assertStatus(200);
        
        // Assertion 2: Response berisi success message
        $response->assertJson([
            'success' => true,
            'message' => 'Transaksi berhasil diupdate'
        ]);
        
        // Assertion 3: Data berubah di database
        $this->assertDatabaseHas('transaksi_parkir', [
            'id_transaksi' => $transaksi->id_transaksi,
            'biaya' => 25000,
            'penalty' => 5000,
            'durasi' => 150
        ]);
    }

    /**
     * Test Case e: 200 - DELETE /api/transaksi/{id}
     * 
     * Controller: TransaksiController
     * Method: destroy()
     * Endpoint: DELETE /api/transaksi/{id}
     * Skenario: Hapus transaksi
     * Status HTTP: 200 OK
     * Assertion: assertStatus(200), assertDatabaseMissing()
     * Tujuan: Memastikan endpoint return HTTP 200 dan data terhapus
     */
    public function test_200_dapat_delete_transaksi()
    {
        Sanctum::actingAs($this->testUser);

        $transaksi = TransaksiParkir::factory()->create([
            'id_user' => $this->testUser->id_user,
            'id_kendaraan' => $this->testKendaraan->id_kendaraan,
            'id_mall' => $this->testMall->id_mall,
            'id_parkiran' => $this->testParkiran->id_parkiran
        ]);

        $transaksiId = $transaksi->id_transaksi;

        $response = $this->deleteJson("/api/transaksi/{$transaksiId}");

        // Assertion 1: Status 200 OK
        $response->assertStatus(200);
        
        // Assertion 2: Response berisi success message
        $response->assertJson([
            'success' => true,
            'message' => 'Transaksi berhasil dihapus'
        ]);
        
        // Assertion 3: Data terhapus dari database
        $this->assertDatabaseMissing('transaksi_parkir', [
            'id_transaksi' => $transaksiId
        ]);
    }

    /**
     * Test Case f: 422 - POST /api/transaksi/masuk (Validation Error)
     * 
     * Controller: TransaksiController
     * Method: masuk()
     * Endpoint: POST /api/transaksi/masuk
     * Skenario: Validation error - data tidak lengkap
     * Status HTTP: 422 Unprocessable Entity
     * Assertion: assertStatus(422), assertJsonValidationErrors()
     * Tujuan: Memastikan endpoint return HTTP 422 untuk validation error
     */
    public function test_422_validation_error_jika_data_tidak_lengkap()
    {
        Sanctum::actingAs($this->testUser);

        // Data tidak lengkap (tanpa id_kendaraan)
        $data = [
            'id_mall' => $this->testMall->id_mall,
            'id_parkiran' => $this->testParkiran->id_parkiran,
            'jenis_transaksi' => 'umum'
        ];

        $response = $this->postJson('/api/transaksi/masuk', $data);

        // Assertion 1: Status 422 Unprocessable Entity
        $response->assertStatus(422);
        
        // Assertion 2: Response berisi validation errors
        $response->assertJsonValidationErrors(['id_kendaraan']);
        
        // Assertion 3: Response structure sesuai
        $response->assertJsonStructure([
            'success',
            'message',
            'errors' => [
                'id_kendaraan'
            ]
        ]);
    }

    /**
     * Test Case g: 404 - GET /api/transaksi/{id} (Not Found)
     * 
     * Controller: TransaksiController
     * Method: show()
     * Endpoint: GET /api/transaksi/{id}
     * Skenario: Resource tidak ditemukan
     * Status HTTP: 404 Not Found
     * Assertion: assertNotFound(), assertJson()
     * Tujuan: Memastikan endpoint return HTTP 404 untuk ID tidak ada
     */
    public function test_404_return_not_found_jika_id_tidak_ditemukan()
    {
        Sanctum::actingAs($this->testUser);

        // ID yang tidak ada
        $response = $this->getJson('/api/transaksi/999999');

        // Assertion 1: Status 404 Not Found
        $response->assertNotFound();
        
        // Assertion 2: Response berisi error message
        $response->assertJson([
            'success' => false,
            'message' => 'Transaksi tidak ditemukan'
        ]);
    }

    /**
     * Test Case h: 401 - GET /api/transaksi (Unauthorized)
     * 
     * Controller: TransaksiController
     * Method: index()
     * Endpoint: GET /api/transaksi
     * Skenario: Akses tanpa autentikasi
     * Status HTTP: 401 Unauthorized
     * Assertion: assertStatus(401)
     * Tujuan: Memastikan endpoint return HTTP 401 tanpa autentikasi
     */
    public function test_401_unauthorized_jika_akses_tanpa_autentikasi()
    {
        // Tidak menggunakan Sanctum::actingAs()
        
        $response = $this->getJson('/api/transaksi');

        // Assertion 1: Status 401 Unauthorized
        $response->assertStatus(401);
        
        // Assertion 2: Response berisi error message
        $response->assertJson([
            'message' => 'Unauthenticated.'
        ]);
    }
}

<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Notifikasi;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;

class NotificationControllerTest extends TestCase
{
    use RefreshDatabase;

    protected $testUser;

    protected function setUp(): void
    {
        parent::setUp();
        $this->testUser = User::factory()->create();
    }

    /**
     * Test Case 1: Dapat mengirim notifikasi berhasil
     * 
     * Controller: NotificationController
     * Method: send()
     * Endpoint: POST /api/notifications/send
     * Skenario: Mengirim notifikasi dengan data valid
     * Status HTTP: 201 Created
     * Assertion: assertCreated(), assertDatabaseHas()
     * Tujuan: Memastikan notifikasi dapat dikirim dengan sukses
     */
    public function test_dapat_mengirim_notifikasi_berhasil()
    {
        Sanctum::actingAs($this->testUser);

        $data = [
            'id_user' => $this->testUser->id_user,
            'pesan' => 'Ini adalah pesan test notifikasi'
        ];

        $response = $this->postJson('/api/notifications/send', $data);

        // Assertion 1: Status 201 Created
        $response->assertCreated();
        
        // Assertion 2: Response berisi success message
        $response->assertJson([
            'success' => true,
            'message' => 'Notifikasi berhasil dikirim'
        ]);
        
        // Assertion 3: Data tersimpan di database
        $this->assertDatabaseHas('notifikasi', [
            'id_user' => $this->testUser->id_user,
            'pesan' => 'Ini adalah pesan test notifikasi'
        ]);
    }

    /**
     * Test Case 2: Notifikasi gagal jika data tidak valid
     * 
     * Controller: NotificationController
     * Method: send()
     * Endpoint: POST /api/notifications/send
     * Skenario: Mengirim notifikasi dengan data tidak lengkap
     * Status HTTP: 422 Unprocessable Entity
     * Assertion: assertStatus(422), assertJsonValidationErrors()
     * Tujuan: Memastikan validasi berfungsi dengan benar
     */
    public function test_notifikasi_gagal_jika_data_tidak_valid()
    {
        Sanctum::actingAs($this->testUser);

        // Data tidak lengkap (tanpa pesan)
        $data = [
            'id_user' => $this->testUser->id_user
            // pesan tidak ada
        ];

        $response = $this->postJson('/api/notifications/send', $data);

        // Assertion 1: Status 422 Unprocessable Entity
        $response->assertStatus(422);
        
        // Assertion 2: Response berisi validation errors
        $response->assertJsonValidationErrors(['pesan']);
        
        // Assertion 3: Response structure sesuai
        $response->assertJsonStructure([
            'success',
            'message',
            'errors' => [
                'pesan'
            ]
        ]);
    }

    /**
     * Test Case 3: Dapat mengambil semua notifikasi user
     * 
     * Controller: NotificationController
     * Method: index()
     * Endpoint: GET /api/notifications
     * Skenario: Mengambil semua notifikasi milik user
     * Status HTTP: 200 OK
     * Assertion: assertOk(), assertJsonCount()
     * Tujuan: Memastikan user dapat melihat semua notifikasinya
     */
    public function test_dapat_mengambil_semua_notifikasi_user()
    {
        // Buat user baru untuk test ini
        $newUser = User::factory()->create();
        Sanctum::actingAs($newUser);

        // Buat 5 notifikasi untuk user
        Notifikasi::factory()->count(5)->create([
            'id_user' => $newUser->id_user
        ]);

        $response = $this->getJson('/api/notifications');

        // Assertion 1: Status 200 OK
        $response->assertOk();
        
        // Assertion 2: Response berisi success true
        $response->assertJson([
            'success' => true
        ]);
        
        // Assertion 3: Data berisi 5 notifikasi
        $response->assertJsonCount(5, 'data');
        
        // Assertion 4: Structure sesuai
        $response->assertJsonStructure([
            'success',
            'data' => [
                '*' => [
                    'id_notifikasi',
                    'id_user',
                    'pesan',
                    'status'
                ]
            ],
            'unread_count'
        ]);
    }

    /**
     * Test Case 4: Dapat menandai notifikasi sebagai dibaca
     * 
     * Controller: NotificationController
     * Method: markAsRead()
     * Endpoint: PUT /api/notifications/{id}/read
     * Skenario: Menandai notifikasi sebagai sudah dibaca
     * Status HTTP: 200 OK
     * Assertion: assertOk(), assertDatabaseHas()
     * Tujuan: Memastikan notifikasi dapat ditandai sebagai dibaca
     */
    public function test_dapat_menandai_notifikasi_sebagai_dibaca()
    {
        Sanctum::actingAs($this->testUser);

        // Buat notifikasi belum dibaca
        $notifikasi = Notifikasi::factory()->create([
            'id_user' => $this->testUser->id_user,
            'status' => 'belum'
        ]);

        $response = $this->putJson("/api/notifications/{$notifikasi->id_notifikasi}/read");

        // Assertion 1: Status 200 OK
        $response->assertOk();
        
        // Assertion 2: Response berisi success message
        $response->assertJson([
            'success' => true,
            'message' => 'Notifikasi ditandai sebagai sudah dibaca'
        ]);
        
        // Assertion 3: Status berubah di database
        $this->assertDatabaseHas('notifikasi', [
            'id_notifikasi' => $notifikasi->id_notifikasi,
            'status' => 'terbaca'
        ]);
    }

    /**
     * Test Case 5: Return 404 jika notifikasi tidak ditemukan
     * 
     * Controller: NotificationController
     * Method: markAsRead()
     * Endpoint: PUT /api/notifications/{id}/read
     * Skenario: Menandai notifikasi yang tidak ada
     * Status HTTP: 404 Not Found
     * Assertion: assertNotFound()
     * Tujuan: Memastikan endpoint return 404 untuk ID tidak ada
     */
    public function test_404_jika_notifikasi_tidak_ditemukan()
    {
        Sanctum::actingAs($this->testUser);

        $response = $this->putJson('/api/notifications/999999/read');

        // Assertion 1: Status 404 Not Found
        $response->assertNotFound();
        
        // Assertion 2: Response berisi error message
        $response->assertJson([
            'success' => false,
            'message' => 'Notifikasi tidak ditemukan'
        ]);
    }

    /**
     * Test Case 6: Dapat mengambil jumlah notifikasi belum dibaca
     * 
     * Controller: NotificationController
     * Method: unreadCount()
     * Endpoint: GET /api/notifications/unread-count
     * Skenario: Mengambil jumlah notifikasi yang belum dibaca
     * Status HTTP: 200 OK
     * Assertion: assertOk(), assertJson()
     * Tujuan: Memastikan perhitungan notifikasi belum dibaca akurat
     */
    public function test_dapat_mengambil_jumlah_notifikasi_belum_dibaca()
    {
        // Buat user baru untuk test ini
        $newUser = User::factory()->create();
        Sanctum::actingAs($newUser);

        // Buat 3 notifikasi belum dibaca
        Notifikasi::factory()->count(3)->create([
            'id_user' => $newUser->id_user,
            'status' => 'belum'
        ]);

        // Buat 2 notifikasi sudah dibaca
        Notifikasi::factory()->count(2)->create([
            'id_user' => $newUser->id_user,
            'status' => 'terbaca'
        ]);

        $response = $this->getJson('/api/notifications/unread-count');

        // Assertion 1: Status 200 OK
        $response->assertOk();
        
        // Assertion 2: Response berisi unread_count = 3
        $response->assertJson([
            'success' => true,
            'unread_count' => 3
        ]);
    }
}

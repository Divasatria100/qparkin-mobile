<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\Notifikasi;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

class NotifikasiModelTest extends TestCase
{
    use RefreshDatabase;

    protected $testUser;

    protected function setUp(): void
    {
        parent::setUp();
        $this->testUser = User::factory()->create();
    }

    /**
     * Test Case 1: CREATE - Dapat membuat notifikasi baru
     * 
     * Model yang diuji: Notifikasi
     * Operasi: Create
     * Assertion: assertDatabaseHas() dan assertNotNull()
     * Tujuan: Memastikan notifikasi dapat dibuat dan tersimpan di database
     */
    public function test_dapat_membuat_notifikasi_baru()
    {
        $notifikasiData = [
            'id_user' => $this->testUser->id_user,
            'pesan' => 'Ini adalah pesan test notifikasi',
            'waktu_kirim' => now(),
            'status' => 'belum'
        ];

        $notifikasi = Notifikasi::create($notifikasiData);

        // Assertion 1: Object tidak null
        $this->assertNotNull($notifikasi);
        
        // Assertion 2: Data tersimpan di database
        $this->assertDatabaseHas('notifikasi', [
            'id_user' => $this->testUser->id_user,
            'pesan' => 'Ini adalah pesan test notifikasi',
            'status' => 'belum'
        ]);

        // Assertion 3: ID notifikasi ter-generate
        $this->assertNotNull($notifikasi->id_notifikasi);
    }

    /**
     * Test Case 2: READ - Dapat mengambil notifikasi by ID
     * 
     * Model yang diuji: Notifikasi
     * Operasi: Read
     * Assertion: assertNotNull() dan assertEquals()
     * Tujuan: Memastikan notifikasi dapat diambil dari database
     */
    public function test_dapat_mengambil_notifikasi_by_id()
    {
        // Buat notifikasi
        $notifikasi = Notifikasi::factory()->create([
            'id_user' => $this->testUser->id_user,
            'pesan' => 'Pesan test notifikasi'
        ]);

        // Ambil notifikasi by ID
        $found = Notifikasi::find($notifikasi->id_notifikasi);

        // Assertion 1: Notifikasi ditemukan
        $this->assertNotNull($found);
        
        // Assertion 2: ID sesuai
        $this->assertEquals($notifikasi->id_notifikasi, $found->id_notifikasi);
        
        // Assertion 3: Data sesuai
        $this->assertEquals('Pesan test notifikasi', $found->pesan);
        $this->assertEquals($this->testUser->id_user, $found->id_user);
    }

    /**
     * Test Case 3: UPDATE - Dapat update notifikasi
     * 
     * Model yang diuji: Notifikasi
     * Operasi: Update
     * Assertion: assertDatabaseHas() dan assertEquals()
     * Tujuan: Memastikan notifikasi dapat diupdate
     */
    public function test_dapat_update_notifikasi()
    {
        // Buat notifikasi
        $notifikasi = Notifikasi::factory()->create([
            'id_user' => $this->testUser->id_user,
            'status' => 'belum'
        ]);

        // Update notifikasi
        $notifikasi->update([
            'status' => 'terbaca'
        ]);

        // Assertion 1: Data berubah di database
        $this->assertDatabaseHas('notifikasi', [
            'id_notifikasi' => $notifikasi->id_notifikasi,
            'status' => 'terbaca'
        ]);

        // Assertion 2: Object ter-update
        $updated = Notifikasi::find($notifikasi->id_notifikasi);
        $this->assertEquals('terbaca', $updated->status);
    }

    /**
     * Test Case 4: DELETE - Dapat delete notifikasi
     * 
     * Model yang diuji: Notifikasi
     * Operasi: Delete
     * Assertion: assertDatabaseMissing() dan assertNull()
     * Tujuan: Memastikan notifikasi dapat dihapus dari database
     */
    public function test_dapat_delete_notifikasi()
    {
        // Buat notifikasi
        $notifikasi = Notifikasi::factory()->create([
            'id_user' => $this->testUser->id_user
        ]);

        $notifikasiId = $notifikasi->id_notifikasi;

        // Delete notifikasi
        $notifikasi->delete();

        // Assertion 1: Data terhapus dari database
        $this->assertDatabaseMissing('notifikasi', [
            'id_notifikasi' => $notifikasiId
        ]);

        // Assertion 2: Tidak dapat ditemukan lagi
        $found = Notifikasi::find($notifikasiId);
        $this->assertNull($found);
    }
}

<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\TransaksiParkir;
use App\Models\User;
use App\Models\Kendaraan;
use App\Models\Mall;
use App\Models\Parkiran;
use Illuminate\Foundation\Testing\RefreshDatabase;

class TransaksiParkirModelTest extends TestCase
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
            'kapasitas' => 500 // Kapasitas mall besar
        ]);
        $this->testKendaraan = Kendaraan::factory()->create([
            'id_user' => $this->testUser->id_user
        ]);
        $this->testParkiran = Parkiran::factory()->create([
            'id_mall' => $this->testMall->id_mall,
            'kapasitas' => 100 // Kapasitas parkiran lebih kecil dari mall
        ]);
    }

    /**
     * Test Case 1: CREATE - Dapat membuat transaksi parkir baru
     * 
     * Model yang diuji: TransaksiParkir
     * Operasi: Create
     * Assertion: assertDatabaseHas() dan assertNotNull()
     * Tujuan: Memastikan transaksi dapat dibuat dan tersimpan di database
     */
    public function test_dapat_membuat_transaksi_parkir_baru()
    {
        $transaksiData = [
            'id_user' => $this->testUser->id_user,
            'id_kendaraan' => $this->testKendaraan->id_kendaraan,
            'id_mall' => $this->testMall->id_mall,
            'id_parkiran' => $this->testParkiran->id_parkiran,
            'jenis_transaksi' => 'umum',
            'waktu_masuk' => now(),
            'waktu_keluar' => null,
            'durasi' => null,
            'biaya' => null,
            'penalty' => 0
        ];

        $transaksi = TransaksiParkir::create($transaksiData);

        // Assertion 1: Object tidak null
        $this->assertNotNull($transaksi);
        
        // Assertion 2: Data tersimpan di database
        $this->assertDatabaseHas('transaksi_parkir', [
            'id_user' => $this->testUser->id_user,
            'id_kendaraan' => $this->testKendaraan->id_kendaraan,
            'jenis_transaksi' => 'umum'
        ]);

        // Assertion 3: ID transaksi ter-generate
        $this->assertNotNull($transaksi->id_transaksi);
    }

    /**
     * Test Case 2: READ - Dapat mengambil transaksi by ID
     * 
     * Model yang diuji: TransaksiParkir
     * Operasi: Read
     * Assertion: assertNotNull() dan assertEquals()
     * Tujuan: Memastikan transaksi dapat diambil dari database
     */
    public function test_dapat_mengambil_transaksi_by_id()
    {
        // Buat transaksi
        $transaksi = TransaksiParkir::factory()->create([
            'id_user' => $this->testUser->id_user,
            'id_kendaraan' => $this->testKendaraan->id_kendaraan,
            'id_mall' => $this->testMall->id_mall,
            'id_parkiran' => $this->testParkiran->id_parkiran,
            'biaya' => 15000
        ]);

        // Ambil transaksi by ID
        $found = TransaksiParkir::find($transaksi->id_transaksi);

        // Assertion 1: Transaksi ditemukan
        $this->assertNotNull($found);
        
        // Assertion 2: ID sesuai
        $this->assertEquals($transaksi->id_transaksi, $found->id_transaksi);
        
        // Assertion 3: Data sesuai
        $this->assertEquals(15000, $found->biaya);
        $this->assertEquals($this->testUser->id_user, $found->id_user);
    }

    /**
     * Test Case 3: UPDATE - Dapat update transaksi parkir
     * 
     * Model yang diuji: TransaksiParkir
     * Operasi: Update
     * Assertion: assertDatabaseHas() dan assertEquals()
     * Tujuan: Memastikan transaksi dapat diupdate
     */
    public function test_dapat_update_transaksi_parkir()
    {
        // Buat transaksi yang sudah selesai
        $transaksi = TransaksiParkir::factory()->create([
            'id_user' => $this->testUser->id_user,
            'id_kendaraan' => $this->testKendaraan->id_kendaraan,
            'id_mall' => $this->testMall->id_mall,
            'id_parkiran' => $this->testParkiran->id_parkiran,
            'biaya' => 10000,
            'waktu_keluar' => now()->subHours(1),
            'durasi' => 60
        ]);

        // Update transaksi (hanya update biaya dan penalty)
        $transaksi->update([
            'biaya' => 20000,
            'penalty' => 5000
        ]);

        // Assertion 1: Data berubah di database
        $this->assertDatabaseHas('transaksi_parkir', [
            'id_transaksi' => $transaksi->id_transaksi,
            'biaya' => 20000,
            'penalty' => 5000
        ]);

        // Assertion 2: Object ter-update
        $updated = TransaksiParkir::find($transaksi->id_transaksi);
        $this->assertEquals(20000, $updated->biaya);
        $this->assertEquals(5000, $updated->penalty);
    }

    /**
     * Test Case 4: DELETE - Dapat delete transaksi parkir
     * 
     * Model yang diuji: TransaksiParkir
     * Operasi: Delete
     * Assertion: assertDatabaseMissing() dan assertNull()
     * Tujuan: Memastikan transaksi dapat dihapus dari database
     */
    public function test_dapat_delete_transaksi_parkir()
    {
        // Buat transaksi
        $transaksi = TransaksiParkir::factory()->create([
            'id_user' => $this->testUser->id_user,
            'id_kendaraan' => $this->testKendaraan->id_kendaraan,
            'id_mall' => $this->testMall->id_mall,
            'id_parkiran' => $this->testParkiran->id_parkiran
        ]);

        $transaksiId = $transaksi->id_transaksi;

        // Delete transaksi
        $transaksi->delete();

        // Assertion 1: Data terhapus dari database
        $this->assertDatabaseMissing('transaksi_parkir', [
            'id_transaksi' => $transaksiId
        ]);

        // Assertion 2: Tidak dapat ditemukan lagi
        $found = TransaksiParkir::find($transaksiId);
        $this->assertNull($found);
    }

    /**
     * Test Case 5: Relasi dengan User
     * 
     * Model yang diuji: TransaksiParkir
     * Operasi: Relationship
     * Assertion: assertNotNull() dan assertInstanceOf()
     * Tujuan: Memastikan relasi dengan User berfungsi
     */
    public function test_relasi_dengan_user()
    {
        $transaksi = TransaksiParkir::factory()->create([
            'id_user' => $this->testUser->id_user,
            'id_kendaraan' => $this->testKendaraan->id_kendaraan,
            'id_mall' => $this->testMall->id_mall,
            'id_parkiran' => $this->testParkiran->id_parkiran
        ]);

        // Load relasi
        $transaksi->load('user');

        // Assertion 1: Relasi tidak null
        $this->assertNotNull($transaksi->user);
        
        // Assertion 2: Instance of User
        $this->assertInstanceOf(User::class, $transaksi->user);
        
        // Assertion 3: ID user sesuai
        $this->assertEquals($this->testUser->id_user, $transaksi->user->id_user);
    }
}

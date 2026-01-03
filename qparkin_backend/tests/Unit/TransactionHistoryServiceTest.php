<?php

namespace Tests\Unit;

use Tests\TestCase;
use App\Services\TransactionHistoryService;
use App\Models\TransaksiParkir;
use App\Models\User;
use App\Models\Kendaraan;
use App\Models\Mall;
use App\Models\Parkiran;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Carbon\Carbon;

class TransactionHistoryServiceTest extends TestCase
{
    use RefreshDatabase;

    protected $historyService;
    protected $testUser;

    protected function setUp(): void
    {
        parent::setUp();
        $this->historyService = new TransactionHistoryService();
        
        // Buat user untuk testing
        $this->testUser = User::factory()->create();
    }

    /**
     * Test Case 1: Get history untuk user baru kosong
     * 
     * Method yang diuji: getHistory()
     * Skenario: Mengambil histori untuk user yang belum punya transaksi
     * Assertion: assertCount() - Memastikan hasil kosong
     * Tujuan: Memastikan fungsi return empty collection untuk user baru
     */
    public function test_get_history_untuk_user_baru_kosong()
    {
        $history = $this->historyService->getHistory($this->testUser->id_user);

        $this->assertCount(0, $history);
    }

    /**
     * Test Case 2: Get history dengan user_id kosong
     * 
     * Method yang diuji: getHistory()
     * Skenario: Mengambil histori dengan user_id null
     * Assertion: assertCount() - Memastikan hasil kosong
     * Tujuan: Validasi bahwa user_id wajib diisi
     */
    public function test_get_history_dengan_user_id_kosong()
    {
        $history = $this->historyService->getHistory(null);

        $this->assertCount(0, $history);
    }

    /**
     * Test Case 3: Filter history by date
     * 
     * Method yang diuji: filterByDate()
     * Skenario: Filter histori berdasarkan rentang tanggal
     * Assertion: assertCount() dan assertEquals()
     * Tujuan: Memastikan filter tanggal berfungsi dengan benar
     */
    public function test_filter_history_by_date()
    {
        // Buat transaksi dengan tanggal berbeda
        $mall = Mall::factory()->create();
        $kendaraan1 = Kendaraan::factory()->create(['id_user' => $this->testUser->id_user]);
        $kendaraan2 = Kendaraan::factory()->create(['id_user' => $this->testUser->id_user]);
        $parkiran = Parkiran::factory()->create(['id_mall' => $mall->id_mall]);

        // Transaksi kemarin (sudah selesai)
        TransaksiParkir::factory()->create([
            'id_user' => $this->testUser->id_user,
            'id_kendaraan' => $kendaraan1->id_kendaraan,
            'id_mall' => $mall->id_mall,
            'id_parkiran' => $parkiran->id_parkiran,
            'waktu_masuk' => Carbon::yesterday(),
            'waktu_keluar' => Carbon::yesterday()->addHours(2),
            'durasi' => 120,
            'biaya' => 10000
        ]);

        // Transaksi hari ini (sudah selesai)
        TransaksiParkir::factory()->create([
            'id_user' => $this->testUser->id_user,
            'id_kendaraan' => $kendaraan2->id_kendaraan,
            'id_mall' => $mall->id_mall,
            'id_parkiran' => $parkiran->id_parkiran,
            'waktu_masuk' => Carbon::today(),
            'waktu_keluar' => Carbon::today()->addHours(1),
            'durasi' => 60,
            'biaya' => 5000
        ]);

        // Filter hanya hari ini
        $history = $this->historyService->filterByDate(
            $this->testUser->id_user,
            Carbon::today()->startOfDay(),
            Carbon::today()->endOfDay()
        );

        $this->assertCount(1, $history);
    }

    /**
     * Test Case 4: Calculate total amount
     * 
     * Method yang diuji: calculateTotal()
     * Skenario: Menghitung total biaya dari histori transaksi
     * Assertion: assertEquals() - Memastikan perhitungan benar
     * Tujuan: Memastikan total biaya dihitung dengan akurat
     */
    public function test_calculate_total_amount()
    {
        $mall = Mall::factory()->create();
        $kendaraan = Kendaraan::factory()->create(['id_user' => $this->testUser->id_user]);
        $parkiran = Parkiran::factory()->create(['id_mall' => $mall->id_mall]);

        // Buat 3 transaksi dengan biaya berbeda
        TransaksiParkir::factory()->create([
            'id_user' => $this->testUser->id_user,
            'id_kendaraan' => $kendaraan->id_kendaraan,
            'id_mall' => $mall->id_mall,
            'id_parkiran' => $parkiran->id_parkiran,
            'biaya' => 10000,
            'penalty' => 2000
        ]);

        TransaksiParkir::factory()->create([
            'id_user' => $this->testUser->id_user,
            'id_kendaraan' => $kendaraan->id_kendaraan,
            'id_mall' => $mall->id_mall,
            'id_parkiran' => $parkiran->id_parkiran,
            'biaya' => 15000,
            'penalty' => 0
        ]);

        $total = $this->historyService->calculateTotal($this->testUser->id_user);

        // Total = 10000 + 2000 + 15000 = 27000
        $this->assertEquals(27000, $total);
    }

    /**
     * Test Case 5: Validate history data valid
     * 
     * Method yang diuji: validateHistoryData()
     * Skenario: Validasi data histori yang lengkap
     * Assertion: assertTrue() - Memastikan validasi berhasil
     * Tujuan: Memastikan data valid lolos validasi
     */
    public function test_validate_history_data_valid()
    {
        $validData = [
            'id_user' => 1,
            'id_kendaraan' => 1,
            'id_mall' => 1,
            'id_parkiran' => 1,
            'jenis_transaksi' => 'umum'
        ];

        $result = $this->historyService->validateHistoryData($validData);

        $this->assertTrue($result);
    }

    /**
     * Test Case 6: Validate history data invalid
     * 
     * Method yang diuji: validateHistoryData()
     * Skenario: Validasi data histori yang tidak lengkap
     * Assertion: assertFalse() - Memastikan validasi gagal
     * Tujuan: Memastikan data tidak lengkap ditolak
     */
    public function test_validate_history_data_invalid()
    {
        // Data tidak lengkap (tanpa id_parkiran)
        $invalidData = [
            'id_user' => 1,
            'id_kendaraan' => 1,
            'id_mall' => 1,
            'jenis_transaksi' => 'umum'
        ];

        $result = $this->historyService->validateHistoryData($invalidData);

        $this->assertFalse($result);
    }

    /**
     * Test Case 7: Get statistics
     * 
     * Method yang diuji: getStatistics()
     * Skenario: Mengambil statistik transaksi user
     * Assertion: assertEquals() - Memastikan statistik akurat
     * Tujuan: Memastikan perhitungan statistik benar
     */
    public function test_get_statistics()
    {
        // Buat user baru untuk test ini
        $newUser = User::factory()->create();
        
        $mall = Mall::factory()->create(['kapasitas' => 500]);
        $kendaraan1 = Kendaraan::factory()->create(['id_user' => $newUser->id_user]);
        $kendaraan2 = Kendaraan::factory()->create(['id_user' => $newUser->id_user]);
        $parkiran = Parkiran::factory()->create([
            'id_mall' => $mall->id_mall,
            'kapasitas' => 100
        ]);

        // Buat 2 transaksi dengan kendaraan berbeda
        TransaksiParkir::factory()->create([
            'id_user' => $newUser->id_user,
            'id_kendaraan' => $kendaraan1->id_kendaraan,
            'id_mall' => $mall->id_mall,
            'id_parkiran' => $parkiran->id_parkiran,
            'biaya' => 10000,
            'penalty' => 0,
            'durasi' => 60,
            'waktu_keluar' => now()->subHours(1)
        ]);
        
        TransaksiParkir::factory()->create([
            'id_user' => $newUser->id_user,
            'id_kendaraan' => $kendaraan2->id_kendaraan,
            'id_mall' => $mall->id_mall,
            'id_parkiran' => $parkiran->id_parkiran,
            'biaya' => 10000,
            'penalty' => 0,
            'durasi' => 60,
            'waktu_keluar' => now()->subHours(2)
        ]);

        $stats = $this->historyService->getStatistics($newUser->id_user);

        $this->assertEquals(2, $stats['total_transaksi']);
        $this->assertEquals(20000, $stats['total_biaya']);
        $this->assertEquals(120, $stats['total_durasi']);
    }

    /**
     * Test Case 8: Has active transaction
     * 
     * Method yang diuji: hasActiveTransaction()
     * Skenario: Cek apakah user memiliki transaksi aktif
     * Assertion: assertTrue() dan assertFalse()
     * Tujuan: Memastikan deteksi transaksi aktif akurat
     */
    public function test_has_active_transaction()
    {
        $mall = Mall::factory()->create();
        $kendaraan = Kendaraan::factory()->create(['id_user' => $this->testUser->id_user]);
        $parkiran = Parkiran::factory()->create(['id_mall' => $mall->id_mall]);

        // Awalnya tidak ada transaksi aktif
        $this->assertFalse($this->historyService->hasActiveTransaction($this->testUser->id_user));

        // Buat transaksi aktif (belum keluar)
        TransaksiParkir::factory()->create([
            'id_user' => $this->testUser->id_user,
            'id_kendaraan' => $kendaraan->id_kendaraan,
            'id_mall' => $mall->id_mall,
            'id_parkiran' => $parkiran->id_parkiran,
            'waktu_masuk' => now(),
            'waktu_keluar' => null
        ]);

        // Sekarang ada transaksi aktif
        $this->assertTrue($this->historyService->hasActiveTransaction($this->testUser->id_user));
    }
}

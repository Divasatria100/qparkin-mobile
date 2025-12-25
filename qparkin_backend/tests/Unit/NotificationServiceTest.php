<?php

namespace Tests\Unit;

use Tests\TestCase;
use App\Services\NotificationService;
use App\Models\Notifikasi;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

class NotificationServiceTest extends TestCase
{
    use RefreshDatabase;

    protected $notificationService;
    protected $testUser;

    protected function setUp(): void
    {
        parent::setUp();
        $this->notificationService = new NotificationService();
        
        // Buat user untuk testing
        $this->testUser = User::factory()->create();
        
        // Hapus notifikasi lama jika ada
        Notifikasi::where('id_user', $this->testUser->id_user)->delete();
    }

    /**
     * Test Case 1: Notifikasi gagal jika user_id kosong
     * 
     * Method yang diuji: sendNotification()
     * Skenario: Mengirim notifikasi dengan user_id kosong
     * Assertion: assertFalse() - Memastikan fungsi return false
     * Tujuan: Validasi bahwa user_id wajib diisi
     */
    public function test_notifikasi_gagal_jika_user_id_kosong()
    {
        $result = $this->notificationService->sendNotification(
            null, // user_id kosong
            'Test Pesan'
        );

        $this->assertFalse($result);
    }

    /**
     * Test Case 2: Notifikasi gagal jika pesan kosong
     * 
     * Method yang diuji: sendNotification()
     * Skenario: Mengirim notifikasi dengan pesan kosong
     * Assertion: assertFalse() - Memastikan fungsi return false
     * Tujuan: Validasi bahwa pesan wajib diisi
     */
    public function test_notifikasi_gagal_jika_pesan_kosong()
    {
        $result = $this->notificationService->sendNotification(
            $this->testUser->id_user,
            '' // pesan kosong
        );

        $this->assertFalse($result);
    }

    /**
     * Test Case 3: Notifikasi berhasil dengan data valid
     * 
     * Method yang diuji: sendNotification()
     * Skenario: Mengirim notifikasi dengan semua data valid
     * Assertion: assertTrue() - Memastikan fungsi return true
     * Tujuan: Memastikan notifikasi terkirim ketika data valid
     */
    public function test_notifikasi_berhasil_dengan_data_valid()
    {
        $result = $this->notificationService->sendNotification(
            $this->testUser->id_user,
            'Test Pesan Notifikasi'
        );

        $this->assertTrue($result);
        
        // Verifikasi data tersimpan di database
        $this->assertDatabaseHas('notifikasi', [
            'id_user' => $this->testUser->id_user,
            'pesan' => 'Test Pesan Notifikasi',
            'status' => 'belum'
        ]);
    }

    /**
     * Test Case 4: Notifikasi gagal jika user tidak ditemukan
     * 
     * Method yang diuji: sendNotification()
     * Skenario: Mengirim notifikasi ke user yang tidak ada
     * Assertion: assertFalse() - Memastikan fungsi return false
     * Tujuan: Validasi bahwa user harus ada di database
     */
    public function test_notifikasi_gagal_jika_user_tidak_ditemukan()
    {
        $result = $this->notificationService->sendNotification(
            999999, // user_id tidak ada
            'Test Pesan'
        );

        $this->assertFalse($result);
    }

    /**
     * Test Case 5: Kirim bulk notification
     * 
     * Method yang diuji: sendBulkNotification()
     * Skenario: Mengirim notifikasi ke multiple users
     * Assertion: assertEquals() dan assertCount() - Memastikan jumlah notifikasi sesuai
     * Tujuan: Memastikan bulk notification berfungsi dengan benar
     */
    public function test_kirim_bulk_notification()
    {
        // Buat 3 user tambahan
        $users = User::factory()->count(3)->create();
        $userIds = $users->pluck('id_user')->toArray();

        $results = $this->notificationService->sendBulkNotification(
            $userIds,
            'Pesan Bulk untuk semua user'
        );

        $this->assertEquals(3, $results['success']);
        $this->assertEquals(0, $results['failed']);
        $this->assertEquals(3, $results['total']);
        
        // Verifikasi semua notifikasi tersimpan
        $this->assertCount(3, Notifikasi::where('pesan', 'Pesan Bulk untuk semua user')->get());
    }

    /**
     * Test Case 6: Hitung notifikasi yang belum dibaca
     * 
     * Method yang diuji: countUnreadNotifications()
     * Skenario: Menghitung jumlah notifikasi belum dibaca
     * Assertion: assertEquals() - Memastikan jumlah sesuai
     * Tujuan: Memastikan perhitungan notifikasi belum dibaca akurat
     */
    public function test_hitung_notifikasi_belum_dibaca()
    {
        // Buat user baru khusus untuk test ini
        $newUser = User::factory()->create();
        
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

        $count = $this->notificationService->countUnreadNotifications($newUser->id_user);

        $this->assertEquals(3, $count);
    }

    /**
     * Test Case 7: Validasi format data notifikasi valid
     * 
     * Method yang diuji: validateNotificationData()
     * Skenario: Validasi data notifikasi lengkap
     * Assertion: assertTrue() - Memastikan data valid lolos validasi
     * Tujuan: Memastikan validasi data berfungsi dengan benar
     */
    public function test_validasi_format_data_notifikasi_valid()
    {
        // Data valid
        $validData = [
            'id_user' => 1,
            'pesan' => 'Test Pesan'
        ];
        $this->assertTrue($this->notificationService->validateNotificationData($validData));
    }

    /**
     * Test Case 8: Validasi format data notifikasi invalid
     * 
     * Method yang diuji: validateNotificationData()
     * Skenario: Validasi data notifikasi tidak lengkap
     * Assertion: assertFalse() - Memastikan data invalid ditolak
     * Tujuan: Memastikan validasi menolak data yang tidak lengkap
     */
    public function test_validasi_format_data_notifikasi_invalid()
    {
        // Data tidak valid (pesan kosong)
        $invalidData = [
            'id_user' => 1
        ];
        $this->assertFalse($this->notificationService->validateNotificationData($invalidData));
    }
}

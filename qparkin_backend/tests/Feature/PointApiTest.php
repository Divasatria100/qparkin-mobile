<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\RiwayatPoin;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Carbon\Carbon;

class PointApiTest extends TestCase
{
    use RefreshDatabase;

    protected function createTestUser($saldoPoin = 1000)
    {
        return User::create([
            'name' => 'Test User',
            'nomor_hp' => '081234567890',
            'email' => 'test@example.com',
            'password' => bcrypt('123456'),
            'role' => 'customer',
            'status' => 'aktif',
            'saldo_poin' => $saldoPoin
        ]);
    }

    protected function createPointHistory($userId, $poin, $perubahan, $keterangan = 'Test')
    {
        return RiwayatPoin::create([
            'id_user' => $userId,
            'poin' => $poin,
            'perubahan' => $perubahan,
            'keterangan' => $keterangan,
            'waktu' => Carbon::now()
        ]);
    }

    public function test_get_balance_returns_user_point_balance()
    {
        $user = $this->createTestUser(1500);
        Sanctum::actingAs($user);

        $response = $this->getJson('/api/points/balance');

        $response->assertStatus(200)
                 ->assertJson([
                     'success' => true,
                     'balance' => 1500
                 ]);
    }

    public function test_get_balance_requires_authentication()
    {
        $response = $this->getJson('/api/points/balance');

        $response->assertStatus(401);
    }

    public function test_get_history_returns_paginated_point_history()
    {
        $user = $this->createTestUser();
        Sanctum::actingAs($user);

        // Create some history entries
        $this->createPointHistory($user->id_user, 100, 'tambah', 'Reward parkir');
        $this->createPointHistory($user->id_user, 50, 'kurang', 'Penggunaan poin');

        $response = $this->getJson('/api/points/history');

        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'success',
                     'data' => [
                         '*' => ['id_poin', 'id_user', 'poin', 'perubahan', 'keterangan', 'waktu']
                     ],
                     'meta' => ['current_page', 'per_page', 'total', 'last_page']
                 ]);
    }

    public function test_get_history_filters_by_type()
    {
        $user = $this->createTestUser();
        Sanctum::actingAs($user);

        $this->createPointHistory($user->id_user, 100, 'tambah');
        $this->createPointHistory($user->id_user, 50, 'kurang');

        $response = $this->getJson('/api/points/history?type=tambah');

        $response->assertStatus(200);
        $data = $response->json('data');
        
        $this->assertCount(1, $data);
        $this->assertEquals('tambah', $data[0]['perubahan']);
    }

    public function test_get_statistics_returns_aggregated_data()
    {
        $user = $this->createTestUser();
        Sanctum::actingAs($user);

        // Create history entries
        $this->createPointHistory($user->id_user, 100, 'tambah');
        $this->createPointHistory($user->id_user, 200, 'tambah');
        $this->createPointHistory($user->id_user, 50, 'kurang');

        $response = $this->getJson('/api/points/statistics');

        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'success',
                     'statistics' => [
                         'total_earned',
                         'total_used',
                         'this_month_earned',
                         'this_month_used'
                     ]
                 ]);

        $stats = $response->json('statistics');
        $this->assertEquals(300, $stats['total_earned']);
        $this->assertEquals(50, $stats['total_used']);
    }

    public function test_use_points_deducts_from_balance()
    {
        $user = $this->createTestUser(1000);
        Sanctum::actingAs($user);

        $response = $this->postJson('/api/points/use', [
            'amount' => 200,
            'description' => 'Pembayaran parkir'
        ]);

        $response->assertStatus(200)
                 ->assertJson([
                     'success' => true,
                     'new_balance' => 800,
                     'points_used' => 200
                 ]);

        // Verify database was updated
        $this->assertDatabaseHas('user', [
            'id_user' => $user->id_user,
            'saldo_poin' => 800
        ]);

        // Verify history was created
        $this->assertDatabaseHas('riwayat_poin', [
            'id_user' => $user->id_user,
            'poin' => 200,
            'perubahan' => 'kurang'
        ]);
    }

    public function test_use_points_fails_with_insufficient_balance()
    {
        $user = $this->createTestUser(100);
        Sanctum::actingAs($user);

        $response = $this->postJson('/api/points/use', [
            'amount' => 200
        ]);

        $response->assertStatus(400)
                 ->assertJson([
                     'success' => false,
                     'message' => 'Saldo poin tidak mencukupi'
                 ]);

        // Verify balance was not changed
        $this->assertDatabaseHas('user', [
            'id_user' => $user->id_user,
            'saldo_poin' => 100
        ]);
    }

    public function test_use_points_validates_required_fields()
    {
        $user = $this->createTestUser();
        Sanctum::actingAs($user);

        $response = $this->postJson('/api/points/use', []);

        $response->assertStatus(422)
                 ->assertJsonValidationErrors(['amount']);
    }

    public function test_use_points_requires_authentication()
    {
        $response = $this->postJson('/api/points/use', [
            'amount' => 100
        ]);

        $response->assertStatus(401);
    }
}

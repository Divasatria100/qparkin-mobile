<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Poin;
use Illuminate\Foundation\Testing\RefreshDatabase;

/**
 * Feature Test: Point API & Database
 * Menguji endpoint API dan database operations
 */
class PointFeatureTest extends TestCase
{
    use RefreshDatabase;
    
    /** @test */
    public function it_can_get_user_point_balance()
    {
        // Arrange
        $user = User::factory()->create();
        Poin::create([
            'id_user' => $user->id_user,
            'poin' => 20,
            'perubahan' => 'tambah',
            'keterangan' => 'Reward parkir',
        ]);
        
        // Act
        $response = $this->actingAs($user)->getJson('/api/poin/balance');
        
        // Assert: HTTP Assertions
        $response->assertOk(); // 200
        $response->assertJson(['balance' => 20]);
    }
    
    /** @test */
    public function it_can_get_point_history()
    {
        // Arrange
        $user = User::factory()->create();
        Poin::factory()->count(3)->create(['id_user' => $user->id_user]);
        
        // Act
        $response = $this->actingAs($user)->getJson('/api/poin/history');
        
        // Assert
        $response->assertStatus(200);
        $response->assertJsonCount(3, 'data');
    }
    
    /** @test */
    public function it_can_create_point_transaction()
    {
        // Arrange
        $user = User::factory()->create();
        $data = [
            'poin' => 20,
            'perubahan' => 'tambah',
            'keterangan' => 'Reward parkir',
        ];
        
        // Act
        $response = $this->actingAs($user)->postJson('/api/poin', $data);
        
        // Assert
        $response->assertCreated(); // 201
        
        // Database Assertions
        $this->assertDatabaseHas('poin', [
            'id_user' => $user->id_user,
            'poin' => 20,
            'perubahan' => 'tambah',
        ]);
        
        $this->assertDatabaseCount('poin', 1);
    }
    
    /** @test */
    public function it_validates_required_fields()
    {
        // Arrange
        $user = User::factory()->create();
        
        // Act
        $response = $this->actingAs($user)->postJson('/api/poin', []);
        
        // Assert
        $response->assertStatus(422); // Validation Error
        $response->assertJsonValidationErrors(['poin', 'perubahan']);
    }
    
    /** @test */
    public function it_returns_404_for_nonexistent_point()
    {
        // Arrange
        $user = User::factory()->create();
        
        // Act
        $response = $this->actingAs($user)->getJson('/api/poin/999');
        
        // Assert
        $response->assertNotFound(); // 404
    }
    
    /** @test */
    public function it_can_use_points_for_discount()
    {
        // Arrange
        $user = User::factory()->create();
        Poin::create([
            'id_user' => $user->id_user,
            'poin' => 100,
            'perubahan' => 'tambah',
            'keterangan' => 'Initial balance',
        ]);
        
        // Act
        $response = $this->actingAs($user)->postJson('/api/poin/use', [
            'amount' => 50,
            'transaction_id' => 1,
        ]);
        
        // Assert
        $response->assertOk();
        
        // Database: Check deduction record
        $this->assertDatabaseHas('poin', [
            'id_user' => $user->id_user,
            'poin' => 50,
            'perubahan' => 'kurang',
        ]);
    }
    
    /** @test */
    public function it_prevents_using_more_points_than_available()
    {
        // Arrange
        $user = User::factory()->create();
        Poin::create([
            'id_user' => $user->id_user,
            'poin' => 30,
            'perubahan' => 'tambah',
            'keterangan' => 'Balance',
        ]);
        
        // Act
        $response = $this->actingAs($user)->postJson('/api/poin/use', [
            'amount' => 50,
            'transaction_id' => 1,
        ]);
        
        // Assert
        $response->assertStatus(400); // Bad Request
        $response->assertJson(['error' => 'Insufficient points']);
    }
}

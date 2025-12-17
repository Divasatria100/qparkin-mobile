<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Mall;
use App\Models\Parkiran;
use App\Models\ParkingFloor;
use App\Models\ParkingSlot;
use App\Models\SlotReservation;
use App\Models\Kendaraan;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;

class SlotReservationApiTest extends TestCase
{
    use RefreshDatabase;

    protected $user;
    protected $mall;
    protected $parkiran;
    protected $floor;
    protected $kendaraan;

    protected function setUp(): void
    {
        parent::setUp();

        // Create test user
        $this->user = User::factory()->create();

        // Create test mall
        $this->mall = Mall::create([
            'nama_mall' => 'Test Mall',
            'alamat' => 'Test Address',
            'latitude' => -6.2088,
            'longitude' => 106.8456,
            'status' => 'active'
        ]);

        // Create test parkiran
        $this->parkiran = Parkiran::create([
            'id_mall' => $this->mall->id_mall,
            'jenis_kendaraan' => 'Roda Empat',
            'kapasitas' => 50,
            'status' => 'active'
        ]);

        // Create test floor
        $this->floor = ParkingFloor::create([
            'id_parkiran' => $this->parkiran->id_parkiran,
            'floor_name' => 'Lantai 1',
            'floor_number' => 1,
            'total_slots' => 10,
            'available_slots' => 5,
            'status' => 'active'
        ]);

        // Create test slots
        for ($i = 1; $i <= 5; $i++) {
            ParkingSlot::create([
                'id_floor' => $this->floor->id_floor,
                'slot_code' => "A0{$i}",
                'jenis_kendaraan' => 'Roda Empat',
                'status' => 'available',
                'position_x' => $i,
                'position_y' => 1
            ]);
        }

        // Create test vehicle
        $this->kendaraan = Kendaraan::create([
            'id_user' => $this->user->id_user,
            'jenis_kendaraan' => 'Roda Empat',
            'merk_kendaraan' => 'Toyota',
            'model_kendaraan' => 'Avanza',
            'plat_nomor' => 'B1234XYZ',
            'warna_kendaraan' => 'Hitam'
        ]);
    }

    /** @test */
    public function it_can_get_parking_floors_for_a_mall()
    {
        Sanctum::actingAs($this->user);

        $response = $this->getJson("/api/parking/floors/{$this->mall->id_mall}");

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    '*' => [
                        'id_floor',
                        'id_mall',
                        'floor_number',
                        'floor_name',
                        'total_slots',
                        'available_slots',
                        'occupied_slots',
                        'reserved_slots',
                        'last_updated'
                    ]
                ]
            ]);

        $this->assertTrue($response->json('success'));
        $this->assertCount(1, $response->json('data'));
    }

    /** @test */
    public function it_can_get_slots_for_visualization()
    {
        Sanctum::actingAs($this->user);

        $response = $this->getJson("/api/parking/slots/{$this->floor->id_floor}/visualization");

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    '*' => [
                        'id_slot',
                        'id_floor',
                        'slot_code',
                        'status',
                        'slot_type',
                        'position_x',
                        'position_y',
                        'last_updated'
                    ]
                ]
            ]);

        $this->assertTrue($response->json('success'));
        $this->assertCount(5, $response->json('data'));
    }

    /** @test */
    public function it_can_filter_slots_by_vehicle_type()
    {
        Sanctum::actingAs($this->user);

        $response = $this->getJson("/api/parking/slots/{$this->floor->id_floor}/visualization?vehicle_type=Roda%20Empat");

        $response->assertStatus(200);
        $this->assertTrue($response->json('success'));
        $this->assertCount(5, $response->json('data'));
    }

    /** @test */
    public function it_can_reserve_a_random_slot()
    {
        Sanctum::actingAs($this->user);

        $response = $this->postJson('/api/parking/slots/reserve-random', [
            'id_floor' => $this->floor->id_floor,
            'id_user' => $this->user->id_user,
            'vehicle_type' => 'Roda Empat',
            'duration_minutes' => 5
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'success',
                'data' => [
                    'reservation_id',
                    'slot_id',
                    'slot_code',
                    'floor_name',
                    'floor_number',
                    'slot_type',
                    'reserved_at',
                    'expires_at'
                ],
                'message'
            ]);

        $this->assertTrue($response->json('success'));
        $this->assertNotNull($response->json('data.reservation_id'));
        $this->assertNotNull($response->json('data.slot_code'));

        // Verify slot is marked as reserved
        $slotId = $response->json('data.slot_id');
        $slot = ParkingSlot::find($slotId);
        $this->assertEquals('reserved', $slot->status);

        // Verify reservation exists in database
        $this->assertDatabaseHas('slot_reservations', [
            'id_slot' => $slotId,
            'id_user' => $this->user->id_user,
            'status' => 'active'
        ]);
    }

    /** @test */
    public function it_returns_error_when_no_slots_available()
    {
        Sanctum::actingAs($this->user);

        // Mark all slots as occupied
        ParkingSlot::where('id_floor', $this->floor->id_floor)->update(['status' => 'occupied']);

        $response = $this->postJson('/api/parking/slots/reserve-random', [
            'id_floor' => $this->floor->id_floor,
            'id_user' => $this->user->id_user,
            'vehicle_type' => 'Roda Empat',
            'duration_minutes' => 5
        ]);

        $response->assertStatus(404)
            ->assertJson([
                'success' => false,
                'message' => 'NO_SLOTS_AVAILABLE'
            ]);
    }

    /** @test */
    public function it_can_create_booking_with_slot_reservation()
    {
        Sanctum::actingAs($this->user);

        // First, reserve a slot
        $reservationResponse = $this->postJson('/api/parking/slots/reserve-random', [
            'id_floor' => $this->floor->id_floor,
            'id_user' => $this->user->id_user,
            'vehicle_type' => 'Roda Empat',
            'duration_minutes' => 5
        ]);

        $reservationId = $reservationResponse->json('data.reservation_id');
        $slotId = $reservationResponse->json('data.slot_id');

        // Now create a booking with the reservation
        $bookingResponse = $this->postJson('/api/booking', [
            'id_parkiran' => $this->parkiran->id_parkiran,
            'id_kendaraan' => $this->kendaraan->id_kendaraan,
            'waktu_mulai' => now()->addHours(1)->toDateTimeString(),
            'durasi_booking' => 2,
            'id_slot' => $slotId,
            'reservation_id' => $reservationId
        ]);

        $bookingResponse->assertStatus(201)
            ->assertJsonStructure([
                'success',
                'message',
                'data'
            ]);

        $this->assertTrue($bookingResponse->json('success'));

        // Verify booking has slot and reservation
        $this->assertDatabaseHas('booking', [
            'id_slot' => $slotId,
            'reservation_id' => $reservationId,
            'status' => 'confirmed'
        ]);

        // Verify reservation is confirmed
        $this->assertDatabaseHas('slot_reservations', [
            'reservation_id' => $reservationId,
            'status' => 'confirmed'
        ]);

        // Verify slot is marked as occupied
        $slot = ParkingSlot::find($slotId);
        $this->assertEquals('occupied', $slot->status);
    }

    /** @test */
    public function it_can_create_booking_without_slot_reservation_using_auto_assignment()
    {
        Sanctum::actingAs($this->user);

        // Create booking without slot reservation (backward compatibility)
        $bookingResponse = $this->postJson('/api/booking', [
            'id_parkiran' => $this->parkiran->id_parkiran,
            'id_kendaraan' => $this->kendaraan->id_kendaraan,
            'waktu_mulai' => now()->addHours(1)->toDateTimeString(),
            'durasi_booking' => 2
        ]);

        $bookingResponse->assertStatus(201)
            ->assertJsonStructure([
                'success',
                'message',
                'data'
            ]);

        $this->assertTrue($bookingResponse->json('success'));

        // Verify booking was created with auto-assigned slot
        $this->assertDatabaseHas('booking', [
            'status' => 'confirmed'
        ]);

        // Verify a slot was assigned
        $booking = \App\Models\Booking::latest()->first();
        $this->assertNotNull($booking->id_slot);
    }

    /** @test */
    public function it_rejects_expired_reservation()
    {
        Sanctum::actingAs($this->user);

        // Create an expired reservation
        $slot = ParkingSlot::where('id_floor', $this->floor->id_floor)->first();
        $slot->markAsReserved();

        $reservation = SlotReservation::create([
            'id_slot' => $slot->id_slot,
            'id_user' => $this->user->id_user,
            'id_floor' => $this->floor->id_floor,
            'status' => 'active',
            'reserved_at' => now()->subMinutes(10),
            'expires_at' => now()->subMinutes(5) // Expired 5 minutes ago
        ]);

        // Try to create booking with expired reservation
        $bookingResponse = $this->postJson('/api/booking', [
            'id_parkiran' => $this->parkiran->id_parkiran,
            'id_kendaraan' => $this->kendaraan->id_kendaraan,
            'waktu_mulai' => now()->addHours(1)->toDateTimeString(),
            'durasi_booking' => 2,
            'id_slot' => $slot->id_slot,
            'reservation_id' => $reservation->reservation_id
        ]);

        $bookingResponse->assertStatus(400)
            ->assertJson([
                'success' => false,
                'message' => 'RESERVATION_EXPIRED'
            ]);
    }

    /** @test */
    public function it_validates_required_fields_for_slot_reservation()
    {
        Sanctum::actingAs($this->user);

        $response = $this->postJson('/api/parking/slots/reserve-random', []);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['id_floor', 'id_user', 'vehicle_type']);
    }

    /** @test */
    public function it_validates_required_fields_for_booking()
    {
        Sanctum::actingAs($this->user);

        $response = $this->postJson('/api/booking', []);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['id_parkiran', 'id_kendaraan', 'waktu_mulai', 'durasi_booking']);
    }
}

# Payment Endpoint Implementation Guide

## Overview
Panduan implementasi endpoint untuk update status pembayaran booking di backend Laravel.

## Endpoint Specification

### Update Payment Status

**Method**: `PUT`  
**URL**: `/api/bookings/{id}/payment`  
**Auth**: Required (Bearer Token)

#### Request

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
Accept: application/json
```

**Path Parameters:**
- `id` (string, required): ID booking yang akan diupdate

**Body:**
```json
{
  "payment_method": "gopay",
  "payment_status": "PAID"
}
```

**Validation Rules:**
- `payment_method`: required, string, max:50
- `payment_status`: required, in:PAID,PENDING,FAILED

#### Response

**Success (200 OK):**
```json
{
  "success": true,
  "message": "Payment status updated successfully",
  "data": {
    "id_booking": "BK001",
    "id_transaksi": "TRX001",
    "payment_status": "PAID",
    "payment_method": "gopay",
    "paid_at": "2024-01-15T10:30:00Z",
    "status": "aktif"
  }
}
```

**Error (400 Bad Request):**
```json
{
  "success": false,
  "message": "Validation error",
  "errors": {
    "payment_status": ["The payment status field is required."]
  }
}
```

**Error (404 Not Found):**
```json
{
  "success": false,
  "message": "Booking not found"
}
```

**Error (403 Forbidden):**
```json
{
  "success": false,
  "message": "You are not authorized to update this booking"
}
```

## Implementation

### 1. Database Migration

Create migration to add payment columns:

```bash
php artisan make:migration add_payment_columns_to_bookings_table
```

**Migration File:**
```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->string('payment_status', 20)->default('PENDING')->after('status');
            $table->string('payment_method', 50)->nullable()->after('payment_status');
            $table->timestamp('paid_at')->nullable()->after('payment_method');
        });
    }

    public function down(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->dropColumn(['payment_status', 'payment_method', 'paid_at']);
        });
    }
};
```

Run migration:
```bash
php artisan migrate
```

### 2. Update Booking Model

**File**: `app/Models/Booking.php`

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Booking extends Model
{
    protected $table = 'bookings';
    protected $primaryKey = 'id_booking';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id_booking',
        'id_transaksi',
        'id_mall',
        'id_parkiran',
        'id_kendaraan',
        'id_slot',
        'qr_code',
        'waktu_mulai',
        'waktu_selesai',
        'durasi_booking',
        'status',
        'payment_status',  // NEW
        'payment_method',  // NEW
        'paid_at',         // NEW
        'biaya_estimasi',
        'diboking_pada',
    ];

    protected $casts = [
        'waktu_mulai' => 'datetime',
        'waktu_selesai' => 'datetime',
        'paid_at' => 'datetime',  // NEW
        'diboking_pada' => 'datetime',
        'biaya_estimasi' => 'decimal:2',
    ];

    // Payment status constants
    const PAYMENT_PENDING = 'PENDING';
    const PAYMENT_PAID = 'PAID';
    const PAYMENT_FAILED = 'FAILED';

    // Payment method constants
    const METHOD_GOPAY = 'gopay';
    const METHOD_OVO = 'ovo';
    const METHOD_DANA = 'dana';
    const METHOD_BCA = 'bca';
    const METHOD_MANDIRI = 'mandiri';
    const METHOD_BNI = 'bni';

    /**
     * Check if booking is paid
     */
    public function isPaid(): bool
    {
        return $this->payment_status === self::PAYMENT_PAID;
    }

    /**
     * Mark booking as paid
     */
    public function markAsPaid(string $paymentMethod): void
    {
        $this->update([
            'payment_status' => self::PAYMENT_PAID,
            'payment_method' => $paymentMethod,
            'paid_at' => now(),
        ]);
    }
}
```

### 3. Create Request Validation

**File**: `app/Http/Requests/UpdatePaymentStatusRequest.php`

```bash
php artisan make:request UpdatePaymentStatusRequest
```

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdatePaymentStatusRequest extends FormRequest
{
    public function authorize(): bool
    {
        // Check if user owns this booking
        $booking = $this->route('id');
        return $this->user()->id === $booking->id_user;
    }

    public function rules(): array
    {
        return [
            'payment_method' => 'required|string|max:50|in:gopay,ovo,dana,bca,mandiri,bni',
            'payment_status' => 'required|string|in:PAID,PENDING,FAILED',
        ];
    }

    public function messages(): array
    {
        return [
            'payment_method.required' => 'Metode pembayaran harus diisi',
            'payment_method.in' => 'Metode pembayaran tidak valid',
            'payment_status.required' => 'Status pembayaran harus diisi',
            'payment_status.in' => 'Status pembayaran tidak valid',
        ];
    }
}
```

### 4. Update Controller

**File**: `app/Http/Controllers/Api/BookingController.php`

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\UpdatePaymentStatusRequest;
use App\Models\Booking;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class BookingController extends Controller
{
    /**
     * Update payment status for a booking
     *
     * @param UpdatePaymentStatusRequest $request
     * @param string $id
     * @return JsonResponse
     */
    public function updatePaymentStatus(UpdatePaymentStatusRequest $request, string $id): JsonResponse
    {
        try {
            DB::beginTransaction();

            // Find booking
            $booking = Booking::where('id_booking', $id)->firstOrFail();

            // Check authorization
            if ($booking->id_user !== auth()->id()) {
                return response()->json([
                    'success' => false,
                    'message' => 'You are not authorized to update this booking',
                ], 403);
            }

            // Check if booking is already paid
            if ($booking->isPaid()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Booking has already been paid',
                ], 400);
            }

            // Update payment status
            $booking->update([
                'payment_status' => $request->payment_status,
                'payment_method' => $request->payment_method,
                'paid_at' => $request->payment_status === 'PAID' ? now() : null,
            ]);

            // If payment is successful, you might want to:
            // 1. Send notification to user
            // 2. Generate invoice
            // 3. Update slot status
            // 4. Log payment transaction

            DB::commit();

            Log::info('Payment status updated', [
                'booking_id' => $booking->id_booking,
                'payment_status' => $request->payment_status,
                'payment_method' => $request->payment_method,
                'user_id' => auth()->id(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Payment status updated successfully',
                'data' => [
                    'id_booking' => $booking->id_booking,
                    'id_transaksi' => $booking->id_transaksi,
                    'payment_status' => $booking->payment_status,
                    'payment_method' => $booking->payment_method,
                    'paid_at' => $booking->paid_at?->toIso8601String(),
                    'status' => $booking->status,
                ],
            ], 200);

        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            DB::rollBack();
            
            return response()->json([
                'success' => false,
                'message' => 'Booking not found',
            ], 404);

        } catch (\Exception $e) {
            DB::rollBack();
            
            Log::error('Error updating payment status', [
                'booking_id' => $id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to update payment status',
                'error' => config('app.debug') ? $e->getMessage() : null,
            ], 500);
        }
    }
}
```

### 5. Add Route

**File**: `routes/api.php`

```php
<?php

use App\Http\Controllers\Api\BookingController;
use Illuminate\Support\Facades\Route;

Route::middleware('auth:api')->group(function () {
    // Existing booking routes...
    Route::post('/bookings', [BookingController::class, 'store']);
    Route::get('/bookings/active', [BookingController::class, 'getActiveBooking']);
    
    // NEW: Payment status update route
    Route::put('/bookings/{id}/payment', [BookingController::class, 'updatePaymentStatus']);
});
```

## Testing

### 1. Manual Testing with Postman/cURL

**Request:**
```bash
curl -X PUT http://localhost:8000/api/bookings/BK001/payment \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "payment_method": "gopay",
    "payment_status": "PAID"
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Payment status updated successfully",
  "data": {
    "id_booking": "BK001",
    "id_transaksi": "TRX001",
    "payment_status": "PAID",
    "payment_method": "gopay",
    "paid_at": "2024-01-15T10:30:00Z",
    "status": "aktif"
  }
}
```

### 2. Automated Testing

**File**: `tests/Feature/PaymentStatusUpdateTest.php`

```bash
php artisan make:test PaymentStatusUpdateTest
```

```php
<?php

namespace Tests\Feature;

use App\Models\Booking;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PaymentStatusUpdateTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_update_payment_status_for_own_booking()
    {
        $user = User::factory()->create();
        $booking = Booking::factory()->create([
            'id_user' => $user->id,
            'payment_status' => 'PENDING',
        ]);

        $response = $this->actingAs($user, 'api')
            ->putJson("/api/bookings/{$booking->id_booking}/payment", [
                'payment_method' => 'gopay',
                'payment_status' => 'PAID',
            ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Payment status updated successfully',
            ]);

        $this->assertDatabaseHas('bookings', [
            'id_booking' => $booking->id_booking,
            'payment_status' => 'PAID',
            'payment_method' => 'gopay',
        ]);
    }

    public function test_user_cannot_update_payment_status_for_other_users_booking()
    {
        $user1 = User::factory()->create();
        $user2 = User::factory()->create();
        
        $booking = Booking::factory()->create([
            'id_user' => $user1->id,
        ]);

        $response = $this->actingAs($user2, 'api')
            ->putJson("/api/bookings/{$booking->id_booking}/payment", [
                'payment_method' => 'gopay',
                'payment_status' => 'PAID',
            ]);

        $response->assertStatus(403);
    }

    public function test_cannot_update_already_paid_booking()
    {
        $user = User::factory()->create();
        $booking = Booking::factory()->create([
            'id_user' => $user->id,
            'payment_status' => 'PAID',
            'paid_at' => now(),
        ]);

        $response = $this->actingAs($user, 'api')
            ->putJson("/api/bookings/{$booking->id_booking}/payment", [
                'payment_method' => 'ovo',
                'payment_status' => 'PAID',
            ]);

        $response->assertStatus(400)
            ->assertJson([
                'success' => false,
                'message' => 'Booking has already been paid',
            ]);
    }
}
```

Run tests:
```bash
php artisan test --filter PaymentStatusUpdateTest
```

## Security Considerations

1. **Authorization**: Ensure user can only update their own bookings
2. **Validation**: Validate payment method and status values
3. **Idempotency**: Prevent double payment updates
4. **Logging**: Log all payment status changes for audit trail
5. **Transaction**: Use database transactions for data consistency

## Deployment Checklist

- [ ] Run migration: `php artisan migrate`
- [ ] Update Booking model with new fields
- [ ] Create UpdatePaymentStatusRequest
- [ ] Add updatePaymentStatus method to BookingController
- [ ] Add route to api.php
- [ ] Test endpoint with Postman
- [ ] Run automated tests
- [ ] Update API documentation
- [ ] Deploy to staging
- [ ] Test on staging
- [ ] Deploy to production

## Troubleshooting

### Issue: 404 Not Found
**Solution**: Check if route is registered correctly in `routes/api.php`

### Issue: 403 Forbidden
**Solution**: Verify user authorization logic in Request or Controller

### Issue: 500 Internal Server Error
**Solution**: Check Laravel logs at `storage/logs/laravel.log`

### Issue: Migration fails
**Solution**: Check if `bookings` table exists and column names are correct

## Summary

✅ Database migration for payment columns  
✅ Booking model updated with payment fields  
✅ Request validation for payment data  
✅ Controller method for payment status update  
✅ API route registered  
✅ Authorization checks implemented  
✅ Error handling with proper HTTP codes  
✅ Logging for audit trail  
✅ Automated tests  

**Endpoint**: `PUT /api/bookings/{id}/payment`  
**Status**: Ready for implementation

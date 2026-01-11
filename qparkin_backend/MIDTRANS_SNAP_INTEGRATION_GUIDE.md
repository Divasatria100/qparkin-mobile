# Midtrans Snap Integration Guide

## Overview
Panduan lengkap integrasi Midtrans Snap untuk pembayaran booking parkir QParkin.

## Architecture

```
Flutter App → Backend API → Midtrans API → Snap Token
           ↓
    WebView (Midtrans Snap UI)
           ↓
    Payment Callback → Backend Webhook → Update Booking Status
```

## Prerequisites

### 1. Midtrans Account
- Register at https://dashboard.midtrans.com/
- Get Server Key and Client Key
- Use Sandbox for testing

### 2. Install Midtrans PHP Library

```bash
composer require midtrans/midtrans-php
```

## Backend Implementation

### 1. Environment Configuration

Add to `.env`:

```env
# Midtrans Configuration
MIDTRANS_SERVER_KEY=your-server-key-here
MIDTRANS_CLIENT_KEY=your-client-key-here
MIDTRANS_IS_PRODUCTION=false
MIDTRANS_IS_SANITIZED=true
MIDTRANS_IS_3DS=true
```

### 2. Config File

Create `config/midtrans.php`:

```php
<?php

return [
    'server_key' => env('MIDTRANS_SERVER_KEY'),
    'client_key' => env('MIDTRANS_CLIENT_KEY'),
    'is_production' => env('MIDTRANS_IS_PRODUCTION', false),
    'is_sanitized' => env('MIDTRANS_IS_SANITIZED', true),
    'is_3ds' => env('MIDTRANS_IS_3DS', true),
];
```

### 3. Midtrans Service

Create `app/Services/MidtransService.php`:

```php
<?php

namespace App\Services;

use Midtrans\Config;
use Midtrans\Snap;

class MidtransService
{
    public function __construct()
    {
        // Set Midtrans configuration
        Config::$serverKey = config('midtrans.server_key');
        Config::$isProduction = config('midtrans.is_production');
        Config::$isSanitized = config('midtrans.is_sanitized');
        Config::$is3ds = config('midtrans.is_3ds');
    }

    /**
     * Create Snap Token for booking payment
     *
     * @param \App\Models\Booking $booking
     * @return string Snap token
     */
    public function createSnapToken($booking)
    {
        $params = [
            'transaction_details' => [
                'order_id' => $booking->id_booking,
                'gross_amount' => (int) $booking->biaya_estimasi,
            ],
            'customer_details' => [
                'first_name' => $booking->user->name ?? 'Customer',
                'email' => $booking->user->email ?? 'customer@example.com',
                'phone' => $booking->user->phone ?? '08123456789',
            ],
            'item_details' => [
                [
                    'id' => $booking->id_parkiran,
                    'price' => (int) $booking->biaya_estimasi,
                    'quantity' => 1,
                    'name' => 'Booking Parkir - ' . ($booking->namaMall ?? 'Mall'),
                ],
            ],
            'callbacks' => [
                'finish' => config('app.url') . '/api/midtrans/finish',
            ],
        ];

        try {
            $snapToken = Snap::getSnapToken($params);
            return $snapToken;
        } catch (\Exception $e) {
            \Log::error('Midtrans Snap Token Error: ' . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Get transaction status from Midtrans
     *
     * @param string $orderId
     * @return object
     */
    public function getTransactionStatus($orderId)
    {
        try {
            $status = \Midtrans\Transaction::status($orderId);
            return $status;
        } catch (\Exception $e) {
            \Log::error('Midtrans Status Check Error: ' . $e->getMessage());
            throw $e;
        }
    }
}
```

### 4. Controller Methods

Add to `app/Http/Controllers/Api/BookingController.php`:

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Services\MidtransService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class BookingController extends Controller
{
    protected $midtransService;

    public function __construct(MidtransService $midtransService)
    {
        $this->midtransService = $midtransService;
    }

    /**
     * Get Snap Token for payment
     *
     * POST /api/bookings/{id}/payment/snap-token
     */
    public function getSnapToken($id)
    {
        try {
            $booking = Booking::where('id_booking', $id)->firstOrFail();

            // Check authorization
            if ($booking->id_user !== auth()->id()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized',
                ], 403);
            }

            // Check if booking is already paid
            if ($booking->payment_status === 'PAID') {
                return response()->json([
                    'success' => false,
                    'message' => 'Booking has already been paid',
                ], 400);
            }

            // Create Snap Token
            $snapToken = $this->midtransService->createSnapToken($booking);

            // Save snap token to booking
            $booking->update([
                'snap_token' => $snapToken,
                'payment_status' => 'PENDING',
            ]);

            Log::info('Snap token created', [
                'booking_id' => $booking->id_booking,
                'user_id' => auth()->id(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Snap token created successfully',
                'data' => [
                    'snap_token' => $snapToken,
                    'booking_id' => $booking->id_booking,
                ],
            ]);

        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Booking not found',
            ], 404);

        } catch (\Exception $e) {
            Log::error('Error creating snap token', [
                'booking_id' => $id,
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to create snap token',
                'error' => config('app.debug') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Update payment status
     *
     * PUT /api/bookings/{id}/payment/status
     */
    public function updatePaymentStatus(Request $request, $id)
    {
        $request->validate([
            'payment_status' => 'required|in:PAID,PENDING,FAILED',
        ]);

        try {
            $booking = Booking::where('id_booking', $id)->firstOrFail();

            // Check authorization
            if ($booking->id_user !== auth()->id()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized',
                ], 403);
            }

            // Update payment status
            $booking->update([
                'payment_status' => $request->payment_status,
                'paid_at' => $request->payment_status === 'PAID' ? now() : null,
            ]);

            Log::info('Payment status updated', [
                'booking_id' => $booking->id_booking,
                'payment_status' => $request->payment_status,
                'user_id' => auth()->id(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Payment status updated successfully',
                'data' => [
                    'booking_id' => $booking->id_booking,
                    'payment_status' => $booking->payment_status,
                    'paid_at' => $booking->paid_at,
                ],
            ]);

        } catch (\Exception $e) {
            Log::error('Error updating payment status', [
                'booking_id' => $id,
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to update payment status',
            ], 500);
        }
    }

    /**
     * Midtrans notification webhook
     *
     * POST /api/midtrans/notification
     */
    public function midtransNotification(Request $request)
    {
        try {
            $notification = $request->all();
            
            Log::info('Midtrans notification received', $notification);

            $orderId = $notification['order_id'];
            $transactionStatus = $notification['transaction_status'];
            $fraudStatus = $notification['fraud_status'] ?? null;

            $booking = Booking::where('id_booking', $orderId)->firstOrFail();

            // Determine payment status
            $paymentStatus = 'PENDING';

            if ($transactionStatus == 'capture') {
                $paymentStatus = ($fraudStatus == 'accept') ? 'PAID' : 'PENDING';
            } elseif ($transactionStatus == 'settlement') {
                $paymentStatus = 'PAID';
            } elseif (in_array($transactionStatus, ['cancel', 'deny', 'expire'])) {
                $paymentStatus = 'FAILED';
            }

            // Update booking
            $booking->update([
                'payment_status' => $paymentStatus,
                'paid_at' => $paymentStatus === 'PAID' ? now() : null,
                'payment_method' => $notification['payment_type'] ?? null,
            ]);

            Log::info('Booking payment status updated from webhook', [
                'booking_id' => $orderId,
                'payment_status' => $paymentStatus,
                'transaction_status' => $transactionStatus,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Notification processed',
            ]);

        } catch (\Exception $e) {
            Log::error('Error processing Midtrans notification', [
                'error' => $e->getMessage(),
                'notification' => $request->all(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to process notification',
            ], 500);
        }
    }
}
```

### 5. Routes

Add to `routes/api.php`:

```php
<?php

use App\Http\Controllers\Api\BookingController;

Route::middleware('auth:api')->group(function () {
    // Snap token endpoint
    Route::post('/bookings/{id}/payment/snap-token', [BookingController::class, 'getSnapToken']);
    
    // Payment status update
    Route::put('/bookings/{id}/payment/status', [BookingController::class, 'updatePaymentStatus']);
});

// Midtrans webhook (no auth required)
Route::post('/midtrans/notification', [BookingController::class, 'midtransNotification']);
```

### 6. Database Migration

```bash
php artisan make:migration add_payment_columns_to_bookings_table
```

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
            $table->string('snap_token')->nullable()->after('payment_method');
            $table->timestamp('paid_at')->nullable()->after('snap_token');
        });
    }

    public function down(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->dropColumn(['payment_status', 'payment_method', 'snap_token', 'paid_at']);
        });
    }
};
```

Run migration:
```bash
php artisan migrate
```

## Testing

### 1. Test Snap Token Generation

```bash
curl -X POST http://localhost:8000/api/bookings/BK001/payment/snap-token \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

Expected response:
```json
{
  "success": true,
  "message": "Snap token created successfully",
  "data": {
    "snap_token": "abc123...",
    "booking_id": "BK001"
  }
}
```

### 2. Test Midtrans Sandbox

Use Midtrans test cards:
- **Success**: 4811 1111 1111 1114
- **Failure**: 4911 1111 1111 1113
- **Challenge**: 4411 1111 1111 1118

## Webhook Configuration

1. Login to Midtrans Dashboard
2. Go to Settings → Configuration
3. Set Notification URL: `https://your-domain.com/api/midtrans/notification`
4. Enable HTTP notification

## Security Considerations

1. **Verify Signature**: Validate Midtrans signature in webhook
2. **HTTPS Only**: Use HTTPS in production
3. **Server Key**: Never expose server key to client
4. **Authorization**: Always check user ownership
5. **Idempotency**: Handle duplicate notifications

## Troubleshooting

### Issue: Snap token creation fails
**Solution**: Check Midtrans credentials in `.env`

### Issue: Webhook not received
**Solution**: 
- Verify notification URL in Midtrans dashboard
- Check firewall/server configuration
- Use ngrok for local testing

### Issue: Payment status not updating
**Solution**: Check Laravel logs and Midtrans dashboard

## Production Checklist

- [ ] Change `MIDTRANS_IS_PRODUCTION=true`
- [ ] Use production Server Key and Client Key
- [ ] Configure production notification URL
- [ ] Test with real payment methods
- [ ] Enable HTTPS
- [ ] Set up monitoring and alerts
- [ ] Configure proper error handling
- [ ] Test webhook delivery

## Summary

✅ Midtrans Snap integration via WebView  
✅ Snap token generation endpoint  
✅ Payment status update endpoint  
✅ Webhook for payment notifications  
✅ Database schema for payment tracking  
✅ Security and authorization checks  
✅ Error handling and logging  

**Flow**: Booking → Snap Token → WebView → Payment → Webhook → Status Update → Confirmation

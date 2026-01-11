# Payment Flow - Quick Reference Guide

## 🎯 What Was Implemented

Added **Payment Page** between Booking Confirmation and Success Dialog.

**New Flow**: Booking → **Payment** → Confirmation

## 📁 Files Created/Modified

### Created
- `qparkin_app/lib/presentation/screens/payment_page.dart` (500+ lines)
- `PAYMENT_FLOW_MIDTRANS_SIMULATION_IMPLEMENTATION.md` (documentation)
- `qparkin_backend/PAYMENT_ENDPOINT_IMPLEMENTATION_GUIDE.md` (backend guide)

### Modified
- `qparkin_app/lib/presentation/screens/booking_page.dart`
  - Added import: `import 'payment_page.dart';`
  - Modified `_showConfirmationDialog()` to navigate to PaymentPage

## 🚀 Quick Start

### Frontend (Flutter)

```bash
cd qparkin_app
flutter run --dart-define=API_URL=http://192.168.0.101:8000
```

**Test Flow:**
1. Login → Map → Select Mall → Book Parking
2. Fill booking details → Tap "Konfirmasi Booking"
3. **NEW**: Payment Page appears
4. Select payment method → Tap "Bayar Sekarang"
5. Wait 2 seconds (simulation)
6. Confirmation Dialog appears

### Backend (Laravel)

**Required Endpoint**: `PUT /api/bookings/{id}/payment`

**Quick Implementation:**

1. **Migration:**
```bash
php artisan make:migration add_payment_columns_to_bookings_table
```

2. **Add to migration:**
```php
$table->string('payment_status', 20)->default('PENDING');
$table->string('payment_method', 50)->nullable();
$table->timestamp('paid_at')->nullable();
```

3. **Run migration:**
```bash
php artisan migrate
```

4. **Add route** (`routes/api.php`):
```php
Route::middleware('auth:api')->group(function () {
    Route::put('/bookings/{id}/payment', [BookingController::class, 'updatePaymentStatus']);
});
```

5. **Add controller method** (`app/Http/Controllers/Api/BookingController.php`):
```php
public function updatePaymentStatus(Request $request, $id)
{
    $request->validate([
        'payment_method' => 'required|string',
        'payment_status' => 'required|in:PAID,PENDING,FAILED',
    ]);

    $booking = Booking::findOrFail($id);
    
    // Authorization check
    if ($booking->id_user !== auth()->id()) {
        return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
    }

    $booking->update([
        'payment_status' => $request->payment_status,
        'payment_method' => $request->payment_method,
        'paid_at' => now(),
    ]);

    return response()->json([
        'success' => true,
        'message' => 'Payment status updated successfully',
        'data' => $booking,
    ]);
}
```

## 🎨 Payment Methods Available

1. **GoPay** (Green)
2. **OVO** (Purple)
3. **DANA** (Blue)
4. **BCA Virtual Account** (Blue)
5. **Mandiri Virtual Account** (Dark Blue)
6. **BNI Virtual Account** (Orange)

## 📊 Payment Page Features

✅ Booking summary (mall, lantai, slot, kendaraan, waktu, durasi)  
✅ Payment method selection (6 options)  
✅ Total payment display (formatted Rupiah)  
✅ "Bayar Sekarang" button  
✅ Loading state during processing  
✅ Error handling with dialogs  
✅ Accessibility support (screen readers)  
✅ Consistent design (BaseParkingCard)  

## 🔄 Complete User Flow

```
┌─────────────────┐
│  Booking Page   │
│  (Fill details) │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Tap "Konfirmasi │
│    Booking"     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Backend API    │
│ Create Booking  │
│ Status: PENDING │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Payment Page   │ ◄── NEW!
│ - Summary       │
│ - Select Method │
│ - Total         │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Tap "Bayar      │
│   Sekarang"     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Processing...   │
│ (2 seconds)     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Backend API    │
│ Update Status   │
│ Status: PAID    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Confirmation    │
│   Dialog        │
│ - QR Code       │
│ - Details       │
└─────────────────┘
```

## 🧪 Testing

### Manual Test
```bash
# 1. Run app
flutter run --dart-define=API_URL=http://192.168.0.101:8000

# 2. Complete booking flow
# 3. Verify payment page appears
# 4. Select payment method
# 5. Tap "Bayar Sekarang"
# 6. Verify confirmation dialog appears
```

### Backend Test
```bash
# Test endpoint with curl
curl -X PUT http://localhost:8000/api/bookings/BK001/payment \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"payment_method":"gopay","payment_status":"PAID"}'
```

## 🐛 Troubleshooting

### Payment page doesn't appear
- Check if `payment_page.dart` import exists in `booking_page.dart`
- Verify navigation logic in `_showConfirmationDialog()`

### API call fails (404)
- Backend endpoint not implemented
- Check route registration in `routes/api.php`

### API call fails (403)
- Authorization issue
- Verify user owns the booking

### API call fails (500)
- Check Laravel logs: `storage/logs/laravel.log`
- Verify database columns exist

## 📚 Documentation

- **Full Implementation**: `PAYMENT_FLOW_MIDTRANS_SIMULATION_IMPLEMENTATION.md`
- **Backend Guide**: `qparkin_backend/PAYMENT_ENDPOINT_IMPLEMENTATION_GUIDE.md`
- **This Guide**: `PAYMENT_FLOW_QUICK_REFERENCE.md`

## ✅ Checklist

### Frontend
- [x] Payment page created
- [x] Booking page modified
- [x] Navigation implemented
- [x] Error handling added
- [x] Accessibility support
- [ ] Test on device

### Backend
- [ ] Migration created
- [ ] Migration run
- [ ] Route added
- [ ] Controller method added
- [ ] Authorization implemented
- [ ] Test endpoint

## 🎯 Next Steps

1. **Implement backend endpoint** (see backend guide)
2. **Test complete flow** end-to-end
3. **Hot restart** Flutter app to test
4. **Verify** payment status updates correctly
5. **Optional**: Add real Midtrans SDK integration

## 💡 Tips

- Use **hot restart** (not hot reload) after changes
- Check debug logs for payment flow: `[PaymentPage]`
- Backend logs show payment updates
- Test with different payment methods
- Verify booking status changes to PAID

---

**Status**: ✅ Frontend Complete | ⏳ Backend Pending  
**Priority**: High (Required for booking flow)  
**Complexity**: Medium

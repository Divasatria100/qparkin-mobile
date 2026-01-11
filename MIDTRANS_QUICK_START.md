# Midtrans Snap WebView - Quick Start Guide

## 🎯 What Changed

**OLD**: Custom payment UI simulation (WRONG)  
**NEW**: Midtrans Snap WebView (CORRECT)

## 🚀 Quick Setup

### Frontend (5 minutes)

1. **Add dependency**:
```bash
cd qparkin_app
flutter pub get
```

2. **Test**:
```bash
flutter run --dart-define=API_URL=http://192.168.0.101:8000
```

3. **Flow**: Booking → Konfirmasi → **Midtrans WebView** → Payment → Confirmation

### Backend (15 minutes)

1. **Install Midtrans**:
```bash
cd qparkin_backend
composer require midtrans/midtrans-php
```

2. **Add to `.env`**:
```env
MIDTRANS_SERVER_KEY=SB-Mid-server-xxx
MIDTRANS_CLIENT_KEY=SB-Mid-client-xxx
MIDTRANS_IS_PRODUCTION=false
```

3. **Run migration**:
```bash
php artisan make:migration add_payment_columns_to_bookings_table
```

Add columns:
```php
$table->string('payment_status', 20)->default('PENDING');
$table->string('payment_method', 50)->nullable();
$table->string('snap_token')->nullable();
$table->timestamp('paid_at')->nullable();
```

```bash
php artisan migrate
```

4. **Add routes** (`routes/api.php`):
```php
Route::middleware('auth:api')->group(function () {
    Route::post('/bookings/{id}/payment/snap-token', [BookingController::class, 'getSnapToken']);
    Route::put('/bookings/{id}/payment/status', [BookingController::class, 'updatePaymentStatus']);
});
```

5. **Implement controller methods** (see `qparkin_backend/MIDTRANS_SNAP_INTEGRATION_GUIDE.md`)

## 📱 Test Flow

1. Login → Map → Select Mall → Book Parking
2. Fill details → Tap "Konfirmasi Booking"
3. **NEW**: Midtrans WebView appears
4. Select payment method
5. Use test card: `4811 1111 1111 1114`
6. Complete payment
7. See confirmation dialog

## 🧪 Midtrans Test Cards

- **Success**: `4811 1111 1111 1114`
- **Failure**: `4911 1111 1111 1113`
- **3DS**: `4411 1111 1111 1118`

CVV: Any 3 digits  
Expiry: Any future date

## 📁 Files

### Created
- `qparkin_app/lib/presentation/screens/midtrans_payment_page.dart`
- `qparkin_backend/MIDTRANS_SNAP_INTEGRATION_GUIDE.md`
- `MIDTRANS_SNAP_WEBVIEW_IMPLEMENTATION.md`

### Modified
- `qparkin_app/pubspec.yaml` (added webview_flutter)
- `qparkin_app/lib/presentation/screens/booking_page.dart` (changed navigation)

### Deprecated
- `qparkin_app/lib/presentation/screens/payment_page.dart` (old simulation)

## ✅ Checklist

### Frontend
- [x] Add webview_flutter dependency
- [x] Create MidtransPaymentPage
- [x] Update booking_page navigation
- [ ] Run flutter pub get
- [ ] Test on device

### Backend
- [ ] Install midtrans/midtrans-php
- [ ] Add credentials to .env
- [ ] Create MidtransService
- [ ] Add snap token endpoint
- [ ] Add status update endpoint
- [ ] Run migration
- [ ] Test endpoints

## 🔗 Documentation

- **Full Guide**: `MIDTRANS_SNAP_WEBVIEW_IMPLEMENTATION.md`
- **Backend Guide**: `qparkin_backend/MIDTRANS_SNAP_INTEGRATION_GUIDE.md`
- **This Guide**: `MIDTRANS_QUICK_START.md`

## 💡 Key Points

✅ Uses **official Midtrans Snap UI** (not custom)  
✅ WebView loads Midtrans payment page  
✅ Handles success/pending/failed callbacks  
✅ Updates booking status via API  
✅ PCI compliant (no card data in app)  

**Status**: ✅ Frontend Ready | ⏳ Backend Needs Implementation

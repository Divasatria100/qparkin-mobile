# Midtrans Snap WebView Implementation

## Overview
Implementasi pembayaran menggunakan **Midtrans Snap WebView** yang menampilkan halaman pembayaran resmi Midtrans, bukan simulasi UI custom.

## ⚠️ Important Changes

**BEFORE** (Simulasi UI - SALAH):
- Custom payment page dengan tombol dan metode pembayaran
- Simulasi delay 2 detik
- Manual UI untuk payment methods

**AFTER** (Midtrans Snap WebView - BENAR):
- WebView menampilkan halaman Midtrans Snap resmi
- UI pembayaran dari Midtrans (tidak boleh dimodifikasi)
- Callback handling untuk success/pending/failed

## Architecture

```
┌─────────────────┐
│  Booking Page   │
│  (Konfirmasi)   │
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
│  Backend API    │
│ Get Snap Token  │ ◄── Request snap token
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Midtrans Snap   │
│    WebView      │ ◄── Load official Midtrans UI
│ (Payment Page)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ User Completes  │
│    Payment      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Midtrans        │
│   Callback      │ ◄── success/pending/failed
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
│    Dialog       │
└─────────────────┘
```

## Implementation Details

### 1. Flutter App

#### A. Dependencies Added

**File**: `qparkin_app/pubspec.yaml`

```yaml
dependencies:
  webview_flutter: ^4.4.2  # NEW
```

Run:
```bash
cd qparkin_app
flutter pub get
```

#### B. Midtrans Payment Page

**File**: `qparkin_app/lib/presentation/screens/midtrans_payment_page.dart`

**Key Features**:
- WebView untuk menampilkan Midtrans Snap
- Request snap token dari backend
- Handle navigation callbacks (success, pending, failed)
- Update booking status setelah pembayaran
- Error handling dengan retry

**Flow**:
1. `initState()` → Initialize WebView
2. `_getSnapToken()` → Request snap token dari backend API
3. `_loadSnapPage(token)` → Load Midtrans Snap URL di WebView
4. `_handleNavigationUrl(url)` → Detect payment result dari URL
5. `_handlePaymentSuccess()` → Update status & navigate to confirmation
6. `_handlePaymentPending()` → Show pending dialog
7. `_handlePaymentFailed()` → Show error dialog with retry

**Midtrans Snap URL**:
- **Sandbox**: `https://app.sandbox.midtrans.com/snap/v2/vtweb/{snap_token}`
- **Production**: `https://app.midtrans.com/snap/v2/vtweb/{snap_token}`

#### C. Modified Booking Page

**File**: `qparkin_app/lib/presentation/screens/booking_page.dart`

**Changes**:
```dart
// OLD
import 'payment_page.dart';

// NEW
import 'midtrans_payment_page.dart';

// OLD
Navigator.push(context, MaterialPageRoute(
  builder: (context) => PaymentPage(booking: booking),
));

// NEW
Navigator.push(context, MaterialPageRoute(
  builder: (context) => MidtransPaymentPage(booking: booking),
));
```

### 2. Backend API

#### Required Endpoints

**A. Get Snap Token**

```
POST /api/bookings/{id}/payment/snap-token
Authorization: Bearer {token}
```

**Response**:
```json
{
  "success": true,
  "message": "Snap token created successfully",
  "data": {
    "snap_token": "abc123xyz...",
    "booking_id": "BK001"
  }
}
```

**B. Update Payment Status**

```
PUT /api/bookings/{id}/payment/status
Authorization: Bearer {token}
Content-Type: application/json

{
  "payment_status": "PAID"
}
```

**C. Midtrans Webhook** (Optional but recommended)

```
POST /api/midtrans/notification
Content-Type: application/json

{
  "order_id": "BK001",
  "transaction_status": "settlement",
  "payment_type": "gopay",
  ...
}
```

#### Database Schema

Add columns to `bookings` table:

```sql
ALTER TABLE bookings 
ADD COLUMN payment_status VARCHAR(20) DEFAULT 'PENDING',
ADD COLUMN payment_method VARCHAR(50) NULL,
ADD COLUMN snap_token TEXT NULL,
ADD COLUMN paid_at TIMESTAMP NULL;
```

## Payment Flow

### Happy Path (Success)

1. **User taps "Konfirmasi Booking"**
   - Backend creates booking with status PENDING
   - Returns booking object

2. **Navigate to MidtransPaymentPage**
   - Show loading state
   - Request snap token from backend

3. **Backend generates Snap Token**
   - Call Midtrans API
   - Save snap token to booking
   - Return snap token to app

4. **Load Midtrans Snap in WebView**
   - URL: `https://app.sandbox.midtrans.com/snap/v2/vtweb/{snap_token}`
   - User sees official Midtrans payment page
   - User selects payment method (GoPay, Bank Transfer, etc.)

5. **User completes payment**
   - Midtrans processes payment
   - Redirects to finish URL with status

6. **App detects payment success**
   - Parse URL parameters
   - Call backend to update status to PAID
   - Navigate to confirmation dialog

7. **Show confirmation**
   - Display QR code
   - Show booking details
   - User can view in Activity page

### Pending Path

1-4. Same as happy path

5. **User selects Bank Transfer**
   - Midtrans shows VA number
   - User needs to complete payment manually

6. **App detects pending status**
   - Show pending dialog
   - Inform user to complete payment
   - Navigate to Activity page

7. **Backend webhook receives notification**
   - When user completes payment
   - Update booking status to PAID
   - Send push notification (optional)

### Failed Path

1-4. Same as happy path

5. **Payment fails or cancelled**
   - User cancels payment
   - Payment denied by bank
   - Payment expires

6. **App detects failure**
   - Show error dialog
   - Offer retry option
   - Or navigate back to booking

## URL Callback Detection

Midtrans redirects to finish URL with query parameters:

```
https://your-app.com/finish?
  order_id=BK001&
  status_code=200&
  transaction_status=settlement
```

**Status Codes**:
- `200` + `settlement` = **SUCCESS** (PAID)
- `200` + `pending` = **PENDING** (Waiting payment)
- `200` + `capture` = **SUCCESS** (Credit card)
- `deny` / `cancel` / `expire` = **FAILED**

## Testing

### 1. Frontend Testing

```bash
cd qparkin_app
flutter run --dart-define=API_URL=http://192.168.0.101:8000
```

**Steps**:
1. Login
2. Navigate to Map → Select Mall → Book Parking
3. Fill booking details
4. Tap "Konfirmasi Booking"
5. **Verify**: MidtransPaymentPage appears with loading
6. **Verify**: Midtrans Snap page loads in WebView
7. Select payment method (use test cards)
8. Complete payment
9. **Verify**: Navigate to confirmation dialog

### 2. Backend Testing

**Test Snap Token Generation**:
```bash
curl -X POST http://localhost:8000/api/bookings/BK001/payment/snap-token \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

### 3. Midtrans Test Cards

**Sandbox Test Cards**:
- **Success**: `4811 1111 1111 1114`
- **Failure**: `4911 1111 1111 1113`
- **Challenge (3DS)**: `4411 1111 1111 1118`

**CVV**: Any 3 digits  
**Expiry**: Any future date

## Files Created/Modified

### Created
1. `qparkin_app/lib/presentation/screens/midtrans_payment_page.dart` (NEW)
2. `qparkin_backend/MIDTRANS_SNAP_INTEGRATION_GUIDE.md` (Backend guide)
3. `MIDTRANS_SNAP_WEBVIEW_IMPLEMENTATION.md` (This file)

### Modified
1. `qparkin_app/pubspec.yaml` - Added `webview_flutter` dependency
2. `qparkin_app/lib/presentation/screens/booking_page.dart` - Changed import and navigation

### Deprecated
1. `qparkin_app/lib/presentation/screens/payment_page.dart` - No longer used (simulasi)

## Configuration

### Midtrans Credentials

**Backend `.env`**:
```env
MIDTRANS_SERVER_KEY=SB-Mid-server-xxx  # Sandbox
MIDTRANS_CLIENT_KEY=SB-Mid-client-xxx  # Sandbox
MIDTRANS_IS_PRODUCTION=false
```

**Get credentials**:
1. Register at https://dashboard.midtrans.com/
2. Go to Settings → Access Keys
3. Copy Server Key and Client Key

## Security Considerations

1. **Never expose Server Key** to Flutter app
2. **Always validate** user authorization before creating snap token
3. **Verify webhook signature** from Midtrans
4. **Use HTTPS** in production
5. **Validate payment status** from Midtrans API, not just from URL

## Troubleshooting

### Issue: WebView shows blank page
**Solution**: 
- Check snap token is valid
- Verify Midtrans URL is correct
- Check internet connection

### Issue: Snap token request fails
**Solution**:
- Verify backend endpoint exists
- Check Midtrans credentials in `.env`
- Check booking exists and user is authorized

### Issue: Payment callback not detected
**Solution**:
- Check URL parsing logic in `_handleNavigationUrl()`
- Verify Midtrans finish URL configuration
- Check debug logs

### Issue: Status not updating after payment
**Solution**:
- Verify backend update endpoint works
- Check auth token is valid
- Implement webhook for reliable status updates

## Production Checklist

### Backend
- [ ] Install Midtrans PHP library: `composer require midtrans/midtrans-php`
- [ ] Add Midtrans credentials to `.env`
- [ ] Create MidtransService
- [ ] Implement snap token endpoint
- [ ] Implement status update endpoint
- [ ] Implement webhook endpoint
- [ ] Run database migration
- [ ] Test with sandbox
- [ ] Configure production credentials
- [ ] Set up webhook URL in Midtrans dashboard

### Frontend
- [ ] Add `webview_flutter` dependency
- [ ] Run `flutter pub get`
- [ ] Test WebView loading
- [ ] Test payment flow end-to-end
- [ ] Test error scenarios
- [ ] Test on real device
- [ ] Build release APK

## Advantages of WebView Approach

✅ **Official UI**: Uses Midtrans's official payment page  
✅ **PCI Compliant**: No need to handle sensitive card data  
✅ **All Payment Methods**: Supports all Midtrans payment methods  
✅ **Automatic Updates**: Midtrans updates UI without app changes  
✅ **Security**: Payment data never touches your server  
✅ **Best Practice**: Recommended by Midtrans for mobile apps  

## Summary

✅ **Midtrans Snap WebView** implemented  
✅ **Official payment UI** from Midtrans  
✅ **Snap token** generation from backend  
✅ **Payment callbacks** handled (success/pending/failed)  
✅ **Status updates** to backend  
✅ **Error handling** with retry  
✅ **Clean architecture** separation  

**New Flow**: Booking → **Midtrans Snap WebView** → Payment → Confirmation

**Status**: ✅ Frontend Complete | ⏳ Backend Pending (needs Midtrans integration)

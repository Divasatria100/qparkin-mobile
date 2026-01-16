# Payment Flow - Midtrans Simulation Implementation

## Overview
Implementasi halaman pembayaran simulasi Midtrans sebagai langkah lanjutan setelah konfirmasi booking. Flow baru: **Booking → Payment → Confirmation**.

## Problem Statement
Sebelumnya, setelah user menekan tombol "Konfirmasi Booking", proses langsung menampilkan dialog konfirmasi tanpa ada step pembayaran. Ini tidak sesuai dengan alur bisnis yang seharusnya ada proses pembayaran terlebih dahulu.

## Solution

### New Booking Flow
```
1. User mengisi form booking (mall, kendaraan, lantai, waktu, durasi)
2. User menekan "Konfirmasi Booking"
3. Backend membuat booking dengan status PENDING
4. ✨ Navigate ke Payment Page (NEW)
5. ✨ User memilih metode pembayaran (NEW)
6. ✨ User menekan "Bayar Sekarang" (NEW)
7. ✨ Simulasi pembayaran berhasil (NEW)
8. ✨ Update status booking menjadi PAID (NEW)
9. Navigate ke Confirmation Dialog
10. User dapat melihat QR code dan detail booking
```

## Implementation Details

### 1. Payment Page (`payment_page.dart`)

**Location**: `qparkin_app/lib/presentation/screens/payment_page.dart`

#### Features

**A. Booking Summary Card**
- Menampilkan ringkasan booking:
  - Nama mall
  - Lantai parkir
  - Nomor slot (atau "Auto-assign")
  - Plat nomor kendaraan
  - Waktu masuk
  - Durasi parkir
  - Waktu keluar estimasi

**B. Payment Method Selection**
- 6 metode pembayaran simulasi:
  1. **GoPay** (Green #00AA13)
  2. **OVO** (Purple #4C3494)
  3. **DANA** (Blue #118EEA)
  4. **BCA Virtual Account** (Blue #0066AE)
  5. **Mandiri Virtual Account** (Dark Blue #003D79)
  6. **BNI Virtual Account** (Orange #ED7D31)

- Setiap metode menampilkan:
  - Icon dengan background warna brand
  - Nama metode pembayaran
  - Checkmark untuk metode terpilih
  - Border highlight untuk metode terpilih

**C. Total Payment Display**
- Menampilkan total biaya dengan format Rupiah
- Styling prominent dengan warna primary

**D. Pay Button**
- Full-width button "Bayar Sekarang"
- Disabled state saat processing
- Accessibility support

**E. Payment Processing**
- Loading state dengan spinner
- Simulasi delay 2 detik
- API call untuk update status booking
- Error handling dengan dialog

#### Code Structure

```dart
class PaymentPage extends StatefulWidget {
  final BookingModel booking;
  
  const PaymentPage({required this.booking});
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isProcessing = false;
  String _selectedPaymentMethod = 'gopay';
  
  // Main sections
  Widget _buildBookingSummary()
  Widget _buildPaymentMethodSection()
  Widget _buildTotalPayment()
  Widget _buildPayButton()
  
  // Payment logic
  Future<void> _handlePayment()
  Future<bool> _updateBookingStatus()
  
  // Navigation
  void _showSuccessDialog()
  void _showErrorDialog(String error)
}
```

### 2. Modified Booking Page Flow

**File**: `qparkin_app/lib/presentation/screens/booking_page.dart`

#### Changes Made

**Before:**
```dart
void _showConfirmationDialog(booking) {
  Navigator.pop(context);
  Navigator.push(
    context,
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BookingConfirmationDialog(booking: booking),
    ),
  );
}
```

**After:**
```dart
void _showConfirmationDialog(booking) {
  Navigator.pop(context);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PaymentPage(booking: booking),
    ),
  );
}
```

**Import Added:**
```dart
import 'payment_page.dart';
```

### 3. Backend API Integration

#### Payment Status Update Endpoint

**Expected Endpoint**: `PUT /api/bookings/{id}/payment`

**Request Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
Accept: application/json
```

**Request Body:**
```json
{
  "payment_method": "gopay",
  "payment_status": "PAID"
}
```

**Expected Response (200 OK):**
```json
{
  "success": true,
  "message": "Payment status updated successfully",
  "data": {
    "id_booking": "BK001",
    "payment_status": "PAID",
    "payment_method": "gopay",
    "paid_at": "2024-01-15T10:30:00Z"
  }
}
```

**Error Response (400/500):**
```json
{
  "success": false,
  "message": "Error message here"
}
```

## Visual Design

### Payment Method Item Design

```
┌─────────────────────────────────────────────────┐
│  ┌────┐                                         │
│  │ 💳 │  GoPay                            ✓     │
│  └────┘                                         │
└─────────────────────────────────────────────────┘
  48x48   Brand Name                    Checkmark
  Icon    (16px)                        (Selected)
```

**Selected State:**
- Border: 2px Primary Color
- Background: Primary Color 5% opacity
- Checkmark visible

**Unselected State:**
- Border: 1px Light Gray
- Background: Transparent
- No checkmark

### Color Scheme

- **Background**: `DesignConstants.backgroundLight`
- **Cards**: White with `BaseParkingCard`
- **Primary Actions**: `DesignConstants.primaryColor`
- **Text Primary**: `DesignConstants.textPrimary`
- **Text Secondary**: `DesignConstants.textSecondary`

## User Experience Flow

### Happy Path

1. **User arrives at Payment Page**
   - Sees booking summary
   - Default payment method: GoPay (pre-selected)
   - Total payment displayed prominently

2. **User selects payment method** (optional)
   - Taps on preferred method
   - Visual feedback: border highlight + checkmark
   - Screen reader announces: "[Method] dipilih"

3. **User taps "Bayar Sekarang"**
   - Button disabled
   - Loading state shown
   - Screen reader announces: "Memproses pembayaran"

4. **Payment processing (2 seconds)**
   - Spinner displayed
   - Text: "Memproses pembayaran... Mohon tunggu sebentar"

5. **Payment success**
   - API updates booking status to PAID
   - Screen reader announces: "Pembayaran berhasil"
   - Navigate to Confirmation Dialog
   - User sees QR code and booking details

### Error Handling

**Scenario 1: Network Error**
- Show error dialog
- Message: "Terjadi kesalahan: [error]"
- Button: "OK" (returns to payment page)
- User can retry payment

**Scenario 2: API Error (400/500)**
- Show error dialog
- Message: "Gagal memperbarui status pembayaran"
- Button: "OK" (returns to payment page)
- User can retry payment

**Scenario 3: Token Expired**
- API returns 401
- Show error dialog
- Redirect to login page

## Accessibility Features

### Screen Reader Support

1. **Payment Method Selection**
   ```dart
   Semantics(
     label: 'Metode pembayaran GoPay, terpilih',
     button: true,
     selected: true,
   )
   ```

2. **Pay Button**
   ```dart
   Semantics(
     label: 'Tombol bayar sekarang',
     hint: 'Ketuk untuk memproses pembayaran',
     button: true,
   )
   ```

3. **Status Announcements**
   - "Memproses pembayaran" (on button press)
   - "Pembayaran berhasil" (on success)
   - "[Method] dipilih" (on method selection)

### Touch Target Sizes

- Payment method items: Full width, 64px+ height
- Pay button: Full width, 56px height
- All interactive elements: Minimum 48x48px

## Testing Guide

### Manual Testing Steps

1. **Test Payment Flow**
   ```bash
   # Run app
   cd qparkin_app
   flutter run --dart-define=API_URL=http://192.168.0.101:8000
   
   # Steps:
   # 1. Login
   # 2. Navigate to Map → Select Mall → Book Parking
   # 3. Fill all booking details
   # 4. Tap "Konfirmasi Booking"
   # 5. Verify: Navigate to Payment Page
   # 6. Verify: Booking summary displayed correctly
   # 7. Select different payment methods
   # 8. Tap "Bayar Sekarang"
   # 9. Verify: Loading state shown
   # 10. Verify: Navigate to Confirmation Dialog after 2 seconds
   ```

2. **Test Payment Methods**
   - Tap each payment method
   - Verify visual feedback (border + checkmark)
   - Verify screen reader announcement

3. **Test Error Handling**
   - Disconnect internet
   - Tap "Bayar Sekarang"
   - Verify error dialog shown
   - Reconnect and retry

4. **Test Accessibility**
   - Enable TalkBack/VoiceOver
   - Navigate through payment page
   - Verify all elements announced correctly

### Backend Testing

**Create Test Endpoint** (if not exists):

```php
// routes/api.php
Route::middleware('auth:api')->group(function () {
    Route::put('/bookings/{id}/payment', [BookingController::class, 'updatePaymentStatus']);
});

// app/Http/Controllers/BookingController.php
public function updatePaymentStatus(Request $request, $id)
{
    $request->validate([
        'payment_method' => 'required|string',
        'payment_status' => 'required|in:PAID,PENDING,FAILED',
    ]);

    $booking = Booking::findOrFail($id);
    
    // Update payment status
    $booking->payment_status = $request->payment_status;
    $booking->payment_method = $request->payment_method;
    $booking->paid_at = now();
    $booking->save();

    return response()->json([
        'success' => true,
        'message' => 'Payment status updated successfully',
        'data' => $booking,
    ]);
}
```

## Database Schema (Recommended)

Add payment-related columns to `bookings` table:

```sql
ALTER TABLE bookings 
ADD COLUMN payment_status VARCHAR(20) DEFAULT 'PENDING',
ADD COLUMN payment_method VARCHAR(50) NULL,
ADD COLUMN paid_at TIMESTAMP NULL;
```

## Files Created/Modified

### Created
1. `qparkin_app/lib/presentation/screens/payment_page.dart` (NEW)
   - Complete payment simulation page
   - 500+ lines of code

### Modified
1. `qparkin_app/lib/presentation/screens/booking_page.dart`
   - Added import for `payment_page.dart`
   - Modified `_showConfirmationDialog()` to navigate to PaymentPage

## Dependencies

All dependencies already exist in `pubspec.yaml`:
- ✅ `flutter/material.dart`
- ✅ `provider`
- ✅ `flutter_secure_storage`
- ✅ `http`

## Next Steps

### For Complete Integration

1. **Backend Implementation**
   - Create `PUT /api/bookings/{id}/payment` endpoint
   - Add payment status validation
   - Update booking status in database

2. **Enhanced Features** (Optional)
   - Add payment timeout (e.g., 15 minutes)
   - Add payment history
   - Add payment receipt download
   - Integrate real Midtrans SDK

3. **Testing**
   - Unit tests for payment logic
   - Integration tests for payment flow
   - E2E tests for complete booking + payment

## Troubleshooting

### Issue: Payment page not showing
**Solution**: Check if booking object is passed correctly from booking_page.dart

### Issue: API call fails
**Solution**: 
- Verify backend endpoint exists
- Check auth token validity
- Verify booking ID format

### Issue: Navigation doesn't work
**Solution**: Ensure context is valid and Navigator is available

## Summary

✅ **Payment page created** with Midtrans simulation  
✅ **6 payment methods** available for selection  
✅ **Booking summary** displayed clearly  
✅ **Payment processing** with loading state  
✅ **Status update** via API call  
✅ **Error handling** with user-friendly dialogs  
✅ **Accessibility** support for screen readers  
✅ **Consistent design** using BaseParkingCard and DesignConstants  

**New Flow**: Booking → **Payment** → Confirmation → Activity Page

# Pending Payment - Quick Reference

## Quick Start

### 1. Run Migration
```bash
cd qparkin_backend
php artisan migrate
```

### 2. Test Backend API
```bash
# Get pending payments
curl -X GET http://localhost:8000/api/booking/pending-payments \
  -H "Authorization: Bearer YOUR_TOKEN"

# Cancel booking
curl -X PUT http://localhost:8000/api/booking/1/cancel \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 3. Test Flutter App
```bash
cd qparkin_app
flutter run --dart-define=API_URL=http://192.168.1.100:8000
```

## API Endpoints

### GET /api/booking/pending-payments
**Purpose:** Mendapatkan list booking yang menunggu pembayaran

**Headers:**
- `Authorization: Bearer {token}`
- `Accept: application/json`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id_booking": "1",
      "nama_mall": "Mega Mall",
      "plat_nomor": "BP 1234 AB",
      "waktu_mulai": "2025-01-15T10:00:00",
      "durasi_booking": 2,
      "biaya_estimasi": 15000,
      "status": "pending_payment"
    }
  ]
}
```

### PUT /api/booking/{id}/cancel
**Purpose:** Membatalkan booking yang pending payment

**Headers:**
- `Authorization: Bearer {token}`
- `Accept: application/json`

**Response:**
```json
{
  "success": true,
  "message": "Booking berhasil dibatalkan"
}
```

## Flutter Usage

### Fetch Pending Payments
```dart
final bookingService = BookingService();
final token = await storage.read(key: 'auth_token');

try {
  final pendingPayments = await bookingService.getPendingPayments(
    token: token!,
  );
  
  print('Found ${pendingPayments.length} pending payments');
} catch (e) {
  print('Error: $e');
}
```

### Cancel Pending Payment
```dart
final success = await bookingService.cancelPendingPayment(
  bookingId: booking.idBooking,
  token: token!,
);

if (success) {
  print('Booking cancelled successfully');
} else {
  print('Failed to cancel booking');
}
```

### Display Pending Payment Card
```dart
PendingPaymentCard(
  booking: booking,
  onContinuePayment: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MidtransPaymentPage(booking: booking),
      ),
    );
  },
  onCancel: () async {
    final confirmed = await showDialog<bool>(...);
    if (confirmed) {
      // Cancel booking
    }
  },
)
```

## User Flow

1. **Create Booking** → Status: `pending_payment`
2. **Exit Payment Page** → Booking saved
3. **Open Activity Page** → Pending payment shown
4. **Tap "Lanjutkan Pembayaran"** → Midtrans opens
5. **Complete Payment** → Status: `aktif`

OR

3. **Tap "Batalkan"** → Confirmation dialog
4. **Confirm** → Booking cancelled, slot released

## Status Values

- `pending_payment` - Menunggu pembayaran
- `aktif` - Pembayaran selesai, parkir aktif
- `selesai` - Parkir selesai
- `expired` - Booking expired
- `cancelled` - Booking dibatalkan

## Troubleshooting

### Pending payment tidak muncul
```bash
# Check database
mysql -u root -p qparkin
SELECT * FROM booking WHERE status = 'pending_payment';

# Check API response
curl -X GET http://localhost:8000/api/booking/pending-payments \
  -H "Authorization: Bearer TOKEN" -v
```

### Cancel tidak berhasil
```bash
# Check booking exists
SELECT * FROM booking WHERE id_transaksi = 1;

# Check user ownership
SELECT b.*, t.id_user 
FROM booking b 
JOIN transaksi_parkir t ON b.id_transaksi = t.id_transaksi 
WHERE b.id_transaksi = 1;
```

### Migration error
```bash
# Rollback
php artisan migrate:rollback --step=1

# Re-run
php artisan migrate

# Check status
php artisan migrate:status
```

## Files Modified

### Backend
- `app/Http/Controllers/Api/BookingController.php` - Added getPendingPayments()
- `routes/api.php` - Added pending-payments route
- `database/migrations/2025_01_15_000001_add_pending_payment_status_to_booking.php` - New

### Flutter
- `lib/data/services/booking_service.dart` - Added getPendingPayments(), cancelPendingPayment()
- `lib/presentation/widgets/pending_payment_card.dart` - New widget
- `lib/presentation/screens/activity_page.dart` - Integrated pending payments

## Testing Checklist

- [ ] Migration runs successfully
- [ ] GET /api/booking/pending-payments returns data
- [ ] PUT /api/booking/{id}/cancel works
- [ ] Pending payment card displays correctly
- [ ] "Lanjutkan Pembayaran" opens Midtrans
- [ ] "Batalkan" shows confirmation dialog
- [ ] Cancel booking works
- [ ] Pull-to-refresh updates data
- [ ] Empty state shows when no pending payments
- [ ] Error handling works (network, auth, etc.)

## Quick Commands

```bash
# Backend
cd qparkin_backend
php artisan migrate
php artisan serve

# Flutter
cd qparkin_app
flutter pub get
flutter run --dart-define=API_URL=http://192.168.1.100:8000

# Test
curl -X GET http://localhost:8000/api/booking/pending-payments \
  -H "Authorization: Bearer TOKEN"
```

## Support

For issues or questions:
1. Check PENDING_PAYMENT_IMPLEMENTATION_COMPLETE.md
2. Check Laravel logs: `storage/logs/laravel.log`
3. Check Flutter console output
4. Check network inspector in browser/app

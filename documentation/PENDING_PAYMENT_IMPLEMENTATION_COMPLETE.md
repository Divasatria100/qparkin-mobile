# Implementasi Pending Payment - Complete

## Overview
Fitur pending payment memungkinkan pengguna untuk melihat booking yang menunggu pembayaran di halaman Aktivitas. Ketika pengguna membuat booking dan halaman Midtrans muncul, lalu pengguna menunda pembayaran (keluar dari aplikasi), informasi pembayaran tersebut akan ditampilkan kembali dengan tombol "Lanjutkan Pembayaran" dan "Batalkan".

## Implementasi

### 1. Backend Changes

#### Migration
**File:** `qparkin_backend/database/migrations/2025_01_15_000001_add_pending_payment_status_to_booking.php`

Menambahkan status `pending_payment` ke enum status booking:
```php
DB::statement("ALTER TABLE booking MODIFY COLUMN status ENUM('aktif', 'selesai', 'expired', 'pending_payment') DEFAULT 'aktif'");
```

**Cara menjalankan:**
```bash
cd qparkin_backend
php artisan migrate
```

#### API Endpoints

**1. Get Pending Payments**
- **Endpoint:** `GET /api/booking/pending-payments`
- **Auth:** Bearer token required
- **Response:**
```json
{
  "success": true,
  "data": [
    {
      "id_transaksi": "1",
      "id_booking": "1",
      "id_mall": "1",
      "nama_mall": "Mega Mall Batam",
      "plat_nomor": "BP 1234 AB",
      "jenis_kendaraan": "Roda Empat",
      "waktu_mulai": "2025-01-15T10:00:00",
      "waktu_selesai": "2025-01-15T12:00:00",
      "durasi_booking": 2,
      "status": "pending_payment",
      "biaya_estimasi": 15000,
      "dibooking_pada": "2025-01-15T09:45:00"
    }
  ]
}
```

**2. Cancel Pending Payment**
- **Endpoint:** `PUT /api/booking/{id}/cancel`
- **Auth:** Bearer token required
- **Response:**
```json
{
  "success": true,
  "message": "Booking berhasil dibatalkan"
}
```

#### Controller Updates
**File:** `qparkin_backend/app/Http/Controllers/Api/BookingController.php`

Menambahkan method `getPendingPayments()`:
```php
public function getPendingPayments(Request $request)
{
    $userId = $request->user()->id_user;
    
    $pendingBookings = Booking::whereHas('transaksiParkir', function ($query) use ($userId) {
        $query->where('id_user', $userId)
              ->where('status', 'pending_payment');
    })
    ->with([...])
    ->orderBy('dibooking_pada', 'desc')
    ->get();
    
    return response()->json([
        'success' => true,
        'data' => $formattedBookings
    ]);
}
```

#### Routes
**File:** `qparkin_backend/routes/api.php`

```php
Route::prefix('booking')->group(function () {
    Route::get('/pending-payments', [BookingController::class, 'getPendingPayments']);
    // ... other routes
});
```

### 2. Flutter Changes

#### Service Layer
**File:** `qparkin_app/lib/data/services/booking_service.dart`

Menambahkan 2 method baru:

**1. Get Pending Payments:**
```dart
Future<List<BookingModel>> getPendingPayments({
  required String token,
}) async {
  final uri = Uri.parse('$_baseUrl/api/booking/pending-payments');
  final response = await _client.get(uri, headers: {...});
  
  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    return (jsonData['data'] as List)
        .map((item) => BookingModel.fromJson(item))
        .toList();
  }
  // ... error handling
}
```

**2. Cancel Pending Payment:**
```dart
Future<bool> cancelPendingPayment({
  required String bookingId,
  required String token,
}) async {
  final uri = Uri.parse('$_baseUrl/api/booking/$bookingId/cancel');
  final response = await _client.put(uri, headers: {...});
  
  return response.statusCode == 200;
}
```

#### Widget Layer
**File:** `qparkin_app/lib/presentation/widgets/pending_payment_card.dart`

Widget baru untuk menampilkan pending payment dengan design yang konsisten:

**Features:**
- Header dengan status "Menunggu Pembayaran" (orange)
- Detail booking (mall, kendaraan, waktu, durasi)
- Total pembayaran
- 2 tombol aksi: "Batalkan" dan "Lanjutkan Pembayaran"

**Design:**
- Border orange untuk highlight pending status
- Icon payment di header
- Responsive layout dengan Row untuk tombol
- Consistent dengan design system (DesignConstants)

#### Screen Updates
**File:** `qparkin_app/lib/presentation/screens/activity_page.dart`

**Changes:**
1. Menambahkan state untuk pending payments:
```dart
List<BookingModel> _pendingPayments = [];
bool _isLoadingPendingPayments = false;
final BookingService _bookingService = BookingService();
```

2. Fetch pending payments saat init:
```dart
@override
void initState() {
  super.initState();
  // ...
  _fetchPendingPayments();
}
```

3. Menampilkan pending payments di atas active parking:
```dart
// Pending Payments Section
if (_pendingPayments.isNotEmpty) ...[
  const Text('Menunggu Pembayaran', ...),
  ..._pendingPayments.map((booking) => PendingPaymentCard(
    booking: booking,
    onContinuePayment: () => _handleContinuePayment(booking),
    onCancel: () => _handleCancelPayment(booking),
  )),
  const Divider(),
  const Text('Parkir Aktif', ...),
],
```

4. Handle continue payment:
```dart
Future<void> _handleContinuePayment(BookingModel booking) async {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MidtransPaymentPage(booking: booking),
    ),
  ).then((_) {
    _fetchPendingPayments();
    _fetchActiveParkingWithErrorHandling();
  });
}
```

5. Handle cancel payment:
```dart
Future<void> _handleCancelPayment(BookingModel booking) async {
  // Show confirmation dialog
  final confirmed = await showDialog<bool>(...);
  
  if (confirmed) {
    final success = await _bookingService.cancelPendingPayment(...);
    if (success) {
      _showSuccessSnackbar('Booking berhasil dibatalkan');
      _fetchPendingPayments();
    }
  }
}
```

6. Pull-to-refresh untuk kedua data:
```dart
RefreshIndicator(
  onRefresh: () async {
    await _fetchActiveParkingWithErrorHandling();
    await _fetchPendingPayments();
  },
  // ...
)
```

## User Flow

### Scenario 1: User menunda pembayaran
1. User membuat booking di booking page
2. Booking dibuat dengan status `pending_payment`
3. User diarahkan ke Midtrans payment page
4. User keluar dari aplikasi (back button / home button)
5. User kembali ke aplikasi dan membuka Activity page
6. **Pending payment card ditampilkan** dengan tombol "Lanjutkan Pembayaran"
7. User tap "Lanjutkan Pembayaran"
8. Midtrans payment page dibuka kembali dengan snap token yang sama
9. User menyelesaikan pembayaran
10. Booking status berubah menjadi `aktif`
11. Pending payment card hilang, active parking ditampilkan

### Scenario 2: User membatalkan booking
1. User melihat pending payment di Activity page
2. User tap tombol "Batalkan"
3. Confirmation dialog muncul
4. User konfirmasi pembatalan
5. API dipanggil untuk cancel booking
6. Slot dirilis, booking status berubah
7. Success snackbar ditampilkan
8. Pending payment card hilang dari list

### Scenario 3: Tidak ada active parking, ada pending payment
1. User tidak memiliki parkir aktif
2. User memiliki 1+ pending payment
3. Activity page menampilkan:
   - Section "Menunggu Pembayaran" dengan pending payment cards
   - Divider
   - Empty state untuk "Parkir Aktif"

## Testing

### Backend Testing
```bash
cd qparkin_backend

# Test get pending payments
curl -X GET http://localhost:8000/api/booking/pending-payments \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"

# Test cancel booking
curl -X PUT http://localhost:8000/api/booking/1/cancel \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

### Flutter Testing
```bash
cd qparkin_app

# Run app
flutter run --dart-define=API_URL=http://192.168.1.100:8000

# Test scenarios:
# 1. Create booking, exit before payment
# 2. Open Activity page - verify pending payment shown
# 3. Tap "Lanjutkan Pembayaran" - verify Midtrans opens
# 4. Tap "Batalkan" - verify confirmation dialog
# 5. Confirm cancel - verify booking cancelled
# 6. Pull to refresh - verify data updates
```

## Database Schema

### Before Migration
```sql
CREATE TABLE booking (
  id_transaksi BIGINT PRIMARY KEY,
  waktu_mulai DATETIME,
  waktu_selesai DATETIME,
  durasi_booking INT,
  status ENUM('aktif', 'selesai', 'expired') DEFAULT 'aktif',
  dibooking_pada DATETIME
);
```

### After Migration
```sql
CREATE TABLE booking (
  id_transaksi BIGINT PRIMARY KEY,
  waktu_mulai DATETIME,
  waktu_selesai DATETIME,
  durasi_booking INT,
  status ENUM('aktif', 'selesai', 'expired', 'pending_payment') DEFAULT 'aktif',
  dibooking_pada DATETIME
);
```

## Status Flow

```
[User creates booking]
        ↓
[Status: pending_payment]
        ↓
    ┌───┴───┐
    ↓       ↓
[Payment]  [Cancel]
    ↓       ↓
[aktif]  [cancelled]
```

## UI Screenshots

### Pending Payment Card
```
┌─────────────────────────────────────┐
│ 💳 Menunggu Pembayaran              │
│    Selesaikan pembayaran untuk      │
│    mengaktifkan booking             │
├─────────────────────────────────────┤
│ 📍 Mega Mall Batam                  │
│ 🚗 BP 1234 AB • Roda Empat          │
│ 🕐 15 Jan 2025, 10:00               │
│ ⏱️ 2 jam                             │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Total Pembayaran    Rp 15.000   │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [Batalkan] [Lanjutkan Pembayaran]  │
└─────────────────────────────────────┘
```

## Error Handling

### Backend Errors
- **401 Unauthorized:** Token invalid/expired
- **404 Not Found:** Booking tidak ditemukan
- **500 Server Error:** Database/server error

### Flutter Error Handling
- Network timeout: Retry dengan exponential backoff
- Invalid token: Redirect ke login
- Cancel failed: Show error snackbar dengan retry option
- Empty state: Show friendly message

## Performance Considerations

1. **Caching:** Tidak ada caching untuk pending payments (data harus real-time)
2. **Polling:** Tidak ada auto-refresh (user harus pull-to-refresh)
3. **Pagination:** Tidak diperlukan (pending payments biasanya sedikit)
4. **Lazy Loading:** Pending payments di-fetch bersamaan dengan active parking

## Security

1. **Authorization:** Semua endpoint memerlukan Bearer token
2. **User Isolation:** User hanya bisa melihat/cancel booking miliknya sendiri
3. **Validation:** Backend memvalidasi ownership sebelum cancel
4. **SQL Injection:** Menggunakan Eloquent ORM (parameterized queries)

## Future Enhancements

1. **Auto-expire:** Pending payments expire setelah 24 jam
2. **Push Notification:** Reminder untuk complete payment
3. **Payment History:** Track payment attempts
4. **Partial Payment:** Support untuk cicilan
5. **Multiple Payment Methods:** Selain Midtrans

## Troubleshooting

### Pending payment tidak muncul
- Cek status booking di database (harus `pending_payment`)
- Cek API response di network inspector
- Cek auth token validity
- Cek user_id matching

### Cancel tidak berhasil
- Cek booking ownership
- Cek booking status (hanya pending_payment bisa di-cancel)
- Cek slot release logic
- Cek database transaction

### Midtrans tidak terbuka
- Cek snap_token validity
- Cek Midtrans configuration
- Cek network connectivity
- Cek WebView permissions

## Summary

Implementasi pending payment selesai dengan fitur lengkap:
- ✅ Backend API untuk get pending payments
- ✅ Backend API untuk cancel booking
- ✅ Flutter service layer
- ✅ Flutter UI widget (PendingPaymentCard)
- ✅ Activity page integration
- ✅ Continue payment flow
- ✅ Cancel payment flow
- ✅ Error handling
- ✅ Pull-to-refresh
- ✅ Empty state handling
- ✅ Database migration

User sekarang dapat melihat dan mengelola pembayaran yang tertunda dengan mudah dari halaman Aktivitas.

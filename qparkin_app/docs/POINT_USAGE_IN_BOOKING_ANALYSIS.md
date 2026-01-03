# Analisis Penggunaan Poin pada Booking Parkir

## Executive Summary

Dokumen ini menganalisis mekanisme penggunaan poin pada proses booking parkir berdasarkan:
1. Implementasi poin yang sudah ada (PointProvider, PointService, models)
2. Implementasi booking yang sudah ada (BookingProvider, BookingPage, CostCalculator)
3. Spesifikasi dari SKPPL QParkin
4. Arsitektur aplikasi yang konsisten

**Rekomendasi**: Implementasi penggunaan poin sebagai **diskon/potongan harga** pada tahap pemilihan durasi booking dengan UI yang jelas dan aman.

---

## 1. Analisis Kondisi Saat Ini

### 1.1 Implementasi Poin yang Sudah Ada

#### ✅ PointProvider (State Management)
```dart
class PointProvider extends ChangeNotifier {
  int? _balance;  // Saldo poin user
  
  // Fetch balance from API
  Future<void> fetchBalance({String? token});
  
  // Use points for payment
  Future<bool> usePoints({
    required int amount,
    required String transactionId,
    String? token,
  });
}
```

#### ✅ PointService (API Layer)
```dart
class PointService {
  // GET /api/points/balance
  Future<int> getBalance({required String token});
  
  // POST /api/points/use
  Future<bool> usePoints({
    required int amount,
    required String transactionId,
    required String token,
  });
}
```

#### ✅ UserModel.saldoPoin
```dart
class UserModel {
  final int saldoPoin;  // Saldo poin dari backend
}
```

### 1.2 Implementasi Booking yang Sudah Ada

#### ✅ BookingProvider (State Management)
```dart
class BookingProvider extends ChangeNotifier {
  Duration? _bookingDuration;
  double _estimatedCost = 0.0;
  Map<String, dynamic>? _costBreakdown;
  
  // Calculate cost based on duration
  void calculateCost();
  
  // Confirm booking
  Future<bool> confirmBooking({
    required String token,
    Function(BookingModel)? onSuccess,
  });
}
```


#### ✅ CostCalculator (Utility)
```dart
class CostCalculator {
  // Calculate parking cost
  static double estimateCost({
    required double durationHours,
    required double firstHourRate,
    required double additionalHourRate,
  });
  
  // Generate cost breakdown
  static Map<String, dynamic> generateCostBreakdown({...});
}
```

#### ✅ CostBreakdownCard (Widget)
```dart
class CostBreakdownCard extends StatefulWidget {
  final double firstHourRate;
  final double additionalHoursRate;
  final int additionalHours;
  final double totalCost;
}
```

### 1.3 Spesifikasi dari SKPPL

#### Kebutuhan Fungsional F004
> "Sistem harus menyediakan simulator pembayaran digital di dalam aplikasi yang mendukung opsi pembayaran seperti QRIS, e-wallet, TapCash, **serta mendukung mekanisme tukar poin** yang dilakukan oleh pengguna (driver)."

#### Kebutuhan Fungsional F005
> "Sistem harus memberikan reward poin setiap transaksi parkir atau booking dan menyediakan manajemen poin, **termasuk penggunaan poin untuk diskon** serta perhitungan penalti jika melebihi durasi booking."

#### Use Case UC006 - Manajemen Poin dan Penalti
**Skenario Alternatif**:
> "Driver mencoba menukarkan poin yang jumlahnya tidak mencukupi untuk reward tertentu. Sistem menampilkan pesan 'Poin tidak mencukupi.'"

**Kesimpulan dari SKPPL**:
- ✅ Poin dapat digunakan sebagai **diskon/potongan harga**
- ✅ Poin dapat digunakan untuk **pembayaran** (tukar poin)
- ✅ Sistem harus validasi saldo poin mencukupi
- ✅ Sistem harus menampilkan pesan error jika poin tidak cukup

---

## 2. Analisis Lokasi Implementasi

### 2.1 Lokasi di BookingPage

Berdasarkan analisis `booking_page.dart`, ada beberapa lokasi potensial:

#### Opsi A: Di UnifiedTimeDurationCard (TIDAK RECOMMENDED)
```dart
// Line ~350-380
UnifiedTimeDurationCard(
  startTime: provider.startTime,
  duration: provider.bookingDuration,
  onTimeChanged: (time) { ... },
  onDurationChanged: (duration) { ... },
)
```
**Alasan TIDAK RECOMMENDED**:
- Widget ini fokus pada pemilihan waktu dan durasi
- Menambah kompleksitas pada widget yang sudah kompleks
- Tidak ada konteks biaya di widget ini

#### Opsi B: Di CostBreakdownCard (RECOMMENDED ⭐)
```dart
// Line ~400-420
CostBreakdownCard(
  firstHourRate: provider.firstHourRate,
  additionalHoursRate: provider.costBreakdown!['additionalHoursTotal'] ?? 0.0,
  additionalHours: provider.costBreakdown!['additionalHours'] ?? 0,
  totalCost: provider.estimatedCost,
  // NEW: Add point usage parameters
  availablePoints: pointProvider.balance ?? 0,
  usedPoints: provider.usedPoints ?? 0,
  onPointsChanged: (points) { provider.setUsedPoints(points); },
)
```
**Alasan RECOMMENDED**:
- ✅ Konteks biaya sudah ada
- ✅ User sudah melihat total biaya
- ✅ Natural flow: lihat biaya → pilih gunakan poin → lihat biaya setelah diskon
- ✅ Tidak mengganggu flow pemilihan waktu/durasi

#### Opsi C: Widget Terpisah Setelah CostBreakdownCard (RECOMMENDED ⭐⭐)
```dart
// Line ~420-430 (setelah CostBreakdownCard)
if (provider.bookingDuration != null && provider.costBreakdown != null)
  CostBreakdownCard(...),

// NEW: Point usage widget
if (provider.bookingDuration != null && provider.estimatedCost > 0)
  PointUsageCard(
    availablePoints: pointProvider.balance ?? 0,
    maxUsablePoints: _calculateMaxUsablePoints(provider.estimatedCost),
    usedPoints: provider.usedPoints ?? 0,
    onPointsChanged: (points) { provider.setUsedPoints(points); },
  ),
```
**Alasan PALING RECOMMENDED**:
- ✅ Separation of concerns (widget terpisah)
- ✅ Mudah di-maintain dan di-test
- ✅ Bisa di-reuse di tempat lain
- ✅ Tidak mengubah widget existing
- ✅ Clear visual hierarchy


---

## 3. Mekanisme Penggunaan Poin

### 3.1 Aturan Bisnis

Berdasarkan analisis SKPPL dan best practices:

1. **Konversi Poin ke Rupiah**: 1 Poin = Rp 1
   - Sederhana dan mudah dipahami user
   - Konsisten dengan sistem reward umum

2. **Maksimal Poin yang Bisa Digunakan**:
   - Tidak boleh melebihi total biaya booking
   - Tidak boleh melebihi saldo poin user
   - Formula: `min(saldoPoin, totalBiaya)`

3. **Minimum Poin yang Bisa Digunakan**:
   - Opsi 1: Tidak ada minimum (user bisa gunakan 1 poin)
   - Opsi 2: Minimum 100 poin (untuk menghindari transaksi kecil)
   - **RECOMMENDED**: Tidak ada minimum (lebih user-friendly)

4. **Validasi**:
   - Validasi saldo poin sebelum confirm booking
   - Validasi ulang di backend saat create booking
   - Tampilkan error jika poin tidak mencukupi

5. **Perhitungan Biaya Final**:
   ```
   totalBiaya = firstHourRate + (additionalHours × additionalHourRate)
   poinDigunakan = min(saldoPoin, totalBiaya)
   biayaSetelahDiskon = totalBiaya - poinDigunakan
   ```

### 3.2 User Flow

```
1. User memilih mall, kendaraan, waktu, durasi
   ↓
2. Sistem menghitung estimasi biaya
   ↓
3. Sistem menampilkan CostBreakdownCard dengan total biaya
   ↓
4. Sistem menampilkan PointUsageCard dengan:
   - Saldo poin tersedia
   - Slider/input untuk pilih jumlah poin
   - Preview biaya setelah diskon
   ↓
5. User menggeser slider atau input jumlah poin
   ↓
6. Sistem update preview biaya real-time
   ↓
7. User tap "Konfirmasi Booking"
   ↓
8. Sistem validasi:
   - Saldo poin mencukupi? ✓
   - Poin tidak melebihi total biaya? ✓
   ↓
9. Sistem kirim booking request dengan:
   - usedPoints: jumlah poin yang digunakan
   - finalCost: biaya setelah diskon poin
   ↓
10. Backend proses booking dan deduct poin
```

### 3.3 State Management

#### Perubahan di BookingProvider

```dart
class BookingProvider extends ChangeNotifier {
  // Existing state
  double _estimatedCost = 0.0;
  Map<String, dynamic>? _costBreakdown;
  
  // NEW: Point usage state
  int _usedPoints = 0;
  int _availablePoints = 0;
  
  // NEW: Getters
  int get usedPoints => _usedPoints;
  int get availablePoints => _availablePoints;
  double get finalCost => _estimatedCost - _usedPoints;
  int get maxUsablePoints => min(_availablePoints, _estimatedCost.toInt());
  
  // NEW: Set available points (from PointProvider)
  void setAvailablePoints(int points) {
    _availablePoints = points;
    
    // Reset used points if exceeds available
    if (_usedPoints > _availablePoints) {
      _usedPoints = min(_availablePoints, _estimatedCost.toInt());
    }
    
    notifyListeners();
  }
  
  // NEW: Set used points (from user input)
  void setUsedPoints(int points) {
    // Validate: tidak boleh melebihi available atau total cost
    final maxUsable = min(_availablePoints, _estimatedCost.toInt());
    _usedPoints = points.clamp(0, maxUsable);
    
    notifyListeners();
  }
  
  // NEW: Reset used points
  void resetUsedPoints() {
    _usedPoints = 0;
    notifyListeners();
  }
  
  // MODIFIED: Calculate cost (reset used points when cost changes)
  void calculateCost() {
    // ... existing calculation ...
    
    // Reset used points if cost changed
    if (_estimatedCost != previousCost) {
      final maxUsable = min(_availablePoints, _estimatedCost.toInt());
      if (_usedPoints > maxUsable) {
        _usedPoints = maxUsable;
      }
    }
    
    notifyListeners();
  }
  
  // MODIFIED: Confirm booking (include used points)
  Future<bool> confirmBooking({
    required String token,
    Function(BookingModel)? onSuccess,
  }) async {
    // ... existing validation ...
    
    // NEW: Validate used points
    if (_usedPoints > _availablePoints) {
      _errorMessage = 'Saldo poin tidak mencukupi';
      notifyListeners();
      return false;
    }
    
    if (_usedPoints > _estimatedCost.toInt()) {
      _errorMessage = 'Poin yang digunakan melebihi total biaya';
      notifyListeners();
      return false;
    }
    
    // Create booking request with used points
    final request = BookingRequest(
      // ... existing fields ...
      usedPoints: _usedPoints,  // NEW
      finalCost: finalCost,     // NEW
    );
    
    // ... rest of booking logic ...
  }
}
```


---

## 4. Opsi Implementasi UI

### Opsi 1: Slider dengan Preview (RECOMMENDED ⭐⭐⭐)

**Deskripsi**: Slider untuk memilih jumlah poin dengan preview biaya real-time

**Kelebihan**:
- ✅ Intuitive dan mudah digunakan
- ✅ Visual feedback langsung
- ✅ Tidak perlu keyboard input
- ✅ Mencegah input invalid (slider auto-clamp)
- ✅ Smooth UX dengan animation

**Kekurangan**:
- ⚠️ Sulit untuk input nilai spesifik (misal: 1234 poin)
- ⚠️ Perlu space lebih untuk slider

**Mockup**:
```
┌─────────────────────────────────────────┐
│ 💰 Gunakan Poin                         │
├─────────────────────────────────────────┤
│ Saldo Poin: 5.000 Poin                  │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 0 ●━━━━━━━━━━━━━━━━━━━━━━━━━ 5.000 │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Poin Digunakan: 2.500 Poin              │
│ Diskon: Rp 2.500                        │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ Total Sebelum: Rp 15.000            │ │
│ │ Diskon Poin:   - Rp 2.500           │ │
│ │ ─────────────────────────────────── │ │
│ │ Total Bayar:   Rp 12.500            │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

**Implementation**:
```dart
class PointUsageCard extends StatefulWidget {
  final int availablePoints;
  final int maxUsablePoints;
  final int usedPoints;
  final Function(int) onPointsChanged;
  final double originalCost;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.stars, color: Color(0xFFFFA726)),
                SizedBox(width: 8),
                Text('Gunakan Poin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            
            SizedBox(height: 12),
            
            // Available points info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Saldo Poin:', style: TextStyle(color: Colors.grey[600])),
                Text('${_formatNumber(availablePoints)} Poin', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Slider
            Slider(
              value: usedPoints.toDouble(),
              min: 0,
              max: maxUsablePoints.toDouble(),
              divisions: maxUsablePoints > 0 ? maxUsablePoints : 1,
              label: '${_formatNumber(usedPoints)} Poin',
              activeColor: Color(0xFF573ED1),
              onChanged: (value) => onPointsChanged(value.toInt()),
            ),
            
            // Used points display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Poin Digunakan:', style: TextStyle(fontSize: 14)),
                Text('${_formatNumber(usedPoints)} Poin', 
                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF573ED1))),
              ],
            ),
            
            SizedBox(height: 4),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Diskon:', style: TextStyle(fontSize: 14)),
                Text('Rp ${_formatNumber(usedPoints)}', 
                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Cost preview
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF573ED1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildCostRow('Total Sebelum:', originalCost, isStrikethrough: usedPoints > 0),
                  if (usedPoints > 0) ...[
                    SizedBox(height: 4),
                    _buildCostRow('Diskon Poin:', -usedPoints.toDouble(), isDiscount: true),
                    Divider(height: 16),
                  ],
                  _buildCostRow('Total Bayar:', originalCost - usedPoints, isFinal: true),
                ],
              ),
            ),
            
            // Info message
            if (usedPoints > 0)
              Padding(
                padding: EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Poin akan dikurangi setelah booking dikonfirmasi',
                        style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```


### Opsi 2: TextField dengan Validasi (ALTERNATIVE)

**Deskripsi**: Input field untuk memasukkan jumlah poin secara manual

**Kelebihan**:
- ✅ Presisi tinggi (bisa input nilai spesifik)
- ✅ Familiar untuk user yang suka kontrol penuh
- ✅ Compact UI (tidak perlu space untuk slider)

**Kekurangan**:
- ⚠️ Perlu keyboard input (mengganggu flow)
- ⚠️ Perlu validasi manual
- ⚠️ Bisa input nilai invalid (perlu error handling)
- ⚠️ Kurang intuitive untuk user awam

**Mockup**:
```
┌─────────────────────────────────────────┐
│ 💰 Gunakan Poin                         │
├─────────────────────────────────────────┤
│ Saldo Poin: 5.000 Poin                  │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ Masukkan jumlah poin                │ │
│ │ [    2500    ] Poin   [Gunakan Max] │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Diskon: Rp 2.500                        │
│ Total Bayar: Rp 12.500                  │
└─────────────────────────────────────────┘
```

**TIDAK RECOMMENDED** karena:
- Mengganggu user flow dengan keyboard
- Lebih prone to error
- Kurang user-friendly

### Opsi 3: Checkbox "Gunakan Semua Poin" (SIMPLE)

**Deskripsi**: Checkbox sederhana untuk gunakan semua poin atau tidak sama sekali

**Kelebihan**:
- ✅ Sangat simple dan cepat
- ✅ Tidak perlu input manual
- ✅ Minimal UI space

**Kekurangan**:
- ❌ Tidak flexible (all or nothing)
- ❌ User tidak bisa pilih jumlah spesifik
- ❌ Kurang optimal untuk user experience

**Mockup**:
```
┌─────────────────────────────────────────┐
│ ☑ Gunakan Poin (5.000 Poin tersedia)   │
│                                         │
│ Diskon: Rp 5.000                        │
│ Total Bayar: Rp 10.000                  │
└─────────────────────────────────────────┘
```

**TIDAK RECOMMENDED** karena:
- Terlalu restrictive
- User mungkin ingin simpan sebagian poin
- Tidak sesuai dengan best practice UX

### Opsi 4: Preset Buttons + Slider (HYBRID)

**Deskripsi**: Kombinasi preset buttons (25%, 50%, 75%, 100%) + slider untuk fine-tuning

**Kelebihan**:
- ✅ Quick access dengan preset buttons
- ✅ Flexibility dengan slider
- ✅ Best of both worlds

**Kekurangan**:
- ⚠️ Lebih complex UI
- ⚠️ Perlu space lebih banyak

**Mockup**:
```
┌─────────────────────────────────────────┐
│ 💰 Gunakan Poin                         │
├─────────────────────────────────────────┤
│ Saldo Poin: 5.000 Poin                  │
│                                         │
│ [25%] [50%] [75%] [100%] [Reset]        │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 0 ●━━━━━━━━━━━━━━━━━━━━━━━━━ 5.000 │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Poin Digunakan: 2.500 Poin              │
│ Total Bayar: Rp 12.500                  │
└─────────────────────────────────────────┘
```

**RECOMMENDED untuk power users**, tapi mungkin overkill untuk MVP

---

## 5. Rekomendasi Implementasi

### 🎯 Pilihan Terbaik: Opsi 1 (Slider dengan Preview)

**Alasan**:
1. **User-Friendly**: Intuitive dan mudah digunakan tanpa perlu keyboard
2. **Visual Feedback**: User langsung melihat dampak penggunaan poin
3. **Error Prevention**: Slider auto-clamp, tidak bisa input invalid
4. **Smooth UX**: Animation dan real-time update
5. **Konsisten**: Sesuai dengan design pattern aplikasi (slider sudah digunakan di time picker)

### 📋 Implementation Plan

#### Phase 1: Backend Preparation (1 hari)
1. ✅ Tambah field `usedPoints` dan `finalCost` di BookingRequest model
2. ✅ Update backend API untuk handle point deduction
3. ✅ Validasi saldo poin di backend
4. ✅ Test API endpoint dengan Postman

#### Phase 2: State Management (1 hari)
1. ✅ Extend BookingProvider dengan point usage state
2. ✅ Add methods: `setAvailablePoints()`, `setUsedPoints()`, `resetUsedPoints()`
3. ✅ Update `calculateCost()` untuk handle point changes
4. ✅ Update `confirmBooking()` untuk include used points
5. ✅ Unit tests untuk BookingProvider

#### Phase 3: UI Implementation (1-2 hari)
1. ✅ Create `PointUsageCard` widget
2. ✅ Integrate dengan BookingPage
3. ✅ Connect dengan PointProvider untuk get balance
4. ✅ Add animations dan transitions
5. ✅ Widget tests untuk PointUsageCard

#### Phase 4: Integration & Testing (1 hari)
1. ✅ Integration test end-to-end
2. ✅ Test edge cases (poin tidak cukup, poin melebihi biaya, dll)
3. ✅ Test offline mode
4. ✅ Accessibility testing
5. ✅ Performance testing

#### Phase 5: Polish & Documentation (0.5 hari)
1. ✅ Code review
2. ✅ Update documentation
3. ✅ User guide
4. ✅ Deploy to staging

**Total Estimasi**: 4-5 hari kerja


---

## 6. Pertimbangan Keamanan

### 6.1 Validasi Client-Side

```dart
// Di BookingProvider
void setUsedPoints(int points) {
  // Validasi 1: Tidak boleh negatif
  if (points < 0) {
    _errorMessage = 'Jumlah poin tidak valid';
    return;
  }
  
  // Validasi 2: Tidak boleh melebihi saldo
  if (points > _availablePoints) {
    _errorMessage = 'Saldo poin tidak mencukupi';
    return;
  }
  
  // Validasi 3: Tidak boleh melebihi total biaya
  if (points > _estimatedCost.toInt()) {
    _errorMessage = 'Poin melebihi total biaya';
    return;
  }
  
  _usedPoints = points;
  notifyListeners();
}
```

### 6.2 Validasi Server-Side (CRITICAL)

**Backend HARUS validasi ulang**:
```php
// Di BookingController.php
public function createBooking(Request $request) {
    $usedPoints = $request->input('used_points', 0);
    $user = auth()->user();
    
    // Validasi 1: Saldo poin user
    if ($usedPoints > $user->saldo_poin) {
        return response()->json([
            'success' => false,
            'message' => 'Saldo poin tidak mencukupi'
        ], 400);
    }
    
    // Validasi 2: Tidak melebihi total biaya
    $totalCost = $this->calculateBookingCost($request);
    if ($usedPoints > $totalCost) {
        return response()->json([
            'success' => false,
            'message' => 'Poin melebihi total biaya'
        ], 400);
    }
    
    // Validasi 3: Atomic transaction
    DB::beginTransaction();
    try {
        // Create booking
        $booking = Booking::create([...]);
        
        // Deduct points
        $user->saldo_poin -= $usedPoints;
        $user->save();
        
        // Create point history
        RiwayatPoin::create([
            'id_user' => $user->id,
            'poin' => $usedPoints,
            'perubahan' => 'kurang',
            'keterangan' => "Digunakan untuk booking #{$booking->id}",
        ]);
        
        DB::commit();
        return response()->json(['success' => true, 'booking' => $booking]);
    } catch (\Exception $e) {
        DB::rollBack();
        return response()->json(['success' => false, 'message' => 'Gagal membuat booking'], 500);
    }
}
```

### 6.3 Race Condition Prevention

**Problem**: User bisa gunakan poin yang sama di multiple devices

**Solution**: Optimistic locking di backend
```php
// Check saldo before deduct
$currentBalance = DB::table('users')
    ->where('id', $user->id)
    ->lockForUpdate()  // Lock row untuk prevent race condition
    ->value('saldo_poin');

if ($currentBalance < $usedPoints) {
    throw new InsufficientPointsException();
}
```

### 6.4 Audit Trail

**Setiap penggunaan poin HARUS tercatat**:
```php
RiwayatPoin::create([
    'id_user' => $user->id,
    'poin' => $usedPoints,
    'perubahan' => 'kurang',
    'keterangan' => "Digunakan untuk booking #{$booking->id} di {$mall->nama_mall}",
    'id_transaksi' => $booking->id_transaksi,  // Link ke transaksi
    'waktu' => now(),
]);
```

---

## 7. Edge Cases & Error Handling

### 7.1 Saldo Poin Berubah Saat Booking

**Scenario**: User mulai booking dengan 5000 poin, tapi saat confirm hanya tersisa 3000 poin (digunakan di device lain)

**Solution**:
```dart
// Di BookingProvider.confirmBooking()
Future<bool> confirmBooking({required String token}) async {
  // Fetch latest balance before confirm
  final latestBalance = await _pointService.getBalance(token: token);
  
  if (_usedPoints > latestBalance) {
    _errorMessage = 'Saldo poin Anda telah berubah. Silakan sesuaikan penggunaan poin.';
    _availablePoints = latestBalance;
    _usedPoints = min(latestBalance, _estimatedCost.toInt());
    notifyListeners();
    return false;
  }
  
  // Proceed with booking...
}
```

### 7.2 Biaya Berubah Saat Durasi Diubah

**Scenario**: User set 2500 poin untuk biaya Rp 15.000, lalu ubah durasi jadi Rp 10.000

**Solution**:
```dart
// Di BookingProvider.calculateCost()
void calculateCost() {
  // ... calculate cost ...
  
  // Auto-adjust used points if exceeds new cost
  if (_usedPoints > _estimatedCost.toInt()) {
    _usedPoints = _estimatedCost.toInt();
    notifyListeners();
  }
}
```

### 7.3 Network Error Saat Confirm

**Scenario**: Booking berhasil di backend, tapi response tidak sampai ke client

**Solution**:
```dart
// Di BookingProvider.confirmBooking()
try {
  final response = await _bookingService.createBookingWithRetry(...);
  
  if (response.success) {
    // Refresh point balance untuk ensure consistency
    await _pointProvider.fetchBalance(token: token);
    return true;
  }
} catch (e) {
  // Log error untuk debugging
  debugPrint('[BookingProvider] Booking failed: $e');
  
  // Show user-friendly message
  _errorMessage = 'Gagal membuat booking. Silakan cek riwayat booking Anda.';
  
  // Suggest user to check booking history
  return false;
}
```

### 7.4 Poin Tidak Cukup di Backend

**Scenario**: Client validation pass, tapi backend validation fail (race condition)

**Solution**:
```dart
// Handle specific error code from backend
if (response.errorCode == 'INSUFFICIENT_POINTS') {
  _errorMessage = 'Saldo poin tidak mencukupi. Silakan kurangi penggunaan poin.';
  
  // Fetch latest balance
  await _pointProvider.fetchBalance(token: token);
  _availablePoints = _pointProvider.balance ?? 0;
  _usedPoints = min(_availablePoints, _estimatedCost.toInt());
  
  notifyListeners();
  return false;
}
```

---

## 8. Testing Strategy

### 8.1 Unit Tests

```dart
// test/providers/booking_provider_point_usage_test.dart
void main() {
  group('BookingProvider Point Usage', () {
    test('setUsedPoints should clamp to max usable', () {
      final provider = BookingProvider();
      provider.setAvailablePoints(5000);
      provider._estimatedCost = 3000;
      
      provider.setUsedPoints(4000);  // Exceeds cost
      
      expect(provider.usedPoints, 3000);  // Should clamp to cost
    });
    
    test('setUsedPoints should clamp to available balance', () {
      final provider = BookingProvider();
      provider.setAvailablePoints(2000);
      provider._estimatedCost = 5000;
      
      provider.setUsedPoints(3000);  // Exceeds balance
      
      expect(provider.usedPoints, 2000);  // Should clamp to balance
    });
    
    test('calculateCost should adjust used points if cost decreases', () {
      final provider = BookingProvider();
      provider.setAvailablePoints(5000);
      provider._estimatedCost = 10000;
      provider.setUsedPoints(8000);
      
      // Change duration (cost decreases to 5000)
      provider.setDuration(Duration(hours: 1));
      
      expect(provider.usedPoints, 5000);  // Should adjust to new cost
    });
    
    test('finalCost should be cost minus used points', () {
      final provider = BookingProvider();
      provider._estimatedCost = 15000;
      provider.setUsedPoints(5000);
      
      expect(provider.finalCost, 10000);
    });
  });
}
```

### 8.2 Widget Tests

```dart
// test/widgets/point_usage_card_test.dart
void main() {
  testWidgets('PointUsageCard should display available points', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PointUsageCard(
            availablePoints: 5000,
            maxUsablePoints: 5000,
            usedPoints: 0,
            originalCost: 15000,
            onPointsChanged: (_) {},
          ),
        ),
      ),
    );
    
    expect(find.text('5.000 Poin'), findsOneWidget);
  });
  
  testWidgets('PointUsageCard slider should update used points', (tester) async {
    int? changedValue;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PointUsageCard(
            availablePoints: 5000,
            maxUsablePoints: 5000,
            usedPoints: 0,
            originalCost: 15000,
            onPointsChanged: (value) => changedValue = value,
          ),
        ),
      ),
    );
    
    // Find and drag slider
    await tester.drag(find.byType(Slider), Offset(100, 0));
    await tester.pumpAndSettle();
    
    expect(changedValue, isNotNull);
    expect(changedValue! > 0, true);
  });
}
```

### 8.3 Integration Tests

```dart
// test/integration/booking_with_points_test.dart
void main() {
  testWidgets('Complete booking flow with points', (tester) async {
    // 1. Navigate to booking page
    // 2. Select vehicle, time, duration
    // 3. Adjust point usage slider
    // 4. Verify cost preview updates
    // 5. Confirm booking
    // 6. Verify success message
    // 7. Verify point balance decreased
  });
}
```

---

## 9. Kesimpulan

### ✅ Rekomendasi Final

**Implementasi Terbaik**:
1. **UI**: Slider dengan preview (Opsi 1)
2. **Lokasi**: Widget terpisah setelah CostBreakdownCard (Opsi C)
3. **State Management**: Extend BookingProvider dengan point usage state
4. **Validasi**: Double validation (client + server)
5. **Error Handling**: Comprehensive dengan user-friendly messages

**Keuntungan**:
- ✅ User-friendly dan intuitive
- ✅ Aman dengan validasi berlapis
- ✅ Maintainable dan testable
- ✅ Konsisten dengan arsitektur aplikasi
- ✅ Sesuai dengan spesifikasi SKPPL

**Timeline**: 4-5 hari kerja

**Risk**: Low (implementasi straightforward dengan pattern yang sudah ada)

### 📝 Next Steps

1. Review dokumen ini dengan tim
2. Koordinasi dengan backend team untuk API changes
3. Create tasks di project management tool
4. Start implementation Phase 1 (Backend Preparation)
5. Parallel development: UI mockup & state management
6. Integration & testing
7. Deploy to staging untuk UAT


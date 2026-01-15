# Booking Payment Amount Fix - Biaya Estimasi Calculation

## Problem

Ketika user melakukan booking dengan nominal Rp 5.000 (1 jam parkir), tetapi saat pembayaran Midtrans menampilkan nominal Rp 10.000.

## Root Cause Analysis

1. **Frontend menghitung biaya dengan benar** menggunakan `CostCalculator`:
   - 1 jam = Rp 5.000 (biaya jam pertama)
   - 2 jam = Rp 8.000 (5.000 + 3.000)
   
2. **Backend TIDAK menghitung biaya** saat booking dibuat:
   - Field `biaya_estimasi` di-set ke 0
   - Tidak ada perhitungan dari tarif parkir
   
3. **Midtrans menggunakan default value**:
   - Saat request snap token, backend menggunakan: `$amount = $booking->biaya_estimasi > 0 ? $booking->biaya_estimasi : 10000`
   - Karena `biaya_estimasi` = 0, maka menggunakan default Rp 10.000

## Solution

### 1. Add `biaya_estimasi` Column to Booking Table

**Migration File**: `database/migrations/2025_01_15_000002_add_biaya_estimasi_to_booking.php`

```php
Schema::table('booking', function (Blueprint $table) {
    $table->decimal('biaya_estimasi', 10, 2)->default(0)->after('durasi_booking');
});
```

### 2. Update Booking Model

**File**: `app/Models/Booking.php`

Added `biaya_estimasi` to `$fillable`:

```php
protected $fillable = [
    'id_transaksi',
    'id_slot',
    'reservation_id',
    'waktu_mulai',
    'waktu_selesai',
    'durasi_booking',
    'biaya_estimasi',  // NEW
    'status',
    'dibooking_pada'
];
```

### 3. Add Cost Calculation Function

**File**: `app/Http/Controllers/Api/BookingController.php`

Added `calculateBookingCost()` method:

```php
private function calculateBookingCost($idParkiran, $idKendaraan, $durasiBooking)
{
    // Get vehicle type
    $kendaraan = \App\Models\Kendaraan::find($idKendaraan);
    $jenisKendaraan = $kendaraan->jenis;

    // Get tarif parkir
    $tarif = \App\Models\TarifParkir::where('id_parkiran', $idParkiran)
        ->where('jenis_kendaraan', $jenisKendaraan)
        ->first();

    // Calculate: first hour + additional hours
    $biayaJamPertama = $tarif->biaya_jam_pertama;
    $biayaJamBerikutnya = $tarif->biaya_jam_berikutnya;

    if ($durasiBooking <= 1) {
        return $biayaJamPertama;
    }

    $additionalHours = $durasiBooking - 1;
    $totalCost = $biayaJamPertama + ($additionalHours * $biayaJamBerikutnya);

    return $totalCost;
}
```

### 4. Calculate Cost When Creating Booking

**File**: `app/Http/Controllers/Api/BookingController.php` - `store()` method

```php
// Calculate estimated cost based on tarif parkir
$biayaEstimasi = $this->calculateBookingCost(
    $request->id_parkiran,
    $request->id_kendaraan,
    $request->durasi_booking
);

// Create booking with calculated cost
$booking = Booking::create([
    'id_transaksi' => $transaksi->id_transaksi,
    'id_slot' => $idSlot,
    'reservation_id' => $reservationId,
    'waktu_mulai' => $waktuMulai,
    'waktu_selesai' => $waktuSelesai,
    'durasi_booking' => $request->durasi_booking,
    'biaya_estimasi' => $biayaEstimasi,  // NEW
    'status' => 'aktif',
    'dibooking_pada' => Carbon::now()
]);
```

### 5. Use Calculated Cost in Midtrans

**File**: `app/Http/Controllers/Api/BookingController.php` - `getSnapToken()` method

```php
// Calculate amount (use biaya_estimasi from booking)
$amount = $booking->biaya_estimasi > 0 ? $booking->biaya_estimasi : 10000;

Log::info('[Payment] Using booking cost', [
    'booking_id' => $id,
    'biaya_estimasi' => $booking->biaya_estimasi,
    'amount_used' => $amount
]);
```

## Implementation Steps

### Step 1: Run Migration

```bash
cd qparkin_backend
php artisan migrate --path=database/migrations/2025_01_15_000002_add_biaya_estimasi_to_booking.php
```

Or use the batch file:

```bash
run_biaya_estimasi_migration.bat
```

Or manually run SQL:

```sql
ALTER TABLE `booking` 
ADD COLUMN `biaya_estimasi` DECIMAL(10,2) NOT NULL DEFAULT 0 AFTER `durasi_booking`;
```

### Step 2: Restart Backend

```bash
restart-backend-clean.bat
```

### Step 3: Test Booking Flow

1. **Create a new booking** with 1 hour duration
2. **Check backend logs** for cost calculation:
   ```
   [BookingController] Calculated booking cost: Rp 5000 for 1 hours
   ```
3. **Verify booking response** includes correct `biaya_estimasi`:
   ```json
   {
     "biaya_estimasi": 5000
   }
   ```
4. **Request Midtrans snap token**
5. **Check payment logs**:
   ```
   [Payment] Using booking cost
   booking_id: 123
   biaya_estimasi: 5000
   amount_used: 5000
   ```
6. **Verify Midtrans shows correct amount**: Rp 5.000

## Cost Calculation Formula

Same as frontend `CostCalculator`:

```
If duration <= 1 hour:
  cost = biaya_jam_pertama

If duration > 1 hour:
  additional_hours = duration - 1
  cost = biaya_jam_pertama + (additional_hours × biaya_jam_berikutnya)
```

### Examples

**Tarif Parkir Motor**:
- Jam pertama: Rp 5.000
- Jam berikutnya: Rp 3.000

| Duration | Calculation | Total |
|----------|-------------|-------|
| 1 jam | 5.000 | Rp 5.000 |
| 2 jam | 5.000 + (1 × 3.000) | Rp 8.000 |
| 3 jam | 5.000 + (2 × 3.000) | Rp 11.000 |
| 4 jam | 5.000 + (3 × 3.000) | Rp 14.000 |

## Files Modified

1. ✅ `qparkin_backend/app/Models/Booking.php` - Added `biaya_estimasi` to fillable
2. ✅ `qparkin_backend/app/Http/Controllers/Api/BookingController.php`:
   - Added `calculateBookingCost()` method
   - Calculate cost in `store()` method
   - Use calculated cost in `getSnapToken()` method
3. ✅ `qparkin_backend/database/migrations/2025_01_15_000002_add_biaya_estimasi_to_booking.php` - New migration
4. ✅ `qparkin_backend/add_biaya_estimasi_column.sql` - SQL fallback
5. ✅ `qparkin_backend/run_biaya_estimasi_migration.bat` - Migration helper

## Testing Checklist

- [ ] Migration runs successfully
- [ ] Booking creation calculates cost correctly
- [ ] Backend logs show calculated cost
- [ ] Booking response includes `biaya_estimasi`
- [ ] Midtrans snap token uses correct amount
- [ ] Payment page shows correct amount (Rp 5.000 for 1 hour)
- [ ] Different durations calculate correctly (2 jam = Rp 8.000, 3 jam = Rp 11.000)
- [ ] Different vehicle types use correct tarif (Motor vs Mobil)

## Fallback Behavior

If cost calculation fails (vehicle not found, tarif not found), system uses default Rp 10.000 to prevent booking failure.

## Benefits

1. ✅ **Accurate pricing** - Backend calculates cost from tarif parkir
2. ✅ **Consistent with frontend** - Same calculation formula
3. ✅ **Correct Midtrans amount** - No more double pricing
4. ✅ **Audit trail** - Cost stored in database for reference
5. ✅ **Flexible** - Easy to update tarif without code changes

## Related Files

- `qparkin_app/lib/utils/cost_calculator.dart` - Frontend calculation (reference)
- `qparkin_backend/app/Models/TarifParkir.php` - Tarif data model
- `BOOKING_PAYMENT_FLOW_COMPLETE.md` - Payment flow documentation
- `MIDTRANS_INTEGRATION_COMPLETE.md` - Midtrans integration guide

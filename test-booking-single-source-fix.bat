@echo off
REM Test script for Booking Single Source of Truth Fix
REM Verifies slot availability consistency

echo ========================================
echo Booking Single Source Fix - Test
echo ========================================
echo.

echo [TEST 1] Checking syntax...
cd qparkin_app
call flutter analyze lib/presentation/screens/booking_page.dart
if %ERRORLEVEL% NEQ 0 (
    echo [FAIL] Syntax errors found
    exit /b 1
)
echo [PASS] No syntax errors
echo.

echo ========================================
echo Critical Test Cases:
echo ========================================
echo.

echo TEST CASE 1: Slot Consistency After Vehicle Selection
echo -------------------------------------------------------
echo [ ] 1. Buka halaman booking
echo [ ] 2. Pilih kendaraan "Roda Dua"
echo [ ] 3. Tunggu floor loading selesai
echo [ ] 4. Catat nilai slot (misalnya: 60)
echo [ ] 5. Pilih waktu (misalnya: 10:00)
echo [ ] 6. Pilih durasi (misalnya: 2 jam)
echo.
echo Expected Result:
echo   - Nilai slot TETAP 60 (tidak berubah ke 0) ✅
echo   - Card Mall: "60 slot tersedia" ✅
echo   - Card Ketersediaan: "60 slot tersedia untuk roda dua" ✅
echo   - SlotUnavailableWidget TIDAK muncul ✅
echo   - Tombol konfirmasi ENABLED ✅
echo.
echo Debug Log Expected:
echo   [BookingProvider] Total available slots for Roda Dua: 60
echo   [BookingProvider] Setting start time: ...
echo   // NO checkAvailability call
echo   [BookingProvider] Setting duration: ...
echo   // NO checkAvailability call
echo.
echo -------------------------------------------------------
echo.

echo TEST CASE 2: No Periodic API Calls
echo -------------------------------------------------------
echo [ ] 1. Buka halaman booking
echo [ ] 2. Pilih kendaraan
echo [ ] 3. Pilih waktu dan durasi
echo [ ] 4. Tunggu 1 menit
echo [ ] 5. Monitor console log
echo.
echo Expected Result:
echo   - TIDAK ada log "[BookingProvider] Checking availability" ✅
echo   - TIDAK ada periodic API calls setiap 30 detik ✅
echo   - Nilai slot tetap konsisten ✅
echo.
echo -------------------------------------------------------
echo.

echo TEST CASE 3: Refresh Button
echo -------------------------------------------------------
echo [ ] 1. Buka halaman booking
echo [ ] 2. Pilih kendaraan "Roda Dua"
echo [ ] 3. Tunggu floor loading selesai
echo [ ] 4. Klik tombol refresh di card ketersediaan
echo.
echo Expected Result:
echo   - Loading indicator muncul ✅
echo   - Log: "[BookingProvider] Loading floors for vehicle type: Roda Dua" ✅
echo   - Nilai slot diupdate dari API ✅
echo   - Nilai slot TIDAK berubah ke 0 ✅
echo.
echo -------------------------------------------------------
echo.

echo TEST CASE 4: Multiple Vehicle Changes
echo -------------------------------------------------------
echo [ ] 1. Buka halaman booking
echo [ ] 2. Pilih kendaraan "Roda Dua" → Catat slot (misalnya: 60)
echo [ ] 3. Ganti ke "Roda Empat" → Catat slot (misalnya: 50)
echo [ ] 4. Ganti kembali ke "Roda Dua" → Catat slot
echo.
echo Expected Result:
echo   - Setiap perubahan memicu loadFloorsForVehicle() ✅
echo   - Slot selalu akurat untuk jenis kendaraan ✅
echo   - Tidak ada konflik data ✅
echo   - Roda Dua: 60 slot (konsisten) ✅
echo   - Roda Empat: 50 slot (konsisten) ✅
echo.
echo -------------------------------------------------------
echo.

echo TEST CASE 5: SlotUnavailableWidget Removed
echo -------------------------------------------------------
echo [ ] 1. Buka halaman booking
echo [ ] 2. Pilih kendaraan dengan slot tersedia
echo [ ] 3. Pilih waktu dan durasi
echo [ ] 4. Scroll ke bawah
echo.
echo Expected Result:
echo   - Card "Slot Tidak Tersedia" TIDAK muncul ✅
echo   - Tidak ada opsi "Pilih waktu alternatif" ✅
echo   - UI lebih bersih ✅
echo.
echo -------------------------------------------------------
echo.

echo ========================================
echo Debug Log Monitoring:
echo ========================================
echo.
echo Monitor log berikut di console:
echo.
echo SHOULD SEE:
echo   ✅ [BookingProvider] Loading floors for vehicle type: [jenis]
echo   ✅ [BookingProvider] Total available slots for [jenis]: [jumlah]
echo   ✅ [BookingProvider] Setting start time: ...
echo   ✅ [BookingProvider] Setting duration: ...
echo.
echo SHOULD NOT SEE:
echo   ❌ [BookingProvider] Checking availability for:
echo   ❌ [BookingProvider] Starting periodic availability check
echo   ❌ [BookingProvider] Available slots: 0
echo.
echo ========================================
echo Test completed successfully!
echo ========================================
echo.
echo Next steps:
echo 1. Run: flutter run --dart-define=API_URL=http://192.168.0.101:8000
echo 2. Navigate to booking page
echo 3. Follow test cases above
echo 4. Monitor debug logs
echo 5. Verify slot values remain consistent
echo.

cd ..
pause

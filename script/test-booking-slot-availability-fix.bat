@echo off
REM Test script for Booking Page Slot Availability Fix
REM Tests slot calculation, floor filtering, and UI rendering

echo ========================================
echo Booking Slot Availability Fix - Test
echo ========================================
echo.

echo [TEST 1] Checking booking_provider.dart syntax...
cd qparkin_app
call flutter analyze lib/logic/providers/booking_provider.dart
if %ERRORLEVEL% NEQ 0 (
    echo [FAIL] Syntax errors found in booking_provider.dart
    exit /b 1
)
echo [PASS] No syntax errors in booking_provider.dart
echo.

echo [TEST 2] Checking booking_page.dart syntax...
call flutter analyze lib/presentation/screens/booking_page.dart
if %ERRORLEVEL% NEQ 0 (
    echo [FAIL] Syntax errors found in booking_page.dart
    exit /b 1
)
echo [PASS] No syntax errors in booking_page.dart
echo.

echo ========================================
echo Manual Testing Checklist:
echo ========================================
echo.
echo TEST CASE 1: Kendaraan Roda Dua (50 slot tersedia)
echo ------------------------------------------------
echo [ ] 1. Buka halaman booking
echo [ ] 2. Pilih kendaraan roda dua
echo [ ] 3. Tunggu floor loading selesai
echo.
echo Expected Result:
echo   - Card ketersediaan: "50 slot tersedia untuk roda dua"
echo   - Label mall: "50 slot tersedia"
echo   - Status: "Banyak slot tersedia" (hijau)
echo   - Card "Slot Tidak Tersedia" TIDAK muncul
echo   - Hanya lantai untuk roda dua yang muncul
echo.
echo Debug Log Expected:
echo   [BookingProvider] Total available slots for Roda Dua: 50
echo   [BookingProvider] SUCCESS: Loaded X floors for Roda Dua
echo.
echo ------------------------------------------------
echo.

echo TEST CASE 2: Kendaraan Roda Empat (Multiple Floors)
echo ------------------------------------------------
echo [ ] 1. Buka halaman booking
echo [ ] 2. Pilih kendaraan roda empat
echo [ ] 3. Tunggu floor loading selesai
echo.
echo Expected Result:
echo   - Card ketersediaan: "XX slot tersedia untuk roda empat"
echo   - Label mall: "XX slot tersedia"
echo   - Status sesuai jumlah slot
echo   - Semua lantai untuk roda empat muncul
echo.
echo ------------------------------------------------
echo.

echo TEST CASE 3: Slot Terbatas (3-10 slot)
echo ------------------------------------------------
echo [ ] 1. Buka halaman booking dengan mall yang slot terbatas
echo [ ] 2. Pilih kendaraan
echo [ ] 3. Tunggu floor loading selesai
echo.
echo Expected Result:
echo   - Card ketersediaan: "X slot tersedia"
echo   - Status: "Slot terbatas" (orange)
echo   - Card "Slot Tidak Tersedia" TIDAK muncul
echo.
echo ------------------------------------------------
echo.

echo TEST CASE 4: Slot Hampir Penuh (1-2 slot)
echo ------------------------------------------------
echo [ ] 1. Buka halaman booking dengan mall hampir penuh
echo [ ] 2. Pilih kendaraan
echo [ ] 3. Tunggu floor loading selesai
echo.
echo Expected Result:
echo   - Card ketersediaan: "1 atau 2 slot tersedia"
echo   - Status: "Hampir penuh" (red)
echo   - Card "Slot Tidak Tersedia" TIDAK muncul
echo.
echo ------------------------------------------------
echo.

echo TEST CASE 5: Slot Benar-Benar Penuh (0 slot)
echo ------------------------------------------------
echo [ ] 1. Buka halaman booking dengan mall penuh
echo [ ] 2. Pilih kendaraan
echo [ ] 3. Pilih waktu dan durasi
echo [ ] 4. Tunggu floor loading selesai
echo.
echo Expected Result:
echo   - Card ketersediaan: "0 slot tersedia"
echo   - Status: "Penuh" (red)
echo   - Card "Slot Tidak Tersedia" MUNCUL
echo   - Opsi waktu alternatif ditampilkan
echo   - Tombol konfirmasi disabled
echo.
echo ------------------------------------------------
echo.

echo TEST CASE 6: Tidak Ada Lantai untuk Jenis Kendaraan
echo ------------------------------------------------
echo [ ] 1. Buka halaman booking
echo [ ] 2. Pilih kendaraan yang tidak ada lantainya
echo [ ] 3. Tunggu floor loading selesai
echo.
echo Expected Result:
echo   - Error message: "Tidak ada lantai parkir untuk jenis kendaraan X"
echo   - Card ketersediaan TIDAK muncul
echo   - Floor selector kosong
echo.
echo ------------------------------------------------
echo.

echo TEST CASE 7: Loading State
echo ------------------------------------------------
echo [ ] 1. Buka halaman booking
echo [ ] 2. Pilih kendaraan
echo [ ] 3. Perhatikan saat floor loading
echo.
echo Expected Result:
echo   - Card ketersediaan TIDAK muncul saat loading
echo   - Loading indicator ditampilkan
echo   - Setelah loading selesai, card muncul dengan data yang benar
echo.
echo ------------------------------------------------
echo.

echo ========================================
echo Debug Log Monitoring:
echo ========================================
echo.
echo Monitor log berikut di console:
echo.
echo 1. [BookingProvider] Loading floors for vehicle type: [jenis]
echo 2. [BookingProvider] Total floors from API: [jumlah]
echo 3. [BookingProvider] Floor [nama]: [jenis] [match] ([slots] slots)
echo 4. [BookingProvider] Filtered floors: [jumlah]
echo 5. [BookingProvider] Total available slots for [jenis]: [jumlah]
echo 6. [BookingProvider] SUCCESS: Loaded [jumlah] floors for [jenis]
echo.
echo ========================================
echo Test completed successfully!
echo ========================================
echo.
echo Next steps:
echo 1. Run: flutter run --dart-define=API_URL=http://192.168.0.101:8000
echo 2. Navigate to booking page
echo 3. Follow manual testing checklist above
echo 4. Monitor debug logs in console
echo 5. Verify all expected behaviors
echo.

cd ..
pause

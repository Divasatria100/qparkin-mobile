@echo off
echo ========================================
echo Testing Booking to Payment Flow
echo ========================================
echo.

REM Test 1: Create booking and verify response includes id_booking
echo [TEST 1] Creating booking...
curl -X POST "http://localhost:8000/api/booking" ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE" ^
  -d "{\"id_parkiran\":1,\"id_kendaraan\":2,\"waktu_mulai\":\"2026-01-15T20:00:00\",\"durasi_booking\":1}"

echo.
echo.
echo ========================================
echo Test completed!
echo ========================================
echo.
echo EXPECTED RESPONSE FIELDS:
echo - success: true
echo - data.id_booking: should be present (same as id_transaksi)
echo - data.id_transaksi: booking ID
echo - data.id_mall: mall ID
echo - data.qr_code: QR code for entry
echo - data.nama_mall: mall name
echo - data.kode_slot: slot code
echo.
echo NEXT STEP:
echo Use the id_booking from response to test payment endpoint:
echo curl -X POST "http://localhost:8000/api/bookings/{id_booking}/payment/snap-token"
echo.
pause

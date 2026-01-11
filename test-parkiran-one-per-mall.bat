@echo off
REM Test script untuk validasi batasan 1 parkiran per mall
REM Tests: UI disabled button, redirect, dan API validation

echo ========================================
echo Testing Parkiran One Per Mall Limit
echo ========================================
echo.

REM Test 1: Check parkiran list page
echo [TEST 1] Testing parkiran list page...
echo URL: http://localhost:8000/admin/parkiran
echo Expected: Tombol "Tambah Parkiran" disabled jika sudah ada parkiran
echo.
pause

REM Test 2: Try to access create form directly (should redirect)
echo [TEST 2] Testing direct access to create form...
echo URL: http://localhost:8000/admin/parkiran/create
echo Expected: Redirect ke /admin/parkiran dengan pesan error
echo.
pause

REM Test 3: Try to submit via API (should return 400)
echo [TEST 3] Testing API submission...
curl -X POST "http://localhost:8000/admin/parkiran/store" ^
  -H "Content-Type: application/json" ^
  -H "Cookie: YOUR_SESSION_COOKIE" ^
  -d "{\"nama_parkiran\":\"Test Parkiran 2\",\"kode_parkiran\":\"TST2\",\"status\":\"Tersedia\",\"jumlah_lantai\":1,\"lantai\":[{\"nama\":\"Lantai 1\",\"jumlah_slot\":50,\"jenis_kendaraan\":\"Roda Empat\"}]}"
echo.
echo Expected Response:
echo {
echo   "success": false,
echo   "message": "Mall Anda sudah memiliki 1 parkiran..."
echo }
echo.
pause

echo ========================================
echo Test Instructions:
echo ========================================
echo.
echo 1. Login sebagai Admin Mall
echo 2. Pastikan mall sudah punya 1 parkiran
echo 3. Akses /admin/parkiran
echo 4. Verifikasi:
echo    - Tombol "Tambah Parkiran" disabled
echo    - Alert informasi muncul
echo    - Tooltip "Mall sudah memiliki 1 parkiran"
echo.
echo 5. Coba akses /admin/parkiran/create langsung
echo 6. Verifikasi:
echo    - Redirect ke /admin/parkiran
echo    - Flash message error muncul
echo.
echo 7. Test dengan mall yang belum punya parkiran
echo 8. Verifikasi:
echo    - Tombol "Tambah Parkiran" aktif
echo    - Tidak ada alert
echo    - Bisa akses form dan submit
echo.
pause

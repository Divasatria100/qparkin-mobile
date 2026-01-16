@echo off
echo ========================================
echo Lokasi Mall - Complete Fix Applied
echo ========================================
echo.

echo [Step 1] Clearing Laravel Cache...
cd qparkin_backend
call php artisan config:clear
call php artisan cache:clear
call php artisan view:clear
call php artisan route:clear
cd ..
echo [OK] Cache cleared
echo.

echo [Step 2] Verifying Files...
echo.

echo Checking layout admin...
findstr /C:"@stack('styles')" qparkin_backend\resources\views\layouts\admin.blade.php >nul
if %errorlevel% equ 0 (
    echo [OK] Layout supports @stack for styles
) else (
    echo [FAIL] Layout missing @stack for styles
)

findstr /C:"@stack('scripts')" qparkin_backend\resources\views\layouts\admin.blade.php >nul
if %errorlevel% equ 0 (
    echo [OK] Layout supports @stack for scripts
) else (
    echo [FAIL] Layout missing @stack for scripts
)
echo.

echo Checking lokasi-mall page...
findstr /C:"@push('styles')" qparkin_backend\resources\views\admin\lokasi-mall.blade.php >nul
if %errorlevel% equ 0 (
    echo [OK] Page uses @push for styles
) else (
    echo [FAIL] Page missing @push for styles
)

findstr /C:"@push('scripts')" qparkin_backend\resources\views\admin\lokasi-mall.blade.php >nul
if %errorlevel% equ 0 (
    echo [OK] Page uses @push for scripts
) else (
    echo [FAIL] Page missing @push for scripts
)
echo.

echo Checking CSS file...
if exist "qparkin_backend\public\css\lokasi-mall.css" (
    echo [OK] lokasi-mall.css exists
) else (
    echo [FAIL] lokasi-mall.css not found
)
echo.

echo Checking JS file...
if exist "qparkin_backend\public\js\lokasi-mall.js" (
    echo [OK] lokasi-mall.js exists
) else (
    echo [FAIL] lokasi-mall.js not found
)
echo.

echo ========================================
echo Fix Summary
echo ========================================
echo.
echo ROOT CAUSE FOUND:
echo - Layout admin.blade.php tidak mendukung @stack
echo - Halaman lokasi-mall.blade.php menggunakan @push
echo - Akibatnya: CSS dan JS tidak ter-load
echo.
echo FIX APPLIED:
echo - Tambahkan @stack('styles') di layout
echo - Tambahkan @stack('scripts') di layout
echo - Maintain backward compatibility dengan @yield
echo.
echo EXPECTED RESULT:
echo 1. CSS halaman muncul sempurna
echo 2. Loading indicator tampil
echo 3. Peta MapLibre GL muncul dalam 1-3 detik
echo 4. Tiles OpenStreetMap ter-load
echo 5. Interactive features bekerja
echo.
echo ========================================
echo Next Steps:
echo ========================================
echo.
echo 1. Run: php artisan serve
echo 2. Login as admin mall
echo 3. Open "Lokasi Mall" page
echo 4. Open DevTools (F12) - Network tab
echo 5. Verify assets loaded:
echo    - lokasi-mall.css (200 OK)
echo    - lokasi-mall.js (200 OK)
echo    - maplibre-gl.css (200 OK)
echo    - maplibre-gl.js (200 OK)
echo 6. Check Console for logs:
echo    [LokasiMall] Initializing...
echo    [LokasiMall] DOM Ready
echo    [LokasiMall] Map loaded
echo 7. Verify visual:
echo    - Page styling applied
echo    - Loading indicator visible
echo    - Map displays with tiles
echo    - Marker interactive
echo.
echo Documentation:
echo - LOKASI_MALL_COMPREHENSIVE_ANALYSIS_FIX.md
echo.
echo ========================================
pause

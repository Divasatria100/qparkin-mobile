@echo off
echo ========================================
echo Lokasi Mall - @yield/@section Fix
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
findstr /C:"@yield('styles')" qparkin_backend\resources\views\layouts\admin.blade.php >nul
if %errorlevel% equ 0 (
    echo [OK] Layout uses @yield for styles
) else (
    echo [FAIL] Layout missing @yield for styles
)

findstr /C:"@yield('scripts')" qparkin_backend\resources\views\layouts\admin.blade.php >nul
if %errorlevel% equ 0 (
    echo [OK] Layout uses @yield for scripts
) else (
    echo [FAIL] Layout missing @yield for scripts
)

findstr /C:"@stack" qparkin_backend\resources\views\layouts\admin.blade.php >nul
if %errorlevel% equ 0 (
    echo [WARN] Layout still has @stack directive
) else (
    echo [OK] Layout has no @stack directive
)
echo.

echo Checking lokasi-mall page...
findstr /C:"@section('styles')" qparkin_backend\resources\views\admin\lokasi-mall.blade.php >nul
if %errorlevel% equ 0 (
    echo [OK] Page uses @section for styles
) else (
    echo [FAIL] Page missing @section for styles
)

findstr /C:"@section('scripts')" qparkin_backend\resources\views\admin\lokasi-mall.blade.php >nul
if %errorlevel% equ 0 (
    echo [OK] Page uses @section for scripts
) else (
    echo [FAIL] Page missing @section for scripts
)

findstr /C:"@push" qparkin_backend\resources\views\admin\lokasi-mall.blade.php >nul
if %errorlevel% equ 0 (
    echo [WARN] Page still has @push directive
) else (
    echo [OK] Page has no @push directive
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
echo ERROR FOUND:
echo - Undefined property: Illuminate\View\Factory::$startPush
echo - Laravel version tidak mendukung @push/@stack
echo.
echo ROOT CAUSE:
echo - Layout menggunakan @stack (tidak kompatibel)
echo - Halaman menggunakan @push (tidak kompatibel)
echo.
echo FIX APPLIED:
echo - Hapus semua @stack dari layout
echo - Hapus semua @push dari halaman
echo - Gunakan @yield di layout
echo - Gunakan @section di halaman
echo.
echo COMPATIBILITY:
echo - @yield/@section kompatibel dengan SEMUA versi Laravel
echo - No more errors!
echo.
echo EXPECTED RESULT:
echo 1. No error: Undefined property
echo 2. CSS halaman muncul sempurna
echo 3. Loading indicator tampil
echo 4. Peta MapLibre GL muncul dalam 1-3 detik
echo 5. Tiles OpenStreetMap ter-load
echo 6. Interactive features bekerja
echo.
echo ========================================
echo Next Steps:
echo ========================================
echo.
echo 1. Run: php artisan serve
echo 2. Login as admin mall
echo 3. Open "Lokasi Mall" page
echo 4. Check Console (F12):
echo    - Should NOT see: Undefined property error
echo    - Should see: [LokasiMall] logs
echo 5. Check Network tab:
echo    - lokasi-mall.css (200 OK)
echo    - lokasi-mall.js (200 OK)
echo    - maplibre-gl.css (200 OK)
echo    - maplibre-gl.js (200 OK)
echo 6. Check Visual:
echo    - Page styling applied
echo    - Loading indicator visible
echo    - Map displays with tiles
echo    - Marker interactive
echo.
echo Documentation:
echo - LOKASI_MALL_YIELD_SECTION_FIX.md
echo.
echo ========================================
pause

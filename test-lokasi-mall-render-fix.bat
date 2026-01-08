@echo off
echo ========================================
echo Lokasi Mall - Container Render Fix Test
echo ========================================
echo.

echo [1/6] Checking map container CSS...
findstr /C:"#map" qparkin_backend\public\css\lokasi-mall.css | findstr /C:"height: 500px" >nul
if %errorlevel% equ 0 (
    echo [OK] Map container has explicit height
) else (
    echo [FAIL] Map container height not found
)
echo.

echo [2/6] Checking parent container min-height...
findstr /C:".card-body" qparkin_backend\public\css\lokasi-mall.css | findstr /C:"min-height" >nul
if %errorlevel% equ 0 (
    echo [OK] Parent container has min-height
) else (
    echo [FAIL] Parent container min-height not found
)
echo.

echo [3/6] Checking loading indicator display...
findstr /C:".map-loading" qparkin_backend\public\css\lokasi-mall.css | findstr /C:"display: block" >nul
if %errorlevel% equ 0 (
    echo [OK] Loading indicator has explicit display
) else (
    echo [FAIL] Loading indicator display not found
)
echo.

echo [4/6] Checking container validation in JS...
findstr /C:"getBoundingClientRect" qparkin_backend\public\js\lokasi-mall.js >nul
if %errorlevel% equ 0 (
    echo [OK] Container validation with getBoundingClientRect found
) else (
    echo [FAIL] Container validation not found
)
echo.

echo [5/6] Checking map.resize() call...
findstr /C:"map.resize()" qparkin_backend\public\js\lokasi-mall.js >nul
if %errorlevel% equ 0 (
    echo [OK] map.resize() call found after load
) else (
    echo [FAIL] map.resize() call not found
)
echo.

echo [6/6] Checking tile loading monitoring...
findstr /C:"map.on('data'" qparkin_backend\public\js\lokasi-mall.js >nul
if %errorlevel% equ 0 (
    echo [OK] Tile loading monitoring found
) else (
    echo [FAIL] Tile loading monitoring not found
)
echo.

echo ========================================
echo Fix Summary
echo ========================================
echo.
echo CSS Fixes:
echo - Parent container: min-height 540px
echo - Loading indicator: display block
echo.
echo JavaScript Fixes:
echo - Container validation with getBoundingClientRect
echo - map.resize() after load event
echo - Tile loading monitoring
echo - Extended timeout to 10 seconds
echo.
echo Expected Result:
echo 1. Loading indicator muncul saat memuat
echo 2. Peta tampil sempurna setelah 1-3 detik
echo 3. Tiles ditampilkan dengan benar
echo 4. Interactive features bekerja
echo.
echo Documentation:
echo - LOKASI_MALL_CONTAINER_RENDER_FIX.md
echo.
echo ========================================
echo Test Complete - Ready to Test in Browser
echo ========================================
echo.
echo Next Steps:
echo 1. Run: php artisan serve
echo 2. Login as admin mall
echo 3. Open "Lokasi Mall" page
echo 4. Check browser console for logs
echo 5. Verify map displays correctly
echo.
pause

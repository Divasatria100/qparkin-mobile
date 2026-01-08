@echo off
echo ========================================
echo Lokasi Mall - Rebuild Verification
echo ========================================
echo.

echo Checking new implementation files...
echo.

echo [1/3] Checking HTML (Blade template)...
if exist "qparkin_backend\resources\views\admin\lokasi-mall.blade.php" (
    echo [OK] HTML file exists
    findstr /C:"mapContainer" qparkin_backend\resources\views\admin\lokasi-mall.blade.php >nul
    if !errorlevel! equ 0 (
        echo [OK] Using new ID: mapContainer
    )
) else (
    echo [FAIL] HTML file not found
)
echo.

echo [2/3] Checking CSS...
if exist "qparkin_backend\public\css\lokasi-mall.css" (
    echo [OK] CSS file exists
    findstr /C:"map-card-body" qparkin_backend\public\css\lokasi-mall.css >nul
    if !errorlevel! equ 0 (
        echo [OK] New CSS structure found
    )
) else (
    echo [FAIL] CSS file not found
)
echo.

echo [3/3] Checking JavaScript...
if exist "qparkin_backend\public\js\lokasi-mall.js" (
    echo [OK] JavaScript file exists
    findstr /C:"LokasiMall" qparkin_backend\public\js\lokasi-mall.js >nul
    if !errorlevel! equ 0 (
        echo [OK] New implementation found
    )
) else (
    echo [FAIL] JavaScript file not found
)
echo.

echo ========================================
echo Rebuild Summary
echo ========================================
echo.
echo New Implementation:
echo - HTML: Clean structure with mapContainer ID
echo - CSS: Fixed height containers, loading overlay
echo - JS: IIFE encapsulation, clean event handlers
echo.
echo Key Features:
echo - MapLibre GL JS v3.6.2
echo - OpenStreetMap tiles (FREE)
echo - Loading indicator with auto-hide
echo - Interactive marker (click, drag)
echo - Geolocation support
echo - Save location via AJAX
echo.
echo Documentation:
echo - LOKASI_MALL_REBUILD_COMPLETE.md
echo.
echo ========================================
echo Next Steps:
echo ========================================
echo.
echo 1. Run: php artisan serve
echo 2. Login as admin mall
echo 3. Open "Lokasi Mall" page
echo 4. Verify:
echo    - Loading indicator muncul
echo    - Peta tampil dalam 1-3 detik
echo    - Tiles OpenStreetMap muncul
echo    - Klik peta untuk add marker
echo    - Drag marker untuk update koordinat
echo.
echo ========================================
pause

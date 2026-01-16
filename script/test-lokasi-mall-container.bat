@echo off
echo ========================================
echo Lokasi Mall - Container Fix Test
echo ========================================
echo.
echo PERBAIKAN YANG DITERAPKAN:
echo 1. Loading indicator dipindahkan KELUAR dari container map
echo 2. Map container bersih tanpa children
echo 3. Ditambahkan immediate invalidateSize() setelah map creation
echo 4. Parent container memiliki position: relative
echo.
echo ========================================
echo CARA TESTING:
echo ========================================
echo.
echo 1. Clear browser cache (Ctrl + Shift + Delete)
echo 2. Buka halaman: /admin/lokasi-mall
echo 3. Buka console (F12)
echo.
echo ========================================
echo EXPECTED CONSOLE OUTPUT:
echo ========================================
echo [Lokasi Mall] Script loaded
echo [Lokasi Mall] Container ready, initializing...
echo [Lokasi Mall] Initializing map...
echo [Lokasi Mall] Leaflet loaded
echo [Lokasi Mall] Container found: 800x500px
echo [Lokasi Mall] Map object created
echo [Lokasi Mall] Initial size calculated  ^<-- BARU!
echo [Lokasi Mall] Tile layer added
echo [Lokasi Mall] Map is ready
echo [Lokasi Mall] Tiles are being requested...
echo [Lokasi Mall] First tile loaded
echo [Lokasi Mall] All tiles loaded successfully
echo [Lokasi Mall] Loading indicator hidden
echo [Lokasi Mall] Final map size recalculated  ^<-- BARU!
echo.
echo ========================================
echo VISUAL CHECK:
echo ========================================
echo [ ] Loading indicator muncul di tengah
echo [ ] Loading hilang dalam 1-5 detik
echo [ ] Tiles tampil sempurna (tidak blank)
echo [ ] Dapat klik pada map untuk place marker
echo [ ] Marker dapat di-drag
echo [ ] Zoom controls berfungsi
echo.
echo ========================================
echo TROUBLESHOOTING:
echo ========================================
echo.
echo Jika masih stuck:
echo 1. Check container height di console:
echo    document.getElementById('map').offsetHeight
echo    ^(harus return 500^)
echo.
echo 2. Check parent positioning:
echo    getComputedStyle(document.querySelector('.card-body')).position
echo    ^(harus return 'relative'^)
echo.
echo 3. Check loading position:
echo    getComputedStyle(document.getElementById('mapLoading')).position
echo    ^(harus return 'absolute'^)
echo.
echo 4. Check map has no children:
echo    document.getElementById('map').children.length
echo    ^(harus return 0 atau hanya leaflet elements^)
echo.
pause

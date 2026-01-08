@echo off
echo ========================================
echo Lokasi Mall - MapLibre GL JS Test
echo ========================================
echo.
echo MIGRASI: Leaflet ^-^> MapLibre GL JS
echo.
echo ========================================
echo KEUNGGULAN MAPLIBRE GL JS:
echo ========================================
echo [+] 100%% Gratis - Tidak ada API key
echo [+] WebGL Rendering - Performa lebih baik
echo [+] Smooth Animations - flyTo() effect
echo [+] Custom Marker - HTML element dengan gradient
echo [+] Open Source - Fork dari Mapbox GL JS
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
echo [Lokasi Mall] MapLibre GL loaded (v3.6.2)
echo [Lokasi Mall] Container found: 800x500px
echo [Lokasi Mall] Map object created
echo [Lokasi Mall] Initialization complete
echo [Lokasi Mall] Map loaded successfully
echo [Lokasi Mall] Loading indicator hidden
echo [Lokasi Mall] Initial marker added
echo.
echo ========================================
echo VISUAL CHECK:
echo ========================================
echo [ ] Map tampil dengan tiles OpenStreetMap
echo [ ] Loading indicator hilang dalam 1-5 detik
echo [ ] Marker custom (bulat ungu gradient) tampil
echo [ ] Marker dapat di-drag
echo [ ] Klik pada map menambahkan marker
echo [ ] Koordinat update di sidebar
echo [ ] Smooth animation saat "Gunakan Lokasi Saat Ini"
echo [ ] Zoom controls berfungsi
echo.
echo ========================================
echo PERBEDAAN KUNCI:
echo ========================================
echo.
echo KOORDINAT FORMAT:
echo   Leaflet:        [lat, lng]
echo   MapLibre GL JS: [lng, lat]  ^<-- PENTING!
echo.
echo NAVIGATION:
echo   Leaflet:        map.setView([lat, lng])
echo   MapLibre GL JS: map.flyTo({ center: [lng, lat] })
echo.
echo MARKER:
echo   Leaflet:        L.marker([lat, lng])
echo   MapLibre GL JS: new maplibregl.Marker().setLngLat([lng, lat])
echo.
echo ========================================
echo TROUBLESHOOTING:
echo ========================================
echo.
echo Jika map tidak tampil:
echo.
echo 1. Check MapLibre GL loaded:
echo    typeof maplibregl
echo    ^(harus return 'object'^)
echo.
echo 2. Check container height:
echo    document.getElementById('map').offsetHeight
echo    ^(harus return 500^)
echo.
echo 3. Check console untuk errors
echo.
echo 4. Verify CDN loaded:
echo    - maplibre-gl.css
echo    - maplibre-gl.js
echo.
echo ========================================
echo BIAYA:
echo ========================================
echo MapLibre GL JS: FREE (Open Source)
echo OpenStreetMap:  FREE (Fair use policy)
echo API Key:        NOT REQUIRED
echo Billing:        NONE
echo.
echo ========================================
echo FILES MODIFIED:
echo ========================================
echo 1. lokasi-mall.blade.php - CDN links
echo 2. lokasi-mall.css       - MapLibre styles
echo 3. lokasi-mall.js        - Complete rewrite
echo.
pause

# Troubleshooting - Fitur Lokasi Mall

## 🐛 Masalah: Peta Tidak Tampil

### Kemungkinan Penyebab & Solusi:

#### 1. Leaflet CSS/JS Tidak Ter-load

**Gejala:**
- Area peta kosong/abu-abu
- Console error: "L is not defined"

**Solusi:**
```bash
# Cek browser console (F12) untuk error
# Pastikan file ter-load:
# - https://unpkg.com/leaflet@1.9.4/dist/leaflet.css
# - https://unpkg.com/leaflet@1.9.4/dist/leaflet.js
```

**Fix:**
- Pastikan koneksi internet aktif
- Coba hard refresh (Ctrl+Shift+R)
- Cek apakah CDN unpkg.com accessible

#### 2. Map Container Tidak Memiliki Height

**Gejala:**
- Peta tidak tampil sama sekali
- Console error: "Map container not found"

**Solusi:**
```css
/* Pastikan CSS ini ada */
#map {
    height: 500px !important;
    width: 100% !important;
}
```

**Fix:**
- Cek file `public/css/lokasi-mall.css` sudah ada
- Pastikan CSS ter-load di halaman
- Inspect element untuk verifikasi height

#### 3. Layout Admin Conflict

**Gejala:**
- Peta tertutup oleh elemen lain
- Z-index issue

**Solusi:**
```css
#map {
    position: relative;
    z-index: 1;
}
```

**Fix:**
- Cek CSS admin layout
- Pastikan tidak ada overflow: hidden di parent
- Verifikasi z-index tidak conflict

#### 4. JavaScript Error

**Gejala:**
- Console menunjukkan error
- Map tidak initialize

**Solusi:**
```javascript
// Cek console untuk error seperti:
// - "Cannot read property 'map' of undefined"
// - "L.map is not a function"
```

**Fix:**
- Pastikan Leaflet.js loaded sebelum script custom
- Cek urutan loading script
- Verifikasi DOMContentLoaded event

## 🔍 Debugging Steps

### Step 1: Cek Browser Console

```javascript
// Buka console (F12) dan ketik:
console.log(typeof L); // Should return "object"
console.log(document.getElementById('map')); // Should return element
```

### Step 2: Verifikasi File Ter-load

```bash
# Cek Network tab di browser DevTools
# Pastikan status 200 OK untuk:
- leaflet.css
- leaflet.js
- lokasi-mall.css
```

### Step 3: Test Manual Initialization

```javascript
// Di console, coba:
var testMap = L.map('map').setView([-6.2088, 106.8456], 13);
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(testMap);
```

### Step 4: Cek Element Dimensions

```javascript
// Di console:
var mapEl = document.getElementById('map');
console.log('Width:', mapEl.offsetWidth);
console.log('Height:', mapEl.offsetHeight);
// Height harus > 0
```

## 🛠️ Quick Fixes

### Fix 1: Force Reload Assets

```bash
# Clear browser cache
Ctrl+Shift+Delete

# Hard refresh
Ctrl+Shift+R

# Or add version query string
<link href="{{ asset('css/lokasi-mall.css?v=2') }}">
```

### Fix 2: Use Local Leaflet Files

Download Leaflet dan simpan di `public/vendor/leaflet/`:

```html
<link rel="stylesheet" href="{{ asset('vendor/leaflet/leaflet.css') }}">
<script src="{{ asset('vendor/leaflet/leaflet.js') }}"></script>
```

### Fix 3: Add Fallback CDN

```html
<!-- Primary CDN -->
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

<!-- Fallback -->
<script>
if (typeof L === 'undefined') {
    document.write('<script src="https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/leaflet.js"><\/script>');
}
</script>
```

### Fix 4: Delay Map Initialization

```javascript
// Tunggu semua resource loaded
window.addEventListener('load', function() {
    setTimeout(function() {
        // Initialize map here
    }, 500);
});
```

## 📋 Checklist Verifikasi

- [ ] Koneksi internet aktif
- [ ] Browser console tidak ada error
- [ ] Leaflet CSS ter-load (cek Network tab)
- [ ] Leaflet JS ter-load (cek Network tab)
- [ ] Element #map ada di DOM
- [ ] Element #map memiliki height > 0
- [ ] Tidak ada CSS conflict
- [ ] JavaScript tidak ada syntax error
- [ ] CSRF token valid
- [ ] User sudah login sebagai Admin Mall

## 🔧 Advanced Debugging

### Enable Verbose Logging

Tambahkan di script:

```javascript
L.Map.addInitHook(function () {
    console.log('Map initialized:', this);
});

L.TileLayer.addInitHook(function () {
    console.log('TileLayer initialized:', this);
});
```

### Check Tile Loading

```javascript
map.on('tileload', function(e) {
    console.log('Tile loaded:', e.coords);
});

map.on('tileerror', function(e) {
    console.error('Tile error:', e);
});
```

### Monitor Map Events

```javascript
map.on('load', function() {
    console.log('Map loaded successfully');
});

map.on('error', function(e) {
    console.error('Map error:', e);
});
```

## 🌐 Browser Compatibility

### Supported Browsers:
- ✅ Chrome 90+
- ✅ Firefox 88+
- ✅ Safari 14+
- ✅ Edge 90+

### Known Issues:
- ❌ IE 11 (not supported by Leaflet 1.9+)
- ⚠️ Safari < 14 (partial support)

## 📞 Still Not Working?

### Collect Debug Info:

```javascript
// Run in console and copy output:
console.log({
    leafletLoaded: typeof L !== 'undefined',
    mapElement: !!document.getElementById('map'),
    mapDimensions: {
        width: document.getElementById('map')?.offsetWidth,
        height: document.getElementById('map')?.offsetHeight
    },
    browser: navigator.userAgent,
    errors: window.errors || []
});
```

### Alternative: Use Google Maps

Jika Leaflet tetap bermasalah, bisa switch ke Google Maps:

```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY"></script>
<script>
function initMap() {
    var map = new google.maps.Map(document.getElementById('map'), {
        center: {lat: -6.2088, lng: 106.8456},
        zoom: 15
    });
}
</script>
```

## 📝 Common Error Messages

### "Cannot read property 'map' of undefined"
**Cause:** Leaflet not loaded
**Fix:** Check script loading order

### "Map container not found"
**Cause:** Element #map doesn't exist
**Fix:** Check HTML structure

### "Map container is already initialized"
**Cause:** Trying to initialize map twice
**Fix:** Check for duplicate initialization code

### "Tiles not loading"
**Cause:** Network issue or wrong tile URL
**Fix:** Check internet connection, try different tile provider

## 🎯 Prevention Tips

1. **Always check console** before reporting issues
2. **Test in incognito mode** to rule out extension conflicts
3. **Use browser DevTools** Network tab to verify resource loading
4. **Keep Leaflet updated** to latest stable version
5. **Test on multiple browsers** for compatibility

---

**Need more help?** Check Laravel logs: `storage/logs/laravel.log`

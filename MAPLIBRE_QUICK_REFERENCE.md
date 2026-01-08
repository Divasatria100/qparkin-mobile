# MapLibre GL JS - Quick Reference

## 🚀 Migrasi dari Leaflet

### Koordinat Format ⚠️ PENTING!

```javascript
// Leaflet: [lat, lng]
[lat, lng]

// MapLibre GL JS: [lng, lat]
[lng, lat]
```

## 📦 Inisialisasi

### Leaflet
```javascript
const map = L.map('map', {
    center: [lat, lng],
    zoom: 15
});

L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '...'
}).addTo(map);
```

### MapLibre GL JS
```javascript
const map = new maplibregl.Map({
    container: 'map',
    style: {
        version: 8,
        sources: {
            'osm': {
                type: 'raster',
                tiles: ['https://a.tile.openstreetmap.org/{z}/{x}/{y}.png'],
                tileSize: 256
            }
        },
        layers: [{
            id: 'osm-layer',
            type: 'raster',
            source: 'osm'
        }]
    },
    center: [lng, lat], // ⚠️ [lng, lat]
    zoom: 15
});
```

## 📍 Marker

### Leaflet
```javascript
const marker = L.marker([lat, lng], {
    draggable: true
}).addTo(map);

marker.bindPopup('Hello').openPopup();

marker.on('dragend', function() {
    const pos = marker.getLatLng();
    console.log(pos.lat, pos.lng);
});
```

### MapLibre GL JS
```javascript
const el = document.createElement('div');
el.className = 'custom-marker';

const marker = new maplibregl.Marker({
    element: el,
    draggable: true
})
.setLngLat([lng, lat]) // ⚠️ [lng, lat]
.addTo(map);

const popup = new maplibregl.Popup()
    .setHTML('Hello');
marker.setPopup(popup);

marker.on('dragend', function() {
    const pos = marker.getLngLat();
    console.log(pos.lat, pos.lng);
});
```

## 🗺️ Navigation

### Leaflet
```javascript
map.setView([lat, lng], 15);
```

### MapLibre GL JS
```javascript
// Instant
map.jumpTo({ center: [lng, lat], zoom: 15 });

// Animated (recommended)
map.flyTo({
    center: [lng, lat],
    zoom: 15,
    essential: true
});
```

## 🎯 Events

### Leaflet
```javascript
map.on('click', function(e) {
    console.log(e.latlng.lat, e.latlng.lng);
});

tileLayer.on('load', function() {
    console.log('Tiles loaded');
});
```

### MapLibre GL JS
```javascript
map.on('click', function(e) {
    console.log(e.lngLat.lat, e.lngLat.lng);
});

map.on('load', function() {
    console.log('Map loaded');
});
```

## 🎨 Custom Marker CSS

```css
.custom-marker {
    width: 30px;
    height: 30px;
    border-radius: 50%;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border: 3px solid white;
    box-shadow: 0 2px 8px rgba(0,0,0,0.3);
    cursor: pointer;
    transition: transform 0.2s;
}

.custom-marker:hover {
    transform: scale(1.1);
}
```

## 📊 Method Comparison

| Leaflet | MapLibre GL JS |
|---------|----------------|
| `L.map()` | `new maplibregl.Map()` |
| `L.marker()` | `new maplibregl.Marker()` |
| `setLatLng()` | `setLngLat()` |
| `getLatLng()` | `getLngLat()` |
| `setView()` | `flyTo()` / `jumpTo()` |
| `bindPopup()` | `setPopup()` |
| `e.latlng` | `e.lngLat` |

## 🔧 Common Patterns

### Get Current View
```javascript
// Leaflet
const center = map.getCenter();
const zoom = map.getZoom();

// MapLibre GL JS
const center = map.getCenter();
const zoom = map.getZoom();
```

### Set Bounds
```javascript
// Leaflet
map.fitBounds([[lat1, lng1], [lat2, lng2]]);

// MapLibre GL JS
map.fitBounds([[lng1, lat1], [lng2, lat2]]);
```

### Add Control
```javascript
// Leaflet
L.control.zoom({ position: 'topright' }).addTo(map);

// MapLibre GL JS
map.addControl(new maplibregl.NavigationControl(), 'top-right');
```

## 💡 Tips

### 1. Koordinat Format
Selalu ingat: MapLibre GL JS menggunakan `[lng, lat]` bukan `[lat, lng]`

### 2. Custom Marker
Gunakan HTML element untuk marker yang lebih fleksibel:
```javascript
const el = document.createElement('div');
el.className = 'my-marker';
el.innerHTML = '<img src="icon.png">';
```

### 3. Smooth Animation
Gunakan `flyTo()` untuk UX yang lebih baik:
```javascript
map.flyTo({
    center: [lng, lat],
    zoom: 15,
    speed: 1.2,
    curve: 1,
    essential: true
});
```

### 4. Loading State
```javascript
let loaded = false;

map.on('load', function() {
    loaded = true;
    hideLoading();
});

// Fallback
setTimeout(() => {
    if (!loaded) hideLoading();
}, 5000);
```

## 🆓 Biaya

- **MapLibre GL JS:** 100% Gratis (Open Source)
- **OpenStreetMap Tiles:** Gratis (Fair use policy)
- **API Key:** Tidak diperlukan
- **Billing:** Tidak ada

## 📚 Resources

- **Docs:** https://maplibre.org/maplibre-gl-js-docs/
- **Examples:** https://maplibre.org/maplibre-gl-js-docs/example/
- **GitHub:** https://github.com/maplibre/maplibre-gl-js
- **CDN:** https://unpkg.com/maplibre-gl@3.6.2/

---

**Quick Tip:** Jika migrasi dari Leaflet, cari-replace semua `[lat, lng]` menjadi `[lng, lat]`!

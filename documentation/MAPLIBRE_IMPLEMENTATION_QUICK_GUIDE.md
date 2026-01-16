# MapLibre GL JS - Quick Implementation Guide

## 🚀 Quick Start (3 Steps)

### Step 1: Add MapLibre GL JS to HTML
```html
<!-- In <head> or before </body> -->
<link rel="stylesheet" href="https://unpkg.com/maplibre-gl@3.6.2/dist/maplibre-gl.css" />
<script src="https://unpkg.com/maplibre-gl@3.6.2/dist/maplibre-gl.js"></script>
```

### Step 2: Create Map Container with CSS
```html
<div id="map"></div>
```

```css
#map {
    height: 500px !important;
    width: 100% !important;
}
```

### Step 3: Initialize Map with FREE OpenStreetMap Tiles
```javascript
const map = new maplibregl.Map({
    container: 'map',
    style: {
        version: 8,
        sources: {
            'osm': {
                type: 'raster',
                tiles: [
                    'https://a.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    'https://b.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    'https://c.tile.openstreetmap.org/{z}/{x}/{y}.png'
                ],
                tileSize: 256,
                attribution: '© OpenStreetMap contributors'
            }
        },
        layers: [{
            id: 'osm',
            type: 'raster',
            source: 'osm'
        }]
    },
    center: [106.8456, -6.2088], // [lng, lat] - Jakarta
    zoom: 15
});
```

**That's it! No API key needed. 100% FREE.** ✅

---

## 📦 Complete Example with Loading Indicator

### HTML
```html
<div style="position: relative;">
    <!-- Loading Indicator -->
    <div id="mapLoading" style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); z-index: 1000;">
        <p>Memuat peta...</p>
    </div>
    
    <!-- Map Container -->
    <div id="map" style="height: 500px; width: 100%;"></div>
</div>

<link rel="stylesheet" href="https://unpkg.com/maplibre-gl@3.6.2/dist/maplibre-gl.css" />
<script src="https://unpkg.com/maplibre-gl@3.6.2/dist/maplibre-gl.js"></script>
```

### JavaScript
```javascript
document.addEventListener('DOMContentLoaded', function() {
    const loadingEl = document.getElementById('mapLoading');
    
    // Create map
    const map = new maplibregl.Map({
        container: 'map',
        style: {
            version: 8,
            sources: {
                'osm': {
                    type: 'raster',
                    tiles: [
                        'https://a.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        'https://b.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        'https://c.tile.openstreetmap.org/{z}/{x}/{y}.png'
                    ],
                    tileSize: 256
                }
            },
            layers: [{
                id: 'osm',
                type: 'raster',
                source: 'osm'
            }]
        },
        center: [106.8456, -6.2088],
        zoom: 15
    });
    
    // Hide loading when map is ready
    map.on('load', function() {
        loadingEl.style.display = 'none';
        console.log('Map loaded!');
    });
    
    // Error handling
    map.on('error', function(e) {
        console.error('Map error:', e);
        loadingEl.innerHTML = '<p style="color: red;">Error loading map</p>';
    });
});
```

---

## 🎯 Common Features

### 1. Add Marker
```javascript
const marker = new maplibregl.Marker()
    .setLngLat([106.8456, -6.2088])
    .addTo(map);
```

### 2. Add Popup
```javascript
const popup = new maplibregl.Popup()
    .setLngLat([106.8456, -6.2088])
    .setHTML('<h3>Jakarta</h3><p>Capital of Indonesia</p>')
    .addTo(map);
```

### 3. Marker with Popup
```javascript
const marker = new maplibregl.Marker()
    .setLngLat([106.8456, -6.2088])
    .setPopup(
        new maplibregl.Popup().setHTML('<b>Jakarta</b>')
    )
    .addTo(map);
```

### 4. Custom Marker
```javascript
const el = document.createElement('div');
el.className = 'custom-marker';
el.style.width = '30px';
el.style.height = '30px';
el.style.borderRadius = '50%';
el.style.background = 'red';

const marker = new maplibregl.Marker({ element: el })
    .setLngLat([106.8456, -6.2088])
    .addTo(map);
```

### 5. Draggable Marker
```javascript
const marker = new maplibregl.Marker({ draggable: true })
    .setLngLat([106.8456, -6.2088])
    .addTo(map);

marker.on('dragend', function() {
    const lngLat = marker.getLngLat();
    console.log('New position:', lngLat.lat, lngLat.lng);
});
```

### 6. Click Event
```javascript
map.on('click', function(e) {
    console.log('Clicked at:', e.lngLat.lat, e.lngLat.lng);
    
    // Add marker on click
    new maplibregl.Marker()
        .setLngLat([e.lngLat.lng, e.lngLat.lat])
        .addTo(map);
});
```

### 7. Fly to Location
```javascript
map.flyTo({
    center: [106.8456, -6.2088],
    zoom: 16,
    essential: true
});
```

### 8. Navigation Controls (Zoom +/-)
```javascript
map.addControl(new maplibregl.NavigationControl(), 'top-right');
```

### 9. Fullscreen Control
```javascript
map.addControl(new maplibregl.FullscreenControl(), 'top-right');
```

### 10. Geolocation
```javascript
navigator.geolocation.getCurrentPosition(function(position) {
    const lat = position.coords.latitude;
    const lng = position.coords.longitude;
    
    map.flyTo({ center: [lng, lat], zoom: 15 });
    
    new maplibregl.Marker()
        .setLngLat([lng, lat])
        .addTo(map);
});
```

---

## 🎨 Styling Tips

### Map Container (CRITICAL!)
```css
#map {
    height: 500px !important;  /* Must have explicit height */
    width: 100% !important;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}
```

### Custom Marker
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

### Loading Overlay
```css
.map-loading {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    z-index: 1000;
    background: white;
    padding: 20px 30px;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}
```

---

## ⚠️ Common Pitfalls

### ❌ Container has no height
```css
/* WRONG - Map won't display */
#map {
    width: 100%;
}
```

```css
/* CORRECT - Must have explicit height */
#map {
    height: 500px !important;
    width: 100%;
}
```

### ❌ Wrong coordinate order
```javascript
// WRONG - MapLibre uses [lng, lat]
map.setCenter([-6.2088, 106.8456]);
```

```javascript
// CORRECT - [longitude, latitude]
map.setCenter([106.8456, -6.2088]);
```

### ❌ Initializing before DOM ready
```javascript
// WRONG - Map container might not exist yet
const map = new maplibregl.Map({ container: 'map' });
```

```javascript
// CORRECT - Wait for DOM
document.addEventListener('DOMContentLoaded', function() {
    const map = new maplibregl.Map({ container: 'map' });
});
```

---

## 🆚 MapLibre vs Leaflet

| Feature | Leaflet | MapLibre GL JS |
|---------|---------|----------------|
| **Rendering** | Canvas/SVG | WebGL |
| **Performance** | Good | Excellent |
| **3D Support** | ❌ | ✅ |
| **Vector Tiles** | Plugin needed | Native |
| **File Size** | ~40KB | ~200KB |
| **Learning Curve** | Easy | Moderate |
| **Best For** | Simple maps | Advanced maps |

---

## 🌍 Free Tile Providers

### 1. OpenStreetMap (Default)
```javascript
tiles: [
    'https://a.tile.openstreetmap.org/{z}/{x}/{y}.png',
    'https://b.tile.openstreetmap.org/{z}/{x}/{y}.png',
    'https://c.tile.openstreetmap.org/{z}/{x}/{y}.png'
]
```

### 2. OpenStreetMap HOT (Humanitarian)
```javascript
tiles: [
    'https://a.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png'
]
```

### 3. CartoDB Positron (Light theme)
```javascript
tiles: [
    'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png'
]
```

### 4. CartoDB Dark Matter (Dark theme)
```javascript
tiles: [
    'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
]
```

**All FREE, no API key required!** ✅

---

## 📚 Resources

- **Official Docs**: https://maplibre.org/maplibre-gl-js/docs/
- **Examples**: https://maplibre.org/maplibre-gl-js/docs/examples/
- **API Reference**: https://maplibre.org/maplibre-gl-js/docs/API/
- **GitHub**: https://github.com/maplibre/maplibre-gl-js

---

## ✅ Checklist for Production

- [ ] MapLibre GL JS script loaded from CDN
- [ ] Map container has explicit height in CSS
- [ ] Loading indicator implemented
- [ ] Error handling added
- [ ] Responsive design tested
- [ ] Mobile compatibility checked
- [ ] Attribution included (OpenStreetMap)
- [ ] Console logs removed (or use production mode)

---

**Happy Mapping! 🗺️**

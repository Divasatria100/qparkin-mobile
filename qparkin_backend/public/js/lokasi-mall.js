/**
 * Lokasi Mall - Clean & Minimal Implementation
 * MapLibre GL JS with OpenStreetMap (Free, No API Key)
 */

(function() {
    'use strict';
    
    console.log('[LokasiMall] Initializing...');
    
    // State
    let map = null;
    let marker = null;
    let currentLat = null;
    let currentLng = null;
    
    // DOM Elements
    let mapContainer = null;
    let loadingOverlay = null;
    let latInput = null;
    let lngInput = null;
    let saveBtn = null;
    let geolocateBtn = null;
    let statusContainer = null;
    
    // Config
    let mallName = '';
    let hasCoords = false;
    let updateUrl = '';
    
    /**
     * Initialize when DOM is ready
     */
    function init() {
        console.log('[LokasiMall] DOM Ready');
        
        // Get DOM elements
        mapContainer = document.getElementById('mapContainer');
        loadingOverlay = document.getElementById('mapLoading');
        latInput = document.getElementById('latitudeInput');
        lngInput = document.getElementById('longitudeInput');
        saveBtn = document.getElementById('saveBtn');
        geolocateBtn = document.getElementById('geolocateBtn');
        statusContainer = document.getElementById('statusContainer');
        
        if (!mapContainer) {
            console.error('[LokasiMall] Map container not found!');
            return;
        }
        
        // Get config from data attributes
        currentLat = parseFloat(mapContainer.dataset.lat) || -6.2088;
        currentLng = parseFloat(mapContainer.dataset.lng) || 106.8456;
        mallName = mapContainer.dataset.mallName || 'Mall';
        hasCoords = mapContainer.dataset.hasCoords === 'true';
        updateUrl = mapContainer.dataset.updateUrl || '';
        
        console.log('[LokasiMall] Config:', {
            lat: currentLat,
            lng: currentLng,
            mallName: mallName,
            hasCoords: hasCoords
        });
        
        // Attach event listeners
        if (saveBtn) saveBtn.addEventListener('click', handleSave);
        if (geolocateBtn) geolocateBtn.addEventListener('click', handleGeolocate);
        
        // Wait for container to be visible, then init map
        waitForContainer();
    }
    
    /**
     * Wait for container to have valid dimensions
     */
    function waitForContainer() {
        const rect = mapContainer.getBoundingClientRect();
        
        if (rect.width > 0 && rect.height > 0) {
            console.log('[LokasiMall] Container ready:', rect.width + 'x' + rect.height);
            initMap();
        } else {
            console.log('[LokasiMall] Waiting for container...');
            setTimeout(waitForContainer, 100);
        }
    }
    
    /**
     * Initialize MapLibre GL map
     */
    function initMap() {
        // Check MapLibre GL loaded
        if (typeof maplibregl === 'undefined') {
            console.error('[LokasiMall] MapLibre GL not loaded!');
            showError('MapLibre GL library tidak ter-load');
            return;
        }
        
        console.log('[LokasiMall] Creating map...');
        
        try {
            // Create map
            map = new maplibregl.Map({
                container: 'mapContainer',
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
                        id: 'osm-layer',
                        type: 'raster',
                        source: 'osm',
                        minzoom: 0,
                        maxzoom: 19
                    }]
                },
                center: [currentLng, currentLat],
                zoom: 15
            });
            
            console.log('[LokasiMall] Map created');
            
            // Map load event
            map.on('load', function() {
                console.log('[LokasiMall] Map loaded');
                
                // Force resize
                setTimeout(function() {
                    map.resize();
                    console.log('[LokasiMall] Map resized');
                }, 100);
                
                // Hide loading
                hideLoading();
                
                // Add marker if coords exist
                if (hasCoords) {
                    addMarker(currentLng, currentLat);
                    console.log('[LokasiMall] Initial marker added');
                }
            });
            
            // Click event
            map.on('click', function(e) {
                const lng = e.lngLat.lng;
                const lat = e.lngLat.lat;
                
                currentLat = lat;
                currentLng = lng;
                
                addMarker(lng, lat);
                updateInputs(lat, lng);
                
                console.log('[LokasiMall] Marker placed:', lat.toFixed(6), lng.toFixed(6));
            });
            
            // Error event
            map.on('error', function(e) {
                console.error('[LokasiMall] Map error:', e);
                showError('Gagal memuat peta');
            });
            
            // Add controls
            map.addControl(new maplibregl.NavigationControl(), 'top-right');
            
            // Fallback timeout
            setTimeout(function() {
                if (loadingOverlay && !loadingOverlay.classList.contains('hidden')) {
                    console.warn('[LokasiMall] Timeout, forcing hide loading');
                    hideLoading();
                }
            }, 10000);
            
        } catch (error) {
            console.error('[LokasiMall] Init error:', error);
            showError('Error: ' + error.message);
        }
    }
    
    /**
     * Add/update marker
     */
    function addMarker(lng, lat) {
        // Remove existing marker
        if (marker) {
            marker.remove();
        }
        
        // Create custom marker element
        const el = document.createElement('div');
        el.className = 'custom-marker';
        
        // Create marker
        marker = new maplibregl.Marker({
            element: el,
            draggable: true
        })
        .setLngLat([lng, lat])
        .addTo(map);
        
        // Add popup
        const popup = new maplibregl.Popup({ offset: 25 })
            .setHTML('<strong>' + mallName + '</strong><br>Lat: ' + lat.toFixed(6) + '<br>Lng: ' + lng.toFixed(6));
        marker.setPopup(popup);
        
        // Drag event
        marker.on('dragend', function() {
            const lngLat = marker.getLngLat();
            currentLat = lngLat.lat;
            currentLng = lngLat.lng;
            updateInputs(lngLat.lat, lngLat.lng);
            console.log('[LokasiMall] Marker dragged:', lngLat.lat.toFixed(6), lngLat.lng.toFixed(6));
        });
    }
    
    /**
     * Update coordinate inputs
     */
    function updateInputs(lat, lng) {
        if (latInput) latInput.value = lat.toFixed(8);
        if (lngInput) lngInput.value = lng.toFixed(8);
    }
    
    /**
     * Handle save button click
     */
    function handleSave() {
        if (!currentLat || !currentLng) {
            alert('Silakan pilih lokasi pada peta terlebih dahulu');
            return;
        }
        
        if (!updateUrl) {
            alert('Error: Update URL tidak ditemukan');
            return;
        }
        
        // Disable button
        saveBtn.disabled = true;
        saveBtn.innerHTML = '<span>Menyimpan...</span>';
        
        console.log('[LokasiMall] Saving:', currentLat, currentLng);
        
        // Get CSRF token
        const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content || '';
        
        // Send request
        fetch(updateUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': csrfToken
            },
            body: JSON.stringify({
                latitude: parseFloat(currentLat),
                longitude: parseFloat(currentLng)
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('✅ Lokasi berhasil disimpan!');
                updateStatus(true);
                console.log('[LokasiMall] Saved successfully');
            } else {
                alert('❌ Gagal menyimpan: ' + (data.message || 'Unknown error'));
            }
        })
        .catch(error => {
            console.error('[LokasiMall] Save error:', error);
            alert('❌ Terjadi kesalahan saat menyimpan');
        })
        .finally(() => {
            // Reset button
            saveBtn.disabled = false;
            saveBtn.innerHTML = '<svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" /></svg>Simpan Lokasi';
        });
    }
    
    /**
     * Handle geolocate button click
     */
    function handleGeolocate() {
        if (!navigator.geolocation) {
            alert('Browser Anda tidak mendukung geolocation');
            return;
        }
        
        // Disable button
        geolocateBtn.disabled = true;
        geolocateBtn.innerHTML = '<span>Mengambil lokasi...</span>';
        
        navigator.geolocation.getCurrentPosition(
            function(position) {
                const lat = position.coords.latitude;
                const lng = position.coords.longitude;
                
                currentLat = lat;
                currentLng = lng;
                
                // Fly to location
                map.flyTo({
                    center: [lng, lat],
                    zoom: 16,
                    essential: true
                });
                
                // Add marker
                addMarker(lng, lat);
                updateInputs(lat, lng);
                
                console.log('[LokasiMall] Geolocated:', lat.toFixed(6), lng.toFixed(6));
                
                // Reset button
                resetGeolocateBtn();
            },
            function(error) {
                console.error('[LokasiMall] Geolocation error:', error);
                alert('Gagal mendapatkan lokasi: ' + error.message);
                resetGeolocateBtn();
            }
        );
    }
    
    function resetGeolocateBtn() {
        geolocateBtn.disabled = false;
        geolocateBtn.innerHTML = '<svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" /></svg>Gunakan Lokasi Saat Ini';
    }
    
    /**
     * Hide loading overlay
     */
    function hideLoading() {
        if (loadingOverlay) {
            loadingOverlay.classList.add('hidden');
            console.log('[LokasiMall] Loading hidden');
        }
    }
    
    /**
     * Show error message
     */
    function showError(message) {
        if (loadingOverlay) {
            loadingOverlay.innerHTML = '<div class="loading-content"><p style="color: #e53e3e;">' + message + '</p></div>';
        }
    }
    
    /**
     * Update status display
     */
    function updateStatus(success) {
        if (!statusContainer) return;
        
        if (success) {
            statusContainer.innerHTML = '<div class="alert alert-success"><svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg><span>Lokasi sudah diatur</span></div>';
        }
    }
    
    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
    
})();

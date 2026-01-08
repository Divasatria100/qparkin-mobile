@extends('layouts.admin')

@section('title', 'Lokasi Mall')

@section('breadcrumb')
<span>Lokasi Mall</span>
@endsection

@section('styles')
<link rel="stylesheet" href="https://unpkg.com/maplibre-gl@3.6.2/dist/maplibre-gl.css" />
<link rel="stylesheet" href="{{ asset('css/lokasi-mall.css') }}">
<!-- SweetAlert2 -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
@endsection

@section('content')
<div class="lokasi-mall-page">
    <!-- Page Header -->
    <div class="page-header">
        <h1>Pengaturan Lokasi Mall</h1>
        <p class="subtitle">Atur koordinat lokasi {{ $mall->nama_mall ?? 'Mall' }} menggunakan peta</p>
    </div>

    <!-- Main Content -->
    <div class="content-wrapper">
        <!-- Map Card -->
        <div class="map-card">
            <div class="map-card-header">
                <h3>Peta Lokasi</h3>
                <span class="hint">Klik pada peta untuk menentukan lokasi mall</span>
            </div>
            
            <div class="map-card-body">
                <!-- Loading Indicator (Sibling, bukan child dari #map) -->
                <div id="mapLoading" class="map-loading-overlay">
                    <div class="loading-content">
                        <div class="spinner"></div>
                        <p>Memuat peta...</p>
                    </div>
                </div>
                
                <!-- Map Container (Clean, no children) -->
                <div id="mapContainer" 
                     data-lat="{{ $mall->latitude ?? '-6.2088' }}"
                     data-lng="{{ $mall->longitude ?? '106.8456' }}"
                     data-mall-name="{{ $mall->nama_mall ?? 'Mall' }}"
                     data-has-coords="{{ ($mall->latitude && $mall->longitude) ? 'true' : 'false' }}"
                     data-update-url="{{ route('admin.lokasi-mall.update') }}">
                </div>
            </div>
        </div>

        <!-- Info Card -->
        <div class="info-card">
            <div class="info-card-header">
                <h3>Informasi Koordinat</h3>
            </div>
            
            <div class="info-card-body">
                <!-- Mall Info -->
                <div class="info-group">
                    <label>Nama Mall</label>
                    <p class="info-value">{{ $mall->nama_mall ?? '-' }}</p>
                </div>
                
                <div class="info-group">
                    <label>Alamat</label>
                    <p class="info-value">{{ $mall->alamat_lengkap ?? $mall->lokasi ?? '-' }}</p>
                </div>

                <!-- Google Maps Coordinate Input -->
                <div class="google-maps-input-group">
                    <label for="googleMapsInput">
                        <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                        </svg>
                        Salin Koordinat Google Maps
                    </label>
                    <div class="input-with-button">
                        <input type="text" id="googleMapsInput" 
                               placeholder="Contoh: 1.072020040894358, 104.02393750738969"
                               title="Paste koordinat dari Google Maps (format: latitude, longitude)">
                        <button type="button" id="parseCoordinatesBtn" class="btn-parse">
                            <svg width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6" />
                            </svg>
                            Gunakan
                        </button>
                    </div>
                    <small class="hint-text">Salin koordinat dari Google Maps dan klik "Gunakan"</small>
                    <div id="coordinateError" class="coordinate-error" style="display: none;"></div>
                </div>

                <!-- Coordinate Inputs -->
                <div class="coordinate-group">
                    <div class="input-group">
                        <label for="latitudeInput">Latitude</label>
                        <input type="text" id="latitudeInput" 
                               value="{{ $mall->latitude ?? '' }}" 
                               placeholder="-6.200000">
                    </div>

                    <div class="input-group">
                        <label for="longitudeInput">Longitude</label>
                        <input type="text" id="longitudeInput" 
                               value="{{ $mall->longitude ?? '' }}" 
                               placeholder="106.816666">
                    </div>
                </div>

                <!-- Status -->
                <div id="statusContainer" class="status-container">
                    @if($mall->latitude && $mall->longitude)
                        <div class="alert alert-success">
                            <svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                            <span>Lokasi sudah diatur</span>
                        </div>
                    @else
                        <div class="alert alert-warning">
                            <svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                            </svg>
                            <span>Lokasi belum diatur</span>
                        </div>
                    @endif
                </div>

                <!-- Action Buttons -->
                <button type="button" id="saveBtn" class="btn btn-primary">
                    <svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                    </svg>
                    Simpan Lokasi
                </button>

                <button type="button" id="geolocateBtn" class="btn btn-secondary">
                    <svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                    </svg>
                    Gunakan Lokasi Saat Ini
                </button>

                <!-- Instructions -->
                <div class="instructions">
                    <h4>Panduan:</h4>
                    <ol>
                        <li><strong>Copy-paste dari Google Maps:</strong> Salin koordinat dari Google Maps (format: lat, lng) dan klik "Gunakan"</li>
                        <li><strong>Klik pada peta:</strong> Klik langsung pada peta untuk menentukan lokasi mall</li>
                        <li><strong>Input manual:</strong> Ketik koordinat langsung di input Latitude/Longitude dan tekan Enter</li>
                        <li><strong>Lokasi saat ini:</strong> Gunakan tombol "Gunakan Lokasi Saat Ini" untuk GPS</li>
                        <li><strong>Simpan:</strong> Klik "Simpan Lokasi" untuk menyimpan perubahan</li>
                    </ol>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<!-- SweetAlert2 -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<!-- MapLibre GL -->
<script src="https://unpkg.com/maplibre-gl@3.6.2/dist/maplibre-gl.js"></script>
<script src="{{ asset('js/lokasi-mall.js') }}"></script>
@endsection

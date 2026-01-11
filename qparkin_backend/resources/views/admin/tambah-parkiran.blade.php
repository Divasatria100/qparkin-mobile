@extends('layouts.admin')

@section('title', 'Tambah Parkiran - QPARKIN')

@section('styles')
<link rel="stylesheet" href="{{ asset('css/tambah-parkiran.css') }}">
@endsection

@section('content')
<div class="breadcrumb">
    <a href="{{ route('admin.parkiran') }}" class="breadcrumb-link">Parkiran</a>
    <span class="breadcrumb-separator">/</span>
    <span>Tambah Parkiran Baru</span>
</div>

<div class="parkiran-add-container">
    <div class="add-header">
        <h2>Tambah Parkiran Baru</h2>
        <p>Buat area parkir baru untuk mall Anda</p>
    </div>

    <div class="add-content">
        <div class="info-section">
            <h3>Informasi Parkiran</h3>
            <div class="info-card">
                <div class="info-icon">
                    <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                    </svg>
                </div>
                <div class="info-content">
                    <h4>Struktur Parkiran</h4>
                    <p>Parkiran terdiri dari beberapa lantai, masing-masing lantai memiliki slot parkir dengan penamaan sistematis.</p>
                    <div class="info-tips">
                        <div class="tip-item">
                            <span class="tip-bullet">•</span>
                            <span>Setiap lantai dapat memiliki jumlah slot yang berbeda</span>
                        </div>
                        <div class="tip-item">
                            <span class="tip-bullet">•</span>
                            <span>Penamaan slot otomatis menggunakan kode parkiran</span>
                        </div>
                        <div class="tip-item">
                            <span class="tip-bullet">•</span>
                            <span>Status parkiran dapat diatur sebagai aktif atau maintenance</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="form-section">
            <h3>Form Tambah Parkiran</h3>
            <form id="tambahParkiranForm" class="parkiran-form">
                @csrf
                <div class="form-group">
                    <label for="namaParkiran">Nama Parkiran *</label>
                    <input type="text" id="namaParkiran" name="nama_parkiran" placeholder="Contoh: Parkiran Mawar, Parkiran Utama" required>
                    <span class="form-hint">Nama yang mudah dikenali untuk parkiran ini</span>
                </div>

                <div class="form-group">
                    <label for="kodeParkiran">Kode Parkiran *</label>
                    <input type="text" id="kodeParkiran" name="kode_parkiran" placeholder="Contoh: MWR, P01, UTAMA" maxlength="10" required>
                    <span class="form-hint">Kode unik untuk identifikasi parkiran (3-10 karakter)</span>
                </div>

                <div class="form-group">
                    <label for="statusParkiran">Status *</label>
                    <select id="statusParkiran" name="status" required>
                        <option value="" hidden>Pilih Status</option>
                        <option value="Tersedia">Aktif</option>
                        <option value="maintenance">Maintenance</option>
                        <option value="Ditutup">Tidak Aktif</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="jumlahLantai">Jumlah Lantai *</label>
                    <input type="number" id="jumlahLantai" name="jumlah_lantai" min="1" max="10" placeholder="Contoh: 3" required>
                    <span class="form-hint">Maksimal 10 lantai</span>
                </div>

                <div class="lantai-configuration">
                    <h4>Konfigurasi Lantai</h4>
                    <div id="lantaiContainer" class="lantai-container">
                        <!-- Dynamic lantai fields will be added here -->
                    </div>
                </div>

                <div class="preview-section">
                    <h4>Preview Parkiran</h4>
                    <div class="preview-card">
                        <div class="preview-header">
                            <div class="preview-icon">
                                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                                </svg>
                            </div>
                            <div class="preview-title">
                                <h5 id="previewNama">Nama Parkiran</h5>
                                <span class="preview-status" id="previewStatus">Status</span>
                            </div>
                        </div>
                        <div class="preview-body">
                            <div class="preview-info">
                                <div class="preview-item">
                                    <span>Total Lantai:</span>
                                    <span id="previewLantai">0</span>
                                </div>
                                <div class="preview-item">
                                    <span>Total Slot:</span>
                                    <span id="previewSlot">0</span>
                                </div>
                                <div class="preview-item">
                                    <span>Kode:</span>
                                    <span id="previewKode">-</span>
                                </div>
                                <div class="preview-item">
                                    <span>Jenis Kendaraan:</span>
                                    <span id="previewJenisKendaraan">-</span>
                                </div>
                            </div>
                            <div class="preview-lantai">
                                <h6>Detail Lantai:</h6>
                                <div id="previewLantaiList" class="preview-lantai-list">
                                    <!-- Dynamic lantai list will be added here -->
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <div class="add-actions">
        <a href="{{ route('admin.parkiran') }}" class="btn-cancel">Batal</a>
        <button class="btn-save" id="saveParkiranBtn">
            <span class="loading-spinner"></span>
            <span class="btn-text">Simpan Parkiran</span>
        </button>
    </div>
</div>
@endsection

@section('scripts')
<script src="{{ asset('js/tambah-parkiran.js') }}"></script>
@endsection

@extends('layouts.admin')

@section('title', 'Edit Parkiran - QPARKIN')

@section('styles')
<link rel="stylesheet" href="{{ asset('css/edit-parkiran.css') }}">
@endsection

@section('content')
<div class="breadcrumb">
    <a href="{{ route('admin.parkiran') }}" class="breadcrumb-link">Parkiran</a>
    <span class="breadcrumb-separator">/</span>
    <span>Edit Parkiran</span>
</div>

<div class="parkiran-edit-container">
    <div class="edit-header">
        <h2>Edit Parkiran</h2>
        <p>Perbarui informasi dan konfigurasi parkiran</p>
    </div>

    <div class="edit-content">
        <div class="current-info-section">
            <h3>Informasi Saat Ini</h3>
            <div class="current-info-card">
                <div class="info-icon">
                    <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                    </svg>
                </div>
                <div class="current-info-content">
                    <h4>{{ $parkiran->nama_parkiran ?? 'Parkiran ' . $parkiran->id_parkiran }}</h4>
                    <div class="current-stats">
                        <div class="current-stat">
                            <span class="label">Kode:</span>
                            <span class="value">{{ $parkiran->kode_parkiran ?? '-' }}</span>
                        </div>
                        <div class="current-stat">
                            <span class="label">Status:</span>
                            <span class="value">{{ $parkiran->status }}</span>
                        </div>
                        <div class="current-stat">
                            <span class="label">Lantai:</span>
                            <span class="value">{{ $parkiran->jumlah_lantai ?? $parkiran->floors->count() }}</span>
                        </div>
                        <div class="current-stat">
                            <span class="label">Total Slot:</span>
                            <span class="value">{{ $parkiran->kapasitas }}</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="form-section">
            <h3>Form Edit Parkiran</h3>
            <form id="editParkiranForm" class="parkiran-form">
                @csrf
                <input type="hidden" name="id_parkiran" value="{{ $parkiran->id_parkiran }}">
                
                <div class="form-group">
                    <label for="namaParkiran">Nama Parkiran *</label>
                    <input type="text" id="namaParkiran" name="nama_parkiran" value="{{ $parkiran->nama_parkiran }}" placeholder="Masukkan nama parkiran" required>
                </div>

                <div class="form-group">
                    <label for="kodeParkiran">Kode Parkiran *</label>
                    <input type="text" id="kodeParkiran" name="kode_parkiran" value="{{ $parkiran->kode_parkiran }}" placeholder="Masukkan kode parkiran" maxlength="10" required>
                    <span class="form-hint">Kode unik untuk identifikasi (maks. 10 karakter)</span>
                </div>

                <div class="form-group">
                    <label for="statusParkiran">Status *</label>
                    <select id="statusParkiran" name="status" required>
                        <option value="Tersedia" {{ $parkiran->status == 'Tersedia' ? 'selected' : '' }}>Aktif</option>
                        <option value="maintenance" {{ $parkiran->status == 'maintenance' ? 'selected' : '' }}>Maintenance</option>
                        <option value="Ditutup" {{ $parkiran->status == 'Ditutup' ? 'selected' : '' }}>Tidak Aktif</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="jumlahLantai">Jumlah Lantai *</label>
                    <input type="number" id="jumlahLantai" name="jumlah_lantai" value="{{ $parkiran->jumlah_lantai ?? $parkiran->floors->count() }}" min="1" max="10" placeholder="Jumlah lantai" required>
                    <span class="form-hint">Mengubah jumlah lantai akan mempengaruhi konfigurasi slot</span>
                </div>

                <div class="lantai-configuration">
                    <h4>Konfigurasi Lantai</h4>
                    <div class="configuration-info">
                        <p>Atur jumlah slot dan sistem penamaan untuk setiap lantai</p>
                    </div>
                    <div id="lantaiContainer" class="lantai-container">
                        <!-- Dynamic lantai fields will be added here -->
                    </div>
                </div>

                <div class="preview-section">
                    <h4>Preview Perubahan</h4>
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
                            <div class="preview-stats">
                                <div class="preview-stat">
                                    <span class="label">Lantai:</span>
                                    <span class="value" id="previewLantai">0</span>
                                </div>
                                <div class="preview-stat">
                                    <span class="label">Total Slot:</span>
                                    <span class="value" id="previewSlot">0</span>
                                </div>
                                <div class="preview-stat">
                                    <span class="label">Kode:</span>
                                    <span class="value" id="previewKode">-</span>
                                </div>
                            </div>
                            <div class="preview-lantai-list">
                                <h6>Detail Lantai:</h6>
                                <div id="previewLantaiList">
                                    <!-- Dynamic lantai preview will be added here -->
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <div class="edit-actions">
        <a href="{{ route('admin.parkiran') }}" class="btn-cancel">Batal</a>
        <button class="btn-delete" id="deleteBtn" type="button">Hapus Parkiran</button>
        <button class="btn-save" id="saveParkiranBtn">
            <span class="loading-spinner"></span>
            <span class="btn-text">Simpan Perubahan</span>
        </button>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div id="deleteModal" class="modal" style="display: none;">
    <div class="modal-content">
        <div class="modal-header">
            <h3>Hapus Parkiran</h3>
            <span class="close">&times;</span>
        </div>
        <div class="modal-body">
            <div class="warning-icon">
                <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z" />
                </svg>
            </div>
            <p>Apakah Anda yakin ingin menghapus <strong>{{ $parkiran->nama_parkiran }}</strong>?</p>
            <p class="warning-text">Tindakan ini tidak dapat dibatalkan. Semua data parkiran, termasuk histori parkir, akan dihapus permanen.</p>
            <div class="confirmation-input">
                <label for="confirmDelete">Ketik "HAPUS" untuk konfirmasi:</label>
                <input type="text" id="confirmDelete" placeholder="HAPUS">
            </div>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn-cancel close-modal">Batal</button>
            <button type="button" class="btn-danger" id="confirmDeleteBtn" disabled>Hapus Parkiran</button>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script>
const parkiranData = @json($parkiran);
const floorsData = @json($parkiran->floors);
</script>
<script src="{{ asset('js/edit-parkiran.js') }}"></script>
@endsection

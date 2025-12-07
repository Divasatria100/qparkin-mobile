@extends('layouts.admin')

@section('title', 'Ubah Foto Profil - QPARKIN')

@section('styles')
<link rel="stylesheet" href="{{ asset('css/admin-profile.css') }}">
<link rel="stylesheet" href="{{ asset('css/ubah-foto.css') }}">
@endsection

@section('content')
<div class="breadcrumb">
    <a href="{{ route('admin.profile') }}" class="breadcrumb-link">Profile</a>
    <span class="breadcrumb-separator">/</span>
    <span>Ubah Foto Profil</span>
</div>

<div class="photo-upload-container">
    <div class="upload-header">
        <h2>Ubah Foto Profil</h2>
        <p>Pilih atau unggah foto baru untuk profil Anda</p>
    </div>

    <div class="upload-content">
        <div class="current-photo-section">
            <h3>Foto Saat Ini</h3>
            <div class="current-photo">
                <div class="avatar-preview large">
                    <svg xmlns="http://www.w3.org/2000/svg" width="80" height="80" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                    </svg>
                </div>
                <p class="photo-info">Foto profil saat ini</p>
            </div>
        </div>

        <div class="upload-section">
            <h3>Unggah Foto Baru</h3>
            <div class="upload-area" id="uploadArea">
                <div class="upload-placeholder">
                    <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    </svg>
                    <p>Seret dan lepas file di sini atau klik untuk memilih</p>
                    <span class="upload-hint">Format: JPG, PNG, GIF (Maks. 2MB)</span>
                </div>
                <input type="file" id="photoInput" accept="image/*" style="display: none;">
            </div>

            <div class="preview-section" id="previewSection" style="display: none;">
                <h4>Pratinjau Foto Baru</h4>
                <div class="photo-preview">
                    <img id="imagePreview" src="" alt="Preview">
                    <button class="remove-preview" id="removePreview">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    </button>
                </div>
            </div>

            <div class="crop-section" id="cropSection" style="display: none;">
                <h4>Pangkas Foto</h4>
                <div class="crop-area">
                    <div class="crop-container">
                        <img id="cropImage" src="" alt="Crop area">
                    </div>
                    <div class="crop-controls">
                        <button class="crop-rotate" id="rotateLeft">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                            </svg>
                        </button>
                        <button class="crop-rotate" id="rotateRight">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                            </svg>
                        </button>
                        <button class="crop-reset" id="resetCrop">Reset</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="upload-actions">
        <button class="btn-danger" onclick="window.location.href='{{ route('admin.profile') }}'">Batal</button>
        <button class="btn-primary" id="savePhotoBtn" disabled>Simpan Foto</button>
    </div>
</div>
@endsection

@section('scripts')
<script src="{{ asset('js/admin-profile.js') }}"></script>
<script src="{{ asset('js/ubah-foto.js') }}"></script>
@endsection

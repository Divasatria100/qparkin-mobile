@extends('layouts.superadmin')

@section('title', 'Ubah Foto Profil - QPARKIN')

@push('styles')
<link rel="stylesheet" href="{{ asset('css/super-profile.css') }}">
<link rel="stylesheet" href="{{ asset('css/ubah-foto.css') }}">
@endpush

@section('breadcrumb')
<a href="{{ route('superadmin.profile') }}" class="breadcrumb-link">Profile</a>
<span class="breadcrumb-separator">/</span>
<span>Ubah Foto Profil</span>
@endsection

@section('content')
<div class="photo-upload-container">
    <div class="upload-header">
        <h2>Ubah Foto Profil</h2>
        <p>Pilih atau unggah foto baru untuk profil Anda</p>
    </div>

    @if(session('success'))
    <div class="alert alert-success">
        {{ session('success') }}
    </div>
    @endif

    @if($errors->any())
    <div class="alert alert-danger">
        <ul>
            @foreach($errors->all() as $error)
            <li>{{ $error }}</li>
            @endforeach
        </ul>
    </div>
    @endif

    <div class="upload-content">
        <div class="current-photo-section">
            <h3>Foto Saat Ini</h3>
            <div class="current-photo">
                <div class="avatar-preview large">
                    @if(isset($user->avatar) && $user->avatar)
                    <img src="{{ asset('storage/' . $user->avatar) }}" alt="Avatar">
                    @else
                    <svg xmlns="http://www.w3.org/2000/svg" width="80" height="80" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                    </svg>
                    @endif
                </div>
                <p class="photo-info">Foto profil saat ini</p>
            </div>
        </div>

        <div class="upload-section">
            <h3>Unggah Foto Baru</h3>
            <form id="uploadPhotoForm" method="POST" action="{{ route('superadmin.profile.photo.update') }}" enctype="multipart/form-data">
                @csrf
                <div class="upload-area" id="uploadArea">
                    <div class="upload-placeholder">
                        <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                        </svg>
                        <p>Seret dan lepas file di sini atau klik untuk memilih</p>
                        <span class="upload-hint">Format: JPG, PNG, GIF (Maks. 2MB)</span>
                    </div>
                    <input type="file" id="photoInput" name="avatar" accept="image/*" style="display: none;">
                </div>

                <div class="preview-section" id="previewSection" style="display: none;">
                    <h4>Pratinjau Foto Baru</h4>
                    <div class="photo-preview">
                        <img id="imagePreview" src="" alt="Preview">
                        <button type="button" class="remove-preview" id="removePreview">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                            </svg>
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <div class="upload-actions">
        <button type="button" class="btn-danger" onclick="window.location.href='{{ route('superadmin.profile') }}'">Batal</button>
        <button type="button" class="btn-primary" id="savePhotoBtn" disabled>Simpan Foto</button>
    </div>
</div>
@endsection

@push('scripts')
<script src="{{ asset('js/ubah-foto.js') }}"></script>
@endpush

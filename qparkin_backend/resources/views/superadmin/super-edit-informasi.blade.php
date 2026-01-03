@extends('layouts.superadmin')

@section('title', 'Edit Informasi - QPARKIN')

@push('styles')
<link rel="stylesheet" href="{{ asset('css/super-profile.css') }}">
<link rel="stylesheet" href="{{ asset('css/edit-informasi.css') }}">
@endpush

@section('breadcrumb')
<a href="{{ route('superadmin.profile') }}" class="breadcrumb-link">Profile</a>
<span class="breadcrumb-separator">/</span>
<span>Edit Informasi</span>
@endsection

@section('content')
<div class="edit-info-container">
    <div class="edit-header">
        <h2>Edit Informasi Pribadi</h2>
        <p>Perbarui informasi profil dan kontak Anda</p>
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

    <form class="edit-form" id="editInfoForm" method="POST" action="{{ route('superadmin.profile.update') }}">
        @csrf
        <div class="form-section">
            <h3>Informasi Akun</h3>
            <div class="form-grid">
                <div class="form-group">
                    <label for="namaLengkap">Nama Lengkap *</label>
                    <input type="text" id="namaLengkap" name="name" value="{{ old('name', $user->name ?? '') }}" required>
                    @error('name')
                    <span class="error-message">{{ $message }}</span>
                    @enderror
                </div>
                
                <div class="form-group">
                    <label for="email">Email *</label>
                    <input type="email" id="email" name="email" value="{{ old('email', $user->email ?? '') }}" required>
                    @error('email')
                    <span class="error-message">{{ $message }}</span>
                    @enderror
                </div>

                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username" value="{{ $user->email }}" readonly>
                    <span class="field-hint">Username tidak dapat diubah</span>
                </div>

                <div class="form-group">
                    <label for="idUser">ID User</label>
                    <input type="text" id="idUser" name="id_user" value="{{ $user->id_user ?? '-' }}" readonly>
                </div>
            </div>
        </div>

        <div class="form-section">
            <h3>Informasi Kontak</h3>
            <div class="form-grid">
                <div class="form-group">
                    <label for="telepon">Nomor Telepon</label>
                    <input type="tel" id="telepon" name="nomor_hp" value="{{ old('nomor_hp', $user->nomor_hp ?? '') }}" placeholder="+62 812-3456-7890">
                    @error('nomor_hp')
                    <span class="error-message">{{ $message }}</span>
                    @enderror
                </div>

                <div class="form-group">
                    <label for="role">Role</label>
                    <input type="text" id="role" name="role" value="Super Administrator" readonly>
                    <span class="field-hint">Role tidak dapat diubah</span>
                </div>

                <div class="form-group full-width">
                    <label for="status">Status Akun</label>
                    <select id="status" name="status">
                        <option value="aktif" {{ ($user->status ?? 'aktif') === 'aktif' ? 'selected' : '' }}>Aktif</option>
                        <option value="nonaktif" {{ ($user->status ?? '') === 'nonaktif' ? 'selected' : '' }}>Nonaktif</option>
                    </select>
                    @error('status')
                    <span class="error-message">{{ $message }}</span>
                    @enderror
                </div>
            </div>
        </div>

        <div class="form-section">
            <h3>Informasi Sistem</h3>
            <div class="form-grid">
                <div class="form-group">
                    <label for="createdAt">Bergabung Sejak</label>
                    <input type="text" id="createdAt" value="{{ $user->created_at ? $user->created_at->translatedFormat('d F Y') : '-' }}" readonly>
                </div>

                <div class="form-group">
                    <label for="lastUpdate">Terakhir Diperbarui</label>
                    <input type="text" id="lastUpdate" value="{{ $user->updated_at ? $user->updated_at->translatedFormat('d F Y H:i') : '-' }}" readonly>
                </div>
            </div>
        </div>

        <div class="form-actions">
            <button type="button" class="btn-danger" onclick="window.location.href='{{ route('superadmin.profile') }}'">Batal</button>
            <button type="button" class="btn-reset" id="resetBtn">Reset</button>
            <button type="submit" class="btn-primary" id="saveBtn">Simpan Perubahan</button>
        </div>
    </form>
</div>
@endsection

@push('scripts')
<script src="{{ asset('js/edit-informasi.js') }}"></script>
@endpush

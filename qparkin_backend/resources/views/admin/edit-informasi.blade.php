@extends('layouts.admin')

@section('title', 'Edit Informasi - QPARKIN')

@section('styles')
<link rel="stylesheet" href="{{ asset('css/admin-profile.css') }}">
<link rel="stylesheet" href="{{ asset('css/edit-informasi.css') }}">
@endsection

@section('content')
<div class="breadcrumb">
    <a href="{{ route('admin.profile') }}" class="breadcrumb-link">Profile</a>
    <span class="breadcrumb-separator">/</span>
    <span>Edit Informasi</span>
</div>

<div class="edit-info-container">
    <div class="edit-header">
        <h2>Edit Informasi Pribadi</h2>
        <p>Perbarui informasi profil dan kontak Anda</p>
    </div>

    <form class="edit-form" id="editInfoForm" method="POST" action="{{ route('admin.profile.update') }}">
        @csrf
        <div class="form-section">
            <h3>Informasi Akun</h3>
            <div class="form-grid">
                <div class="form-group">
                    <label for="namaLengkap">Nama Lengkap *</label>
                    <input type="text" id="namaLengkap" name="name" value="{{ old('name', $user->name ?? '') }}" required>
                    <span class="error-message" id="namaError"></span>
                </div>
                
                <div class="form-group">
                    <label for="email">Email *</label>
                    <input type="email" id="email" name="email" value="{{ old('email', $user->email ?? '') }}" required>
                    <span class="error-message" id="emailError"></span>
                </div>

                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username" value="{{ $user->username ?? $user->email }}" readonly>
                    <span class="field-hint">Username tidak dapat diubah</span>
                </div>

                <div class="form-group">
                    <label for="idAdmin">ID Admin</label>
                    <input type="text" id="idAdmin" name="id_admin" value="{{ $user->adminMall->id_admin_mall ?? 'ADM-001' }}" readonly>
                </div>
            </div>
        </div>

        <div class="form-section">
            <h3>Informasi Kontak</h3>
            <div class="form-grid">
                <div class="form-group">
                    <label for="telepon">Nomor Telepon</label>
                    <input type="tel" id="telepon" name="nomor_hp" value="{{ old('nomor_hp', $user->nomor_hp ?? '') }}">
                    <span class="error-message" id="teleponError"></span>
                </div>

                <div class="form-group">
                    <label for="role">Role</label>
                    <input type="text" id="role" name="role" value="{{ ucwords(str_replace('_', ' ', $user->role ?? 'Admin Mall')) }}" readonly>
                    <span class="field-hint">Role tidak dapat diubah</span>
                </div>

                <div class="form-group full-width">
                    <label for="status">Status Akun</label>
                    <select id="status" name="status">
                        <option value="aktif" {{ ($user->status ?? 'aktif') === 'aktif' ? 'selected' : '' }}>Aktif</option>
                        <option value="nonaktif" {{ ($user->status ?? '') === 'nonaktif' ? 'selected' : '' }}>Nonaktif</option>
                    </select>
                    <span class="error-message" id="statusError"></span>
                </div>
            </div>
        </div>

        <div class="form-section">
            <h3>Informasi Mall</h3>
            <div class="form-grid">
                <div class="form-group">
                    <label for="namaMall">Nama Mall *</label>
                    <input type="text" id="namaMall" name="mall_name" value="{{ $user->adminMall->mall->nama_mall ?? 'Mall' }}" readonly>
                    <span class="error-message" id="mallError"></span>
                </div>

                <div class="form-group">
                    <label for="kodeMall">Kode Mall</label>
                    <input type="text" id="kodeMall" name="mall_code" value="{{ $user->adminMall->mall->kode_mall ?? 'ML' }}" readonly>
                </div>

                <div class="form-group full-width">
                    <label for="alamatMall">Alamat Mall</label>
                    <textarea id="alamatMall" name="alamat_mall" rows="2" readonly>{{ $user->adminMall->mall->alamat ?? '-' }}</textarea>
                    <span class="field-hint">Informasi mall tidak dapat diubah</span>
                </div>
            </div>
        </div>

        <div class="form-actions">
            <button type="button" class="btn-danger" onclick="window.location.href='{{ route('admin.profile') }}'">Batal</button>
            <button type="button" class="btn-reset" id="resetBtn">Reset</button>
            <button type="submit" class="btn-primary" id="saveBtn">Simpan Perubahan</button>
        </div>
    </form>
</div>
@endsection

@section('scripts')
<script src="{{ asset('js/admin-profile.js') }}"></script>
<script src="{{ asset('js/edit-informasi.js') }}"></script>
@endsection

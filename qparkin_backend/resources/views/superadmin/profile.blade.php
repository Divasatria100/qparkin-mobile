@extends('layouts.superadmin')

@section('title', 'Profil Super Admin - QPARKIN')

@push('styles')
<link rel="stylesheet" href="{{ asset('css/super-profile.css') }}">
@endpush

@section('breadcrumb')
<span>Profile</span>
@endsection

@section('content')
<!-- Profile Section -->
<div class="profile-section">
    <div class="profile-header">
        <div class="profile-avatar">
            <div class="avatar-placeholder">
                <svg xmlns="http://www.w3.org/2000/svg" width="60" height="60" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                </svg>
            </div>
            <a href="{{ route('superadmin.profile.photo') }}" class="change-avatar-btn" style="text-decoration-line: none;">Ubah Foto</a>
        </div>
        <div class="profile-info">
            <h2>{{ $user->name ?? 'Super Admin' }}</h2>
            <p>{{ $user->email ?? 'superadmin@qparkin.com' }}</p>
            <div class="profile-status">
                <span class="status-badge {{ $user->status === 'aktif' ? 'active' : '' }}">{{ ucfirst($user->status ?? 'Aktif') }}</span>
                <span class="join-date">Bergabung sejak: {{ $user->created_at ? $user->created_at->translatedFormat('d F Y') : '1 Januari 2024' }}</span>
            </div>
        </div>
    </div>

    <div class="profile-content">
        <div class="profile-card">
            <div class="card-header">
                <h3>Informasi Pribadi</h3>
                <a href="{{ route('superadmin.profile.edit') }}" class="edit-btn" style="text-decoration-line: none;">Edit</a>
            </div>
            <div class="card-body">
                <div class="info-grid">
                    <div class="info-item">
                        <label>Nama Lengkap</label>
                        <p>{{ $user->name ?? '-' }}</p>
                    </div>
                    <div class="info-item">
                        <label>Email</label>
                        <p>{{ $user->email ?? '-' }}</p>
                    </div>
                    <div class="info-item">
                        <label>Nomor Telepon</label>
                        <p>{{ $user->nomor_hp ?? '-' }}</p>
                    </div>
                    <div class="info-item">
                        <label>Role</label>
                        <p>Super Administrator</p>
                    </div>
                    <div class="info-item">
                        <label>Status Akun</label>
                        <p>{{ ucfirst($user->status ?? 'Aktif') }}</p>
                    </div>
                    <div class="info-item">
                        <label>ID User</label>
                        <p>{{ $user->id_user ?? '-' }}</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="profile-card">
            <div class="card-header">
                <h3>Keamanan Akun</h3>
                <a href="{{ route('superadmin.profile.security') }}" class="edit-btn" style="text-decoration-line: none;">Ubah</a>
            </div>
            <div class="card-body">
                <div class="info-grid">
                    <div class="info-item">
                        <label>Kata Sandi</label>
                        <p>••••••••</p>
                    </div>
                    <div class="info-item">
                        <label>Verifikasi 2 Langkah</label>
                        <p class="status-off">Tidak Aktif</p>
                    </div>
                    <div class="info-item">
                        <label>Sesi Aktif</label>
                        <p>1 perangkat</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script src="{{ asset('js/super-profile.js') }}"></script>
@endpush

@extends('layouts.admin')

@section('title', 'Ubah Keamanan - QPARKIN')

@section('styles')
<link rel="stylesheet" href="{{ asset('css/admin-profile.css') }}">
<link rel="stylesheet" href="{{ asset('css/ubah-keamanan.css') }}">
@endsection

@section('content')
<div class="breadcrumb">
    <a href="{{ route('admin.profile') }}" class="breadcrumb-link">Profile</a>
    <span class="breadcrumb-separator">/</span>
    <span>Ubah Keamanan</span>
</div>

<div class="security-container">
    <div class="security-header">
        <h2>Pengaturan Keamanan Akun</h2>
        <p>Kelola kata sandi dan pengaturan keamanan akun Anda</p>
    </div>

    <div class="security-content">
        <div class="security-section">
            <div class="section-header">
                <h3>Ubah Kata Sandi</h3>
                <span class="section-badge">Direkomendasikan</span>
            </div>
            <form class="security-form" id="changePasswordForm" method="POST" action="{{ route('admin.profile.update') }}">
                @csrf
                <div class="form-group">
                    <label for="currentPassword">Kata Sandi Saat Ini *</label>
                    <div class="password-input">
                        <input type="password" id="currentPassword" name="current_password" required>
                        <button type="button" class="toggle-password" data-target="currentPassword">
                            <svg class="eye-icon" xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                            </svg>
                        </button>
                    </div>
                    <span class="error-message" id="currentPasswordError"></span>
                </div>

                <div class="form-group">
                    <label for="newPassword">Kata Sandi Baru *</label>
                    <div class="password-input">
                        <input type="password" id="newPassword" name="password" required minlength="8">
                        <button type="button" class="toggle-password" data-target="newPassword">
                            <svg class="eye-icon" xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                            </svg>
                        </button>
                    </div>
                    <div class="password-strength">
                        <div class="strength-bar">
                            <div class="strength-fill" id="strengthFill"></div>
                        </div>
                        <span class="strength-text" id="strengthText">Kekuatan kata sandi</span>
                    </div>
                    <span class="error-message" id="newPasswordError"></span>
                </div>

                <div class="form-group">
                    <label for="confirmPassword">Konfirmasi Kata Sandi Baru *</label>
                    <div class="password-input">
                        <input type="password" id="confirmPassword" name="password_confirmation" required>
                        <button type="button" class="toggle-password" data-target="confirmPassword">
                            <svg class="eye-icon" xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                            </svg>
                        </button>
                    </div>
                    <span class="error-message" id="confirmPasswordError"></span>
                </div>

                <div class="password-requirements">
                    <h4>Persyaratan Kata Sandi:</h4>
                    <ul>
                        <li id="reqLength" class="requirement">Minimal 8 karakter</li>
                        <li id="reqUppercase" class="requirement">Minimal 1 huruf besar</li>
                        <li id="reqLowercase" class="requirement">Minimal 1 huruf kecil</li>
                        <li id="reqNumber" class="requirement">Minimal 1 angka</li>
                        <li id="reqSpecial" class="requirement">Minimal 1 karakter spesial</li>
                    </ul>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn-primary" id="savePasswordBtn">Ubah Kata Sandi</button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script src="{{ asset('js/admin-profile.js') }}"></script>
<script src="{{ asset('js/ubah-keamanan.js') }}"></script>
@endsection

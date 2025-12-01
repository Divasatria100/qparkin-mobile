@extends('layouts.superadmin')

@section('title', 'Profile Super Admin')

@section('breadcrumb')
<span>Profile</span>
@endsection

@section('content')
<div class="profile-container">
    <div class="profile-card">
        <div class="profile-header">
            <div class="profile-avatar">
                <img src="{{ auth()->user()->avatar ?? asset('images/default-avatar.png') }}" alt="Profile">
            </div>
            <div class="profile-info">
                <h2>{{ auth()->user()->name }}</h2>
                <p>{{ auth()->user()->email }}</p>
                <span class="badge badge-primary">Super Admin</span>
            </div>
        </div>

        <div class="profile-actions">
            <a href="{{ route('superadmin.profile.edit') }}" class="btn btn-primary">Edit Informasi</a>
            <a href="{{ route('superadmin.profile.photo') }}" class="btn btn-secondary">Ubah Foto</a>
            <a href="{{ route('superadmin.profile.security') }}" class="btn btn-secondary">Ubah Keamanan</a>
        </div>

        <div class="profile-details">
            <h3>Informasi Akun</h3>
            <div class="detail-row">
                <span class="label">Role:</span>
                <span class="value">Super Administrator</span>
            </div>
            <div class="detail-row">
                <span class="label">Bergabung:</span>
                <span class="value">{{ auth()->user()->created_at->format('d F Y') }}</span>
            </div>
            <div class="detail-row">
                <span class="label">Status:</span>
                <span class="value badge-success">Aktif</span>
            </div>
        </div>
    </div>
</div>
@endsection

@push('styles')
<link rel="stylesheet" href="{{ asset('css/super-profile.css') }}">
@endpush

@push('scripts')
<script src="{{ asset('js/super-profile.js') }}"></script>
@endpush

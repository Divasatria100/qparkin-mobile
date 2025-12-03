@extends('layouts.admin')

@section('title', 'Profile')

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
                <span class="badge">Admin Mall</span>
            </div>
        </div>

        <div class="profile-actions">
            <a href="{{ route('admin.profile.edit') }}" class="btn btn-primary">Edit Informasi</a>
            <a href="{{ route('admin.profile.photo') }}" class="btn btn-secondary">Ubah Foto</a>
            <a href="{{ route('admin.profile.security') }}" class="btn btn-secondary">Ubah Keamanan</a>
        </div>

        <div class="profile-details">
            <h3>Informasi Mall</h3>
            <div class="detail-row">
                <span class="label">Nama Mall:</span>
                <span class="value">{{ auth()->user()->mall->name ?? '-' }}</span>
            </div>
            <div class="detail-row">
                <span class="label">Lokasi:</span>
                <span class="value">{{ auth()->user()->mall->location ?? '-' }}</span>
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
<link rel="stylesheet" href="{{ asset('css/admin-profile.css') }}">
@endpush

@push('scripts')
<script src="{{ asset('js/admin-profile.js') }}"></script>
@endpush

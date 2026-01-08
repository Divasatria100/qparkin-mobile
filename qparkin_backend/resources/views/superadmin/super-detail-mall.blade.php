@extends('layouts.superadmin')

@section('title', 'Detail Mall - {{ $mall->nama_mall }} - QPARKIN')

@push('styles')
<link rel="stylesheet" href="{{ asset('css/super-detail-mall.css') }}">
@endpush

@section('breadcrumb')
<a href="{{ route('superadmin.mall') }}" class="breadcrumb-link">Manajemen Mall</a>
<span class="breadcrumb-separator">/</span>
<span>Detail Mall - {{ $mall->nama_mall }}</span>
@endsection

@section('content')
<!-- Page Header -->
<div class="page-header">
    <div class="header-content">
        <div class="mall-header">
            <div class="mall-logo-large">
                <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                </svg>
            </div>
            <div class="mall-info-header">
                <h1>{{ $mall->nama_mall }}</h1>
                <div class="mall-meta">
                    <span class="mall-code">ID: {{ $mall->id_mall }}</span>
                    <div class="mall-status-badge active">
                        <span class="status-dot"></span>
                        Status: Aktif
                    </div>
                </div>
                <p class="mall-description">
                    {{ $mall->alamat_lengkap ?? 'Alamat tidak tersedia' }}
                </p>
            </div>
        </div>
    </div>
    <div class="header-actions">
        <a href="{{ route('superadmin.mall.edit', $mall->id_mall) }}" class="btn-primary">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
            </svg>
            Edit Mall
        </a>
        <a href="{{ route('superadmin.mall') }}" class="btn-secondary">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
            </svg>
            Kembali
        </a>
    </div>
</div>

<!-- Dashboard Tabs -->
<div class="dashboard-tabs">
    <nav class="tabs-navigation">
        <button class="tab-button active" data-tab="overview">Overview</button>
        <button class="tab-button" data-tab="parking">Parkir & Tarif</button>
        <button class="tab-button" data-tab="admin">Admin & Staff</button>
    </nav>

    <!-- Overview Tab -->
    <div class="tab-content active" id="overview-tab">
        <!-- Statistics Cards -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon primary">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                    </svg>
                </div>
                <div class="stat-content">
                    <h3>Total Slot Parkir</h3>
                    <div class="stat-value">{{ number_format($mall->kapasitas ?? 0) }}</div>
                    <div class="stat-trend">Kapasitas total</div>
                </div>
            </div>

            <div class="stat-card">
                <div class="stat-icon success">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                    </svg>
                </div>
                <div class="stat-content">
                    <h3>Pendapatan Bulan Ini</h3>
                    <div class="stat-value">Rp {{ number_format($mall->transaksiParkir->sum('biaya'), 0, ',', '.') }}</div>
                    <div class="stat-trend positive">Total pendapatan</div>
                </div>
            </div>

            <div class="stat-card">
                <div class="stat-icon warning">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                    </svg>
                </div>
                <div class="stat-content">
                    <h3>Total Transaksi</h3>
                    <div class="stat-value">{{ number_format($mall->transaksiParkir->count()) }}</div>
                    <div class="stat-trend">Semua transaksi</div>
                </div>
            </div>

            <div class="stat-card">
                <div class="stat-icon info">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7v8a2 2 0 002 2h6M8 7V5a2 2 0 012-2h4.586a1 1 0 01.707.293l4.414 4.414a1 1 0 01.293.707V15a2 2 0 01-2 2h-2M8 7H6a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2v-2" />
                    </svg>
                </div>
                <div class="stat-content">
                    <h3>Area Parkir</h3>
                    <div class="stat-value">{{ $mall->parkiran->count() }}</div>
                    <div class="stat-trend">Total area</div>
                </div>
            </div>
        </div>

        <!-- Main Content Grid -->
        <div class="content-grid">

            <!-- Basic Information -->
            <div class="info-card">
                <div class="card-header">
                    <h3>Informasi Dasar</h3>
                </div>
                <div class="card-body">
                    <div class="info-grid">
                        <div class="info-item">
                            <label>Nama Mall</label>
                            <span>{{ $mall->nama_mall }}</span>
                        </div>
                        <div class="info-item">
                            <label>ID Mall</label>
                            <span>{{ $mall->id_mall }}</span>
                        </div>
                        <div class="info-item">
                            <label>Alamat Lengkap</label>
                            <span>{{ $mall->alamat_lengkap ?? '-' }}</span>
                        </div>
                        <div class="info-item">
                            <label>Status</label>
                            <span class="badge active">Aktif</span>
                        </div>
                        <div class="info-item">
                            <label>Kapasitas Total</label>
                            <span>{{ number_format($mall->kapasitas ?? 0) }} slot</span>
                        </div>
                        <div class="info-item">
                            <label>Slot Reservation</label>
                            <span class="badge {{ $mall->has_slot_reservation_enabled ? 'active' : 'inactive' }}">
                                {{ $mall->has_slot_reservation_enabled ? 'Aktif' : 'Nonaktif' }}
                            </span>
                        </div>
                        <div class="info-item">
                            <label>Terdaftar Sejak</label>
                            <span>{{ $mall->created_at ? $mall->created_at->translatedFormat('d F Y') : '-' }}</span>
                        </div>
                        <div class="info-item">
                            <label>Terakhir Update</label>
                            <span>{{ $mall->updated_at ? $mall->updated_at->translatedFormat('d F Y H:i') : '-' }}</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Contact Information -->
            <div class="info-card">
                <div class="card-header">
                    <h3>Kontak & Lokasi</h3>
                </div>
                <div class="card-body">
                    <div class="info-grid">
                        <div class="info-item">
                            <label>Alamat</label>
                            <span>{{ $mall->alamat_lengkap ?? '-' }}</span>
                        </div>
                        <div class="info-item">
                            <label>Google Maps</label>
                            <span>{{ $mall->alamat_gmaps ? 'Tersedia' : 'Belum diatur' }}</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Quick Actions -->
            <div class="info-card">
                <div class="card-header">
                    <h3>Aksi Cepat</h3>
                </div>
                <div class="card-body">
                    <div class="quick-actions">
                        <a href="{{ route('superadmin.mall.edit', $mall->id_mall) }}" class="quick-action-btn">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                            </svg>
                            Edit Mall
                        </a>
                        <button class="quick-action-btn" onclick="alert('Fitur dalam pengembangan')">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                            </svg>
                            Lihat Laporan
                        </button>
                        <button class="quick-action-btn" onclick="alert('Fitur dalam pengembangan')">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z" />
                            </svg>
                            Kelola Admin
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Parking & Rates Tab -->
    <div class="tab-content" id="parking-tab">
        <div class="tab-header">
            <h2>Konfigurasi Parkir & Tarif</h2>
            <p>Pengaturan kapasitas parkir dan struktur tarif</p>
        </div>

        <div class="content-grid">

            <!-- Parking Areas -->
            <div class="info-card">
                <div class="card-header">
                    <h3>Area Parkir</h3>
                    <span class="badge-count">{{ $mall->parkiran->count() }} Area</span>
                </div>
                <div class="card-body">
                    @if($mall->parkiran->count() > 0)
                    <div class="parking-areas-list">
                        @foreach($mall->parkiran as $parkir)
                        <div class="parking-area-item">
                            <div class="parking-area-icon">
                                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7v8a2 2 0 002 2h6M8 7V5a2 2 0 012-2h4.586a1 1 0 01.707.293l4.414 4.414a1 1 0 01.293.707V15a2 2 0 01-2 2h-2M8 7H6a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2v-2" />
                                </svg>
                            </div>
                            <div class="parking-area-info">
                                <strong>{{ $parkir->nama_parkiran }}</strong>
                                <p>{{ $parkir->kode_parkiran }} • {{ $parkir->kapasitas }} slot • {{ $parkir->jumlah_lantai }} lantai</p>
                                <span class="badge {{ strtolower($parkir->status) === 'tersedia' ? 'active' : 'inactive' }}">
                                    {{ $parkir->status }}
                                </span>
                            </div>
                        </div>
                        @endforeach
                    </div>
                    @else
                    <p class="text-muted">Belum ada area parkir</p>
                    @endif
                </div>
            </div>

            <!-- Tarif Parkir -->
            <div class="info-card">
                <div class="card-header">
                    <h3>Tarif Parkir</h3>
                    <span class="badge-count">{{ $mall->tarifParkir->count() }} Jenis</span>
                </div>
                <div class="card-body">
                    @if($mall->tarifParkir->count() > 0)
                    <div class="tarif-list">
                        @foreach($mall->tarifParkir as $tarif)
                        <div class="tarif-item">
                            <div class="tarif-type">{{ $tarif->jenis_kendaraan }}</div>
                            <div class="tarif-details">
                                <span>Jam Pertama: Rp {{ number_format($tarif->satu_jam_pertama, 0, ',', '.') }}</span>
                                <span>Per Jam: Rp {{ number_format($tarif->tarif_parkir_per_jam, 0, ',', '.') }}</span>
                            </div>
                        </div>
                        @endforeach
                    </div>
                    @else
                    <p class="text-muted">Belum ada tarif parkir</p>
                    @endif
                </div>
            </div>
        </div>
    </div>

    <!-- Admin & Staff Tab -->
    <div class="tab-content" id="admin-tab">
        <div class="tab-header">
            <h2>Admin & Staff</h2>
            <p>Daftar admin dan staff yang mengelola mall ini</p>
        </div>

        <div class="content-grid">
            <div class="info-card full-width">
                <div class="card-header">
                    <h3>Daftar Admin</h3>
                    <span class="badge-count">{{ $mall->adminMall->count() }} Admin</span>
                </div>
                <div class="card-body">
                    @if($mall->adminMall->count() > 0)
                    <div class="admin-grid">
                        @foreach($mall->adminMall as $admin)
                        <div class="admin-card">
                            <div class="admin-avatar-large">
                                <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                </svg>
                            </div>
                            <div class="admin-card-info">
                                <h4>{{ $admin->user->name ?? 'N/A' }}</h4>
                                <p>{{ $admin->user->email ?? '-' }}</p>
                                <span class="badge active">{{ $admin->hak_akses ?? 'Admin' }}</span>
                            </div>
                        </div>
                        @endforeach
                    </div>
                    @else
                    <p class="text-muted">Belum ada admin yang ditugaskan</p>
                    @endif
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script src="{{ asset('js/super-detail-mall.js') }}"></script>
@endpush

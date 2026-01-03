@extends('layouts.superadmin')

@section('title', 'Manajemen Mall - QPARKIN')

@push('styles')
<link rel="stylesheet" href="{{ asset('css/super-manajemen-mall.css') }}">
@endpush

@section('breadcrumb')
<span>Manajemen Mall</span>
@endsection

@section('content')
<!-- Page Header -->
<div class="page-header">
    <div class="header-content">
        <h1>Manajemen Mall</h1>
        <p>Kelola semua mall yang terdaftar dalam sistem QPARKIN</p>
    </div>
    <div class="header-actions">
        <a href="{{ route('superadmin.mall.create') }}" class="btn-primary">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
            </svg>
            Tambah Mall Baru
        </a>
    </div>
</div>

<!-- Mall Management Section -->
<div class="management-section">

    <!-- Search and Filter -->
    <div class="search-filter-bar">
        <div class="search-box">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
            <input type="text" id="searchInput" placeholder="Cari mall berdasarkan nama, lokasi, atau admin...">
        </div>
        <div class="filter-options">
            <select id="statusFilter">
                <option value="">Semua Status</option>
                <option value="active">Aktif</option>
                <option value="inactive">Nonaktif</option>
                <option value="maintenance">Maintenance</option>
            </select>
            <select id="regionFilter">
                <option value="">Semua Wilayah</option>
                <option value="jakarta">Jakarta</option>
                <option value="bodetabek">Bodetabek</option>
                <option value="jawa-barat">Jawa Barat</option>
                <option value="jawa-tengah">Jawa Tengah</option>
                <option value="jawa-timur">Jawa Timur</option>
            </select>
        </div>
    </div>

    <!-- Mall Cards Grid -->
    <div class="mall-cards-grid">
        @forelse($malls as $mall)
        <!-- Mall Card -->
        <div class="mall-card">
            <div class="mall-card-header">
                <div class="mall-status active">
                    <span class="status-dot"></span>
                    Aktif
                </div>
                <div class="mall-actions">
                    <a href="{{ route('superadmin.mall.edit', $mall->id_mall) }}" class="action-btn" title="Edit">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                        </svg>
                    </a>
                    <button class="action-btn" onclick="deleteMall({{ $mall->id_mall }})" title="Hapus">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                        </svg>
                    </button>
                </div>
            </div>
            <div class="mall-card-body">
                <div class="mall-logo">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                    </svg>
                </div>
                <div class="mall-info">
                    <h3 class="mall-name">{{ $mall->nama_mall }}</h3>
                    <p class="mall-location">{{ $mall->lokasi ?? '-' }}</p>
                    <div class="mall-stats">
                        <div class="stat">
                            <span class="stat-value">{{ number_format($mall->kapasitas ?? 0) }}</span>
                            <span class="stat-label">Slot Parkir</span>
                        </div>
                        <div class="stat">
                            <span class="stat-value">{{ $mall->parkiran->count() }}</span>
                            <span class="stat-label">Area</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="mall-card-footer">
                <div class="mall-admin">
                    <span class="admin-label">Admin:</span>
                    <span class="admin-name">{{ $mall->adminMall->first()->user->name ?? 'Belum ada' }}</span>
                </div>
                <a href="{{ route('superadmin.mall.detail', $mall->id_mall) }}" class="view-details">Lihat Detail</a>
            </div>
        </div>
        @empty
        <div class="empty-state-full">
            <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
            </svg>
            <p>Belum ada data mall</p>
            <a href="{{ route('superadmin.mall.create') }}" class="btn-primary">Tambah Mall Pertama</a>
        </div>
        @endforelse
    </div>

    <!-- Pagination -->
    @if($malls->count() > 0)
    <div class="pagination">
        <button class="pagination-btn disabled">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
            </svg>
        </button>
        <button class="pagination-btn active">1</button>
        <button class="pagination-btn">2</button>
        <button class="pagination-btn">3</button>
        <span class="pagination-ellipsis">...</span>
        <button class="pagination-btn">8</button>
        <button class="pagination-btn">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
        </button>
    </div>
    @endif
</div>
@endsection

@push('scripts')
<script src="{{ asset('js/super-manajemen-mall.js') }}"></script>
@endpush

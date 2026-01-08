@extends('layouts.superadmin')

@section('title', 'Pengajuan Akun')

@section('breadcrumb')
<span>Pengajuan Akun</span>
@endsection

@section('content')
<!-- Page Header -->
<div class="page-header">
    <h1>Pengajuan Akun Admin Mall</h1>
    <p>Kelola permohonan akun admin mall baru yang menunggu verifikasi</p>
</div>

<!-- Filter Section -->
<div class="filter-section">
    <div class="filter-controls">
        <div class="filter-group">
            <label for="statusFilter">Status</label>
            <select id="statusFilter" class="filter-select">
                <option value="all">Semua Status</option>
                <option value="pending" selected>Menunggu Verifikasi</option>
                <option value="approved">Disetujui</option>
                <option value="rejected">Ditolak</option>
            </select>
        </div>
        <div class="filter-group">
            <label for="dateFilter">Tanggal Pengajuan</label>
            <select id="dateFilter" class="filter-select">
                <option value="all">Semua Tanggal</option>
                <option value="today">Hari Ini</option>
                <option value="week">Minggu Ini</option>
                <option value="month">Bulan Ini</option>
            </select>
        </div>
        <div class="filter-group">
            <label for="searchInput">Cari</label>
            <div class="search-wrapper">
                <input type="text" id="searchInput" placeholder="Cari nama atau mall...">
                <button class="search-btn">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                </button>
            </div>
        </div>
    </div>
    <div class="filter-actions">
        <button class="btn-secondary" id="resetFilters">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
            </svg>
            Reset Filter
        </button>
    </div>
</div>

<!-- Applications Table -->
<div class="table-section">
    <div class="table-header">
        <h2>Daftar Pengajuan Akun</h2>
        <div class="table-actions">
            <span class="table-count">{{ count($requests ?? []) }} pengajuan ditemukan</span>
            <div class="action-buttons">
                <button class="btn-icon" id="exportBtn" title="Ekspor Data">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                    </svg>
                </button>
                <button class="btn-icon" id="refreshBtn" title="Refresh Data">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                    </svg>
                </button>
            </div>
        </div>
    </div>
    <div class="table-container">
        <table class="data-table">
            <thead>
                <tr>
                    <th>
                        <input type="checkbox" id="selectAll">
                    </th>
                    <th>Nama Lengkap</th>
                    <th>Email</th>
                    <th>Nama Mall</th>
                    <th>Lokasi</th>
                    <th>Tanggal Pengajuan</th>
                    <th>Status</th>
                    <th>Aksi</th>
                </tr>
            </thead>
            <tbody>
                @forelse($requests ?? [] as $request)
                <tr>
                    <td>
                        <input type="checkbox" class="row-checkbox" data-id="{{ $request->id_user ?? $request->id }}">
                    </td>
                    <td>
                        <div class="user-info-cell">
                            <div class="user-avatar">
                                <img src="{{ $request->avatar ? asset('storage/' . $request->avatar) : asset('images/avatar-placeholder.png') }}" alt="Avatar">
                            </div>
                            <div class="user-details">
                                <span class="user-name">{{ $request->name }}</span>
                                <span class="user-phone">{{ $request->nomor_hp ?? 'N/A' }}</span>
                            </div>
                        </div>
                    </td>
                    <td>{{ $request->email }}</td>
                    <td>{{ $request->requested_mall_name ?? 'N/A' }}</td>
                    <td>{{ $request->requested_mall_location ?? 'N/A' }}</td>
                    <td>{{ $request->applied_at ? \Carbon\Carbon::parse($request->applied_at)->format('d M Y H:i') : 'N/A' }}</td>
                    <td>
                        <span class="status-badge {{ $request->application_status == 'pending' ? 'pending' : ($request->application_status == 'approved' ? 'approved' : 'rejected') }}">
                            {{ $request->application_status == 'pending' ? 'Menunggu' : ($request->application_status == 'approved' ? 'Disetujui' : 'Ditolak') }}
                        </span>
                    </td>
                    <td>
                        <div class="action-buttons">
                            @if($request->application_status == 'pending')
                            <button class="btn-action approve" data-id="{{ $request->id_user ?? $request->id }}" title="Setujui">
                                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                                </svg>
                            </button>
                            <button class="btn-action reject" data-id="{{ $request->id_user ?? $request->id }}" title="Tolak">
                                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                                </svg>
                            </button>
                            @endif
                            <button class="btn-action view" data-id="{{ $request->id_user ?? $request->id }}" title="Lihat Detail">
                                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                </svg>
                            </button>
                        </div>
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="8" class="text-center">Tidak ada pengajuan akun</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>

<!-- Bulk Actions -->
<div class="bulk-actions" id="bulkActions" style="display: none;">
    <div class="bulk-info">
        <span id="selectedCount">0</span> pengajuan dipilih
    </div>
    <div class="bulk-buttons">
        <button class="btn-bulk approve" id="bulkApprove">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
            Setujui yang Dipilih
        </button>
        <button class="btn-bulk reject" id="bulkReject">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
            Tolak yang Dipilih
        </button>
    </div>
</div>
@endsection

@push('styles')
<link rel="stylesheet" href="{{ asset('css/super-pengajuan-akun.css') }}">
@endpush

@push('scripts')
<script src="{{ asset('js/super-pengajuan-akun.js') }}"></script>
@endpush

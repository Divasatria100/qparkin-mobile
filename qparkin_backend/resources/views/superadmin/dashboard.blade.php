@extends('layouts.superadmin')

@section('title', 'Dashboard Super Admin')

@section('breadcrumb')
<span>Dashboard</span>
@endsection

@section('content')
<!-- System Overview Cards -->
<div class="cards-grid">
    <div class="card">
        <div class="card-header">
            <h3>Total Mall Terdaftar</h3>
        </div>
        <div class="card-body">
            <div class="card-value">{{ $totalMalls ?? 0 }}</div>
            <div class="card-trend positive">
                <span>+3</span> bulan ini
            </div>
        </div>
    </div>
    <div class="card">
        <div class="card-header">
            <h3>Total Pendapatan Sistem</h3>
        </div>
        <div class="card-body">
            <div class="card-value">Rp {{ number_format($totalRevenue ?? 0, 0, ',', '.') }}</div>
            <div class="card-trend positive">
                <span>+15.8%</span> dari bulan lalu
            </div>
        </div>
    </div>
    <div class="card">
        <div class="card-header">
            <h3>Admin Aktif</h3>
        </div>
        <div class="card-body">
            <div class="card-value">{{ $activeAdmins ?? 0 }}</div>
            <div class="card-trend positive">
                <span>+5</span> dari bulan lalu
            </div>
        </div>
    </div>
    <div class="card">
        <div class="card-header">
            <h3>Pengajuan Akun Baru</h3>
        </div>
        <div class="card-body">
            <div class="card-value">{{ $pendingRequests ?? 0 }}</div>
            <div class="card-trend negative">
                Menunggu verifikasi
            </div>
        </div>
    </div>
    <div class="card">
        <div class="card-header">
            <h3>Transaksi Hari Ini</h3>
        </div>
        <div class="card-body">
            <div class="card-value">{{ number_format($todayTransactions ?? 0, 0, ',', '.') }}</div>
            <div class="card-trend positive">
                <span>+8.3%</span> dari kemarin
            </div>
        </div>
    </div>
    <div class="card">
        <div class="card-header">
            <h3>Pengguna Aktif</h3>
        </div>
        <div class="card-body">
            <div class="card-value">{{ number_format($activeUsers ?? 0, 0, ',', '.') }}</div>
            <div class="card-trend positive">
                <span>+12.5%</span> growth
            </div>
        </div>
    </div>
</div>

<!-- Quick Actions -->
<div class="quick-actions-section">
    <h2 class="section-title">Aksi Cepat</h2>
    <div class="actions-grid">
        <a href="{{ route('superadmin.pengajuan') }}" class="action-card">
            <div class="action-icon pending">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z" />
                </svg>
            </div>
            <div class="action-content">
                <h3>Verifikasi Pengajuan</h3>
                <p>{{ $pendingRequests ?? 0 }} permohonan menunggu</p>
            </div>
        </a>
        <a href="{{ route('superadmin.mall') }}" class="action-card">
            <div class="action-icon primary">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                </svg>
            </div>
            <div class="action-content">
                <h3>Kelola Mall</h3>
                <p>Tambah atau edit mall</p>
            </div>
        </a>
        <a href="{{ route('superadmin.laporan') }}" class="action-card">
            <div class="action-icon success">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                </svg>
            </div>
            <div class="action-content">
                <h3>Laporan Sistem</h3>
                <p>Analitik dan statistik</p>
            </div>
        </a>
    </div>
</div>

<!-- Recent Activity & Mall Performance -->
<div class="dashboard-grid">
    <!-- Recent Activity -->
    <div class="table-section">
        <div class="table-header">
            <h2>Aktivitas Terbaru</h2>
            <a href="#" class="view-all">Lihat Semua</a>
        </div>
        <div class="table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Waktu</th>
                        <th>Aktivitas</th>
                        <th>Lokasi</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($recentActivities ?? [] as $activity)
                    <tr>
                        <td>{{ $activity->time }}</td>
                        <td>{{ $activity->description }}</td>
                        <td>{{ $activity->location }}</td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="3" style="text-align: center;">Tidak ada aktivitas</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <!-- Top Performing Malls -->
    <div class="table-section">
        <div class="table-header">
            <h2>Top 5 Mall</h2>
            <a href="{{ route('superadmin.laporan') }}" class="view-all">Lihat Ranking</a>
        </div>
        <div class="table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Peringkat</th>
                        <th>Nama Mall</th>
                        <th>Pendapatan</th>
                        <th>Growth</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($topMalls ?? [] as $index => $mall)
                    <tr>
                        <td>{{ $index + 1 }}</td>
                        <td>{{ $mall->name }}</td>
                        <td>Rp {{ number_format($mall->revenue, 0, ',', '.') }}</td>
                        <td class="{{ $mall->growth >= 0 ? 'positive' : 'negative' }}">{{ $mall->growth }}%</td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="4" style="text-align: center;">Tidak ada data</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
</div>
@endsection

@push('styles')
<link rel="stylesheet" href="{{ asset_version('css/super-dashboard.css') }}">
@endpush

@push('scripts')
<script src="{{ asset_version('js/super-dashboard.js') }}"></script>
@endpush

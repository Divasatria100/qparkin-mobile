@extends('layouts.superadmin')

@section('title', 'Laporan & Analitik')

@section('breadcrumb')
<span>Laporan & Analitik</span>
@endsection

@section('content')
<!-- Page Header -->
<div class="page-header">
    <div class="header-content">
        <div class="header-text">
            <h1>Laporan & Analitik Sistem</h1>
            <p>Analisis komprehensif kinerja sistem dan semua mall terdaftar</p>
        </div>
        <div class="header-actions">
            <button class="btn-primary" id="generateReport">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
                Generate Laporan
            </button>
        </div>
    </div>
</div>

<!-- Date Range Filter -->
<div class="filter-section">
    <div class="filter-controls">
        <div class="filter-group">
            <label for="dateRange">Rentang Waktu</label>
            <select id="dateRange" class="filter-select">
                <option value="7days">7 Hari Terakhir</option>
                <option value="30days" selected>30 Hari Terakhir</option>
                <option value="90days">90 Hari Terakhir</option>
                <option value="custom">Kustom</option>
            </select>
        </div>
        <div class="filter-group custom-date" id="customDateRange" style="display: none;">
            <label for="startDate">Dari Tanggal</label>
            <input type="date" id="startDate" class="filter-select">
        </div>
        <div class="filter-group custom-date" id="customDateRangeEnd" style="display: none;">
            <label for="endDate">Sampai Tanggal</label>
            <input type="date" id="endDate" class="filter-select">
        </div>
        <div class="filter-group">
            <label for="mallFilter">Mall</label>
            <select id="mallFilter" class="filter-select">
                <option value="all">Semua Mall</option>
                @foreach($mallPerformance as $mall)
                <option value="{{ $mall->id_mall }}">{{ $mall->nama_mall }}</option>
                @endforeach
            </select>
        </div>
    </div>
    <div class="filter-actions">
        <button class="btn-secondary" id="applyFilters">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z" />
            </svg>
            Terapkan Filter
        </button>
    </div>
</div>

<!-- KPI Cards -->
<div class="kpi-grid">
    <div class="kpi-card">
        <div class="kpi-header">
            <h3>Total Pendapatan</h3>
            <div class="kpi-trend {{ $revenueGrowth >= 0 ? 'positive' : 'negative' }}">
                {{ $revenueGrowth >= 0 ? '+' : '' }}{{ $revenueGrowth }}%
            </div>
        </div>
        <div class="kpi-value">Rp {{ number_format($totalRevenue / 1000000, 1) }}M</div>
        <div class="kpi-subtitle">30 Hari Terakhir</div>
    </div>
    <div class="kpi-card">
        <div class="kpi-header">
            <h3>Total Transaksi</h3>
            <div class="kpi-trend {{ $transactionGrowth >= 0 ? 'positive' : 'negative' }}">
                {{ $transactionGrowth >= 0 ? '+' : '' }}{{ $transactionGrowth }}%
            </div>
        </div>
        <div class="kpi-value">{{ number_format($totalTransactions / 1000, 1) }}K</div>
        <div class="kpi-subtitle">30 Hari Terakhir</div>
    </div>
    <div class="kpi-card">
        <div class="kpi-header">
            <h3>Pengguna Aktif</h3>
            <div class="kpi-trend {{ $userGrowth >= 0 ? 'positive' : 'negative' }}">
                {{ $userGrowth >= 0 ? '+' : '' }}{{ $userGrowth }}%
            </div>
        </div>
        <div class="kpi-value">{{ number_format($activeUsers / 1000, 1) }}K</div>
        <div class="kpi-subtitle">Pengguna Unik</div>
    </div>
    <div class="kpi-card">
        <div class="kpi-header">
            <h3>Rata-rata Waktu Parkir</h3>
            <div class="kpi-trend negative">
                -2.1%
            </div>
        </div>
        <div class="kpi-value">{{ $avgParkingHours }} Jam</div>
        <div class="kpi-subtitle">Per Kendaraan</div>
    </div>
</div>

<!-- Charts Section -->
<div class="charts-grid">
    <!-- Revenue Chart -->
    <div class="chart-section">
        <div class="chart-header">
            <h3>Pendapatan Harian</h3>
            <div class="chart-actions">
                <button class="chart-action-btn active" data-period="7d">7D</button>
                <button class="chart-action-btn" data-period="30d">30D</button>
                <button class="chart-action-btn" data-period="90d">90D</button>
            </div>
        </div>
        <div class="chart-container">
            <canvas id="revenueChart"></canvas>
        </div>
    </div>

    <!-- Transaction Chart -->
    <div class="chart-section">
        <div class="chart-header">
            <h3>Volume Transaksi</h3>
            <div class="chart-actions">
                <button class="chart-action-btn active" data-period="7d">7D</button>
                <button class="chart-action-btn" data-period="30d">30D</button>
                <button class="chart-action-btn" data-period="90d">90D</button>
            </div>
        </div>
        <div class="chart-container">
            <canvas id="transactionChart"></canvas>
        </div>
    </div>

    <!-- Mall Performance -->
    <div class="chart-section">
        <div class="chart-header">
            <h3>Kinerja per Mall</h3>
            <div class="chart-actions">
                <button class="chart-action-btn active" data-metric="revenue">Pendapatan</button>
                <button class="chart-action-btn" data-metric="transactions">Transaksi</button>
            </div>
        </div>
        <div class="chart-container">
            <canvas id="mallPerformanceChart"></canvas>
        </div>
    </div>

    <!-- Peak Hours -->
    <div class="chart-section">
        <div class="chart-header">
            <h3>Jam Sibuk</h3>
            <div class="chart-actions">
                <button class="chart-action-btn active" data-day="weekday">Weekday</button>
                <button class="chart-action-btn" data-day="weekend">Weekend</button>
            </div>
        </div>
        <div class="chart-container">
            <canvas id="peakHoursChart"></canvas>
        </div>
    </div>
</div>

<!-- Detailed Reports Section -->
<div class="reports-section">
    <div class="section-header">
        <h2>Laporan Detail</h2>
        <div class="section-actions">
            <button class="btn-secondary" id="exportAll">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
                Ekspor Semua
            </button>
        </div>
    </div>

    <div class="reports-grid">
        <!-- Financial Report -->
        <div class="report-card">
            <div class="report-header">
                <div class="report-icon financial">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                </div>
                <h3>Laporan Keuangan</h3>
            </div>
            <div class="report-content">
                <p>Ringkasan pendapatan, pengeluaran, dan profit margin</p>
                <div class="report-stats">
                    <div class="stat">
                        <span class="stat-value">Rp {{ number_format($totalRevenue / 1000000, 1) }}M</span>
                        <span class="stat-label">Total Pendapatan</span>
                    </div>
                    <div class="stat">
                        <span class="stat-value">Rp {{ number_format($totalRevenue * 0.75 / 1000000, 1) }}M</span>
                        <span class="stat-label">Profit Bersih</span>
                    </div>
                </div>
            </div>
            <div class="report-actions">
                <button class="btn-report view" data-report="financial">Lihat Detail</button>
                <button class="btn-report export" data-report="financial">Ekspor</button>
            </div>
        </div>

        <!-- Transaction Report -->
        <div class="report-card">
            <div class="report-header">
                <div class="report-icon transaction">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z" />
                    </svg>
                </div>
                <h3>Laporan Transaksi</h3>
            </div>
            <div class="report-content">
                <p>Analisis volume dan pola transaksi parkir</p>
                <div class="report-stats">
                    <div class="stat">
                       

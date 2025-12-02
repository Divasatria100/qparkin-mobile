@extends('layouts.superadmin')

@section('title', 'Laporan & Analitik')

@section('breadcrumb')
<span>Laporan & Analitik</span>
@endsection

@section('content')
<div class="laporan-section">
    <div class="section-header">
        <h2>Laporan & Analitik Sistem</h2>
        <div class="header-actions">
            <select class="filter-select" id="periodFilter">
                <option value="daily">Harian</option>
                <option value="weekly">Mingguan</option>
                <option value="monthly" selected>Bulanan</option>
                <option value="yearly">Tahunan</option>
            </select>
            <button class="btn btn-primary">Export PDF</button>
            <button class="btn btn-secondary">Export Excel</button>
        </div>
    </div>

    <!-- Summary Cards -->
    <div class="cards-grid">
        <div class="card">
            <div class="card-header">
                <h3>Total Transaksi</h3>
            </div>
            <div class="card-body">
                <div class="card-value">{{ number_format($totalTransactions ?? 0, 0, ',', '.') }}</div>
            </div>
        </div>
        <div class="card">
            <div class="card-header">
                <h3>Total Pendapatan</h3>
            </div>
            <div class="card-body">
                <div class="card-value">Rp {{ number_format($totalRevenue ?? 0, 0, ',', '.') }}</div>
            </div>
        </div>
        <div class="card">
            <div class="card-header">
                <h3>Rata-rata per Mall</h3>
            </div>
            <div class="card-body">
                <div class="card-value">Rp {{ number_format($averagePerMall ?? 0, 0, ',', '.') }}</div>
            </div>
        </div>
    </div>

    <!-- Revenue Chart -->
    <div class="chart-section">
        <h3>Grafik Pendapatan</h3>
        <canvas id="revenueChart"></canvas>
    </div>

    <!-- Mall Performance Table -->
    <div class="table-section">
        <div class="table-header">
            <h2>Performa Mall</h2>
        </div>
        <div class="table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Ranking</th>
                        <th>Nama Mall</th>
                        <th>Total Transaksi</th>
                        <th>Pendapatan</th>
                        <th>Growth</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($mallPerformance ?? [] as $index => $mall)
                    <tr>
                        <td>{{ $index + 1 }}</td>
                        <td>{{ $mall->name }}</td>
                        <td>{{ number_format($mall->transactions, 0, ',', '.') }}</td>
                        <td>Rp {{ number_format($mall->revenue, 0, ',', '.') }}</td>
                        <td class="{{ $mall->growth >= 0 ? 'positive' : 'negative' }}">{{ $mall->growth }}%</td>
                        <td>
                            <a href="{{ route('superadmin.mall.detail', $mall->id) }}" class="btn-action">Detail</a>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="6" style="text-align: center;">Tidak ada data</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
</div>
@endsection

@push('styles')
<link rel="stylesheet" href="{{ asset('css/super-laporan.css') }}">
@endpush

@push('scripts')
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script src="{{ asset('js/super-laporan.js') }}"></script>
@endpush

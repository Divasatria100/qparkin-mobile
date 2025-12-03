@extends('layouts.admin')

@section('title', 'Dashboard Admin')

@section('breadcrumb')
<span>Dashboard</span>
@endsection

@section('content')
<!-- Cards Section -->
<div class="cards-grid">
    <div class="card">
        <div class="card-header">
            <h3>Pendapatan Harian</h3>
        </div>
        <div class="card-body">
            <div class="card-value">Rp {{ number_format($dailyRevenue ?? 0, 0, ',', '.') }}</div>
            <div class="card-trend positive">
                <span>+12.5%</span> dari kemarin
            </div>
        </div>
    </div>
    <div class="card">
        <div class="card-header">
            <h3>Pendapatan Mingguan</h3>
        </div>
        <div class="card-body">
            <div class="card-value">Rp {{ number_format($weeklyRevenue ?? 0, 0, ',', '.') }}</div>
            <div class="card-trend positive">
                <span>+8.3%</span> dari minggu lalu
            </div>
        </div>
    </div>
    <div class="card">
        <div class="card-header">
            <h3>Pendapatan Bulanan</h3>
        </div>
        <div class="card-body">
            <div class="card-value">Rp {{ number_format($monthlyRevenue ?? 0, 0, ',', '.') }}</div>
            <div class="card-trend negative">
                <span>-2.1%</span> dari bulan lalu
            </div>
        </div>
    </div>
    <div class="card">
        <div class="card-header">
            <h3>Tiket Masuk</h3>
        </div>
        <div class="card-body">
            <div class="card-value">{{ $ticketsIn ?? 0 }}</div>
        </div>
    </div>
    <div class="card">
        <div class="card-header">
            <h3>Tiket Keluar</h3>
        </div>
        <div class="card-body">
            <div class="card-value">{{ $ticketsOut ?? 0 }}</div>
        </div>
    </div>
    <div class="card">
        <div class="card-header">
            <h3>Sedang Parkir</h3>
        </div>
        <div class="card-body">
            <div class="card-value">{{ $currentParking ?? 0 }}</div>
        </div>
    </div>
</div>

<!-- Transaction History -->
<div class="table-section">
    <div class="table-header">
        <h2>Riwayat Transaksi Terbaru</h2>
        <a href="{{ route('admin.tiket') }}" class="view-all">Lihat Semua</a>
    </div>
    <div class="table-container">
        <table class="data-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Plat</th>
                    <th>Jenis</th>
                    <th>Jam Masuk</th>
                    <th>Jam Keluar</th>
                    <th>Durasi Parkir</th>
                    <th>Biaya</th>
                </tr>
            </thead>
            <tbody>
                @forelse($recentTransactions ?? [] as $transaction)
                <tr>
                    <td>{{ $transaction->id }}</td>
                    <td>{{ $transaction->license_plate }}</td>
                    <td>{{ $transaction->vehicle_type }}</td>
                    <td>{{ $transaction->entry_time }}</td>
                    <td>{{ $transaction->exit_time ?? '-' }}</td>
                    <td>{{ $transaction->duration ?? '-' }}</td>
                    <td>Rp {{ number_format($transaction->fee ?? 0, 0, ',', '.') }}</td>
                </tr>
                @empty
                <tr>
                    <td colspan="7" style="text-align: center;">Tidak ada transaksi</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>
@endsection

@push('styles')
<link rel="stylesheet" href="{{ asset('css/admin-dashboard.css') }}">
@endpush

@push('scripts')
<script src="{{ asset('js/admin-dashboard.js') }}"></script>
@endpush

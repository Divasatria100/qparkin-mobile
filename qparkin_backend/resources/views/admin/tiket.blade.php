@extends('layouts.admin')

@section('title', 'Tiket - QPARKIN')

@section('styles')
<link rel="stylesheet" href="{{ asset('css/admin-tiket.css') }}">
@endsection

@section('content')
<!-- Breadcrumb -->
<div class="breadcrumb">
    <span>Tiket</span>
</div>

<!-- Search and Filter Section -->
<div class="search-filter-section">
    <div class="search-box">
        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
        </svg>
        <input type="text" id="searchInput" placeholder="Cari plat nomor, ID, atau jenis kendaraan...">
    </div>
    <div class="filter-controls">
        <div class="date-filter">
            <input type="date" id="startDate" class="date-input" value="{{ request('start_date') }}">
            <span>sampai</span>
            <input type="date" id="endDate" class="date-input" value="{{ request('end_date') }}">
        </div>
        <select id="statusFilter" onchange="filterByStatus(this.value)">
            <option value="">Semua Status</option>
            <option value="sedang_parkir" {{ request('status') === 'sedang_parkir' ? 'selected' : '' }}>Sedang Parkir</option>
            <option value="selesai" {{ request('status') === 'selesai' ? 'selected' : '' }}>Selesai</option>
        </select>
    </div>
</div>

<!-- Tiket Table -->
<div class="table-section">
    <div class="table-header">
        <h2>Data Tiket ({{ $tickets->total() }})</h2>
        <div class="table-actions">
            <button class="export-btn" onclick="exportData()">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
                Ekspor Data
            </button>
        </div>
    </div>
    <div class="table-container">
        <table class="data-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Plat</th>
                    <th>Kendaraan</th>
                    <th>Pengguna</th>
                    <th>Status</th>
                    <th>Aksi</th>
                </tr>
            </thead>
            <tbody>
                @forelse($tickets as $ticket)
                <tr>
                    <td>TRX{{ str_pad($ticket->id_transaksi, 6, '0', STR_PAD_LEFT) }}</td>
                    <td>{{ $ticket->kendaraan->plat_nomor ?? '-' }}</td>
                    <td>{{ $ticket->kendaraan->jenis_kendaraan ?? '-' }}</td>
                    <td>
                        @if($ticket->kendaraan && $ticket->kendaraan->customer)
                            <span class="badge booking">Booking</span>
                        @else
                            <span class="badge umum">Umum</span>
                        @endif
                    </td>
                    <td>
                        @if($ticket->waktu_keluar)
                            <span class="status selesai">Selesai</span>
                        @else
                            <span class="status sedang-parkir">Sedang Parkir</span>
                        @endif
                    </td>
                    <td>
                        <div class="action-buttons">
                            <button class="btn-detail" onclick="window.location.href='{{ route('admin.tiket.detail', $ticket->id_transaksi) }}'">Detail</button>
                        </div>
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="6" style="text-align: center; padding: 40px;">
                        <div style="color: #64748b;">
                            <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="none" viewBox="0 0 24 24" stroke="currentColor" style="margin: 0 auto 16px; display: block; opacity: 0.5;">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                            </svg>
                            <p style="font-size: 1.125rem; font-weight: 600; margin-bottom: 8px;">Tidak Ada Data Tiket</p>
                            <p style="font-size: 0.875rem;">Belum ada transaksi parkir yang tercatat.</p>
                        </div>
                    </td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <!-- Pagination -->
    @if($tickets->hasPages())
    <div class="pagination-container">
        <div class="pagination-info">
            Menampilkan {{ $tickets->firstItem() }} - {{ $tickets->lastItem() }} dari {{ $tickets->total() }} data
        </div>
        <div class="pagination-links">
            {{ $tickets->links() }}
        </div>
    </div>
    @endif
</div>
@endsection

@section('scripts')
<script>
    function filterByStatus(status) {
        const url = new URL(window.location.href);
        if (status) {
            url.searchParams.set('status', status);
        } else {
            url.searchParams.delete('status');
        }
        window.location.href = url.toString();
    }

    function exportData() {
        window.location.href = '{{ route("admin.tiket") }}?export=excel';
    }

    // Search functionality
    document.getElementById('searchInput').addEventListener('input', function(e) {
        const searchTerm = e.target.value.toLowerCase();
        const rows = document.querySelectorAll('.data-table tbody tr');
        
        rows.forEach(row => {
            const text = row.textContent.toLowerCase();
            row.style.display = text.includes(searchTerm) ? '' : 'none';
        });
    });

    // Date filter
    document.getElementById('startDate').addEventListener('change', applyDateFilter);
    document.getElementById('endDate').addEventListener('change', applyDateFilter);

    function applyDateFilter() {
        const startDate = document.getElementById('startDate').value;
        const endDate = document.getElementById('endDate').value;
        
        if (startDate && endDate) {
            const url = new URL(window.location.href);
            url.searchParams.set('start_date', startDate);
            url.searchParams.set('end_date', endDate);
            window.location.href = url.toString();
        }
    }
</script>
<script src="{{ asset('js/admin-dashboard.js') }}"></script>
@endsection

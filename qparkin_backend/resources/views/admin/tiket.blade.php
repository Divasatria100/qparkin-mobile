@extends('layouts.admin')

@section('title', 'Tiket')

@section('breadcrumb')
<span>Tiket</span>
@endsection

@section('content')
<div class="table-section">
    <div class="table-header">
        <h2>Daftar Tiket Parkir</h2>
        <div class="header-actions">
            <input type="text" class="search-input" placeholder="Cari tiket...">
            <button class="btn btn-primary">Export Excel</button>
        </div>
    </div>
    
    <div class="table-container">
        <table class="data-table">
            <thead>
                <tr>
                    <th>ID Tiket</th>
                    <th>Plat Nomor</th>
                    <th>Jenis Kendaraan</th>
                    <th>Jam Masuk</th>
                    <th>Jam Keluar</th>
                    <th>Durasi</th>
                    <th>Biaya</th>
                    <th>Status</th>
                    <th>Aksi</th>
                </tr>
            </thead>
            <tbody>
                @forelse($tickets ?? [] as $ticket)
                <tr>
                    <td>{{ $ticket->id }}</td>
                    <td>{{ $ticket->license_plate }}</td>
                    <td>{{ $ticket->vehicle_type }}</td>
                    <td>{{ $ticket->entry_time }}</td>
                    <td>{{ $ticket->exit_time ?? '-' }}</td>
                    <td>{{ $ticket->duration ?? '-' }}</td>
                    <td>Rp {{ number_format($ticket->fee ?? 0, 0, ',', '.') }}</td>
                    <td>
                        <span class="badge badge-{{ $ticket->status == 'active' ? 'warning' : 'success' }}">
                            {{ ucfirst($ticket->status) }}
                        </span>
                    </td>
                    <td>
                        <a href="{{ route('admin.tiket.detail', $ticket->id) }}" class="btn-action">Detail</a>
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="9" style="text-align: center;">Tidak ada data tiket</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>
    
    <div class="pagination">
        {{ $tickets->links() ?? '' }}
    </div>
</div>
@endsection

@push('styles')
<link rel="stylesheet" href="{{ asset('css/admin-tiket.css') }}">
@endpush

@push('scripts')
<script src="{{ asset('js/admin-tiket.js') }}"></script>
@endpush

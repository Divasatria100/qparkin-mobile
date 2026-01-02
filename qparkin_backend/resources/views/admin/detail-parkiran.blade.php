@extends('layouts.admin')

@section('title', 'Detail Parkiran - QPARKIN')

@section('styles')
<link rel="stylesheet" href="{{ asset('css/detail-parkiran.css') }}">
@endsection

@section('content')
<div class="breadcrumb">
    <a href="{{ route('admin.parkiran') }}" class="breadcrumb-link">Parkiran</a>
    <span class="breadcrumb-separator">/</span>
    <span>Detail Parkiran</span>
</div>

<div class="parkiran-detail-container">
    <div class="detail-header">
        <div class="header-left">
            <h2>{{ $parkiran->nama_parkiran ?? 'Parkiran ' . $parkiran->id_parkiran }}</h2>
            <div class="header-info">
                <span class="status-badge {{ strtolower($parkiran->status) == 'tersedia' ? 'active' : (strtolower($parkiran->status) == 'maintenance' ? 'maintenance' : 'closed') }}">
                    {{ $parkiran->status }}
                </span>
                @if($parkiran->kode_parkiran)
                <span class="kode-badge">{{ $parkiran->kode_parkiran }}</span>
                @endif
            </div>
        </div>
        <div class="header-actions">
            <a href="{{ route('admin.parkiran') }}" class="btn-back">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
                </svg>
                Kembali
            </a>
            <a href="{{ route('admin.parkiran.edit', $parkiran->id_parkiran) }}" class="btn-edit">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                </svg>
                Edit Parkiran
            </a>
        </div>
    </div>

    <div class="detail-content">
        <div class="overview-section">
            <h3>Overview Parkiran</h3>
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon total-lantai">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                        </svg>
                    </div>
                    <div class="stat-info">
                        <span class="stat-value">{{ $parkiran->jumlah_lantai ?? $parkiran->floors->count() }}</span>
                        <span class="stat-label">Total Lantai</span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon total-slot">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                        </svg>
                    </div>
                    <div class="stat-info">
                        <span class="stat-value">{{ $parkiran->kapasitas }}</span>
                        <span class="stat-label">Total Slot</span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon available">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                        </svg>
                    </div>
                    <div class="stat-info">
                        <span class="stat-value">{{ $parkiran->total_available }}</span>
                        <span class="stat-label">Tersedia</span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon occupied">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    </div>
                    <div class="stat-info">
                        <span class="stat-value">{{ $parkiran->total_occupied }}</span>
                        <span class="stat-label">Terisi</span>
                    </div>
                </div>
            </div>

            <div class="utilization-chart">
                <h4>Utilisasi Parkiran</h4>
                <div class="chart-container">
                    <div class="chart-bar">
                        <div class="chart-fill" style="width: {{ $parkiran->utilization }}%"></div>
                    </div>
                    <div class="chart-labels">
                        <span>0%</span>
                        <span>{{ $parkiran->utilization }}%</span>
                        <span>100%</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="lantai-section">
            <div class="section-header">
                <h3>Detail Lantai</h3>
            </div>

            <div class="lantai-container grid-view">
                @foreach($parkiran->floors as $floor)
                <div class="lantai-card">
                    <div class="lantai-card-header">
                        <h4>{{ $floor->floor_name }}</h4>
                        <div class="lantai-header-badges">
                            <span class="lantai-badge">Lantai {{ $floor->floor_number }}</span>
                            <span class="status-badge-small {{ $floor->status == 'active' ? 'active' : ($floor->status == 'maintenance' ? 'maintenance' : 'inactive') }}">
                                @if($floor->status == 'active')
                                    Aktif
                                @elseif($floor->status == 'maintenance')
                                    Maintenance
                                @else
                                    Tidak Aktif
                                @endif
                            </span>
                        </div>
                    </div>
                    <div class="lantai-card-body">
                        <div class="lantai-stats">
                            <div class="lantai-stat">
                                <span class="label">Total Slot</span>
                                <span class="value">{{ $floor->total_slots }}</span>
                            </div>
                            <div class="lantai-stat">
                                <span class="label">Tersedia</span>
                                <span class="value available">{{ $floor->available_slots }}</span>
                            </div>
                            <div class="lantai-stat">
                                <span class="label">Terisi</span>
                                <span class="value occupied">{{ $floor->total_slots - $floor->available_slots }}</span>
                            </div>
                        </div>
                        @if($floor->status == 'maintenance')
                        <div class="lantai-warning">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-1.964-1.333-2.732 0L4.082 16c-.77 1.333.192 3 1.732 3z" />
                            </svg>
                            <span>Lantai sedang maintenance - tidak bisa di-booking</span>
                        </div>
                        @endif
                        <div class="lantai-progress">
                            <div class="progress-bar">
                                <div class="progress-fill" style="width: {{ $floor->total_slots > 0 ? round((($floor->total_slots - $floor->available_slots) / $floor->total_slots) * 100, 2) : 0 }}%"></div>
                            </div>
                            <span class="progress-text">{{ $floor->total_slots > 0 ? round((($floor->total_slots - $floor->available_slots) / $floor->total_slots) * 100, 2) : 0 }}% Terisi</span>
                        </div>
                    </div>
                </div>
                @endforeach
            </div>
        </div>

        <div class="slot-detail-section">
            <h3>Detail Slot Parkir</h3>
            <div class="slot-filters">
                <div class="filter-group">
                    <label for="filterLantai">Filter Lantai:</label>
                    <select id="filterLantai">
                        <option value="all">Semua Lantai</option>
                        @foreach($parkiran->floors as $floor)
                        <option value="{{ $floor->id_floor }}">{{ $floor->floor_name }}</option>
                        @endforeach
                    </select>
                </div>
                <div class="filter-group">
                    <label for="filterStatus">Filter Status:</label>
                    <select id="filterStatus">
                        <option value="all">Semua Status</option>
                        <option value="available">Tersedia</option>
                        <option value="occupied">Terisi</option>
                        <option value="reserved">Reserved</option>
                        <option value="maintenance">Maintenance</option>
                    </select>
                </div>
            </div>

            <div class="slot-grid" id="slotGrid">
                @foreach($parkiran->floors as $floor)
                    @foreach($floor->slots as $slot)
                    @php
                        // Derive display status from parent floor
                        $displayStatus = $floor->status == 'maintenance' ? 'maintenance' : $slot->status;
                        $displayStatusText = $floor->status == 'maintenance' ? 'Maintenance' : ucfirst($slot->status);
                    @endphp
                    <div class="slot-item {{ $displayStatus }}" data-floor="{{ $floor->id_floor }}" data-status="{{ $displayStatus }}" data-floor-status="{{ $floor->status }}">
                        <div class="slot-code">{{ $slot->slot_code }}</div>
                        <div class="slot-status">{{ $displayStatusText }}</div>
                    </div>
                    @endforeach
                @endforeach
            </div>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script>
document.addEventListener('DOMContentLoaded', function() {
    const filterLantai = document.getElementById('filterLantai');
    const filterStatus = document.getElementById('filterStatus');
    const slotGrid = document.getElementById('slotGrid');
    const slots = slotGrid.querySelectorAll('.slot-item');

    function filterSlots() {
        const selectedFloor = filterLantai.value;
        const selectedStatus = filterStatus.value;

        slots.forEach(slot => {
            const floorMatch = selectedFloor === 'all' || slot.dataset.floor === selectedFloor;
            // Use the derived display status (which includes floor maintenance)
            const displayStatus = slot.dataset.status;
            const statusMatch = selectedStatus === 'all' || displayStatus === selectedStatus;

            if (floorMatch && statusMatch) {
                slot.style.display = 'flex';
            } else {
                slot.style.display = 'none';
            }
        });
    }

    filterLantai.addEventListener('change', filterSlots);
    filterStatus.addEventListener('change', filterSlots);
    
    console.log('Detail parkiran loaded - Floor maintenance status is derived to slots');
});
</script>
@endsection

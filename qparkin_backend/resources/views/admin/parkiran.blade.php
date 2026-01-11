@extends('layouts.admin')

@section('title', 'Parkiran - QPARKIN')

@section('styles')
<link rel="stylesheet" href="{{ asset('css/parkiran.css') }}">
@endsection

@section('content')
<div class="breadcrumb">
    <span>Parkiran</span>
</div>

<!-- Header Section -->
<div class="parkiran-header">
    <div class="header-left">
        <h1>Manajemen Parkiran Mall</h1>
        <p class="subtitle">Kelola area parkir dan lokasi parkir di mall Anda</p>
    </div>
    <div class="header-actions">
        @if($hasExistingParkiran)
            <button class="btn-tambah" disabled style="opacity: 0.5; cursor: not-allowed;" title="Mall sudah memiliki 1 parkiran">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                </svg>
                Tambah Parkiran
            </button>
        @else
            <a href="{{ route('admin.parkiran.create') }}" class="btn-tambah">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                </svg>
                Tambah Parkiran
            </a>
        @endif
    </div>
</div>

<!-- Info Alert if parkiran already exists -->
@if($hasExistingParkiran)
<div class="alert alert-info" style="background: #e0f2fe; border: 1px solid #0ea5e9; border-radius: 8px; padding: 16px; margin-bottom: 24px; display: flex; align-items: start; gap: 12px;">
    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="#0ea5e9" style="flex-shrink: 0; margin-top: 2px;">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
    </svg>
    <div>
        <strong style="color: #0369a1; display: block; margin-bottom: 4px;">Batasan Parkiran</strong>
        <p style="color: #075985; margin: 0; font-size: 14px;">
            Mall Anda sudah memiliki 1 parkiran. Sistem hanya mengizinkan 1 parkiran per mall untuk konsistensi dengan flow booking. 
            Anda dapat mengedit parkiran yang sudah ada atau menambah lantai baru di parkiran tersebut.
        </p>
    </div>
</div>
@endif

<!-- Parkiran Cards -->
<div class="parkiran-cards">
    @forelse($parkingAreas as $parkiran)
    <div class="parkiran-card">
        <div class="card-header">
            <div class="parking-icon">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                </svg>
            </div>
            <div class="card-title">
                <h3>{{ $parkiran->nama_parkiran ?? 'Parkiran ' . $parkiran->id_parkiran }}</h3>
                <span class="status-badge {{ strtolower($parkiran->status) == 'tersedia' ? 'active' : (strtolower($parkiran->status) == 'maintenance' ? 'maintenance' : 'closed') }}">
                    {{ $parkiran->status }}
                </span>
            </div>
        </div>
        <div class="card-body">
            <div class="info-grid">
                <div class="info-item">
                    <span class="label">Total Lantai</span>
                    <span class="value">{{ $parkiran->jumlah_lantai ?? $parkiran->floors->count() }} Lantai</span>
                </div>
                <div class="info-item">
                    <span class="label">Total Slot</span>
                    <span class="value">{{ $parkiran->kapasitas }} Slot</span>
                </div>
                <div class="info-item">
                    <span class="label">Tersedia</span>
                    <span class="value available">{{ $parkiran->total_available ?? 0 }} Slot</span>
                </div>
                <div class="info-item">
                    <span class="label">Terisi</span>
                    <span class="value occupied">{{ $parkiran->total_occupied ?? 0 }} Slot</span>
                </div>
            </div>
            
            <div class="lantai-preview">
                <h4>Denah Lantai</h4>
                <div class="lantai-list">
                    @foreach($parkiran->floors->take(3) as $floor)
                    <div class="lantai-item">
                        <span>{{ $floor->floor_name }}</span>
                        <span class="slot-info">{{ $floor->total_slots }} slot ({{ $floor->available_slots }} tersedia)</span>
                    </div>
                    @endforeach
                    @if($parkiran->floors->count() > 3)
                    <div class="lantai-item">
                        <span>...</span>
                        <span class="slot-info">+{{ $parkiran->floors->count() - 3 }} lantai lainnya</span>
                    </div>
                    @endif
                </div>
            </div>
        </div>
        <div class="card-footer">
            <a href="{{ route('admin.parkiran.detail', $parkiran->id_parkiran) }}" class="btn-detail">Lihat Detail</a>
            <a href="{{ route('admin.parkiran.edit', $parkiran->id_parkiran) }}" class="btn-edit">Edit</a>
        </div>
    </div>
    @empty
    <div class="empty-state" style="grid-column: 1/-1; text-align: center; padding: 60px 20px;">
        <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" fill="none" viewBox="0 0 24 24" stroke="currentColor" style="margin: 0 auto 20px; color: #cbd5e1;">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
        </svg>
        <h3 style="color: #64748b; margin-bottom: 8px;">Belum Ada Parkiran</h3>
        <p style="color: #94a3b8; margin-bottom: 20px;">Mulai dengan menambahkan area parkir pertama Anda</p>
        <a href="{{ route('admin.parkiran.create') }}" class="btn-tambah">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
            </svg>
            Tambah Parkiran
        </a>
    </div>
    @endforelse
</div>
@endsection

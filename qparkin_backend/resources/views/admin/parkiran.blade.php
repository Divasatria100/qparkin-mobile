@extends('layouts.admin')

@section('title', 'Parkiran')

@section('breadcrumb')
<span>Parkiran</span>
@endsection

@section('content')
<div class="parkiran-section">
    <div class="section-header">
        <h2>Manajemen Area Parkir</h2>
        <a href="{{ route('admin.parkiran.create') }}" class="btn btn-primary">Tambah Area Parkir</a>
    </div>

    <div class="parkiran-grid">
        @forelse($parkingAreas ?? [] as $area)
        <div class="parkiran-card">
            <div class="parkiran-header">
                <h3>{{ $area->name }}</h3>
                <span class="badge badge-{{ $area->is_active ? 'success' : 'secondary' }}">
                    {{ $area->is_active ? 'Aktif' : 'Nonaktif' }}
                </span>
            </div>
            <div class="parkiran-body">
                <div class="capacity-info">
                    <div class="capacity-item">
                        <span class="label">Total Kapasitas:</span>
                        <span class="value">{{ $area->total_capacity }}</span>
                    </div>
                    <div class="capacity-item">
                        <span class="label">Terisi:</span>
                        <span class="value">{{ $area->occupied }}</span>
                    </div>
                    <div class="capacity-item">
                        <span class="label">Tersedia:</span>
                        <span class="value available">{{ $area->available }}</span>
                    </div>
                </div>
                <div class="progress-bar">
                    <div class="progress-fill" style="width: {{ ($area->occupied / $area->total_capacity) * 100 }}%"></div>
                </div>
            </div>
            <div class="parkiran-actions">
                <a href="{{ route('admin.parkiran.detail', $area->id) }}" class="btn btn-secondary">Detail</a>
                <a href="{{ route('admin.parkiran.edit', $area->id) }}" class="btn btn-primary">Edit</a>
            </div>
        </div>
        @empty
        <div class="empty-state">
            <p>Belum ada area parkir. Silakan tambah area parkir baru.</p>
        </div>
        @endforelse
    </div>
</div>
@endsection

@push('styles')
<link rel="stylesheet" href="{{ asset('css/parkiran.css') }}">
@endpush

@push('scripts')
<script src="{{ asset('js/parkiran.js') }}"></script>
@endpush

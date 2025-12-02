@extends('layouts.admin')

@section('title', 'Tarif Parkir')

@section('breadcrumb')
<span>Tarif</span>
@endsection

@section('content')
<div class="tarif-section">
    <div class="section-header">
        <h2>Pengaturan Tarif Parkir</h2>
    </div>

    <div class="tarif-grid">
        @foreach($tariffs ?? [] as $tariff)
        <div class="tarif-card">
            <div class="tarif-header">
                <h3>{{ $tariff->vehicle_type }}</h3>
                <span class="badge badge-{{ $tariff->is_active ? 'success' : 'secondary' }}">
                    {{ $tariff->is_active ? 'Aktif' : 'Nonaktif' }}
                </span>
            </div>
            <div class="tarif-body">
                <div class="tarif-item">
                    <span class="label">Tarif per Jam:</span>
                    <span class="value">Rp {{ number_format($tariff->hourly_rate, 0, ',', '.') }}</span>
                </div>
                <div class="tarif-item">
                    <span class="label">Tarif Harian:</span>
                    <span class="value">Rp {{ number_format($tariff->daily_rate, 0, ',', '.') }}</span>
                </div>
            </div>
            <div class="tarif-actions">
                <a href="{{ route('admin.tarif.edit', $tariff->id) }}" class="btn btn-primary">Edit Tarif</a>
            </div>
        </div>
        @endforeach
    </div>
</div>
@endsection

@push('styles')
<link rel="stylesheet" href="{{ asset('css/admin-tarif.css') }}">
@endpush

@push('scripts')
<script src="{{ asset('js/admin-tarif.js') }}"></script>
@endpush

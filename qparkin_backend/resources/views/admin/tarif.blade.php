@extends('layouts.admin')

@section('title', 'Tarif - QPARKIN')

@section('styles')
<link rel="stylesheet" href="{{ asset('css/admin-tarif.css') }}">
@endsection

@section('content')
<!-- Breadcrumb -->
<div class="breadcrumb">
    <span>Tarif Parkir</span>
</div>

@if(session('success'))
<div class="alert alert-success" style="background: #d1fae5; color: #065f46; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #6ee7b7;">
    {{ session('success') }}
</div>
@endif

<!-- Header Section -->
<div class="tarif-header">
    <div class="header-left">
        <h1>Manajemen Tarif Parkir</h1>
        <p class="subtitle">Kelola tarif parkir untuk berbagai jenis kendaraan</p>
    </div>
</div>

<!-- Tarif Cards - Horizontal Scroll -->
<div class="tarif-cards-container">
    <div class="tarif-cards-scroll">
        @php
            $jenisKendaraan = [
                'Roda Dua' => ['icon' => 'roda-dua', 'color' => '#22c55e'],
                'Roda Tiga' => ['icon' => 'roda-tiga', 'color' => '#8b5cf6'],
                'Roda Empat' => ['icon' => 'roda-empat', 'color' => '#3b82f6'],
                'Lebih dari Enam' => ['icon' => 'roda-lebih', 'color' => '#ef4444']
            ];
        @endphp

        @foreach($jenisKendaraan as $jenis => $config)
            @php
                $tarif = $tarifs->firstWhere('jenis_kendaraan', $jenis);
                $tarifPertama = $tarif->satu_jam_pertama ?? 0;
                $tarifBerikutnya = $tarif->tarif_parkir_per_jam ?? 0;
                $total3Jam = $tarifPertama + ($tarifBerikutnya * 2);
            @endphp
            
            <div class="tarif-card">
                <div class="card-header">
                    <div class="vehicle-icon {{ $config['icon'] }}">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            @if($jenis === 'Roda Dua')
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                            @elseif($jenis === 'Roda Tiga')
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4" />
                            @elseif($jenis === 'Roda Empat')
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
                            @else
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
                            @endif
                        </svg>
                    </div>
                    <h3>{{ $jenis }}</h3>
                </div>
                <div class="card-body">
                    <div class="tarif-item">
                        <span class="label">1 Jam Pertama</span>
                        <span class="value">Rp {{ number_format($tarifPertama, 0, ',', '.') }}</span>
                    </div>
                    <div class="tarif-item">
                        <span class="label">Per Jam Berikutnya</span>
                        <span class="value">Rp {{ number_format($tarifBerikutnya, 0, ',', '.') }}</span>
                    </div>
                    <div class="tarif-item total">
                        <span class="label">Total 3 Jam</span>
                        <span class="value">Rp {{ number_format($total3Jam, 0, ',', '.') }}</span>
                    </div>
                </div>
                <div class="card-footer">
                    <a href="{{ route('admin.tarif.edit', $tarif->id_tarif ?? 0) }}" class="btn-edit">Edit</a>
                </div>
            </div>
        @endforeach
    </div>
</div>

<!-- Riwayat Perubahan Tarif -->
<div class="table-section">
    <div class="table-header">
        <h2>Riwayat Perubahan Tarif</h2>
    </div>
    <div class="table-container">
        <table class="data-table">
            <thead>
                <tr>
                    <th>Tanggal</th>
                    <th>Jenis Kendaraan</th>
                    <th>Tarif Lama</th>
                    <th>Tarif Baru</th>
                    <th>Diubah Oleh</th>
                </tr>
            </thead>
            <tbody>
                @forelse($riwayat as $item)
                <tr>
                    <td>{{ \Carbon\Carbon::parse($item->created_at)->format('d M Y, H:i') }}</td>
                    <td>
                        <span style="display: inline-block; padding: 4px 12px; background: #f1f5f9; border-radius: 6px; font-weight: 500;">
                            {{ $item->jenis_kendaraan }}
                        </span>
                    </td>
                    <td>
                        <div style="font-size: 0.875rem;">
                            <div>Jam 1: <strong>Rp {{ number_format($item->tarif_lama_jam_pertama, 0, ',', '.') }}</strong></div>
                            <div style="color: #64748b;">Per jam: Rp {{ number_format($item->tarif_lama_per_jam, 0, ',', '.') }}</div>
                        </div>
                    </td>
                    <td>
                        <div style="font-size: 0.875rem;">
                            <div>Jam 1: <strong style="color: #059669;">Rp {{ number_format($item->tarif_baru_jam_pertama, 0, ',', '.') }}</strong></div>
                            <div style="color: #64748b;">Per jam: Rp {{ number_format($item->tarif_baru_per_jam, 0, ',', '.') }}</div>
                        </div>
                    </td>
                    <td>{{ $item->user->name ?? 'Admin Mall' }}</td>
                </tr>
                @empty
                <tr>
                    <td colspan="5" style="text-align: center; padding: 40px; color: #64748b;">
                        <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="none" viewBox="0 0 24 24" stroke="currentColor" style="margin: 0 auto 16px; display: block; opacity: 0.5;">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        <p style="font-size: 1.125rem; font-weight: 600; margin-bottom: 8px;">Belum Ada Riwayat</p>
                        <p style="font-size: 0.875rem;">Riwayat perubahan tarif akan muncul di sini.</p>
                    </td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>
@endsection

@section('scripts')
<script src="{{ asset('js/admin-dashboard.js') }}"></script>
<script src="{{ asset('js/admin-tarif.js') }}"></script>
@endsection

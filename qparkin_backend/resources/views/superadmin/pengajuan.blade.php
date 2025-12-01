@extends('layouts.superadmin')

@section('title', 'Pengajuan Akun')

@section('breadcrumb')
<span>Pengajuan Akun</span>
@endsection

@section('content')
<div class="pengajuan-section">
    <div class="section-header">
        <h2>Daftar Pengajuan Akun</h2>
        <div class="filter-tabs">
            <button class="tab-btn active" data-status="pending">Menunggu</button>
            <button class="tab-btn" data-status="approved">Disetujui</button>
            <button class="tab-btn" data-status="rejected">Ditolak</button>
        </div>
    </div>

    <div class="table-section">
        <div class="table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Nama</th>
                        <th>Email</th>
                        <th>Nama Mall</th>
                        <th>Lokasi</th>
                        <th>Tanggal Pengajuan</th>
                        <th>Status</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($requests ?? [] as $request)
                    <tr>
                        <td>{{ $request->id }}</td>
                        <td>{{ $request->name }}</td>
                        <td>{{ $request->email }}</td>
                        <td>{{ $request->mall_name }}</td>
                        <td>{{ $request->location }}</td>
                        <td>{{ $request->created_at->format('d/m/Y') }}</td>
                        <td>
                            <span class="badge badge-{{ $request->status == 'pending' ? 'warning' : ($request->status == 'approved' ? 'success' : 'danger') }}">
                                {{ ucfirst($request->status) }}
                            </span>
                        </td>
                        <td>
                            @if($request->status == 'pending')
                            <button class="btn-action btn-success" onclick="approveRequest({{ $request->id }})">Setujui</button>
                            <button class="btn-action btn-danger" onclick="rejectRequest({{ $request->id }})">Tolak</button>
                            @else
                            <a href="{{ route('superadmin.pengajuan.detail', $request->id) }}" class="btn-action">Detail</a>
                            @endif
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="8" style="text-align: center;">Tidak ada pengajuan</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
</div>
@endsection

@push('styles')
<link rel="stylesheet" href="{{ asset('css/super-pengajuan-akun.css') }}">
@endpush

@push('scripts')
<script src="{{ asset('js/super-pengajuan-akun.js') }}"></script>
@endpush

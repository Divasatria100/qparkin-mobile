@extends('layouts.superadmin')

@section('title', 'Manajemen Mall')

@section('breadcrumb')
<span>Manajemen Mall</span>
@endsection

@section('content')
<div class="mall-section">
    <div class="section-header">
        <h2>Daftar Mall</h2>
        <a href="{{ route('superadmin.mall.create') }}" class="btn btn-primary">Tambah Mall</a>
    </div>

    <div class="table-section">
        <div class="table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Nama Mall</th>
                        <th>Lokasi</th>
                        <th>Admin</th>
                        <th>Total Area</th>
                        <th>Status</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($malls ?? [] as $mall)
                    <tr>
                        <td>{{ $mall->id }}</td>
                        <td>{{ $mall->name }}</td>
                        <td>{{ $mall->location }}</td>
                        <td>{{ $mall->admin->name ?? '-' }}</td>
                        <td>{{ $mall->parking_areas_count ?? 0 }}</td>
                        <td>
                            <span class="badge badge-{{ $mall->is_active ? 'success' : 'secondary' }}">
                                {{ $mall->is_active ? 'Aktif' : 'Nonaktif' }}
                            </span>
                        </td>
                        <td>
                            <a href="{{ route('superadmin.mall.detail', $mall->id) }}" class="btn-action">Detail</a>
                            <a href="{{ route('superadmin.mall.edit', $mall->id) }}" class="btn-action">Edit</a>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="7" style="text-align: center;">Tidak ada data mall</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
</div>
@endsection

@push('styles')
<link rel="stylesheet" href="{{ asset('css/super-manajemen-mall.css') }}">
@endpush

@push('scripts')
<script src="{{ asset('js/super-manajemen-mall.js') }}"></script>
@endpush

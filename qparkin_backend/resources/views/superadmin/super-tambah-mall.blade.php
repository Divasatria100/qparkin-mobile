@extends('layouts.superadmin')

@section('title', 'Tambah Mall - QPARKIN')

@push('styles')
<link rel="stylesheet" href="{{ asset('css/super-manajemen-mall.css') }}">
<link rel="stylesheet" href="{{ asset('css/edit-informasi.css') }}">
@endpush

@section('breadcrumb')
<a href="{{ route('superadmin.mall') }}" class="breadcrumb-link">Manajemen Mall</a>
<span class="breadcrumb-separator">/</span>
<span>Tambah Mall</span>
@endsection

@section('content')
<div class="edit-info-container">
    <div class="edit-header">
        <h2>Tambah Mall Baru</h2>
        <p>Lengkapi informasi mall yang akan ditambahkan</p>
    </div>

    @if($errors->any())
    <div class="alert alert-danger">
        <ul>
            @foreach($errors->all() as $error)
            <li>{{ $error }}</li>
            @endforeach
        </ul>
    </div>
    @endif

    <form class="edit-form" id="addMallForm" method="POST" action="{{ route('superadmin.mall.store') }}">
        @csrf
        <div class="form-section">
            <h3>Informasi Dasar</h3>
            <div class="form-grid">
                <div class="form-group full-width">
                    <label for="namaMall">Nama Mall *</label>
                    <input type="text" id="namaMall" name="nama_mall" value="{{ old('nama_mall') }}" required placeholder="Contoh: Grand Indonesia">
                    @error('nama_mall')
                    <span class="error-message">{{ $message }}</span>
                    @enderror
                </div>
                
                <div class="form-group full-width">
                    <label for="alamatLengkap">Alamat Lengkap *</label>
                    <textarea id="alamatLengkap" name="alamat_lengkap" rows="3" required placeholder="Contoh: Jl. MH Thamrin No. 1, Jakarta Pusat">{{ old('alamat_lengkap') }}</textarea>
                    @error('alamat_lengkap')
                    <span class="error-message">{{ $message }}</span>
                    @enderror
                </div>

                <div class="form-group">
                    <label for="latitude">Latitude</label>
                    <input type="number" step="0.00000001" id="latitude" name="latitude" value="{{ old('latitude') }}" placeholder="-6.2088">
                    <span class="field-hint">Opsional: Koordinat GPS</span>
                    @error('latitude')
                    <span class="error-message">{{ $message }}</span>
                    @enderror
                </div>

                <div class="form-group">
                    <label for="longitude">Longitude</label>
                    <input type="number" step="0.00000001" id="longitude" name="longitude" value="{{ old('longitude') }}" placeholder="106.8456">
                    <span class="field-hint">Opsional: Koordinat GPS</span>
                    @error('longitude')
                    <span class="error-message">{{ $message }}</span>
                    @enderror
                </div>

                <div class="form-group">
                    <label for="kapasitas">Kapasitas Total *</label>
                    <input type="number" id="kapasitas" name="kapasitas" value="{{ old('kapasitas') }}" required min="1" placeholder="Contoh: 1000">
                    @error('kapasitas')
                    <span class="error-message">{{ $message }}</span>
                    @enderror
                </div>

                <div class="form-group">
                    <label for="slotReservation">Slot Reservation</label>
                    <select id="slotReservation" name="has_slot_reservation_enabled">
                        <option value="0" {{ old('has_slot_reservation_enabled') == '0' ? 'selected' : '' }}>Nonaktif</option>
                        <option value="1" {{ old('has_slot_reservation_enabled') == '1' ? 'selected' : '' }}>Aktif</option>
                    </select>
                    @error('has_slot_reservation_enabled')
                    <span class="error-message">{{ $message }}</span>
                    @enderror
                </div>

                <div class="form-group full-width">
                    <label for="alamatGmaps">Alamat Google Maps</label>
                    <textarea id="alamatGmaps" name="alamat_gmaps" rows="3" placeholder="Link Google Maps atau koordinat">{{ old('alamat_gmaps') }}</textarea>
                    <span class="field-hint">Opsional: Link Google Maps untuk navigasi</span>
                    @error('alamat_gmaps')
                    <span class="error-message">{{ $message }}</span>
                    @enderror
                </div>
            </div>
        </div>

        <div class="form-section">
            <h3>Informasi Admin</h3>
            <div class="form-grid">
                <div class="form-group">
                    <label for="adminName">Nama Admin</label>
                    <input type="text" id="adminName" name="admin_name" value="{{ old('admin_name') }}" placeholder="Nama lengkap admin">
                    <span class="field-hint">Opsional: Bisa ditambahkan nanti</span>
                </div>

                <div class="form-group">
                    <label for="adminEmail">Email Admin</label>
                    <input type="email" id="adminEmail" name="admin_email" value="{{ old('admin_email') }}" placeholder="admin@mall.com">
                    <span class="field-hint">Opsional: Bisa ditambahkan nanti</span>
                </div>

                <div class="form-group">
                    <label for="adminPhone">Nomor Telepon Admin</label>
                    <input type="tel" id="adminPhone" name="admin_phone" value="{{ old('admin_phone') }}" placeholder="+62 812-3456-7890">
                </div>

                <div class="form-group">
                    <label for="adminPassword">Password Admin</label>
                    <input type="password" id="adminPassword" name="admin_password" placeholder="Minimal 8 karakter">
                    <span class="field-hint">Diperlukan jika membuat admin baru</span>
                </div>
            </div>
        </div>

        <div class="form-actions">
            <button type="button" class="btn-danger" onclick="window.location.href='{{ route('superadmin.mall') }}'">Batal</button>
            <button type="button" class="btn-reset" id="resetBtn">Reset</button>
            <button type="submit" class="btn-primary" id="saveBtn">Simpan Mall</button>
        </div>
    </form>
</div>
@endsection

@push('scripts')
<script src="{{ asset('js/edit-informasi.js') }}"></script>
@endpush

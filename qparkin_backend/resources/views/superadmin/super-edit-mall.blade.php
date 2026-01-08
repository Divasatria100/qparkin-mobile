@extends('layouts.superadmin')

@section('title', 'Edit Mall - QPARKIN')

@push('styles')
<link rel="stylesheet" href="{{ asset('css/super-manajemen-mall.css') }}">
<link rel="stylesheet" href="{{ asset('css/edit-informasi.css') }}">
@endpush

@section('breadcrumb')
<a href="{{ route('superadmin.mall') }}" class="breadcrumb-link">Manajemen Mall</a>
<span class="breadcrumb-separator">/</span>
<span>Edit Mall</span>
@endsection

@section('content')
<div class="edit-info-container">
    <div class="edit-header">
        <h2>Edit Informasi Mall</h2>
        <p>Perbarui informasi mall {{ $mall->nama_mall }}</p>
    </div>

    @if(session('success'))
    <div class="alert alert-success">
        {{ session('success') }}
    </div>
    @endif

    @if($errors->any())
    <div class="alert alert-danger">
        <ul>
            @foreach($errors->all() as $error)
            <li>{{ $error }}</li>
            @endforeach
        </ul>
    </div>
    @endif

    <form class="edit-form" id="editMallForm" method="POST" action="{{ route('superadmin.mall.update', $mall->id_mall) }}">
        @csrf
        @method('PUT')
        
        <div class="form-section">
            <h3>Informasi Dasar</h3>
            <div class="form-grid">
                <div class="form-group">
                    <label for="idMall">ID Mall</label>
                    <input type="text" id="idMall" value="{{ $mall->id_mall }}" readonly>
                    <span class="field-hint">ID tidak dapat diubah</span>
                </div>

                <div class="form-group">
                    <label for="namaMall">Nama Mall *</label>
                    <input type="text" id="namaMall" name="nama_mall" value="{{ old('nama_mall', $mall->nama_mall) }}" required>
                    @error('nama_mall')
                    <span class="error-message">{{ $message }}</span>
                    @enderror
                </div>
                
                <div class="form-group full-width">
                    <label for="alamatLengkap">Alamat Lengkap *</label>
                    <textarea id="alamatLengkap" name="alamat_lengkap" rows="3" required>{{ old('alamat_lengkap', $mall->alamat_lengkap) }}</textarea>
                    @error('alamat_lengkap')
                    <span class="error-message">{{ $message }}</span>
                    @enderror
                </div>

                <div class="form-group">
                    <label for="latitude">Latitude</label>
                    <input type="number" step="0.00000001" id="latitude" name="latitude" value="{{ old('latitude', $mall->latitude) }}">
                    <span class="field-hint">Koordinat GPS</span>
                    @error('latitude')
                    <span class="error-message">{{ $message }}</span>
                    @enderror
                </div>

                <div class="form-group">
                    <label for="longitude">Longitude</label>
                    <input type="number" step="0.00000001" id="longitude" name="longitude" value="{{ old('longitude', $mall->longitude) }}">
                    <span class="field-hint">Koordinat GPS</span>
                    @error('longitude')
                    <span class="error-message">{{ $message }}</span>
                    @enderror
                </div>

                <div class="form-group">
                    <label for="kapasitas">Kapasitas Total *</label>
                    <input type="number" id="kapasitas" name="kapasitas" value="{{ old('kapasitas', $mall->kapasitas) }}" required min="1">
                    @error('kapasitas')
                    <span class="error-message">{{ $message }}</span>
                    @enderror
                </div>

                <div class="form-group">
                    <label for="slotReservation">Slot Reservation</label>
                    <select id="slotReservation" name="has_slot_reservation_enabled">
                        <option value="0" {{ old('has_slot_reservation_enabled', $mall->has_slot_reservation_enabled) == '0' ? 'selected' : '' }}>Nonaktif</option>
                        <option value="1" {{ old('has_slot_reservation_enabled', $mall->has_slot_reservation_enabled) == '1' ? 'selected' : '' }}>Aktif</option>
                    </select>
                    @error('has_slot_reservation_enabled')
                    <span class="error-message">{{ $message }}</span>
                    @enderror
                </div>

                <div class="form-group full-width">
                    <label for="alamatGmaps">Alamat Google Maps</label>
                    <textarea id="alamatGmaps" name="alamat_gmaps" rows="3">{{ old('alamat_gmaps', $mall->alamat_gmaps) }}</textarea>
                    <span class="field-hint">Link Google Maps atau koordinat</span>
                    @error('alamat_gmaps')
                    <span class="error-message">{{ $message }}</span>
                    @enderror
                </div>
            </div>
        </div>

        <div class="form-section">
            <h3>Informasi Sistem</h3>
            <div class="form-grid">
                <div class="form-group">
                    <label for="createdAt">Terdaftar Sejak</label>
                    <input type="text" id="createdAt" value="{{ $mall->created_at ? $mall->created_at->translatedFormat('d F Y H:i') : '-' }}" readonly>
                </div>

                <div class="form-group">
                    <label for="updatedAt">Terakhir Diperbarui</label>
                    <input type="text" id="updatedAt" value="{{ $mall->updated_at ? $mall->updated_at->translatedFormat('d F Y H:i') : '-' }}" readonly>
                </div>

                <div class="form-group">
                    <label for="totalAdmin">Total Admin</label>
                    <input type="text" id="totalAdmin" value="{{ $mall->adminMall->count() }} Admin" readonly>
                </div>

                <div class="form-group">
                    <label for="totalParkir">Total Area Parkir</label>
                    <input type="text" id="totalParkir" value="{{ $mall->parkiran->count() }} Area" readonly>
                </div>
            </div>
        </div>

        <div class="form-actions">
            <button type="button" class="btn-danger" onclick="window.location.href='{{ route('superadmin.mall.detail', $mall->id_mall) }}'">Batal</button>
            <button type="button" class="btn-reset" id="resetBtn">Reset</button>
            <button type="submit" class="btn-primary" id="saveBtn">Simpan Perubahan</button>
        </div>
    </form>
</div>
@endsection

@push('scripts')
<script src="{{ asset('js/edit-informasi.js') }}"></script>
@endpush

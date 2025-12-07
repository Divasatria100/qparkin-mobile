@extends('layouts.admin')

@section('title', 'Edit Tarif - QPARKIN')

@section('styles')
<link rel="stylesheet" href="{{ asset('css/admin-tarif.css') }}">
<style>
.edit-tarif-container {
    max-width: 600px;
    margin: 0 auto;
    padding: 24px;
}

.form-card {
    background: white;
    border-radius: 12px;
    padding: 32px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.form-card h2 {
    font-size: 1.5rem;
    font-weight: 600;
    color: #1e293b;
    margin-bottom: 8px;
}

.form-card .subtitle {
    color: #64748b;
    margin-bottom: 32px;
}

.form-group {
    margin-bottom: 24px;
}

.form-group label {
    display: block;
    font-weight: 500;
    color: #334155;
    margin-bottom: 8px;
}

.form-group input {
    width: 100%;
    padding: 12px 16px;
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    font-size: 1rem;
    transition: all 0.2s;
}

.form-group input:focus {
    outline: none;
    border-color: #3b82f6;
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.form-group .input-prefix {
    position: relative;
}

.form-group .input-prefix input {
    padding-left: 40px;
}

.form-group .input-prefix::before {
    content: 'Rp';
    position: absolute;
    left: 16px;
    top: 50%;
    transform: translateY(-50%);
    color: #64748b;
    font-weight: 500;
}

.form-actions {
    display: flex;
    gap: 12px;
    margin-top: 32px;
}

.btn {
    padding: 12px 24px;
    border-radius: 8px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
    text-decoration: none;
    display: inline-block;
    text-align: center;
    border: none;
    font-size: 1rem;
}

.btn-primary {
    background: #3b82f6;
    color: white;
    flex: 1;
}

.btn-primary:hover {
    background: #2563eb;
}

.btn-secondary {
    background: #f1f5f9;
    color: #475569;
    flex: 1;
}

.btn-secondary:hover {
    background: #e2e8f0;
}

.vehicle-badge {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 8px 16px;
    background: #f1f5f9;
    border-radius: 8px;
    font-weight: 500;
    color: #334155;
    margin-bottom: 24px;
}

.alert {
    padding: 12px 16px;
    border-radius: 8px;
    margin-bottom: 24px;
}

.alert-danger {
    background: #fee2e2;
    color: #991b1b;
    border: 1px solid #fecaca;
}
</style>
@endsection

@section('content')
<!-- Breadcrumb -->
<div class="breadcrumb">
    <a href="{{ route('admin.tarif') }}">Tarif Parkir</a>
    <span>/</span>
    <span>Edit Tarif</span>
</div>

<div class="edit-tarif-container">
    <div class="form-card">
        <h2>Edit Tarif Parkir</h2>
        <p class="subtitle">Perbarui tarif parkir untuk jenis kendaraan ini</p>

        <div class="vehicle-badge">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
            </svg>
            {{ $tariff->jenis_kendaraan }}
        </div>

        @if ($errors->any())
            <div class="alert alert-danger">
                <ul style="margin: 0; padding-left: 20px;">
                    @foreach ($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        @endif

        <form action="{{ route('admin.tarif.update', $tariff->id_tarif) }}" method="POST">
            @csrf
            
            <div class="form-group">
                <label for="satu_jam_pertama">Tarif 1 Jam Pertama</label>
                <div class="input-prefix">
                    <input 
                        type="number" 
                        id="satu_jam_pertama" 
                        name="satu_jam_pertama" 
                        value="{{ old('satu_jam_pertama', $tariff->satu_jam_pertama) }}" 
                        required
                        min="0"
                        step="1000"
                        placeholder="5000"
                    >
                </div>
            </div>

            <div class="form-group">
                <label for="tarif_parkir_per_jam">Tarif Per Jam Berikutnya</label>
                <div class="input-prefix">
                    <input 
                        type="number" 
                        id="tarif_parkir_per_jam" 
                        name="tarif_parkir_per_jam" 
                        value="{{ old('tarif_parkir_per_jam', $tariff->tarif_parkir_per_jam) }}" 
                        required
                        min="0"
                        step="1000"
                        placeholder="3000"
                    >
                </div>
            </div>

            <div class="form-actions">
                <a href="{{ route('admin.tarif') }}" class="btn btn-secondary">Batal</a>
                <button type="submit" class="btn btn-primary">Simpan Perubahan</button>
            </div>
        </form>
    </div>
</div>
@endsection

@section('scripts')
<script>
// Auto format number input
document.querySelectorAll('input[type="number"]').forEach(input => {
    input.addEventListener('blur', function() {
        if (this.value) {
            this.value = Math.round(this.value);
        }
    });
});
</script>
@endsection

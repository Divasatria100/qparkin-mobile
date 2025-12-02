@extends('layouts.admin')

@section('title', 'Notifikasi')

@section('breadcrumb')
<span>Notifikasi</span>
@endsection

@section('content')
<div class="notifikasi-section">
    <div class="section-header">
        <h2>Notifikasi</h2>
        <button class="btn btn-secondary" onclick="markAllAsRead()">Tandai Semua Dibaca</button>
    </div>

    <div class="notifikasi-list">
        @forelse($notifications ?? [] as $notification)
        <div class="notifikasi-item {{ $notification->is_read ? '' : 'unread' }}">
            <div class="notifikasi-icon">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                </svg>
            </div>
            <div class="notifikasi-content">
                <h4>{{ $notification->title }}</h4>
                <p>{{ $notification->message }}</p>
                <span class="notifikasi-time">{{ $notification->created_at->diffForHumans() }}</span>
            </div>
        </div>
        @empty
        <div class="empty-state">
            <p>Tidak ada notifikasi</p>
        </div>
        @endforelse
    </div>
</div>
@endsection

@push('styles')
<link rel="stylesheet" href="{{ asset('css/notifikasi.css') }}">
@endpush

@push('scripts')
<script src="{{ asset('js/notifikasi.js') }}"></script>
@endpush

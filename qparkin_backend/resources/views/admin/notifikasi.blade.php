@extends('layouts.admin')

@section('title', 'Notifikasi - QPARKIN')

@section('styles')
<link rel="stylesheet" href="{{ asset('css/admin-profile.css') }}">
<link rel="stylesheet" href="{{ asset('css/notifikasi.css') }}">
@endsection

@section('content')
<div class="breadcrumb">
    <span>Notifikasi</span>
</div>

<div class="notifications-container">
    <div class="notifications-header">
        <h2>Notifikasi</h2>
        <div class="header-actions">
            <button class="btn-mark-all" id="markAllRead">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                </svg>
                Tandai Semua Dibaca
            </button>
            <div class="filter-options">
                <select id="filterCategory" onchange="window.location.href='{{ route('admin.notifikasi') }}?category=' + this.value">
                    <option value="all" {{ $category === 'all' ? 'selected' : '' }}>Semua Kategori</option>
                    <option value="system" {{ $category === 'system' ? 'selected' : '' }}>Sistem</option>
                    <option value="parking" {{ $category === 'parking' ? 'selected' : '' }}>Parkir</option>
                    <option value="payment" {{ $category === 'payment' ? 'selected' : '' }}>Pembayaran</option>
                    <option value="security" {{ $category === 'security' ? 'selected' : '' }}>Keamanan</option>
                    <option value="maintenance" {{ $category === 'maintenance' ? 'selected' : '' }}>Pemeliharaan</option>
                    <option value="report" {{ $category === 'report' ? 'selected' : '' }}>Laporan</option>
                </select>
            </div>
            <button class="btn-clear-all" id="clearAllNotifications">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
            </button>
        </div>
    </div>

    @if($notifications->count() > 0)
    <div class="notifications-list" id="notificationsList">
        @foreach($notifications as $notification)
        <div class="notification-item {{ $notification->status === 'belum' ? 'unread' : '' }}" 
             data-category="{{ $notification->kategori }}"
             data-id="{{ $notification->id_notifikasi }}">
            <div class="notification-icon {{ $notification->kategori }}">
                @if($notification->kategori === 'system')
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                </svg>
                @elseif($notification->kategori === 'parking')
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                </svg>
                @elseif($notification->kategori === 'payment')
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                @elseif($notification->kategori === 'security')
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                </svg>
                @elseif($notification->kategori === 'maintenance')
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                </svg>
                @else
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
                @endif
            </div>
            <div class="notification-content">
                <div class="notification-header">
                    <h4>{{ $notification->judul }}</h4>
                    <span class="notification-category-label">{{ ucfirst($notification->kategori) }}</span>
                </div>
                <p>{{ $notification->pesan }}</p>
                <span class="notification-time">{{ $notification->created_at->diffForHumans() }}</span>
            </div>
        </div>
        @endforeach
    </div>
    @else
    <div class="notifications-empty" id="emptyState">
        <div class="empty-icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
            </svg>
        </div>
        <h3>Tidak Ada Notifikasi</h3>
        <p>Semua notifikasi telah dibaca. Anda akan mendapat notifikasi baru ketika ada aktivitas penting.</p>
    </div>
    @endif
</div>

<form id="markAllReadForm" action="{{ route('admin.notifikasi.readAll') }}" method="POST" style="display: none;">
    @csrf
</form>

<form id="clearAllForm" action="{{ route('admin.notifikasi.clearAll') }}" method="POST" style="display: none;">
    @csrf
    @method('DELETE')
</form>
@endsection

@section('scripts')
<script src="{{ asset('js/admin-profile.js') }}"></script>
<script>
    const unreadCount = {{ $unreadCount }};
    const markAllReadUrl = '{{ route('admin.notifikasi.readAll') }}';
    const clearAllUrl = '{{ route('admin.notifikasi.clearAll') }}';
    const csrfToken = '{{ csrf_token() }}';
</script>
<script src="{{ asset('js/notifikasi.js') }}"></script>
@endsection

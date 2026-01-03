@extends('layouts.admin')

@section('title', 'Detail Parkiran - QPARKIN')

@section('styles')
<link rel="stylesheet" href="{{ asset('css/detail-parkiran.css') }}">
@endsection

@section('content')
<div class="breadcrumb">
    <a href="{{ route('admin.parkiran') }}" class="breadcrumb-link">Parkiran</a>
    <span class="breadcrumb-separator">/</span>
    <span>Detail Parkiran</span>
</div>

<div class="parkiran-detail-container">
    <div class="detail-header">
        <div class="header-left">
            <h2>{{ $parkiran->nama_parkiran ?? 'Parkiran ' . $parkiran->id_parkiran }}</h2>
            <div class="header-info">
                <span class="status-badge {{ strtolower($parkiran->status) == 'tersedia' ? 'active' : (strtolower($parkiran->status) == 'maintenance' ? 'maintenance' : 'closed') }}">
                    {{ $parkiran->status }}
                </span>
                @if($parkiran->kode_parkiran)
                <span class="kode-badge">{{ $parkiran->kode_parkiran }}</span>
                @endif
            </div>
        </div>
        <div class="header-actions">
            <a href="{{ route('admin.parkiran') }}" class="btn-back">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
                </svg>
                Kembali
            </a>
            <a href="{{ route('admin.parkiran.edit', $parkiran->id_parkiran) }}" class="btn-edit">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                </svg>
                Edit Parkiran
            </a>
        </div>
    </div>

    <div class="detail-content">
        <div class="overview-section">
            <h3>Overview Parkiran</h3>
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon total-lantai">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                        </svg>
                    </div>
                    <div class="stat-info">
                        <span class="stat-value">{{ $parkiran->jumlah_lantai ?? $parkiran->floors->count() }}</span>
                        <span class="stat-label">Total Lantai</span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon total-slot">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                        </svg>
                    </div>
                    <div class="stat-info">
                        <span class="stat-value">{{ $parkiran->kapasitas }}</span>
                        <span class="stat-label">Total Slot</span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon available">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                        </svg>
                    </div>
                    <div class="stat-info">
                        <span class="stat-value">{{ $parkiran->total_available }}</span>
                        <span class="stat-label">Tersedia</span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon occupied">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    </div>
                    <div class="stat-info">
                        <span class="stat-value">{{ $parkiran->total_occupied }}</span>
                        <span class="stat-label">Terisi</span>
                    </div>
                </div>
            </div>

            <div class="utilization-chart">
                <h4>Utilisasi Parkiran</h4>
                <div class="chart-container">
                    <div class="chart-bar">
                        <div class="chart-fill" style="width: {{ $parkiran->utilization }}%"></div>
                    </div>
                    <div class="chart-labels">
                        <span>0%</span>
                        <span>{{ $parkiran->utilization }}%</span>
                        <span>100%</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="lantai-section">
            <div class="section-header">
                <h3>Detail Lantai</h3>
            </div>

            <div class="lantai-container grid-view">
                @foreach($parkiran->floors as $floor)
                <div class="lantai-card">
                    <div class="lantai-card-header">
                        <h4>{{ $floor->floor_name }}</h4>
                        <div class="lantai-header-badges">
                            <span class="lantai-badge">Lantai {{ $floor->floor_number }}</span>
                            <span class="status-badge-small {{ $floor->status == 'active' ? 'active' : ($floor->status == 'maintenance' ? 'maintenance' : 'inactive') }}">
                                @if($floor->status == 'active')
                                    Aktif
                                @elseif($floor->status == 'maintenance')
                                    Maintenance
                                @else
                                    Tidak Aktif
                                @endif
                            </span>
                        </div>
                    </div>
                    <div class="lantai-card-body">
                        <div class="lantai-stats">
                            <div class="lantai-stat">
                                <span class="label">Total Slot</span>
                                <span class="value">{{ $floor->total_slots }}</span>
                            </div>
                            <div class="lantai-stat">
                                <span class="label">Tersedia</span>
                                <span class="value available">{{ $floor->available_slots }}</span>
                            </div>
                            <div class="lantai-stat">
                                <span class="label">Terisi</span>
                                <span class="value occupied">{{ $floor->total_slots - $floor->available_slots }}</span>
                            </div>
                        </div>
                        @if($floor->status == 'maintenance')
                        <div class="lantai-warning">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-1.964-1.333-2.732 0L4.082 16c-.77 1.333.192 3 1.732 3z" />
                            </svg>
                            <span>Lantai sedang maintenance - tidak bisa di-booking</span>
                        </div>
                        @endif
                        <div class="lantai-progress">
                            <div class="progress-bar">
                                <div class="progress-fill" style="width: {{ $floor->total_slots > 0 ? round((($floor->total_slots - $floor->available_slots) / $floor->total_slots) * 100, 2) : 0 }}%"></div>
                            </div>
                            <span class="progress-text">{{ $floor->total_slots > 0 ? round((($floor->total_slots - $floor->available_slots) / $floor->total_slots) * 100, 2) : 0 }}% Terisi</span>
                        </div>
                    </div>
                </div>
                @endforeach
            </div>
        </div>

        <div class="slot-detail-section">
            <h3>Detail Slot Parkir</h3>
            <div class="slot-filters">
                <div class="filter-group">
                    <label for="filterLantai">Filter Lantai:</label>
                    <select id="filterLantai">
                        <option value="all">Semua Lantai</option>
                        @foreach($parkiran->floors as $floor)
                        <option value="{{ $floor->id_floor }}">{{ $floor->floor_name }}</option>
                        @endforeach
                    </select>
                </div>
                <div class="filter-group">
                    <label for="filterStatus">Filter Status:</label>
                    <select id="filterStatus">
                        <option value="all">Semua Status</option>
                        <option value="available">Tersedia</option>
                        <option value="occupied">Terisi</option>
                        <option value="reserved">Reserved</option>
                        <option value="maintenance">Maintenance</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label for="itemsPerPage">Slot per Halaman:</label>
                    <select id="itemsPerPage">
                        <option value="20">20 slot</option>
                        <option value="50">50 slot</option>
                        <option value="100">100 slot</option>
                        <option value="all">Semua</option>
                    </select>
                </div>
            </div>

            <div class="pagination-info" id="paginationInfo">
                <span id="showingText">Menampilkan 1-20 dari 100 slot</span>
            </div>

            <div class="slot-grid" id="slotGrid">
                @foreach($parkiran->floors as $floor)
                    @foreach($floor->slots as $slot)
                    @php
                        // Derive display status from parent floor
                        $displayStatus = $floor->status == 'maintenance' ? 'maintenance' : $slot->status;
                        $displayStatusText = $floor->status == 'maintenance' ? 'Maintenance' : ucfirst($slot->status);
                    @endphp
                    <div class="slot-item {{ $displayStatus }}" data-floor="{{ $floor->id_floor }}" data-status="{{ $displayStatus }}" data-floor-status="{{ $floor->status }}">
                        <div class="slot-code">{{ $slot->slot_code }}</div>
                        <div class="slot-status">{{ $displayStatusText }}</div>
                    </div>
                    @endforeach
                @endforeach
            </div>

            <div class="pagination-controls" id="paginationControls">
                <button class="pagination-btn" id="firstPageBtn" title="Halaman Pertama">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 19l-7-7 7-7m8 14l-7-7 7-7" />
                    </svg>
                </button>
                <button class="pagination-btn" id="prevPageBtn" title="Halaman Sebelumnya">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                    </svg>
                </button>
                <div class="pagination-numbers" id="paginationNumbers"></div>
                <button class="pagination-btn" id="nextPageBtn" title="Halaman Selanjutnya">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                    </svg>
                </button>
                <button class="pagination-btn" id="lastPageBtn" title="Halaman Terakhir">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5l7 7-7 7M5 5l7 7-7 7" />
                    </svg>
                </button>
            </div>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script>
document.addEventListener('DOMContentLoaded', function() {
    // Elements
    const filterLantai = document.getElementById('filterLantai');
    const filterStatus = document.getElementById('filterStatus');
    const itemsPerPageSelect = document.getElementById('itemsPerPage');
    const slotGrid = document.getElementById('slotGrid');
    const paginationInfo = document.getElementById('paginationInfo');
    const showingText = document.getElementById('showingText');
    const paginationControls = document.getElementById('paginationControls');
    const paginationNumbers = document.getElementById('paginationNumbers');
    const firstPageBtn = document.getElementById('firstPageBtn');
    const prevPageBtn = document.getElementById('prevPageBtn');
    const nextPageBtn = document.getElementById('nextPageBtn');
    const lastPageBtn = document.getElementById('lastPageBtn');
    
    // Get all slots and store them
    const allSlots = Array.from(slotGrid.querySelectorAll('.slot-item'));
    
    // Pagination state
    let currentPage = 1;
    let itemsPerPage = 20;
    let filteredSlots = [];

    // Initialize
    function init() {
        filterAndPaginate();
        setupEventListeners();
    }

    // Setup event listeners
    function setupEventListeners() {
        filterLantai.addEventListener('change', () => {
            currentPage = 1; // Reset to page 1 when filter changes
            filterAndPaginate();
        });
        
        filterStatus.addEventListener('change', () => {
            currentPage = 1; // Reset to page 1 when filter changes
            filterAndPaginate();
        });
        
        itemsPerPageSelect.addEventListener('change', () => {
            const value = itemsPerPageSelect.value;
            itemsPerPage = value === 'all' ? Infinity : parseInt(value);
            currentPage = 1; // Reset to page 1 when items per page changes
            filterAndPaginate();
        });
        
        firstPageBtn.addEventListener('click', () => goToPage(1));
        prevPageBtn.addEventListener('click', () => goToPage(currentPage - 1));
        nextPageBtn.addEventListener('click', () => goToPage(currentPage + 1));
        lastPageBtn.addEventListener('click', () => {
            const totalPages = Math.ceil(filteredSlots.length / itemsPerPage);
            goToPage(totalPages);
        });
    }

    // Filter slots based on selected filters
    function filterSlots() {
        const selectedFloor = filterLantai.value;
        const selectedStatus = filterStatus.value;

        filteredSlots = allSlots.filter(slot => {
            const floorMatch = selectedFloor === 'all' || slot.dataset.floor === selectedFloor;
            const displayStatus = slot.dataset.status;
            const statusMatch = selectedStatus === 'all' || displayStatus === selectedStatus;
            return floorMatch && statusMatch;
        });
    }

    // Display slots for current page
    function displaySlots() {
        // Clear grid
        slotGrid.innerHTML = '';
        
        // Calculate pagination
        const totalSlots = filteredSlots.length;
        const totalPages = Math.ceil(totalSlots / itemsPerPage);
        const startIndex = (currentPage - 1) * itemsPerPage;
        const endIndex = Math.min(startIndex + itemsPerPage, totalSlots);
        
        // Get slots for current page
        const slotsToDisplay = filteredSlots.slice(startIndex, endIndex);
        
        // Display slots
        slotsToDisplay.forEach(slot => {
            slotGrid.appendChild(slot.cloneNode(true));
        });
        
        // Update pagination info
        updatePaginationInfo(startIndex + 1, endIndex, totalSlots);
        
        // Update pagination controls
        updatePaginationControls(currentPage, totalPages);
    }

    // Update pagination info text
    function updatePaginationInfo(start, end, total) {
        if (total === 0) {
            showingText.textContent = 'Tidak ada slot yang ditampilkan';
            paginationInfo.style.display = 'block';
        } else if (itemsPerPage === Infinity) {
            showingText.textContent = `Menampilkan semua ${total} slot`;
            paginationInfo.style.display = 'block';
        } else {
            showingText.textContent = `Menampilkan ${start}-${end} dari ${total} slot`;
            paginationInfo.style.display = 'block';
        }
    }

    // Update pagination controls
    function updatePaginationControls(page, totalPages) {
        // Hide pagination if showing all or only one page
        if (itemsPerPage === Infinity || totalPages <= 1) {
            paginationControls.style.display = 'none';
            return;
        }
        
        paginationControls.style.display = 'flex';
        
        // Update button states
        firstPageBtn.disabled = page === 1;
        prevPageBtn.disabled = page === 1;
        nextPageBtn.disabled = page === totalPages;
        lastPageBtn.disabled = page === totalPages;
        
        // Generate page numbers
        generatePageNumbers(page, totalPages);
    }

    // Generate page number buttons
    function generatePageNumbers(page, totalPages) {
        paginationNumbers.innerHTML = '';
        
        // Calculate which page numbers to show
        let startPage = Math.max(1, page - 2);
        let endPage = Math.min(totalPages, page + 2);
        
        // Adjust if near start or end
        if (page <= 3) {
            endPage = Math.min(5, totalPages);
        }
        if (page >= totalPages - 2) {
            startPage = Math.max(1, totalPages - 4);
        }
        
        // Add first page and ellipsis if needed
        if (startPage > 1) {
            addPageButton(1);
            if (startPage > 2) {
                addEllipsis();
            }
        }
        
        // Add page numbers
        for (let i = startPage; i <= endPage; i++) {
            addPageButton(i, i === page);
        }
        
        // Add ellipsis and last page if needed
        if (endPage < totalPages) {
            if (endPage < totalPages - 1) {
                addEllipsis();
            }
            addPageButton(totalPages);
        }
    }

    // Add page button
    function addPageButton(pageNum, isActive = false) {
        const btn = document.createElement('button');
        btn.className = 'pagination-number' + (isActive ? ' active' : '');
        btn.textContent = pageNum;
        btn.addEventListener('click', () => goToPage(pageNum));
        paginationNumbers.appendChild(btn);
    }

    // Add ellipsis
    function addEllipsis() {
        const ellipsis = document.createElement('span');
        ellipsis.className = 'pagination-ellipsis';
        ellipsis.textContent = '...';
        paginationNumbers.appendChild(ellipsis);
    }

    // Go to specific page
    function goToPage(page) {
        const totalPages = Math.ceil(filteredSlots.length / itemsPerPage);
        if (page < 1 || page > totalPages) return;
        
        currentPage = page;
        displaySlots();
        
        // Scroll to top of slot grid
        slotGrid.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }

    // Main filter and paginate function
    function filterAndPaginate() {
        filterSlots();
        displaySlots();
    }

    // Initialize on load
    init();
    
    console.log('Detail parkiran loaded - Floor maintenance status is derived to slots with pagination');
});
</script>
@endsection

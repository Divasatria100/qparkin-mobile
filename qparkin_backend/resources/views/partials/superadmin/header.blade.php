<header class="admin-header">
    <div class="header-left">
        <button id="sidebarToggle" class="menu-toggle" aria-label="Toggle Sidebar">
            <svg id="menuIcon" xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
            </svg>
            <svg id="closeIcon" xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
        </button>
        <h1 class="logo">QPARKIN <span class="role-badge">SUPER</span></h1>
    </div>
    <div class="header-right">
        <div class="user-info">
            <span>{{ auth()->user()->name ?? 'Super Admin' }}</span>
        </div>
    </div>
</header>

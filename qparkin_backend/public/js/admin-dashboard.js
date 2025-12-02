// Admin Dashboard JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Elements
    const sidebarToggle = document.getElementById('sidebarToggle');
    const menuIcon = document.getElementById('menuIcon');
    const closeIcon = document.getElementById('closeIcon');
    const sidebar = document.querySelector('.admin-sidebar');
    const overlay = document.querySelector('.sidebar-overlay');
    const navItems = document.querySelectorAll('.nav-item:not(.logout)');

    // Sidebar state management (in-memory storage)
    const sidebarState = {
        collapsed: false,
        
        save: function(isCollapsed) {
            this.collapsed = isCollapsed;
            // Simpan ke session untuk persist antar halaman
            try {
                sessionStorage.setItem('sidebarCollapsed', isCollapsed ? '1' : '0');
            } catch (e) {
                console.log('SessionStorage not available, using memory only');
            }
        },
        
        load: function() {
            try {
                const saved = sessionStorage.getItem('sidebarCollapsed');
                return saved === '1';
            } catch (e) {
                return this.collapsed;
            }
        }
    };
    
    // Toggle sidebar function
    function toggleSidebar() {
        const isDesktop = window.innerWidth > 768;
        
        if (isDesktop) {
            // Desktop: Collapse/Expand sidebar (keep hamburger icon)
            sidebar.classList.toggle('collapsed');
        } else {
            // Mobile: Show/Hide sidebar with overlay (change icon)
            const isOpen = sidebar.classList.contains('show');
            
            if (isOpen) {
                closeSidebar();
            } else {
                openSidebar();
            }
        }
    }
    
    function openSidebar() {
        sidebar.classList.add('show');
        overlay.classList.add('show');
        menuIcon.classList.add('hidden');
        closeIcon.classList.add('show');
        menuIcon.style.display = 'none';
        closeIcon.style.display = 'block';
        
        // Prevent body scroll on mobile when sidebar is open
        document.body.style.overflow = 'hidden';
    }
    
    function closeSidebar() {
        sidebar.classList.remove('show');
        overlay.classList.remove('show');
        menuIcon.classList.remove('hidden');
        closeIcon.classList.remove('show');
        menuIcon.style.display = 'block';
        closeIcon.style.display = 'none';
        
        // Restore body scroll
        document.body.style.overflow = '';
    }
    
    // Sidebar Toggle Event
    if (sidebarToggle) {
        sidebarToggle.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            toggleSidebar();
        });
    }
    
    // Close sidebar when clicking on overlay (mobile only)
    if (overlay) {
        overlay.addEventListener('click', function() {
            if (window.innerWidth <= 768) {
                closeSidebar();
            }
        });
    }
    
    // Active Navigation
    navItems.forEach(item => {
        item.addEventListener('click', function(e) {
            // Remove active class from all items
            navItems.forEach(navItem => {
                navItem.classList.remove('active');
            });
            
            // Add active class to clicked item
            this.classList.add('active');
            
            // Close sidebar on mobile after selection
            if (window.innerWidth <= 768) {
                setTimeout(() => {
                    closeSidebar();
                }, 300);
            }
        });
    });
    
    // Handle window resize
    let resizeTimer;
    window.addEventListener('resize', function() {
        clearTimeout(resizeTimer);
        resizeTimer = setTimeout(function() {
            const isDesktop = window.innerWidth > 768;
            
            if (isDesktop) {
                // Reset mobile states on desktop
                closeSidebar();
                sidebar.classList.remove('show');
                overlay.classList.remove('show');
                document.body.style.overflow = '';
            } else {
                // Reset collapsed state on mobile
                sidebar.classList.remove('collapsed');
                menuIcon.style.display = 'block';
                closeIcon.style.display = 'none';
            }
        }, 250);
    });
    
    // Prevent sidebar close when clicking inside sidebar
    if (sidebar) {
        sidebar.addEventListener('click', function(e) {
            e.stopPropagation();
        });
    }
    
    // Close sidebar with ESC key (mobile only)
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape' && sidebar.classList.contains('show') && window.innerWidth <= 768) {
            closeSidebar();
        }
    });
    
    // Smooth scroll for content
    const adminContent = document.querySelector('.admin-content');
    if (adminContent) {
        adminContent.style.scrollBehavior = 'smooth';
    }
    
    // Add animation to cards on load
    const cards = document.querySelectorAll('.card');
    cards.forEach((card, index) => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        setTimeout(() => {
            card.style.transition = 'all 0.5s ease';
            card.style.opacity = '1';
            card.style.transform = 'translateY(0)';
        }, index * 100);
    });

    // Restore sidebar state on page load (desktop only)
    function restoreSidebarState() {
        const isDesktop = window.innerWidth > 768;
        
        if (isDesktop) {
            const isCollapsed = sidebarState.load();
            if (isCollapsed) {
                sidebar.classList.add('collapsed');
            }
        }
    }

    // Call restore before other initializations
    restoreSidebarState();

    // Initialize icon state on load
    menuIcon.style.display = 'block';
    closeIcon.style.display = 'none';
    
    // Initialize icon state on load
    const isDesktop = window.innerWidth > 768;
    if (isDesktop) {
        menuIcon.style.display = 'block';
        closeIcon.style.display = 'none';
    }
    
    // Log dashboard loaded
    console.log('Dashboard loaded successfully');
    console.log('Sidebar functionality initialized');
    console.log('Screen width:', window.innerWidth);
});
// Super Admin Dashboard JavaScript
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
                sessionStorage.setItem('superSidebarCollapsed', isCollapsed ? '1' : '0');
            } catch (e) {
                console.log('SessionStorage not available, using memory only');
            }
        },
        
        load: function() {
            try {
                const saved = sessionStorage.getItem('superSidebarCollapsed');
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
            const isCollapsed = sidebar.classList.contains('collapsed');
            if (isCollapsed) {
                sidebar.classList.remove('collapsed');
                sidebarState.save(false);
            } else {
                sidebar.classList.add('collapsed');
                sidebarState.save(true);
            }
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
                sidebarState.save(false);
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
    
    // Add animation to action cards
    const actionCards = document.querySelectorAll('.action-card');
    actionCards.forEach((card, index) => {
        card.style.opacity = '0';
        card.style.transform = 'scale(0.9)';
        setTimeout(() => {
            card.style.transition = 'all 0.4s ease';
            card.style.opacity = '1';
            card.style.transform = 'scale(1)';
        }, 600 + (index * 100));
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
    
    // Real-time data simulation for Super Admin
    function simulateRealTimeData() {
        // Update notification badges randomly
        const notificationBadges = document.querySelectorAll('.notification-badge');
        notificationBadges.forEach(badge => {
            const currentCount = parseInt(badge.textContent);
            const randomChange = Math.random() > 0.7 ? 1 : 0;
            if (randomChange && currentCount < 20) {
                badge.textContent = currentCount + 1;
                badge.style.animation = 'none';
                setTimeout(() => {
                    badge.style.animation = 'pulse 2s infinite';
                }, 10);
            }
        });
        
        // Update card values slightly for demo
        const cardValues = document.querySelectorAll('.card-value');
        cardValues.forEach(value => {
            if (value.textContent.includes('Rp')) {
                const current = parseInt(value.textContent.replace(/[^\d]/g, ''));
                const randomChange = Math.floor(Math.random() * 1000000);
                const newValue = current + randomChange;
                value.textContent = `Rp ${(newValue / 1000000).toFixed(1)}M`;
            } else if (!isNaN(parseInt(value.textContent))) {
                const current = parseInt(value.textContent);
                const randomChange = Math.floor(Math.random() * 10);
                value.textContent = current + randomChange;
            }
        });
    }
    
    // Update data every 30 seconds for demo purposes
    setInterval(simulateRealTimeData, 30000);
    
    // Log dashboard loaded
    console.log('Super Admin Dashboard loaded successfully');
    console.log('Sidebar functionality initialized');
    console.log('Screen width:', window.innerWidth);
    console.log('Real-time data simulation started');
});

// Additional Super Admin specific functions
const SuperAdminDashboard = {
    // Function to quickly approve account requests
    quickApproveAccount: function(accountId) {
        console.log(`Quick approving account: ${accountId}`);
        // Implementation for quick approval
    },
    
    // Function to generate system report
    generateSystemReport: function(type, dateRange) {
        console.log(`Generating ${type} report for ${dateRange}`);
        // Implementation for report generation
    },
    
    // Function to manage mall settings
    updateMallSettings: function(mallId, settings) {
        console.log(`Updating settings for mall ${mallId}`, settings);
        // Implementation for mall settings update
    }
};
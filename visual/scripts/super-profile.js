// Super Admin Profile JavaScript
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
            sidebarState.save(sidebar.classList.contains('collapsed'));
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
            navItems.forEach(nav => nav.classList.remove('active'));
            
            // Add active class to clicked item
            this.classList.add('active');
            
            // Close sidebar on mobile after navigation
            if (window.innerWidth <= 768) {
                closeSidebar();
            }
        });
    });
    
    // Load saved sidebar state on desktop
    function loadSidebarState() {
        if (window.innerWidth > 768) {
            const savedState = sidebarState.load();
            if (savedState) {
                sidebar.classList.add('collapsed');
            } else {
                sidebar.classList.remove('collapsed');
            }
        }
    }
    
    // Handle window resize
    function handleResize() {
        if (window.innerWidth > 768) {
            // Desktop: Ensure sidebar is visible and overlay is hidden
            sidebar.classList.remove('show');
            overlay.classList.remove('show');
            document.body.style.overflow = '';
            
            // Restore hamburger icon
            menuIcon.classList.remove('hidden');
            closeIcon.classList.remove('show');
            menuIcon.style.display = 'block';
            closeIcon.style.display = 'none';
            
            // Load saved state
            loadSidebarState();
        } else {
            // Mobile: Ensure sidebar is hidden by default
            sidebar.classList.remove('collapsed');
            closeSidebar();
        }
    }
    
    // Initialize
    loadSidebarState();
    
    // Add resize listener
    window.addEventListener('resize', handleResize);
    
    // Add click outside to close sidebar (mobile)
    document.addEventListener('click', function(e) {
        if (window.innerWidth <= 768 && 
            sidebar.classList.contains('show') && 
            !sidebar.contains(e.target) && 
            e.target !== sidebarToggle) {
            closeSidebar();
        }
    });
    
    // Keyboard navigation support
    document.addEventListener('keydown', function(e) {
        // ESC key closes sidebar
        if (e.key === 'Escape' && window.innerWidth <= 768 && sidebar.classList.contains('show')) {
            closeSidebar();
        }
    });
    
    // Profile card animations
    const profileCards = document.querySelectorAll('.profile-card');
    
    // Add intersection observer for scroll animations
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);
    
    // Apply initial styles and observe
    profileCards.forEach((card, index) => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        card.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
        card.style.transitionDelay = `${index * 0.1}s`;
        
        observer.observe(card);
    });
    
    // Notification badges animation
    const notificationBadges = document.querySelectorAll('.notification-badge');
    
    notificationBadges.forEach(badge => {
        // Add subtle hover effect
        badge.addEventListener('mouseenter', function() {
            this.style.transform = 'scale(1.1)';
        });
        
        badge.addEventListener('mouseleave', function() {
            this.style.transform = 'scale(1)';
        });
    });
    
    // Avatar placeholder animation
    const avatarPlaceholder = document.querySelector('.avatar-placeholder');
    
    if (avatarPlaceholder) {
        avatarPlaceholder.addEventListener('mouseenter', function() {
            this.style.transform = 'scale(1.05) rotate(5deg)';
        });
        
        avatarPlaceholder.addEventListener('mouseleave', function() {
            this.style.transform = 'scale(1) rotate(0deg)';
        });
    }
    
    // Smooth scroll for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
    
    // Performance optimization: Debounce resize handler
    let resizeTimeout;
    window.addEventListener('resize', function() {
        clearTimeout(resizeTimeout);
        resizeTimeout = setTimeout(handleResize, 100);
    });
    
    // Initialize tooltips (placeholder for future enhancement)
    function initTooltips() {
        // Tooltip functionality can be added here
        console.log('Tooltip system initialized');
    }
    
    initTooltips();
    
    // Logout confirmation
    const logoutLink = document.querySelector('.nav-item.logout .nav-link');
    
    if (logoutLink) {
        logoutLink.addEventListener('click', function(e) {
            if (!confirm('Apakah Anda yakin ingin keluar?')) {
                e.preventDefault();
            }
        });
    }
    
    // Add loading state for better UX
    window.addEventListener('load', function() {
        document.body.classList.add('loaded');
        
        // Remove initial loading animation
        setTimeout(() => {
            const loadingElements = document.querySelectorAll('.loading');
            loadingElements.forEach(el => el.classList.remove('loading'));
        }, 500);
    });
    
    // Error handling for missing elements
    function checkRequiredElements() {
        const required = [sidebarToggle, sidebar, overlay];
        required.forEach(el => {
            if (!el) {
                console.warn('Required element not found:', el);
            }
        });
    }
    
    checkRequiredElements();
    
    console.log('Super Admin Profile initialized successfully');
});
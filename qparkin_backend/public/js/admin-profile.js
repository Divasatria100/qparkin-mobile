// Admin Profile JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Elements
    const sidebarToggle = document.getElementById('sidebarToggle');
    const menuIcon = document.getElementById('menuIcon');
    const closeIcon = document.getElementById('closeIcon');
    const sidebar = document.querySelector('.admin-sidebar');
    const overlay = document.querySelector('.sidebar-overlay');
    const navItems = document.querySelectorAll('.nav-item:not(.logout)');
    const editButtons = document.querySelectorAll('.edit-btn');
    const changeAvatarBtn = document.querySelector('.change-avatar-btn');

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
    
    // Edit Button Functionality
    editButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            const card = this.closest('.profile-card');
            const cardHeader = card.querySelector('.card-header h3').textContent;
            
            if (cardHeader === 'Informasi Pribadi') {
                showEditPersonalInfoModal();
            } else if (cardHeader === 'Keamanan Akun') {
                showSecuritySettingsModal();
            }
        });
    });
    
    // Change Avatar Button
    if (changeAvatarBtn) {
        changeAvatarBtn.addEventListener('click', function(e) {
            e.preventDefault();
            showAvatarUploadModal();
        });
    }
    
    // Modal Functions
    function showEditPersonalInfoModal() {
        // Create modal for editing personal info
        const modal = document.createElement('div');
        modal.className = 'modal-overlay';
        modal.innerHTML = `
            <div class="modal-content">
                <div class="modal-header">
                    <h3>Edit Informasi Pribadi</h3>
                    <button class="modal-close">&times;</button>
                </div>
                <div class="modal-body">
                    <form id="editPersonalInfoForm">
                        <div class="form-group">
                            <label for="fullName">Nama Lengkap</label>
                            <input type="text" id="fullName" value="Admin Mall Central Park" required>
                        </div>
                        <div class="form-group">
                            <label for="email">Email</label>
                            <input type="email" id="email" value="admin@centralpark.com" required>
                        </div>
                        <div class="form-group">
                            <label for="phone">Nomor Telepon</label>
                            <input type="tel" id="phone" value="+62 812-3456-7890">
                        </div>
                        <div class="form-group">
                            <label for="address">Alamat</label>
                            <textarea id="address" rows="3">Jl. Central Park No. 123, Jakarta Barat</textarea>
                        </div>
                        <div class="form-actions">
                            <button type="button" class="btn-cancel">Batal</button>
                            <button type="submit" class="btn-save">Simpan Perubahan</button>
                        </div>
                    </form>
                </div>
            </div>
        `;
        
        document.body.appendChild(modal);
        
        // Add event listeners for modal
        const closeBtn = modal.querySelector('.modal-close');
        const cancelBtn = modal.querySelector('.btn-cancel');
        const form = modal.querySelector('#editPersonalInfoForm');
        
        function closeModal() {
            modal.remove();
            document.body.style.overflow = '';
        }
        
        closeBtn.addEventListener('click', closeModal);
        cancelBtn.addEventListener('click', closeModal);
        
        modal.addEventListener('click', function(e) {
            if (e.target === modal) {
                closeModal();
            }
        });
        
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            // Simpan perubahan (dalam implementasi nyata, ini akan mengirim data ke server)
            alert('Perubahan berhasil disimpan!');
            closeModal();
        });
        
        document.body.style.overflow = 'hidden';
    }
    
    function showSecuritySettingsModal() {
        const modal = document.createElement('div');
        modal.className = 'modal-overlay';
        modal.innerHTML = `
            <div class="modal-content">
                <div class="modal-header">
                    <h3>Pengaturan Keamanan</h3>
                    <button class="modal-close">&times;</button>
                </div>
                <div class="modal-body">
                    <form id="securitySettingsForm">
                        <div class="form-group">
                            <label for="currentPassword">Kata Sandi Saat Ini</label>
                            <input type="password" id="currentPassword" required>
                        </div>
                        <div class="form-group">
                            <label for="newPassword">Kata Sandi Baru</label>
                            <input type="password" id="newPassword" required minlength="8">
                        </div>
                        <div class="form-group">
                            <label for="confirmPassword">Konfirmasi Kata Sandi Baru</label>
                            <input type="password" id="confirmPassword" required>
                        </div>
                        <div class="form-group checkbox-group">
                            <input type="checkbox" id="twoFactor">
                            <label for="twoFactor">Aktifkan Verifikasi 2 Langkah</label>
                        </div>
                        <div class="form-actions">
                            <button type="button" class="btn-cancel">Batal</button>
                            <button type="submit" class="btn-save">Simpan Pengaturan</button>
                        </div>
                    </form>
                </div>
            </div>
        `;
        
        document.body.appendChild(modal);
        
        const closeBtn = modal.querySelector('.modal-close');
        const cancelBtn = modal.querySelector('.btn-cancel');
        const form = modal.querySelector('#securitySettingsForm');
        
        function closeModal() {
            modal.remove();
            document.body.style.overflow = '';
        }
        
        closeBtn.addEventListener('click', closeModal);
        cancelBtn.addEventListener('click', closeModal);
        
        modal.addEventListener('click', function(e) {
            if (e.target === modal) {
                closeModal();
            }
        });
        
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            const newPassword = form.querySelector('#newPassword').value;
            const confirmPassword = form.querySelector('#confirmPassword').value;
            
            if (newPassword !== confirmPassword) {
                alert('Konfirmasi kata sandi tidak sesuai!');
                return;
            }
            
            alert('Pengaturan keamanan berhasil diperbarui!');
            closeModal();
        });
        
        document.body.style.overflow = 'hidden';
    }
    
    function showAvatarUploadModal() {
        const modal = document.createElement('div');
        modal.className = 'modal-overlay';
        modal.innerHTML = `
            <div class="modal-content">
                <div class="modal-header">
                    <h3>Ubah Foto Profil</h3>
                    <button class="modal-close">&times;</button>
                </div>
                <div class="modal-body">
                    <div class="avatar-upload">
                        <div class="avatar-preview">
                            <div class="avatar-placeholder large">
                                <svg xmlns="http://www.w3.org/2000/svg" width="80" height="80" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                </svg>
                            </div>
                        </div>
                        <div class="upload-options">
                            <input type="file" id="avatarFile" accept="image/*" style="display: none;">
                            <button type="button" class="btn-upload" id="selectAvatarBtn">Pilih Foto</button>
                            <p class="upload-hint">Format: JPG, PNG, maksimal 2MB</p>
                        </div>
                        <div class="form-actions">
                            <button type="button" class="btn-cancel">Batal</button>
                            <button type="button" class="btn-save" id="saveAvatarBtn" disabled>Simpan Foto</button>
                        </div>
                    </div>
                </div>
            </div>
        `;
        
        document.body.appendChild(modal);
        
        const closeBtn = modal.querySelector('.modal-close');
        const cancelBtn = modal.querySelector('.btn-cancel');
        const selectBtn = modal.querySelector('#selectAvatarBtn');
        const saveBtn = modal.querySelector('#saveAvatarBtn');
        const fileInput = modal.querySelector('#avatarFile');
        
        function closeModal() {
            modal.remove();
            document.body.style.overflow = '';
        }
        
        closeBtn.addEventListener('click', closeModal);
        cancelBtn.addEventListener('click', closeModal);
        
        selectBtn.addEventListener('click', function() {
            fileInput.click();
        });
        
        fileInput.addEventListener('change', function(e) {
            if (e.target.files.length > 0) {
                saveBtn.disabled = false;
            }
        });
        
        saveBtn.addEventListener('click', function() {
            alert('Foto profil berhasil diubah!');
            closeModal();
        });
        
        modal.addEventListener('click', function(e) {
            if (e.target === modal) {
                closeModal();
            }
        });
        
        document.body.style.overflow = 'hidden';
    }
    
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
    
    // Add animation to profile cards on load
    const profileCards = document.querySelectorAll('.profile-card');
    profileCards.forEach((card, index) => {
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
    
    // Log profile page loaded
    console.log('Profile page loaded successfully');
    console.log('Sidebar functionality initialized');
    console.log('Screen width:', window.innerWidth);
});
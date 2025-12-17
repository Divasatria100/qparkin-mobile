// Notifikasi JavaScript
document.addEventListener('DOMContentLoaded', function() {
    const markAllReadBtn = document.getElementById('markAllRead');
    const clearAllBtn = document.getElementById('clearAllNotifications');
    const filterCategory = document.getElementById('filterCategory');
    const notificationsList = document.getElementById('notificationsList');
    const emptyState = document.getElementById('emptyState');
    const markReadBtns = document.querySelectorAll('.btn-mark-read');
    const notificationItems = document.querySelectorAll('.notification-item');
    const sidebarBadge = document.querySelector('.sidebar-nav .notification-badge');

    // Initialize notification state
    let unreadCount = document.querySelectorAll('.notification-item.unread').length;
    updateBadgeCount();

    // Clear all notifications
    clearAllBtn.addEventListener('click', function() {
        const allNotifications = document.querySelectorAll('.notification-item');
        
        if (allNotifications.length === 0) {
            showNotification('Tidak ada notifikasi untuk dihapus.', 'info');
            return;
        }

        if (confirm(`Apakah Anda yakin ingin menghapus semua notifikasi? Tindakan ini tidak dapat dibatalkan.`)) {
            // Submit to Laravel backend
            fetch(clearAllUrl, {
                method: 'DELETE',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': csrfToken
                }
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // Remove all notifications from DOM
                    allNotifications.forEach(item => {
                        item.remove();
                    });

                    // Update unread count to 0
                    unreadCount = 0;
                    updateBadgeCount();
                    
                    // Show empty state
                    checkEmptyState();
                    
                    showNotification('Semua notifikasi telah dihapus.', 'success');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                showNotification('Terjadi kesalahan. Silakan coba lagi.', 'error');
            });
        }
    });

    // Mark all as read
    markAllReadBtn.addEventListener('click', function() {
        // Show confirmation
        if (unreadCount === 0) {
            showNotification('Tidak ada notifikasi yang belum dibaca.', 'info');
            return;
        }

        if (confirm(`Tandai semua ${unreadCount} notifikasi sebagai sudah dibaca?`)) {
            // Submit form to Laravel backend
            fetch(markAllReadUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': csrfToken
                }
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // Mark all notifications as read in UI
                    notificationItems.forEach(item => {
                        item.classList.remove('unread');
                    });

                    // Update unread count
                    unreadCount = 0;
                    updateBadgeCount();
                    
                    showNotification('Semua notifikasi telah ditandai sebagai sudah dibaca.');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                showNotification('Terjadi kesalahan. Silakan coba lagi.', 'error');
            });
        }
    });

    // Mark single notification as read
    markReadBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            const notificationId = this.getAttribute('data-id');
            const notificationItem = this.closest('.notification-item');
            
            if (notificationItem.classList.contains('unread')) {
                notificationItem.classList.remove('unread');
                unreadCount--;
                updateBadgeCount();
                checkEmptyState();
                showNotification('Notifikasi ditandai sebagai sudah dibaca.');
            }
        });
    });

    // Filter notifications by category - UPDATE FUNGSI INI
    filterCategory.addEventListener('change', function() {
        const selectedCategory = this.value;
        const notificationItems = document.querySelectorAll('.notification-item');
        let visibleItems = 0;

        notificationItems.forEach(item => {
            const itemCategory = item.getAttribute('data-category');
            
            if (selectedCategory === 'all' || itemCategory === selectedCategory) {
                item.style.display = 'flex';
                visibleItems++;
            } else {
                item.style.display = 'none';
            }
        });

        // Show empty state if no items match filter
        if (visibleItems === 0 && selectedCategory !== 'all') {
            emptyState.style.display = 'block';
            emptyState.innerHTML = `
                <div class="empty-icon">
                    <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                </div>
                <h3>Tidak Ada Notifikasi</h3>
                <p>Tidak ada notifikasi dalam kategori "${getCategoryName(selectedCategory)}".</p>
            `;
            notificationsList.style.display = 'none';
        } else {
            emptyState.style.display = 'none';
            notificationsList.style.display = 'block';
        }
    });

    // Mark all as read - UPDATE FUNGSI INI
    markAllReadBtn.addEventListener('click', function() {
        // Show confirmation
        if (unreadCount === 0) {
            showNotification('Semua notifkasi sudah dibaca.', 'success');
            return;
        }

        if (confirm(`Tandai semua ${unreadCount} notifikasi sebagai sudah dibaca?`)) {
            // Mark all unread notifications as read
            const unreadItems = document.querySelectorAll('.notification-item.unread');
            unreadItems.forEach(item => {
                item.classList.remove('unread');
                // Hanya menghilangkan styling unread, tidak menghapus elemen
            });

            // Update unread count
            unreadCount = 0;
            updateBadgeCount();
            
            // Check if all notifications are read
            checkEmptyState();
            
            showNotification('Semua notifikasi ditandai sudah dibaca.');
        }
    });

    // Update badge count in sidebar
    function updateBadgeCount() {
        if (sidebarBadge) {
            if (unreadCount > 0) {
                sidebarBadge.textContent = unreadCount;
                sidebarBadge.style.display = 'flex';
            } else {
                sidebarBadge.style.display = 'none';
            }
        }
    }

    // Check if all notifications are read - UPDATE FUNGSI INI
    function checkEmptyState() {
        const allNotifications = document.querySelectorAll('.notification-item');
        const unreadNotifications = document.querySelectorAll('.notification-item.unread');
        
        // Hanya tampilkan empty state jika benar-benar tidak ada notifikasi sama sekali
        // atau jika filter aktif dan tidak ada yang match
        if (allNotifications.length === 0) {
            emptyState.style.display = 'block';
            notificationsList.style.display = 'none';
        } else {
            emptyState.style.display = 'none';
            notificationsList.style.display = 'block';
        }
    }

    // Get category name for display
    function getCategoryName(category) {
        const categories = {
            'system': 'Sistem',
            'parking': 'Parkir',
            'payment': 'Pembayaran',
            'security': 'Keamanan',
            'maintenance': 'Pemeliharaan',
            'report': 'Laporan'
        };
        return categories[category] || category;
    }

    // Show notification message
    function showNotification(message, type = 'success') {
        // Remove existing notification
        const existingNotification = document.querySelector('.notification-toast');
        if (existingNotification) {
            existingNotification.remove();
        }

        // Create notification
        const notification = document.createElement('div');
        notification.className = `notification-toast ${type}`;
        notification.innerHTML = `
            <span>${message}</span>
            <button class="toast-close">&times;</button>
        `;

        // Add styles
        notification.style.cssText = `
            position: fixed;
            top: 80px;
            right: 20px;
            background: ${type === 'success' ? '#22c55e' : type === 'error' ? '#ef4444' : '#f59e0b'};
            color: white;
            padding: 12px 16px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            display: flex;
            align-items: center;
            gap: 12px;
            z-index: 1000;
            animation: slideIn 0.3s ease;
        `;

        // Close button
        const closeBtn = notification.querySelector('.toast-close');
        closeBtn.style.cssText = `
            background: none;
            border: none;
            color: white;
            font-size: 18px;
            cursor: pointer;
            padding: 0;
            width: 20px;
            height: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
        `;

        closeBtn.addEventListener('click', () => {
            notification.remove();
        });

        document.body.appendChild(notification);

        // Auto remove after 5 seconds
        setTimeout(() => {
            if (notification.parentNode) {
                notification.remove();
            }
        }, 5000);
    }

    // Click on notification item (mark as read)
    notificationItems.forEach(item => {
        item.addEventListener('click', function(e) {
            // Don't trigger if clicking on mark-read button
            if (!e.target.closest('.btn-mark-read')) {
                if (this.classList.contains('unread')) {
                    const notificationId = this.getAttribute('data-id');
                    
                    // Mark as read in backend
                    fetch(`/admin/notifikasi/${notificationId}/read`, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                            'X-CSRF-TOKEN': csrfToken
                        }
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            this.classList.remove('unread');
                            unreadCount--;
                            updateBadgeCount();
                        }
                    })
                    .catch(error => {
                        console.error('Error:', error);
                    });
                }
            }
        });
    });

    // Keyboard shortcuts
    document.addEventListener('keydown', function(e) {
        if (e.ctrlKey && e.key === 'm') {
            e.preventDefault();
            markAllReadBtn.click();
        }
    });

    console.log('Notifikasi page loaded successfully');
    console.log(`Total notifikasi belum dibaca: ${unreadCount}`);

    document.addEventListener('DOMContentLoaded', function() {
        const markAllReadBtn = document.getElementById('markAllRead');
        const clearAllBtn = document.getElementById('clearAllNotifications');
        const filterCategory = document.getElementById('filterCategory');
        const notificationsList = document.getElementById('notificationsList');
        const emptyState = document.getElementById('emptyState');
        const markReadBtns = document.querySelectorAll('.btn-mark-read');
        const notificationItems = document.querySelectorAll('.notification-item');
        const sidebarBadge = document.querySelector('.sidebar-nav .notification-badge');
    
        // Initialize notification state
        let unreadCount = document.querySelectorAll('.notification-item.unread').length;
        updateBadgeCount();
    
        // Clear all notifications
        clearAllBtn.addEventListener('click', function() {
            const allNotifications = document.querySelectorAll('.notification-item');
            
            if (allNotifications.length === 0) {
                showNotification('Tidak ada notifikasi untuk dihapus.', 'info');
                return;
            }
    
            if (confirm(`Apakah Anda yakin ingin menghapus semua notifikasi? Tindakan ini tidak dapat dibatalkan.`)) {
                // Remove all notifications from DOM
                allNotifications.forEach(item => {
                    item.remove();
                });
    
                // Update unread count to 0
                unreadCount = 0;
                updateBadgeCount();
                
                // Show empty state
                checkEmptyState();
                
                showNotification('Semua notifikasi telah dihapus.', 'success');
            }
        });
    
        // Mark all as read
        markAllReadBtn.addEventListener('click', function() {
            // Show confirmation
            if (unreadCount === 0) {
                showNotification('Tidak ada notifikasi yang belum dibaca.', 'info');
                return;
            }
    
            if (confirm(`Tandai semua ${unreadCount} notifikasi sebagai sudah dibaca?`)) {
                // Mark all notifications as read
                notificationItems.forEach(item => {
                    item.classList.remove('unread');
                });
    
                // Update unread count
                unreadCount = 0;
                updateBadgeCount();
                
                // Check if all notifications are read
                checkEmptyState();
                
                showNotification('Semua notifikasi telah ditandai sebagai sudah dibaca.');
            }
        });
    
        // ... sisa kode JavaScript yang ada ...
    });
    
    // Update fungsi checkEmptyState untuk handle ketika semua notifikasi dihapus
    function checkEmptyState() {
        const allNotifications = document.querySelectorAll('.notification-item');
        const unreadNotifications = document.querySelectorAll('.notification-item.unread');
        
        // Jika tidak ada notifikasi sama sekali (setelah dihapus)
        if (allNotifications.length === 0) {
            emptyState.style.display = 'block';
            notificationsList.style.display = 'none';
            emptyState.innerHTML = `
                <div class="empty-icon">
                    <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                    </svg>
                </div>
                <h3>Tidak Ada Notifikasi</h3>
                <p>Belum ada notifikasi yang tersedia. Notifikasi akan muncul ketika ada aktivitas sistem.</p>
            `;
        } 
    }
});
// Super Admin Pengajuan Akun JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Initialize the application
    initPengajuanAkun();
});

function initPengajuanAkun() {
    // Initialize all components
    initFilters();
    initTableInteractions();
    initBulkActions();
    initActionButtons();
}

// Filter functionality
function initFilters() {
    const statusFilter = document.getElementById('statusFilter');
    const dateFilter = document.getElementById('dateFilter');
    const searchInput = document.getElementById('searchInput');
    const resetFiltersBtn = document.getElementById('resetFilters');
    
    // Status filter change
    if (statusFilter) {
        statusFilter.addEventListener('change', function() {
            applyFilters();
        });
    }
    
    // Date filter change
    if (dateFilter) {
        dateFilter.addEventListener('change', function() {
            applyFilters();
        });
    }
    
    // Search input with debounce
    if (searchInput) {
        let searchTimeout;
        searchInput.addEventListener('input', function() {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(() => {
                applyFilters();
            }, 300);
        });
    }
    
    // Reset filters
    if (resetFiltersBtn) {
        resetFiltersBtn.addEventListener('click', function() {
            resetFilters();
        });
    }
}

function applyFilters() {
    const statusFilter = document.getElementById('statusFilter').value;
    const dateFilter = document.getElementById('dateFilter').value;
    const searchTerm = document.getElementById('searchInput').value.toLowerCase();
    
    const rows = document.querySelectorAll('.data-table tbody tr');
    let visibleCount = 0;
    
    rows.forEach(row => {
        const name = row.querySelector('.user-name').textContent.toLowerCase();
        const mall = row.querySelector('td:nth-child(4)').textContent.toLowerCase();
        const status = row.querySelector('.status-badge').textContent.toLowerCase();
        const date = row.querySelector('td:nth-child(6)').textContent;
        
        let statusMatch = statusFilter === 'all' || 
                         (statusFilter === 'pending' && status === 'menunggu') ||
                         (statusFilter === 'approved' && status === 'disetujui') ||
                         (statusFilter === 'rejected' && status === 'ditolak');
        
        let dateMatch = dateFilter === 'all' || filterByDate(date, dateFilter);
        let searchMatch = searchTerm === '' || name.includes(searchTerm) || mall.includes(searchTerm);
        
        if (statusMatch && dateMatch && searchMatch) {
            row.style.display = '';
            visibleCount++;
        } else {
            row.style.display = 'none';
        }
    });
    
    // Update table count
    const tableCount = document.querySelector('.table-count');
    if (tableCount) {
        tableCount.textContent = `${visibleCount} pengajuan ditemukan`;
    }
}

function filterByDate(date, filterType) {
    const today = new Date();
    const rowDate = new Date(date);
    
    switch (filterType) {
        case 'today':
            return rowDate.toDateString() === today.toDateString();
        case 'week':
            const weekAgo = new Date(today);
            weekAgo.setDate(today.getDate() - 7);
            return rowDate >= weekAgo;
        case 'month':
            const monthAgo = new Date(today);
            monthAgo.setMonth(today.getMonth() - 1);
            return rowDate >= monthAgo;
        default:
            return true;
    }
}

function resetFilters() {
    document.getElementById('statusFilter').value = 'pending';
    document.getElementById('dateFilter').value = 'all';
    document.getElementById('searchInput').value = '';
    applyFilters();
}

// Table interactions
function initTableInteractions() {
    const selectAllCheckbox = document.getElementById('selectAll');
    const rowCheckboxes = document.querySelectorAll('.row-checkbox');
    
    // Select all functionality
    if (selectAllCheckbox) {
        selectAllCheckbox.addEventListener('change', function() {
            const isChecked = this.checked;
            rowCheckboxes.forEach(checkbox => {
                if (!checkbox.closest('tr').style.display || checkbox.closest('tr').style.display === '') {
                    checkbox.checked = isChecked;
                }
            });
            updateBulkActions();
        });
    }
    
    // Individual row checkbox functionality
    rowCheckboxes.forEach(checkbox => {
        checkbox.addEventListener('change', function() {
            updateSelectAllCheckbox();
            updateBulkActions();
        });
    });
}

function updateSelectAllCheckbox() {
    const selectAllCheckbox = document.getElementById('selectAll');
    const visibleRows = Array.from(document.querySelectorAll('.row-checkbox')).filter(
        checkbox => !checkbox.closest('tr').style.display || checkbox.closest('tr').style.display === ''
    );
    
    if (visibleRows.length === 0) {
        selectAllCheckbox.checked = false;
        selectAllCheckbox.indeterminate = false;
        return;
    }
    
    const checkedCount = visibleRows.filter(checkbox => checkbox.checked).length;
    
    if (checkedCount === 0) {
        selectAllCheckbox.checked = false;
        selectAllCheckbox.indeterminate = false;
    } else if (checkedCount === visibleRows.length) {
        selectAllCheckbox.checked = true;
        selectAllCheckbox.indeterminate = false;
    } else {
        selectAllCheckbox.checked = false;
        selectAllCheckbox.indeterminate = true;
    }
}

// Bulk actions
function initBulkActions() {
    const bulkApproveBtn = document.getElementById('bulkApprove');
    const bulkRejectBtn = document.getElementById('bulkReject');
    
    if (bulkApproveBtn) {
        bulkApproveBtn.addEventListener('click', function() {
            const selectedIds = getSelectedApplicationIds();
            if (selectedIds.length > 0) {
                approveApplications(selectedIds);
            }
        });
    }
    
    if (bulkRejectBtn) {
        bulkRejectBtn.addEventListener('click', function() {
            const selectedIds = getSelectedApplicationIds();
            if (selectedIds.length > 0) {
                rejectApplications(selectedIds);
            }
        });
    }
}

function updateBulkActions() {
    const selectedCount = getSelectedApplicationIds().length;
    const bulkActions = document.getElementById('bulkActions');
    const selectedCountElement = document.getElementById('selectedCount');
    
    if (selectedCountElement) {
        selectedCountElement.textContent = selectedCount;
    }
    
    if (bulkActions) {
        if (selectedCount > 0) {
            bulkActions.classList.add('show');
        } else {
            bulkActions.classList.remove('show');
        }
    }
}

function getSelectedApplicationIds() {
    const selectedIds = [];
    document.querySelectorAll('.row-checkbox:checked').forEach(checkbox => {
        const row = checkbox.closest('tr');
        const actionBtn = row.querySelector('.btn-action');
        if (actionBtn) {
            selectedIds.push(actionBtn.getAttribute('data-id'));
        }
    });
    return selectedIds;
}

// Individual action buttons
function initActionButtons() {
    // Approve buttons
    document.querySelectorAll('.btn-action.approve').forEach(btn => {
        btn.addEventListener('click', function() {
            const applicationId = this.getAttribute('data-id');
            approveApplications([applicationId]);
        });
    });
    
    // Reject buttons
    document.querySelectorAll('.btn-action.reject').forEach(btn => {
        btn.addEventListener('click', function() {
            const applicationId = this.getAttribute('data-id');
            rejectApplications([applicationId]);
        });
    });
    
    // View buttons
    document.querySelectorAll('.btn-action.view').forEach(btn => {
        btn.addEventListener('click', function() {
            const applicationId = this.getAttribute('data-id');
            viewApplicationDetails(applicationId);
        });
    });
    
    // Refresh button
    const refreshBtn = document.getElementById('refreshBtn');
    if (refreshBtn) {
        refreshBtn.addEventListener('click', function() {
            refreshData();
        });
    }
    
    // Export button
    const exportBtn = document.getElementById('exportBtn');
    if (exportBtn) {
        exportBtn.addEventListener('click', function() {
            exportData();
        });
    }
}

// Application actions
function approveApplications(applicationIds) {
    if (applicationIds.length === 0) return;
    
    // Show confirmation dialog
    const message = applicationIds.length === 1 
        ? 'Apakah Anda yakin ingin menyetujui pengajuan akun ini?'
        : `Apakah Anda yakin ingin menyetujui ${applicationIds.length} pengajuan akun?`;
    
    if (confirm(message)) {
        // Simulate API call
        console.log('Menyetujui pengajuan:', applicationIds);
        
        // Update UI
        applicationIds.forEach(id => {
            const row = document.querySelector(`.btn-action[data-id="${id}"]`).closest('tr');
            const statusBadge = row.querySelector('.status-badge');
            statusBadge.textContent = 'Disetujui';
            statusBadge.className = 'status-badge approved';
            
            // Disable action buttons
            row.querySelectorAll('.btn-action').forEach(btn => {
                btn.disabled = true;
                btn.style.opacity = '0.5';
                btn.style.cursor = 'not-allowed';
            });
            
            // Uncheck the row
            const checkbox = row.querySelector('.row-checkbox');
            checkbox.checked = false;
        });
        
        // Update counts and UI
        updateSelectAllCheckbox();
        updateBulkActions();
        updateNotificationCount();
        
        // Show success message
        showNotification(`${applicationIds.length} pengajuan berhasil disetujui`, 'success');
    }
}

function rejectApplications(applicationIds) {
    if (applicationIds.length === 0) return;
    
    // Show confirmation dialog
    const message = applicationIds.length === 1 
        ? 'Apakah Anda yakin ingin menolak pengajuan akun ini?'
        : `Apakah Anda yakin ingin menolak ${applicationIds.length} pengajuan akun?`;
    
    if (confirm(message)) {
        // Simulate API call
        console.log('Menolak pengajuan:', applicationIds);
        
        // Update UI
        applicationIds.forEach(id => {
            const row = document.querySelector(`.btn-action[data-id="${id}"]`).closest('tr');
            const statusBadge = row.querySelector('.status-badge');
            statusBadge.textContent = 'Ditolak';
            statusBadge.className = 'status-badge rejected';
            
            // Disable action buttons
            row.querySelectorAll('.btn-action').forEach(btn => {
                btn.disabled = true;
                btn.style.opacity = '0.5';
                btn.style.cursor = 'not-allowed';
            });
            
            // Uncheck the row
            const checkbox = row.querySelector('.row-checkbox');
            checkbox.checked = false;
        });
        
        // Update counts and UI
        updateSelectAllCheckbox();
        updateBulkActions();
        updateNotificationCount();
        
        // Show success message
        showNotification(`${applicationIds.length} pengajuan berhasil ditolak`, 'success');
    }
}

function viewApplicationDetails(applicationId) {
    // In a real application, this would navigate to a detail page or show a modal
    console.log('Melihat detail pengajuan:', applicationId);
    
    // For now, we'll just show an alert
    alert(`Melihat detail pengajuan dengan ID: ${applicationId}\n\nFitur ini akan membuka halaman detail atau modal dengan informasi lengkap tentang pengajuan akun.`);
}

function refreshData() {
    // Simulate data refresh
    console.log('Memperbarui data...');
    
    // Show loading state
    const refreshBtn = document.getElementById('refreshBtn');
    if (refreshBtn) {
        const originalHTML = refreshBtn.innerHTML;
        refreshBtn.innerHTML = '<svg class="animate-spin" xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" /></svg>';
        refreshBtn.disabled = true;
        
        // Simulate API call
        setTimeout(() => {
            refreshBtn.innerHTML = originalHTML;
            refreshBtn.disabled = false;
            
            // Show success message
            showNotification('Data berhasil diperbarui', 'success');
        }, 1500);
    }
}

function exportData() {
    // Simulate export functionality
    console.log('Mengekspor data...');
    
    // Show loading state
    const exportBtn = document.getElementById('exportBtn');
    if (exportBtn) {
        const originalHTML = exportBtn.innerHTML;
        exportBtn.innerHTML = '<svg class="animate-spin" xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" /></svg>';
        exportBtn.disabled = true;
        
        // Simulate export process
        setTimeout(() => {
            exportBtn.innerHTML = originalHTML;
            exportBtn.disabled = false;
            
            // Show success message
            showNotification('Data berhasil diekspor', 'success');
            
            // In a real application, this would trigger a file download
            // For demo purposes, we'll just log it
            console.log('Data exported successfully');
        }, 2000);
    }
}

// Utility functions
function updateNotificationCount() {
    // Update the notification badge in the sidebar
    const pendingCount = document.querySelectorAll('.status-badge.pending').length;
    const notificationBadge = document.querySelector('.sidebar-nav .active .notification-badge');
    
    if (notificationBadge) {
        if (pendingCount > 0) {
            notificationBadge.textContent = pendingCount;
            notificationBadge.style.display = 'flex';
        } else {
            notificationBadge.style.display = 'none';
        }
    }
}

function showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `fixed top-4 right-4 z-50 p-4 rounded-lg shadow-lg transition-all duration-300 transform translate-x-full ${getNotificationClass(type)}`;
    notification.innerHTML = `
        <div class="flex items-center gap-3">
            <span class="text-lg">${getNotificationIcon(type)}</span>
            <span class="font-medium">${message}</span>
        </div>
    `;
    
    // Add to page
    document.body.appendChild(notification);
    
    // Animate in
    setTimeout(() => {
        notification.classList.remove('translate-x-full');
    }, 10);
    
    // Remove after delay
    setTimeout(() => {
        notification.classList.add('translate-x-full');
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 300);
    }, 3000);
}

function getNotificationClass(type) {
    switch (type) {
        case 'success':
            return 'bg-green-50 text-green-800 border border-green-200';
        case 'error':
            return 'bg-red-50 text-red-800 border border-red-200';
        case 'warning':
            return 'bg-yellow-50 text-yellow-800 border border-yellow-200';
        default:
            return 'bg-blue-50 text-blue-800 border border-blue-200';
    }
}

function getNotificationIcon(type) {
    switch (type) {
        case 'success':
            return '✓';
        case 'error':
            return '✕';
        case 'warning':
            return '⚠';
        default:
            return 'ℹ';
    }
}
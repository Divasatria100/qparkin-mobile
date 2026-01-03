// Super Pengajuan Akun & Manajemen Pengguna JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Tab Navigation
    const tabButtons = document.querySelectorAll('.tab-button');
    const tabPanes = document.querySelectorAll('.tab-pane');
    
    // Initialize tab functionality
    function initTabs() {
        tabButtons.forEach(button => {
            button.addEventListener('click', function() {
                const targetTab = this.getAttribute('data-tab');
                
                // Remove active class from all buttons and panes
                tabButtons.forEach(btn => btn.classList.remove('active'));
                tabPanes.forEach(pane => pane.classList.remove('active'));
                
                // Add active class to current button and pane
                this.classList.add('active');
                document.getElementById(targetTab).classList.add('active');
                
                // Update URL hash
                window.location.hash = targetTab;
            });
        });
        
        // Check URL hash on load
        if (window.location.hash) {
            const targetTab = window.location.hash.substring(1);
            const targetButton = document.querySelector(`[data-tab="${targetTab}"]`);
            if (targetButton) {
                targetButton.click();
            }
        }
    }
    
    // Application Management
    const selectAllCheckbox = document.getElementById('select-all');
    const rowCheckboxes = document.querySelectorAll('.row-select');
    const bulkApproveBtn = document.getElementById('bulk-approve');
    const bulkRejectBtn = document.getElementById('bulk-reject');
    
    // Initialize application management
    function initApplicationManagement() {
        // Select All functionality
        if (selectAllCheckbox) {
            selectAllCheckbox.addEventListener('change', function() {
                const isChecked = this.checked;
                rowCheckboxes.forEach(checkbox => {
                    checkbox.checked = isChecked;
                });
                updateBulkActionsState();
            });
        }
        
        // Individual checkbox change
        rowCheckboxes.forEach(checkbox => {
            checkbox.addEventListener('change', function() {
                updateBulkActionsState();
                updateSelectAllState();
            });
        });
        
        // Bulk approve action
        if (bulkApproveBtn) {
            bulkApproveBtn.addEventListener('click', function() {
                const selectedIds = getSelectedApplicationIds();
                if (selectedIds.length > 0) {
                    approveApplications(selectedIds);
                } else {
                    showNotification('Pilih setidaknya satu permohonan untuk disetujui', 'warning');
                }
            });
        }
        
        // Bulk reject action
        if (bulkRejectBtn) {
            bulkRejectBtn.addEventListener('click', function() {
                const selectedIds = getSelectedApplicationIds();
                if (selectedIds.length > 0) {
                    rejectApplications(selectedIds);
                } else {
                    showNotification('Pilih setidaknya satu permohonan untuk ditolak', 'warning');
                }
            });
        }
        
        // Individual action buttons
        const approveButtons = document.querySelectorAll('.btn-approve');
        const rejectButtons = document.querySelectorAll('.btn-reject');
        const detailButtons = document.querySelectorAll('.btn-detail');
        
        approveButtons.forEach(button => {
            button.addEventListener('click', function() {
                const applicationId = this.getAttribute('data-id');
                approveApplications([applicationId]);
            });
        });
        
        rejectButtons.forEach(button => {
            button.addEventListener('click', function() {
                const applicationId = this.getAttribute('data-id');
                rejectApplications([applicationId]);
            });
        });
        
        detailButtons.forEach(button => {
            button.addEventListener('click', function() {
                const applicationId = this.getAttribute('data-id');
                viewApplicationDetails(applicationId);
            });
        });
    }
    
    // Get selected application IDs
    function getSelectedApplicationIds() {
        const selectedIds = [];
        rowCheckboxes.forEach(checkbox => {
            if (checkbox.checked) {
                const row = checkbox.closest('tr');
                const actionButton = row.querySelector('.btn-approve, .btn-reject');
                if (actionButton) {
                    selectedIds.push(actionButton.getAttribute('data-id'));
                }
            }
        });
        return selectedIds;
    }
    
    // Update bulk actions state
    function updateBulkActionsState() {
        const selectedCount = document.querySelectorAll('.row-select:checked').length;
        if (bulkApproveBtn && bulkRejectBtn) {
            bulkApproveBtn.textContent = `Approve (${selectedCount})`;
            bulkRejectBtn.textContent = `Reject (${selectedCount})`;
            
            bulkApproveBtn.disabled = selectedCount === 0;
            bulkRejectBtn.disabled = selectedCount === 0;
        }
    }
    
    // Update select all state
    function updateSelectAllState() {
        if (selectAllCheckbox) {
            const checkedCount = document.querySelectorAll('.row-select:checked').length;
            const totalCount = rowCheckboxes.length;
            selectAllCheckbox.checked = checkedCount === totalCount;
            selectAllCheckbox.indeterminate = checkedCount > 0 && checkedCount < totalCount;
        }
    }
    
    // Approve applications
    function approveApplications(applicationIds) {
        console.log('Approving applications:', applicationIds);
        
        // Show confirmation dialog
        if (confirm(`Apakah Anda yakin ingin menyetujui ${applicationIds.length} permohonan?`)) {
            // Simulate API call
            showNotification(`Menyetujui ${applicationIds.length} permohonan...`, 'info');
            
            setTimeout(() => {
                // Update UI
                applicationIds.forEach(id => {
                    const row = document.querySelector(`[data-id="${id}"]`).closest('tr');
                    if (row) {
                        const statusCell = row.querySelector('.status-badge');
                        const actionCell = row.querySelector('.action-buttons');
                        
                        // Update status
                        statusCell.className = 'status-badge approved';
                        statusCell.textContent = 'Disetujui';
                        
                        // Update actions
                        actionCell.innerHTML = `
                            <button class="btn-view" data-id="${id}">View</button>
                            <button class="btn-deactivate" data-id="${id}">Nonaktifkan</button>
                        `;
                        
                        // Re-bind event listeners
                        bindActionListeners(actionCell);
                    }
                });
                
                showNotification(`${applicationIds.length} permohonan berhasil disetujui`, 'success');
                updateStats();
            }, 1500);
        }
    }
    
    // Reject applications
    function rejectApplications(applicationIds) {
        console.log('Rejecting applications:', applicationIds);
        
        // Show confirmation dialog with reason input
        const reason = prompt('Masukkan alasan penolakan:');
        if (reason !== null) {
            // Simulate API call
            showNotification(`Menolak ${applicationIds.length} permohonan...`, 'info');
            
            setTimeout(() => {
                // Update UI
                applicationIds.forEach(id => {
                    const row = document.querySelector(`[data-id="${id}"]`).closest('tr');
                    if (row) {
                        const statusCell = row.querySelector('.status-badge');
                        const actionCell = row.querySelector('.action-buttons');
                        
                        // Update status
                        statusCell.className = 'status-badge rejected';
                        statusCell.textContent = 'Ditolak';
                        
                        // Update actions
                        actionCell.innerHTML = `
                            <button class="btn-view" data-id="${id}">View</button>
                            <button class="btn-restore" data-id="${id}">Restore</button>
                        `;
                        
                        // Re-bind event listeners
                        bindActionListeners(actionCell);
                    }
                });
                
                showNotification(`${applicationIds.length} permohonan ditolak. Alasan: ${reason}`, 'success');
                updateStats();
            }, 1500);
        }
    }
    
    // View application details
    function viewApplicationDetails(applicationId) {
        console.log('Viewing application details:', applicationId);
        // In a real implementation, this would open a modal with detailed information
        showNotification(`Membuka detail permohonan #${applicationId}`, 'info');
    }
    
    // Bind action listeners to dynamically created buttons
    function bindActionListeners(container) {
        const approveBtn = container.querySelector('.btn-approve');
        const rejectBtn = container.querySelector('.btn-reject');
        const viewBtn = container.querySelector('.btn-view');
        const deactivateBtn = container.querySelector('.btn-deactivate');
        const activateBtn = container.querySelector('.btn-activate');
        const restoreBtn = container.querySelector('.btn-restore');
        
        if (approveBtn) {
            approveBtn.addEventListener('click', function() {
                const id = this.getAttribute('data-id');
                approveApplications([id]);
            });
        }
        
        if (rejectBtn) {
            rejectBtn.addEventListener('click', function() {
                const id = this.getAttribute('data-id');
                rejectApplications([id]);
            });
        }
        
        if (viewBtn) {
            viewBtn.addEventListener('click', function() {
                const id = this.getAttribute('data-id');
                viewApplicationDetails(id);
            });
        }
        
        // Add similar listeners for other buttons as needed
    }
    
    // Update statistics
    function updateStats() {
        // In a real implementation, this would fetch updated stats from the server
        console.log('Updating statistics...');
    }
    
    // Role Management
    const addRoleBtn = document.getElementById('add-role');
    
    function initRoleManagement() {
        if (addRoleBtn) {
            addRoleBtn.addEventListener('click', function() {
                showAddRoleModal();
            });
        }
        
        // Add event listeners for role cards
        const roleEditButtons = document.querySelectorAll('.role-actions .btn-edit');
        const roleViewButtons = document.querySelectorAll('.role-actions .btn-view');
        
        roleEditButtons.forEach(button => {
            button.addEventListener('click', function() {
                const roleCard = this.closest('.role-card');
                const roleName = roleCard.querySelector('h3').textContent;
                showEditRoleModal(roleName);
            });
        });
        
        roleViewButtons.forEach(button => {
            button.addEventListener('click', function() {
                const roleCard = this.closest('.role-card');
                const roleName = roleCard.querySelector('h3').textContent;
                showRoleDetails(roleName);
            });
        });
    }
    
    function showAddRoleModal() {
        // In a real implementation, this would show a modal for adding new roles
        showNotification('Membuka form tambah role baru', 'info');
    }
    
    function showEditRoleModal(roleName) {
        // In a real implementation, this would show a modal for editing roles
        showNotification(`Mengedit role: ${roleName}`, 'info');
    }
    
    function showRoleDetails(roleName) {
        // In a real implementation, this would show detailed role information
        showNotification(`Melihat detail role: ${roleName}`, 'info');
    }
    
    // User Management
    const exportUsersBtn = document.getElementById('export-users');
    
    function initUserManagement() {
        if (exportUsersBtn) {
            exportUsersBtn.addEventListener('click', function() {
                exportUserData();
            });
        }
    }
    
    function exportUserData() {
        showNotification('Mengekspor data pengguna...', 'info');
        
        // Simulate export process
        setTimeout(() => {
            showNotification('Data pengguna berhasil diekspor', 'success');
        }, 2000);
    }
    
    // Notification System
    function showNotification(message, type = 'info') {
        // Create notification element
        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        notification.innerHTML = `
            <div class="notification-content">
                <span class="notification-message">${message}</span>
                <button class="notification-close">&times;</button>
            </div>
        `;
        
        // Add styles
        notification.style.cssText = `
            position: fixed;
            top: 80px;
            right: 20px;
            background: ${getNotificationColor(type)};
            color: white;
            padding: 12px 16px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            z-index: 1000;
            animation: slideInRight 0.3s ease;
        `;
        
        // Add to page
        document.body.appendChild(notification);
        
        // Auto remove after 3 seconds
        setTimeout(() => {
            if (notification.parentNode) {
                notification.style.animation = 'slideOutRight 0.3s ease';
                setTimeout(() => {
                    if (notification.parentNode) {
                        document.body.removeChild(notification);
                    }
                }, 300);
            }
        }, 3000);
        
        // Close on click
        const closeBtn = notification.querySelector('.notification-close');
        closeBtn.addEventListener('click', () => {
            if (notification.parentNode) {
                document.body.removeChild(notification);
            }
        });
    }
    
    function getNotificationColor(type) {
        const colors = {
            info: '#6366f1',
            success: '#22c55e',
            warning: '#f59e0b',
            error: '#ef4444'
        };
        return colors[type] || colors.info;
    }
    
    // Add CSS for animations
    const style = document.createElement('style');
    style.textContent = `
        @keyframes slideInRight {
            from {
                transform: translateX(100%);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }
        
        @keyframes slideOutRight {
            from {
                transform: translateX(0);
                opacity: 1;
            }
            to {
                transform: translateX(100%);
                opacity: 0;
            }
        }
        
        .notification-close {
            background: none;
            border: none;
            color: white;
            font-size: 18px;
            cursor: pointer;
            margin-left: 10px;
        }
        
        .notification-content {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
    `;
    document.head.appendChild(style);
    
    // Initialize all functionality
    initTabs();
    initApplicationManagement();
    initRoleManagement();
    initUserManagement();
    
    // Log page load
    console.log('Super Pengajuan Akun & Manajemen Pengguna page loaded successfully');
});

// Additional User Management functions
const SuperUserManagement = {
    // Function to approve admin applications
    approveAdminApplication: function(applicationId, mallAssignment) {
        console.log(`Approving admin application: ${applicationId} for mall: ${mallAssignment}`);
        // Implementation for admin application approval
    },
    
    // Function to manage user roles
    updateUserRole: function(userId, newRole, permissions) {
        console.log(`Updating user ${userId} to role ${newRole} with permissions:`, permissions);
        // Implementation for user role management
    },
    
    // Function to export user data
    exportUserData: function(filters, format) {
        console.log(`Exporting user data with filters:`, filters);
        console.log(`Format: ${format}`);
        // Implementation for user data export
    },
    
    // Function to manage role permissions
    updateRolePermissions: function(roleId, permissions) {
        console.log(`Updating permissions for role ${roleId}:`, permissions);
        // Implementation for role permission management
    }
};
// Super Manajemen Mall JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Initialize mall management functionality
    initMallManagement();
    initTableSearch();
});

// Initialize table search and filter
function initTableSearch() {
    const searchInput = document.getElementById('searchInput');
    const statusFilter = document.getElementById('statusFilter');
    const table = document.getElementById('mallTable');
    
    if (searchInput && table) {
        searchInput.addEventListener('input', function() {
            filterTable();
        });
    }
    
    if (statusFilter && table) {
        statusFilter.addEventListener('change', function() {
            filterTable();
        });
    }
}

// Filter table based on search and filters
function filterTable() {
    const searchInput = document.getElementById('searchInput');
    const statusFilter = document.getElementById('statusFilter');
    const table = document.getElementById('mallTable');
    
    if (!table) return;
    
    const searchTerm = searchInput ? searchInput.value.toLowerCase() : '';
    const statusValue = statusFilter ? statusFilter.value.toLowerCase() : '';
    const rows = table.querySelectorAll('tbody tr');
    
    let visibleCount = 0;
    
    rows.forEach(row => {
        // Skip empty state row
        if (row.querySelector('.empty-state')) {
            return;
        }
        
        const text = row.textContent.toLowerCase();
        const statusBadge = row.querySelector('.badge');
        const status = statusBadge ? statusBadge.textContent.toLowerCase() : '';
        
        const matchesSearch = text.includes(searchTerm);
        const matchesStatus = !statusValue || status.includes(statusValue);
        
        if (matchesSearch && matchesStatus) {
            row.style.display = '';
            visibleCount++;
        } else {
            row.style.display = 'none';
        }
    });
}

function initMallManagement() {
    // Search functionality
    const searchInput = document.querySelector('.search-box input');
    if (searchInput) {
        searchInput.addEventListener('input', debounce(function(e) {
            const searchTerm = e.target.value.toLowerCase();
            filterMalls(searchTerm);
        }, 300));
    }

    // Filter functionality
    const statusFilter = document.getElementById('statusFilter');
    const regionFilter = document.getElementById('regionFilter');
    
    if (statusFilter) {
        statusFilter.addEventListener('change', function() {
            applyFilters();
        });
    }
    
    if (regionFilter) {
        regionFilter.addEventListener('change', function() {
            applyFilters();
        });
    }

    // Pagination functionality
    const paginationButtons = document.querySelectorAll('.pagination-btn:not(.disabled)');
    paginationButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            if (!this.classList.contains('active')) {
                const pageNum = this.textContent.trim();
                if (pageNum && !isNaN(pageNum)) {
                    handlePagination(pageNum);
                }
            }
        });
    });

    console.log('Mall management initialized');
    console.log('Search input:', searchInput ? 'Found' : 'Not found');
    console.log('Status filter:', statusFilter ? 'Found' : 'Not found');
    console.log('Region filter:', regionFilter ? 'Found' : 'Not found');
    console.log('Mall cards:', document.querySelectorAll('.mall-card').length);
}

// Debounce function for search
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Filter malls based on search term
function filterMalls(searchTerm) {
    const mallCards = document.querySelectorAll('.mall-card');
    let visibleCount = 0;
    
    mallCards.forEach(card => {
        const mallName = card.querySelector('.mall-name').textContent.toLowerCase();
        const mallLocation = card.querySelector('.mall-location').textContent.toLowerCase();
        const adminName = card.querySelector('.admin-name').textContent.toLowerCase();
        
        const matchesSearch = mallName.includes(searchTerm) || 
                            mallLocation.includes(searchTerm) || 
                            adminName.includes(searchTerm);
        
        if (matchesSearch) {
            card.style.display = 'block';
            visibleCount++;
        } else {
            card.style.display = 'none';
        }
    });
    
    // Update pagination visibility if needed
    updatePaginationVisibility(visibleCount);
}

// Apply all active filters
function applyFilters() {
    const statusFilter = document.getElementById('statusFilter');
    const regionFilter = document.getElementById('regionFilter');
    const mallCards = document.querySelectorAll('.mall-card');
    let visibleCount = 0;
    
    const selectedStatus = statusFilter ? statusFilter.value : '';
    const selectedRegion = regionFilter ? regionFilter.value : '';
    
    mallCards.forEach(card => {
        const cardStatus = card.querySelector('.mall-status').textContent.toLowerCase().trim();
        const cardLocation = card.querySelector('.mall-location').textContent.toLowerCase();
        
        const statusMatch = !selectedStatus || 
                          (selectedStatus === 'active' && cardStatus === 'aktif') ||
                          (selectedStatus === 'inactive' && cardStatus === 'nonaktif') ||
                          (selectedStatus === 'maintenance' && cardStatus === 'maintenance');
        
        const regionMatch = !selectedRegion || cardLocation.includes(selectedRegion);
        
        if (statusMatch && regionMatch) {
            card.style.display = 'block';
            visibleCount++;
        } else {
            card.style.display = 'none';
        }
    });
    
    updatePaginationVisibility(visibleCount);
}

// Update pagination based on visible items
function updatePaginationVisibility(visibleCount) {
    const pagination = document.querySelector('.pagination');
    if (pagination) {
        if (visibleCount === 0) {
            pagination.style.display = 'none';
        } else {
            pagination.style.display = 'flex';
        }
    }
}

// No need for handleMallAction - buttons use direct links and onclick

// Delete mall function - Global function
window.deleteMall = function(mallId) {
    if (!confirm('Apakah Anda yakin ingin menghapus mall ini? Tindakan ini tidak dapat dibatalkan.')) {
        return;
    }

    // Get CSRF token
    const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
    
    // Show loading
    const btn = event.target.closest('.action-btn');
    const originalHTML = btn ? btn.innerHTML : '';
    if (btn) {
        btn.disabled = true;
        btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" /></svg>';
    }

    // Send delete request
    fetch(`/superadmin/mall/${mallId}/delete`, {
        method: 'DELETE',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': token,
            'Accept': 'application/json'
        }
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showNotification(data.message, 'success');
            // Remove card with animation
            const card = btn ? btn.closest('.mall-card') : null;
            if (card) {
                card.style.opacity = '0';
                card.style.transform = 'scale(0.9)';
                setTimeout(() => {
                    card.remove();
                    // Check if no more cards
                    const remainingCards = document.querySelectorAll('.mall-card');
                    if (remainingCards.length === 0) {
                        window.location.reload();
                    }
                }, 300);
            } else {
                setTimeout(() => {
                    window.location.reload();
                }, 1500);
            }
        } else {
            showNotification(data.message, 'error');
            if (btn) {
                btn.disabled = false;
                btn.innerHTML = originalHTML;
            }
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showNotification('Terjadi kesalahan saat menghapus mall', 'error');
        if (btn) {
            btn.disabled = false;
            btn.innerHTML = originalHTML;
        }
    });
}

// View details links work via href - no JS needed

// Handle pagination
function handlePagination(page) {
    console.log(`Loading page: ${page}`);
    
    // Show loading state
    const pagination = document.querySelector('.pagination');
    const originalHTML = pagination.innerHTML;
    pagination.innerHTML = '<span class="text-sm text-gray-600">Memuat halaman...</span>';
    
    // Simulate API call
    setTimeout(() => {
        // Update active page
        const buttons = document.querySelectorAll('.pagination-btn');
        buttons.forEach(btn => {
            btn.classList.remove('active');
            if (btn.textContent.trim() === page) {
                btn.classList.add('active');
            }
        });
        
        // Restore pagination
        pagination.innerHTML = originalHTML;
        
        // Re-initialize pagination event listeners
        const newButtons = document.querySelectorAll('.pagination-btn:not(.disabled)');
        newButtons.forEach(button => {
            button.addEventListener('click', function() {
                if (!this.classList.contains('active')) {
                    handlePagination(this.textContent.trim());
                }
            });
        });
        
        showNotification(`Halaman ${page} dimuat`, 'info');
    }, 1000);
}

// Show notification
function showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `fixed top-4 right-4 z-50 p-4 rounded-lg shadow-lg transition-all duration-300 transform translate-x-full ${
        type === 'success' ? 'bg-green-500 text-white' :
        type === 'error' ? 'bg-red-500 text-white' :
        'bg-blue-500 text-white'
    }`;
    notification.textContent = message;
    
    // Add to page
    document.body.appendChild(notification);
    
    // Animate in
    setTimeout(() => {
        notification.classList.remove('translate-x-full');
    }, 100);
    
    // Remove after delay
    setTimeout(() => {
        notification.classList.add('translate-x-full');
        setTimeout(() => {
            document.body.removeChild(notification);
        }, 300);
    }, 3000);
}

// Export functions for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        initMallManagement,
        filterMalls,
        applyFilters,
        handleMallAction
    };
}
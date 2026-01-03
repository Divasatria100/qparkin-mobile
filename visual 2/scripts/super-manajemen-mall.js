// Super Manajemen Mall JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Initialize mall management functionality
    initMallManagement();
});

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

    // Action buttons functionality
    const actionButtons = document.querySelectorAll('.action-btn');
    actionButtons.forEach(button => {
        button.addEventListener('click', function() {
            const card = this.closest('.mall-card');
            const mallName = card.querySelector('.mall-name').textContent;
            const action = this.getAttribute('title');
            
            handleMallAction(action, mallName, card);
        });
    });

    // Pagination functionality
    const paginationButtons = document.querySelectorAll('.pagination-btn:not(.disabled)');
    paginationButtons.forEach(button => {
        button.addEventListener('click', function() {
            if (!this.classList.contains('active')) {
                handlePagination(this.textContent.trim());
            }
        });
    });

    // View details functionality
    const viewDetailsLinks = document.querySelectorAll('.view-details');
    viewDetailsLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const card = this.closest('.mall-card');
            const mallName = card.querySelector('.mall-name').textContent;
            viewMallDetails(mallName);
        });
    });
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

// Handle mall actions (edit, delete)
function handleMallAction(action, mallName, card) {
    switch (action) {
        case 'Edit':
            editMall(mallName, card);
            break;
        case 'Hapus':
            deleteMall(mallName, card);
            break;
        default:
            console.log('Unknown action:', action);
    }
}

// Edit mall function
function editMall(mallName, card) {
    // In a real application, this would redirect to an edit page
    // For now, we'll simulate the behavior
    console.log(`Editing mall: ${mallName}`);
    
    // Show loading state
    const actions = card.querySelector('.mall-actions');
    const originalHTML = actions.innerHTML;
    actions.innerHTML = '<span class="text-sm text-blue-600">Mengedit...</span>';
    
    // Simulate API call
    setTimeout(() => {
        // Redirect to edit page (simulated)
        window.location.href = `super-edit-mall.html?mall=${encodeURIComponent(mallName)}`;
    }, 1000);
}

// Delete mall function
function deleteMall(mallName, card) {
    // Show confirmation dialog
    if (confirm(`Apakah Anda yakin ingin menghapus ${mallName}? Tindakan ini tidak dapat dibatalkan.`)) {
        console.log(`Deleting mall: ${mallName}`);
        
        // Show loading state
        const actions = card.querySelector('.mall-actions');
        const originalHTML = actions.innerHTML;
        actions.innerHTML = '<span class="text-sm text-red-600">Menghapus...</span>';
        
        // Simulate API call
        setTimeout(() => {
            // Remove card with animation
            card.style.opacity = '0';
            card.style.transform = 'translateX(100px)';
            
            setTimeout(() => {
                card.remove();
                showNotification(`${mallName} berhasil dihapus`, 'success');
            }, 300);
        }, 1500);
    }
}

// View mall details
function viewMallDetails(mallName) {
    console.log(`Viewing details for: ${mallName}`);
    
    // In a real application, this would redirect to a details page
    // For now, we'll simulate the behavior
    window.location.href = `super-detail-mall.html?mall=${encodeURIComponent(mallName)}`;
}

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
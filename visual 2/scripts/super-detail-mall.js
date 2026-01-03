// Super Detail Mall JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Initialize detail mall functionality
    initDetailMall();
});

function initDetailMall() {
    // Get mall data from URL parameter
    const urlParams = new URLSearchParams(window.location.search);
    const mallName = urlParams.get('mall');
    
    if (mallName) {
        loadMallDetail(mallName);
    }

    // Initialize tabs
    initTabs();

    // Initialize quick actions
    initQuickActions();

    // Initialize real-time data updates
    initRealTimeUpdates();
}

function loadMallDetail(mallName) {
    console.log(`Loading detail for mall: ${mallName}`);
    
    // Show loading state
    showNotification('Memuat detail mall...', 'info');
    
    // Simulate API call to load mall data
    setTimeout(() => {
        // Update page title and header
        document.title = `Detail Mall - ${mallName} - QPARKIN`;
        
        // Update breadcrumb
        const breadcrumb = document.querySelector('.breadcrumb span:last-child');
        if (breadcrumb) {
            breadcrumb.textContent = `Detail Mall - ${mallName}`;
        }
        
        showNotification('Detail mall berhasil dimuat', 'success');
        
        // Load additional data for tabs
        loadTabData('overview');
    }, 1000);
}

function initTabs() {
    const tabButtons = document.querySelectorAll('.tab-button');
    const tabContents = document.querySelectorAll('.tab-content');
    
    tabButtons.forEach(button => {
        button.addEventListener('click', function() {
            const tabId = this.getAttribute('data-tab');
            
            // Remove active class from all buttons and contents
            tabButtons.forEach(btn => btn.classList.remove('active'));
            tabContents.forEach(content => content.classList.remove('active'));
            
            // Add active class to clicked button and corresponding content
            this.classList.add('active');
            document.getElementById(`${tabId}-tab`).classList.add('active');
            
            // Load tab data if needed
            loadTabData(tabId);
        });
    });
}

function loadTabData(tabId) {
    switch (tabId) {
        case 'overview':
            // Overview data is already loaded
            break;
        case 'parking':
            loadParkingData();
            break;
        case 'performance':
            loadPerformanceData();
            break;
        case 'admin':
            loadAdminData();
            break;
        case 'settings':
            loadSettingsData();
            break;
    }
}

function loadParkingData() {
    // Simulate loading parking data
    console.log('Loading parking data...');
    // In a real application, this would fetch data from an API
}

function loadPerformanceData() {
    // Simulate loading performance data
    console.log('Loading performance data...');
    
    const placeholder = document.querySelector('#performance-tab .performance-placeholder');
    if (placeholder) {
        setTimeout(() => {
            placeholder.innerHTML = `
                <div class="performance-content">
                    <h3>Performance Analytics</h3>
                    <div class="performance-stats">
                        <div class="performance-metric">
                            <span class="metric-value">85%</span>
                            <span class="metric-label">Average Occupancy</span>
                        </div>
                        <div class="performance-metric">
                            <span class="metric-value">Rp 450Jt</span>
                            <span class="metric-label">Monthly Revenue</span>
                        </div>
                        <div class="performance-metric">
                            <span class="metric-value">12.5%</span>
                            <span class="metric-label">Growth Rate</span>
                        </div>
                    </div>
                </div>
            `;
        }, 500);
    }
}

function loadAdminData() {
    // Simulate loading admin data
    console.log('Loading admin data...');
    
    const placeholder = document.querySelector('#admin-tab .admin-placeholder');
    if (placeholder) {
        setTimeout(() => {
            placeholder.innerHTML = `
                <div class="admin-content">
                    <h3>Admin Management</h3>
                    <div class="admin-list">
                        <div class="admin-item">
                            <div class="admin-avatar">
                                <span>BS</span>
                            </div>
                            <div class="admin-info">
                                <h4>Budi Santoso</h4>
                                <p>Primary Admin</p>
                                <span>budi.santoso@grand-indonesia.com</span>
                            </div>
                            <div class="admin-status active">
                                <span class="status-dot"></span>
                                Active
                            </div>
                        </div>
                    </div>
                </div>
            `;
        }, 500);
    }
}

function loadSettingsData() {
    // Simulate loading settings data
    console.log('Loading settings data...');
    
    const placeholder = document.querySelector('#settings-tab .settings-placeholder');
    if (placeholder) {
        setTimeout(() => {
            placeholder.innerHTML = `
                <div class="settings-content">
                    <h3>System Settings</h3>
                    <div class="settings-list">
                        <div class="setting-item">
                            <label>API Integration</label>
                            <span class="status-badge active">Connected</span>
                        </div>
                        <div class="setting-item">
                            <label>Payment Gateway</label>
                            <span class="status-badge active">Active</span>
                        </div>
                        <div class="setting-item">
                            <label>System Version</label>
                            <span>v2.1.4</span>
                        </div>
                    </div>
                </div>
            `;
        }, 500);
    }
}

function initQuickActions() {
    const quickActionButtons = document.querySelectorAll('.quick-action-btn');
    
    quickActionButtons.forEach(button => {
        button.addEventListener('click', function() {
            const action = this.getAttribute('data-action');
            handleQuickAction(action);
        });
    });
}

function handleQuickAction(action) {
    const mallName = document.querySelector('.mall-info-header h1').textContent;
    
    switch (action) {
        case 'edit-rates':
            showNotification(`Membuka editor tarif untuk ${mallName}`, 'info');
            // In real application, this would open a modal or redirect
            setTimeout(() => {
                window.location.href = `super-edit-mall.html?mall=${encodeURIComponent(mallName)}&section=rates`;
            }, 500);
            break;
            
        case 'view-reports':
            showNotification(`Membuka laporan ${mallName}`, 'info');
            // In real application, this would open reports page
            setTimeout(() => {
                window.location.href = `super-laporan.html?mall=${encodeURIComponent(mallName)}`;
            }, 500);
            break;
            
        case 'manage-admin':
            showNotification(`Membuka manajemen admin ${mallName}`, 'info');
            // In real application, this would open admin management
            setTimeout(() => {
                window.location.href = `super-edit-mall.html?mall=${encodeURIComponent(mallName)}&section=admin`;
            }, 500);
            break;
            
        case 'system-status':
            showNotification(`Memeriksa status sistem ${mallName}`, 'info');
            checkSystemStatus(mallName);
            break;
            
        default:
            console.log('Unknown action:', action);
    }
}

function checkSystemStatus(mallName) {
    // Show loading state
    const button = document.querySelector('[data-action="system-status"]');
    const originalText = button.innerHTML;
    button.innerHTML = `
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="spin">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
        </svg>
        Memeriksa Status...
    `;
    
    // Simulate system status check
    setTimeout(() => {
        button.innerHTML = originalText;
        showNotification(`Sistem ${mallName} berjalan normal`, 'success');
    }, 2000);
}

function initRealTimeUpdates() {
    // Simulate real-time data updates
    setInterval(updateRealTimeData, 30000); // Update every 30 seconds
}

function updateRealTimeData() {
    // Update visitor count randomly
    const visitorElement = document.querySelector('.stat-card:nth-child(3) .stat-value');
    if (visitorElement) {
        const currentVisitors = parseInt(visitorElement.textContent.replace(/,/g, ''));
        const randomChange = Math.floor(Math.random() * 50) - 10; // -10 to +40
        const newVisitors = Math.max(0, currentVisitors + randomChange);
        visitorElement.textContent = newVisitors.toLocaleString();
        
        // Update trend
        const trendElement = visitorElement.nextElementSibling;
        if (trendElement && randomChange > 0) {
            trendElement.innerHTML = `<span>+${randomChange}</span> dari 5 menit lalu`;
        }
    }
    
    // Update occupancy rate
    const occupancyElement = document.querySelector('.stat-card:nth-child(4) .stat-value');
    if (occupancyElement) {
        const currentOccupancy = parseInt(occupancyElement.textContent);
        const randomChange = Math.floor(Math.random() * 6) - 2; // -2% to +3%
        const newOccupancy = Math.max(0, Math.min(100, currentOccupancy + randomChange));
        occupancyElement.textContent = `${newOccupancy}%`;
    }
}

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

// Add CSS for spinning animation
const style = document.createElement('style');
style.textContent = `
    .spin {
        animation: spin 1s linear infinite;
    }
    
    @keyframes spin {
        from { transform: rotate(0deg); }
        to { transform: rotate(360deg); }
    }
    
    .performance-metric {
        text-align: center;
        padding: 20px;
        background: #f8fafc;
        border-radius: 8px;
        margin: 10px;
    }
    
    .metric-value {
        display: block;
        font-size: 2rem;
        font-weight: 700;
        color: #6366f1;
        margin-bottom: 4px;
    }
    
    .metric-label {
        font-size: 0.875rem;
        color: #64748b;
    }
    
    .admin-item {
        display: flex;
        align-items: center;
        gap: 16px;
        padding: 16px;
        background: #f8fafc;
        border-radius: 8px;
        margin-bottom: 12px;
    }
    
    .admin-avatar {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background: #6366f1;
        color: white;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 600;
    }
    
    .admin-info h4 {
        margin: 0 0 4px 0;
        color: #1e293b;
    }
    
    .admin-info p {
        margin: 0 0 2px 0;
        color: #64748b;
        font-size: 0.875rem;
    }
    
    .admin-info span {
        font-size: 0.75rem;
        color: #94a3b8;
    }
    
    .admin-status {
        display: flex;
        align-items: center;
        gap: 6px;
        font-size: 0.75rem;
        padding: 4px 8px;
        border-radius: 12px;
        background: #f0fdf4;
        color: #16a34a;
    }
    
    .setting-item {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 12px 0;
        border-bottom: 1px solid #e2e8f0;
    }
    
    .setting-item:last-child {
        border-bottom: none;
    }
    
    .setting-item label {
        font-weight: 600;
        color: #374151;
    }
    
    .status-badge {
        padding: 4px 8px;
        border-radius: 6px;
        font-size: 0.75rem;
        font-weight: 600;
    }
    
    .status-badge.active {
        background: #f0fdf4;
        color: #16a34a;
    }
`;
document.head.appendChild(style);

// Export functions for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        initDetailMall,
        loadMallDetail,
        handleQuickAction
    };
}
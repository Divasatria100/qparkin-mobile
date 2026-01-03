// Super Laporan & Analitik JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Initialize filter functionality
    const periodeSelect = document.getElementById('periode');
    const mallSelect = document.getElementById('mall');
    const jenisLaporanSelect = document.getElementById('jenis-laporan');
    const generateBtn = document.querySelector('.btn-generate');
    const exportBtn = document.querySelector('.btn-export');
    
    // Generate Report Function
    function generateReport() {
        const periode = periodeSelect.value;
        const mall = mallSelect.value;
        const jenisLaporan = jenisLaporanSelect.value;
        
        console.log('Generating report with parameters:', {
            periode,
            mall,
            jenisLaporan
        });
        
        // Show loading state
        const originalText = generateBtn.textContent;
        generateBtn.textContent = 'Generating...';
        generateBtn.disabled = true;
        
        // Simulate API call
        setTimeout(() => {
            generateBtn.textContent = originalText;
            generateBtn.disabled = false;
            
            // Show success notification
            showNotification('Laporan berhasil digenerate!', 'success');
        }, 2000);
    }
    
    // Export Function
    function exportData() {
        const periode = periodeSelect.value;
        const mall = mallSelect.value;
        const jenisLaporan = jenisLaporanSelect.value;
        
        console.log('Exporting data with parameters:', {
            periode,
            mall,
            jenisLaporan
        });
        
        // Show loading state
        const originalText = exportBtn.textContent;
        exportBtn.textContent = 'Exporting...';
        exportBtn.disabled = true;
        
        // Simulate export process
        setTimeout(() => {
            exportBtn.textContent = originalText;
            exportBtn.disabled = false;
            
            // Trigger download (simulated)
            triggerDownload();
            
            // Show success notification
            showNotification('Data berhasil diekspor!', 'success');
        }, 1500);
    }
    
    // Trigger Download (Simulated)
    function triggerDownload() {
        // In a real implementation, this would trigger an actual file download
        console.log('Download triggered for exported data');
        
        // Create a temporary link for download simulation
        const link = document.createElement('a');
        link.style.display = 'none';
        document.body.appendChild(link);
        
        // Simulate click (in real implementation, this would have actual file URL)
        setTimeout(() => {
            document.body.removeChild(link);
        }, 100);
    }
    
    // Show Notification
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
            background: ${type === 'success' ? '#22c55e' : '#6366f1'};
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
    
    // Event Listeners
    if (generateBtn) {
        generateBtn.addEventListener('click', generateReport);
    }
    
    if (exportBtn) {
        exportBtn.addEventListener('click', exportData);
    }
    
    // Add event listeners for export buttons in export cards
    const exportCardButtons = document.querySelectorAll('.export-card .btn-export');
    exportCardButtons.forEach(button => {
        button.addEventListener('click', function() {
            const card = this.closest('.export-card');
            const title = card.querySelector('h3').textContent;
            showNotification(`${title} sedang diekspor...`, 'info');
            
            // Simulate export process
            setTimeout(() => {
                showNotification(`${title} berhasil diekspor!`, 'success');
            }, 1500);
        });
    });
    
    // Add event listeners for action buttons
    const actionButtons = document.querySelectorAll('.btn-action');
    actionButtons.forEach(button => {
        button.addEventListener('click', function() {
            const section = this.closest('.report-section');
            const title = section.querySelector('h2').textContent;
            showNotification(`Memproses ${title.toLowerCase()}...`, 'info');
        });
    });
    
    // Initialize chart placeholders with sample data
    function initializeCharts() {
        // In a real implementation, this would initialize actual charts
        // For now, we'll just log that charts would be initialized
        console.log('Initializing report charts...');
        
        // Simulate chart data loading
        setTimeout(() => {
            console.log('Charts initialized with sample data');
        }, 500);
    }
    
    // Initialize on load
    initializeCharts();
    
    // Log page load
    console.log('Super Laporan & Analitik page loaded successfully');
});

// Additional Laporan specific functions
const SuperLaporan = {
    // Function to generate consolidated financial report
    generateFinancialReport: function(periode, format = 'pdf') {
        console.log(`Generating financial report for ${periode} in ${format} format`);
        // Implementation for financial report generation
    },
    
    // Function to compare mall performance
    compareMallPerformance: function(mallIds, metrics) {
        console.log(`Comparing performance for malls: ${mallIds.join(', ')}`);
        console.log(`Metrics: ${metrics.join(', ')}`);
        // Implementation for mall performance comparison
    },
    
    // Function to analyze feature usage
    analyzeFeatureUsage: function(features, dateRange) {
        console.log(`Analyzing feature usage for: ${features.join(', ')}`);
        console.log(`Date range: ${dateRange}`);
        // Implementation for feature usage analysis
    },
    
    // Function to export accounting data
    exportAccountingData: function(periode, reportType) {
        console.log(`Exporting ${reportType} data for ${periode}`);
        // Implementation for accounting data export
    }
};
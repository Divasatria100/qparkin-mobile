// Super Admin Laporan JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Initialize the reports page
    initLaporanPage();
});

function initLaporanPage() {
    // Initialize all components
    initFilters();
    initCharts();
    initReportActions();
    initTableInteractions();
}

// Filter functionality
function initFilters() {
    const dateRange = document.getElementById('dateRange');
    const customDateRange = document.getElementById('customDateRange');
    const customDateRangeEnd = document.getElementById('customDateRangeEnd');
    const applyFiltersBtn = document.getElementById('applyFilters');
    
    // Date range change
    if (dateRange) {
        dateRange.addEventListener('change', function() {
            if (this.value === 'custom') {
                customDateRange.style.display = 'flex';
                customDateRangeEnd.style.display = 'flex';
            } else {
                customDateRange.style.display = 'none';
                customDateRangeEnd.style.display = 'none';
            }
        });
    }
    
    // Apply filters
    if (applyFiltersBtn) {
        applyFiltersBtn.addEventListener('click', function() {
            applyFilters();
        });
    }
    
    // Set default dates for custom range
    setDefaultDates();
}

function setDefaultDates() {
    const today = new Date();
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(today.getDate() - 30);
    
    document.getElementById('startDate').value = formatDate(thirtyDaysAgo);
    document.getElementById('endDate').value = formatDate(today);
}

function formatDate(date) {
    return date.toISOString().split('T')[0];
}

function applyFilters() {
    const dateRange = document.getElementById('dateRange').value;
    const mallFilter = document.getElementById('mallFilter').value;
    
    let dateText = '';
    switch (dateRange) {
        case '7days':
            dateText = '7 Hari Terakhir';
            break;
        case '30days':
            dateText = '30 Hari Terakhir';
            break;
        case '90days':
            dateText = '90 Hari Terakhir';
            break;
        case 'custom':
            const startDate = document.getElementById('startDate').value;
            const endDate = document.getElementById('endDate').value;
            dateText = `${startDate} sampai ${endDate}`;
            break;
    }
    
    const mallText = mallFilter === 'all' ? 'Semua Mall' : 
                    document.getElementById('mallFilter').selectedOptions[0].text;
    
    // Show loading state
    showNotification(`Memuat data untuk ${mallText} - ${dateText}`, 'info');
    
    // In a real application, this would fetch new data from the server
    // For now, we'll just update the charts with the new timeframe
    updateCharts(dateRange);
}

// Charts initialization and management
function initCharts() {
    createRevenueChart();
    createTransactionChart();
    createMallPerformanceChart();
    createPeakHoursChart();
    
    // Initialize chart period buttons
    initChartPeriodButtons();
}

function createRevenueChart() {
    const ctx = document.getElementById('revenueChart').getContext('2d');
    
    // Sample data for revenue chart
    const data = {
        labels: ['1 Mar', '5 Mar', '10 Mar', '15 Mar', '20 Mar', '25 Mar', '30 Mar'],
        datasets: [{
            label: 'Pendapatan Harian',
            data: [120, 150, 180, 200, 170, 220, 250],
            borderColor: '#6366f1',
            backgroundColor: 'rgba(99, 102, 241, 0.1)',
            borderWidth: 3,
            fill: true,
            tension: 0.4
        }]
    };
    
    const config = {
        type: 'line',
        data: data,
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    mode: 'index',
                    intersect: false,
                    callbacks: {
                        label: function(context) {
                            return `Rp ${context.parsed.y}Jt`;
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    },
                    ticks: {
                        callback: function(value) {
                            return `Rp ${value}Jt`;
                        }
                    }
                },
                x: {
                    grid: {
                        display: false
                    }
                }
            }
        }
    };
    
    window.revenueChart = new Chart(ctx, config);
}

function createTransactionChart() {
    const ctx = document.getElementById('transactionChart').getContext('2d');
    
    // Sample data for transaction chart
    const data = {
        labels: ['1 Mar', '5 Mar', '10 Mar', '15 Mar', '20 Mar', '25 Mar', '30 Mar'],
        datasets: [{
            label: 'Transaksi Harian',
            data: [7500, 8200, 7800, 8500, 8000, 9200, 9500],
            borderColor: '#10b981',
            backgroundColor: 'rgba(16, 185, 129, 0.1)',
            borderWidth: 3,
            fill: true,
            tension: 0.4
        }]
    };
    
    const config = {
        type: 'line',
        data: data,
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    mode: 'index',
                    intersect: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    }
                },
                x: {
                    grid: {
                        display: false
                    }
                }
            }
        }
    };
    
    window.transactionChart = new Chart(ctx, config);
}

function createMallPerformanceChart() {
    const ctx = document.getElementById('mallPerformanceChart').getContext('2d');
    
    // Sample data for mall performance
    const data = {
        labels: ['Grand Indonesia', 'Plaza Indonesia', 'Pacific Place', 'Senayan City', 'Lippo Mall'],
        datasets: [{
            label: 'Pendapatan (Juta Rupiah)',
            data: [450, 380, 320, 290, 260],
            backgroundColor: [
                'rgba(99, 102, 241, 0.8)',
                'rgba(139, 92, 246, 0.8)',
                'rgba(59, 130, 246, 0.8)',
                'rgba(16, 185, 129, 0.8)',
                'rgba(245, 158, 11, 0.8)'
            ],
            borderColor: [
                'rgb(99, 102, 241)',
                'rgb(139, 92, 246)',
                'rgb(59, 130, 246)',
                'rgb(16, 185, 129)',
                'rgb(245, 158, 11)'
            ],
            borderWidth: 1
        }]
    };
    
    const config = {
        type: 'bar',
        data: data,
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            return `Rp ${context.parsed.y}Jt`;
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    },
                    ticks: {
                        callback: function(value) {
                            return `Rp ${value}Jt`;
                        }
                    }
                },
                x: {
                    grid: {
                        display: false
                    }
                }
            }
        }
    };
    
    window.mallPerformanceChart = new Chart(ctx, config);
}

function createPeakHoursChart() {
    const ctx = document.getElementById('peakHoursChart').getContext('2d');
    
    // Sample data for peak hours
    const data = {
        labels: ['06:00', '08:00', '10:00', '12:00', '14:00', '16:00', '18:00', '20:00', '22:00'],
        datasets: [{
            label: 'Weekday',
            data: [120, 450, 320, 280, 220, 380, 520, 380, 150],
            borderColor: '#6366f1',
            backgroundColor: 'rgba(99, 102, 241, 0.1)',
            borderWidth: 3,
            fill: true,
            tension: 0.4
        }, {
            label: 'Weekend',
            data: [80, 320, 580, 720, 650, 820, 950, 720, 380],
            borderColor: '#10b981',
            backgroundColor: 'rgba(16, 185, 129, 0.1)',
            borderWidth: 3,
            fill: true,
            tension: 0.4
        }]
    };
    
    const config = {
        type: 'line',
        data: data,
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                tooltip: {
                    mode: 'index',
                    intersect: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    },
                    title: {
                        display: true,
                        text: 'Jumlah Kendaraan'
                    }
                },
                x: {
                    grid: {
                        display: false
                    },
                    title: {
                        display: true,
                        text: 'Jam'
                    }
                }
            }
        }
    };
    
    window.peakHoursChart = new Chart(ctx, config);
}

function initChartPeriodButtons() {
    // Revenue and transaction chart period buttons
    document.querySelectorAll('.chart-actions .chart-action-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const parent = this.closest('.chart-actions');
            const period = this.getAttribute('data-period');
            const metric = this.getAttribute('data-metric');
            const day = this.getAttribute('data-day');
            
            // Update active state
            parent.querySelectorAll('.chart-action-btn').forEach(b => {
                b.classList.remove('active');
            });
            this.classList.add('active');
            
            // Update chart based on period
            if (period) {
                updateChartPeriod(period, this.closest('.chart-section'));
            }
            
            if (metric) {
                updateChartMetric(metric, this.closest('.chart-section'));
            }
            
            if (day) {
                updateChartDay(day, this.closest('.chart-section'));
            }
        });
    });
}

function updateChartPeriod(period, chartSection) {
    // In a real application, this would fetch new data from the server
    // For demo purposes, we'll just show a notification
    const chartTitle = chartSection.querySelector('h3').textContent;
    showNotification(`Memperbarui ${chartTitle} untuk periode ${period}`, 'info');
}

function updateChartMetric(metric, chartSection) {
    const chartTitle = chartSection.querySelector('h3').textContent;
    showNotification(`Mengubah metrik ${chartTitle} menjadi ${metric === 'revenue' ? 'Pendapatan' : 'Transaksi'}`, 'info');
}

function updateChartDay(day, chartSection) {
    const chartTitle = chartSection.querySelector('h3').textContent;
    showNotification(`Mengubah ${chartTitle} untuk ${day === 'weekday' ? 'Weekday' : 'Weekend'}`, 'info');
}

function updateCharts(dateRange) {
    // In a real application, this would update all charts with new data
    // For demo purposes, we'll just simulate the update
    
    // Show loading state on charts
    const charts = document.querySelectorAll('.chart-container canvas');
    charts.forEach(chart => {
        chart.style.opacity = '0.5';
    });
    
    // Simulate API call delay
    setTimeout(() => {
        charts.forEach(chart => {
            chart.style.opacity = '1';
        });
        showNotification('Data charts berhasil diperbarui', 'success');
    }, 1000);
}

// Report actions
function initReportActions() {
    const generateReportBtn = document.getElementById('generateReport');
    const exportAllBtn = document.getElementById('exportAll');
    const viewReportBtns = document.querySelectorAll('.btn-report.view');
    const exportReportBtns = document.querySelectorAll('.btn-report.export');
    
    // Generate report
    if (generateReportBtn) {
        generateReportBtn.addEventListener('click', function() {
            generateComprehensiveReport();
        });
    }
    
    // Export all reports
    if (exportAllBtn) {
        exportAllBtn.addEventListener('click', function() {
            exportAllReports();
        });
    }
    
    // View individual reports
    viewReportBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            const reportType = this.getAttribute('data-report');
            viewReport(reportType);
        });
    });
    
    // Export individual reports
    exportReportBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            const reportType = this.getAttribute('data-report');
            exportReport(reportType);
        });
    });
}

function generateComprehensiveReport() {
    // Show loading state
    const btn = document.getElementById('generateReport');
    const originalHTML = btn.innerHTML;
    btn.innerHTML = '<svg class="animate-spin" xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" /></svg> Membuat Laporan...';
    btn.disabled = true;
    
    // Simulate report generation
    setTimeout(() => {
        btn.innerHTML = originalHTML;
        btn.disabled = false;
        
        // Show success message with download link
        showNotification('Laporan komprehensif berhasil dibuat dan siap diunduh', 'success');
        
        // In a real application, this would trigger a file download
        console.log('Comprehensive report generated successfully');
    }, 3000);
}

function exportAllReports() {
    // Show loading state
    const btn = document.getElementById('exportAll');
    const originalHTML = btn.innerHTML;
    btn.innerHTML = '<svg class="animate-spin" xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" /></svg> Mengekspor...';
    btn.disabled = true;
    
    // Simulate export process
    setTimeout(() => {
        btn.innerHTML = originalHTML;
        btn.disabled = false;
        
        showNotification('Semua laporan berhasil diekspor', 'success');
        console.log('All reports exported successfully');
    }, 2000);
}

function viewReport(reportType) {
    const reportNames = {
        'financial': 'Laporan Keuangan',
        'transaction': 'Laporan Transaksi',
        'user': 'Laporan Pengguna',
        'operational': 'Laporan Operasional'
    };
    
    // In a real application, this would navigate to a detailed report page
    // For demo purposes, we'll show an alert
    alert(`Membuka ${reportNames[reportType]}\n\nFitur ini akan membuka halaman detail dengan analisis mendalam untuk laporan ${reportNames[reportType].toLowerCase()}.`);
}

function exportReport(reportType) {
    const reportNames = {
        'financial': 'Laporan Keuangan',
        'transaction': 'Laporan Transaksi',
        'user': 'Laporan Pengguna',
        'operational': 'Laporan Operasional'
    };
    
    // Show loading state for the specific button
    const btn = document.querySelector(`.btn-report.export[data-report="${reportType}"]`);
    const originalHTML = btn.innerHTML;
    btn.innerHTML = 'Mengekspor...';
    btn.disabled = true;
    
    // Simulate export process
    setTimeout(() => {
        btn.innerHTML = originalHTML;
        btn.disabled = false;
        
        showNotification(`${reportNames[reportType]} berhasil diekspor`, 'success');
        console.log(`${reportNames[reportType]} exported successfully`);
    }, 1500);
}

// Table interactions
function initTableInteractions() {
    const exportRankingBtn = document.getElementById('exportRanking');
    const refreshRankingBtn = document.getElementById('refreshRanking');
    const viewMallBtns = document.querySelectorAll('.btn-action.view');
    
    // Export ranking
    if (exportRankingBtn) {
        exportRankingBtn.addEventListener('click', function() {
            exportRankingData();
        });
    }
    
    // Refresh ranking
    if (refreshRankingBtn) {
        refreshRankingBtn.addEventListener('click', function() {
            refreshRankingData();
        });
    }
    
    // View mall details
    viewMallBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            const mallId = this.getAttribute('data-mall');
            viewMallDetails(mallId);
        });
    });
}

function exportRankingData() {
    // Show loading state
    const btn = document.getElementById('exportRanking');
    const originalHTML = btn.innerHTML;
    btn.innerHTML = '<svg class="animate-spin" xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" /></svg>';
    btn.disabled = true;
    
    // Simulate export process
    setTimeout(() => {
        btn.innerHTML = originalHTML;
        btn.disabled = false;
        
        showNotification('Data ranking mall berhasil diekspor', 'success');
        console.log('Ranking data exported successfully');
    }, 1500);
}

function refreshRankingData() {
    // Show loading state
    const btn = document.getElementById('refreshRanking');
    const originalHTML = btn.innerHTML;
    btn.innerHTML = '<svg class="animate-spin" xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" /></svg>';
    btn.disabled = true;
    
    // Simulate refresh process
    setTimeout(() => {
        btn.innerHTML = originalHTML;
        btn.disabled = false;
        
        showNotification('Data ranking berhasil diperbarui', 'success');
        console.log('Ranking data refreshed successfully');
    }, 1000);
}

function viewMallDetails(mallId) {
    const mallNames = {
        'grand-indonesia': 'Grand Indonesia',
        'plaza-indonesia': 'Plaza Indonesia',
        'pacific-place': 'Pacific Place'
    };
    
    // In a real application, this would navigate to mall details page
    // For demo purposes, we'll show an alert
    alert(`Melihat detail kinerja ${mallNames[mallId]}\n\nFitur ini akan membuka halaman detail dengan analisis mendalam untuk mall ${mallNames[mallId]}.`);
}

// Utility functions
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
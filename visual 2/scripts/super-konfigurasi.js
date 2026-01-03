// Super Admin Konfigurasi JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Tab Navigation
    const tabHeaders = document.querySelectorAll('.tab-header');
    const tabContents = document.querySelectorAll('.tab-content');

    tabHeaders.forEach(header => {
        header.addEventListener('click', () => {
            const targetTab = header.getAttribute('data-tab');
            
            // Remove active class from all tabs
            tabHeaders.forEach(h => h.classList.remove('active'));
            tabContents.forEach(c => c.classList.remove('active'));
            
            // Add active class to current tab
            header.classList.add('active');
            document.getElementById(targetTab).classList.add('active');
        });
    });

    // Password Toggle Functionality
    const passwordToggles = document.querySelectorAll('.password-toggle');
    
    passwordToggles.forEach(toggle => {
        toggle.addEventListener('click', function() {
            const passwordInput = this.previousElementSibling;
            const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
            passwordInput.setAttribute('type', type);
            
            // Change icon
            this.textContent = type === 'password' ? '👁️' : '🔒';
        });
    });

    // Test Connection Buttons
    const testButtons = document.querySelectorAll('.btn-test');
    
    testButtons.forEach(button => {
        button.addEventListener('click', function() {
            const originalText = this.textContent;
            const card = this.closest('.config-card');
            const statusBadge = card.querySelector('.status-badge');
            
            // Show loading state
            this.textContent = 'Testing...';
            this.disabled = true;
            
            // Simulate API test
            setTimeout(() => {
                // Simulate success
                this.textContent = 'Connection Successful!';
                this.style.background = '#10b981';
                
                // Update status badge
                if (statusBadge) {
                    statusBadge.textContent = 'Aktif';
                    statusBadge.className = 'status-badge active';
                }
                
                // Reset button after delay
                setTimeout(() => {
                    this.textContent = originalText;
                    this.style.background = '';
                    this.disabled = false;
                }, 2000);
            }, 1500);
        });
    });

    // Save Configuration Buttons
    const saveButtons = document.querySelectorAll('.btn-primary');
    
    saveButtons.forEach(button => {
        if (button.textContent.includes('Simpan')) {
            button.addEventListener('click', function() {
                const originalText = this.textContent;
                
                // Show loading state
                this.textContent = 'Menyimpan...';
                this.disabled = true;
                
                // Simulate save operation
                setTimeout(() => {
                    this.textContent = 'Berhasil Disimpan!';
                    this.style.background = '#10b981';
                    
                    // Show success notification
                    showNotification('Konfigurasi berhasil disimpan!', 'success');
                    
                    // Reset button after delay
                    setTimeout(() => {
                        this.textContent = originalText;
                        this.style.background = '';
                        this.disabled = false;
                    }, 2000);
                }, 1000);
            });
        }
    });

    // Log Filter Functionality
    const logFilters = document.querySelector('.log-filters');
    const logTable = document.querySelector('.data-table tbody');
    
    if (logFilters) {
        const filterButton = logFilters.querySelector('.btn-primary');
        
        filterButton.addEventListener('click', function() {
            const logType = document.getElementById('log-type').value;
            const logDate = document.getElementById('log-date').value;
            const logUser = document.getElementById('log-user').value;
            
            // Show loading state
            this.textContent = 'Memfilter...';
            this.disabled = true;
            
            // Simulate filter operation
            setTimeout(() => {
                filterLogs(logType, logDate, logUser);
                this.textContent = 'Filter';
                this.disabled = false;
                
                showNotification('Log berhasil difilter!', 'success');
            }, 500);
        });
    }

    // Export Logs Functionality
    const exportButton = document.querySelector('.btn-outline');
    
    if (exportButton && exportButton.textContent.includes('Ekspor')) {
        exportButton.addEventListener('click', function() {
            // Simulate export operation
            this.textContent = 'Mengekspor...';
            this.disabled = true;
            
            setTimeout(() => {
                this.textContent = 'Ekspor Log';
                this.disabled = false;
                
                // Create and trigger download
                const blob = new Blob(['Simulated log export data'], { type: 'text/csv' });
                const url = window.URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = `system-logs-${new Date().toISOString().split('T')[0]}.csv`;
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                window.URL.revokeObjectURL(url);
                
                showNotification('Log berhasil diekspor!', 'success');
            }, 1000);
        });
    }

    // Template Preview Functionality
    const previewButtons = document.querySelectorAll('.btn-outline.btn-sm');
    
    previewButtons.forEach(button => {
        if (button.textContent.includes('Preview')) {
            button.addEventListener('click', function() {
                const templateItem = this.closest('.template-item');
                const templateName = templateItem.querySelector('h4').textContent;
                
                showTemplatePreview(templateName);
            });
        }
    });

    // Switch Toggle Functionality
    const switches = document.querySelectorAll('.switch input');
    
    switches.forEach(switchInput => {
        switchInput.addEventListener('change', function() {
            const settingItem = this.closest('.setting-item');
            const settingName = settingItem.querySelector('h4').textContent;
            const isEnabled = this.checked;
            
            // Simulate API call to update setting
            console.log(`Setting "${settingName}" ${isEnabled ? 'enabled' : 'disabled'}`);
            
            showNotification(
                `Notifikasi ${settingName} ${isEnabled ? 'diaktifkan' : 'dinonaktifkan'}!`,
                isEnabled ? 'success' : 'warning'
            );
        });
    });

    // System Health Monitoring Simulation
    function updateSystemHealth() {
        const cpuUsage = document.querySelector('.resource:nth-child(1) .usage-fill');
        const memoryUsage = document.querySelector('.resource:nth-child(2) .usage-fill');
        const storageUsage = document.querySelector('.resource:nth-child(3) .usage-fill');
        
        if (cpuUsage && memoryUsage && storageUsage) {
            // Simulate random usage changes
            const newCpuUsage = Math.min(100, Math.max(30, parseInt(cpuUsage.style.width) + (Math.random() - 0.5) * 10));
            const newMemoryUsage = Math.min(100, Math.max(40, parseInt(memoryUsage.style.width) + (Math.random() - 0.5) * 8));
            const newStorageUsage = Math.min(100, Math.max(25, parseInt(storageUsage.style.width) + (Math.random() - 0.5) * 5));
            
            cpuUsage.style.width = `${newCpuUsage}%`;
            cpuUsage.nextElementSibling.textContent = `${Math.round(newCpuUsage)}%`;
            
            memoryUsage.style.width = `${newMemoryUsage}%`;
            memoryUsage.nextElementSibling.textContent = `${Math.round(newMemoryUsage)}%`;
            
            storageUsage.style.width = `${newStorageUsage}%`;
            storageUsage.nextElementSibling.textContent = `${Math.round(newStorageUsage)}%`;
        }
    }

    // Update system health every 30 seconds
    setInterval(updateSystemHealth, 30000);

    // Helper Functions
    function filterLogs(type, date, user) {
        const rows = logTable.querySelectorAll('tr');
        
        rows.forEach(row => {
            let showRow = true;
            
            // Filter by type
            if (type !== 'all') {
                const rowType = row.classList[0]?.replace('log-', '');
                if (rowType !== type) {
                    showRow = false;
                }
            }
            
            // Filter by date
            if (date) {
                const rowDate = row.cells[0].textContent.split(' ')[0];
                if (rowDate !== date) {
                    showRow = false;
                }
            }
            
            // Filter by user
            if (user !== 'all') {
                const rowUser = row.cells[2].textContent.toLowerCase();
                if (!rowUser.includes(user.toLowerCase())) {
                    showRow = false;
                }
            }
            
            row.style.display = showRow ? '' : 'none';
        });
    }

    function showTemplatePreview(templateName) {
        // Create modal for template preview
        const modal = document.createElement('div');
        modal.className = 'modal-overlay';
        modal.innerHTML = `
            <div class="modal-content">
                <div class="modal-header">
                    <h3>Preview: ${templateName}</h3>
                    <button class="modal-close">&times;</button>
                </div>
                <div class="modal-body">
                    <div class="template-preview">
                        <h4>Subject: ${getTemplateSubject(templateName)}</h4>
                        <div class="preview-content">
                            ${getTemplateContent(templateName)}
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button class="btn btn-primary">Gunakan Template</button>
                    <button class="btn btn-outline modal-close">Tutup</button>
                </div>
            </div>
        `;
        
        document.body.appendChild(modal);
        
        // Add event listeners for modal close
        const closeButtons = modal.querySelectorAll('.modal-close');
        closeButtons.forEach(button => {
            button.addEventListener('click', () => {
                document.body.removeChild(modal);
            });
        });
        
        // Close modal when clicking outside
        modal.addEventListener('click', (e) => {
            if (e.target === modal) {
                document.body.removeChild(modal);
            }
        });
    }

    function getTemplateSubject(templateName) {
        const subjects = {
            'Welcome Email': 'Selamat Datang di QPARKIN - Sistem Manajemen Parkir Mall',
            'Reset Password': 'Reset Password Akun QPARKIN Anda',
            'Laporan Bulanan': 'Laporan Performa Bulanan - QPARKIN',
            'Notifikasi Sistem': 'Notifikasi Sistem QPARKIN',
            'OTP Verification': 'Kode Verifikasi OTP QPARKIN',
            'Parking Reminder': 'Pengingat Waktu Parkir - QPARKIN'
        };
        
        return subjects[templateName] || 'Template Subject';
    }

    function getTemplateContent(templateName) {
        const contents = {
            'Welcome Email': `
                <p>Halo [Nama Admin],</p>
                <p>Selamat datang di QPARKIN! Akun admin Anda telah berhasil dibuat.</p>
                <p>Anda sekarang dapat mengakses dashboard manajemen parkir mall dengan detail login berikut:</p>
                <ul>
                    <li>Email: [Email]</li>
                    <li>Password: [Password Sementara]</li>
                </ul>
                <p>Silakan login dan ubah password Anda segera setelah login pertama.</p>
                <p>Salam,<br>Tim QPARKIN</p>
            `,
            'Reset Password': `
                <p>Halo [Nama Admin],</p>
                <p>Kami menerima permintaan reset password untuk akun QPARKIN Anda.</p>
                <p>Klik link berikut untuk reset password: [Reset Link]</p>
                <p>Link ini akan kadaluarsa dalam 1 jam.</p>
                <p>Jika Anda tidak meminta reset password, abaikan email ini.</p>
                <p>Salam,<br>Tim QPARKIN</p>
            `,
            'OTP Verification': `
                Kode OTP Anda: [OTP_CODE]
                Berlaku hingga: [EXPIRY_TIME]
                
                Jangan bagikan kode ini kepada siapapun.
            `
        };
        
        return contents[templateName] || '<p>Preview konten template akan ditampilkan di sini.</p>';
    }

    function showNotification(message, type = 'info') {
        // Remove existing notification
        const existingNotification = document.querySelector('.notification');
        if (existingNotification) {
            existingNotification.remove();
        }
        
        // Create notification element
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.innerHTML = `
            <div class="notification-content">
                <span class="notification-message">${message}</span>
                <button class="notification-close">&times;</button>
            </div>
        `;
        
        // Add styles
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: ${type === 'success' ? '#10b981' : type === 'error' ? '#ef4444' : '#6366f1'};
            color: white;
            padding: 12px 16px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            z-index: 1000;
        `;
        
        document.body.appendChild(notification);
        
        // Add close functionality
        const closeButton = notification.querySelector('.notification-close');
        closeButton.addEventListener('click', () => {
            notification.remove();
        });
        
        // Auto remove after 5 seconds
        setTimeout(() => {
            if (notification.parentNode) {
                notification.remove();
            }
        }, 5000);
    }

    // Initialize system health on load
    updateSystemHealth();
});
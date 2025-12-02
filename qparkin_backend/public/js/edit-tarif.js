// Edit Tarif JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Elements
    const tarifForm = document.getElementById('tarifForm');
    const saveBtn = document.getElementById('saveTarifBtn');
    const jenisKendaraan = document.getElementById('jenisKendaraan');
    const satuJamPertama = document.getElementById('satuJamPertama');
    const tarifPerJam = document.getElementById('tarifPerJam');
    
    // Preview elements
    const preview1Jam = document.getElementById('preview1Jam');
    const preview3Jam = document.getElementById('preview3Jam');
    const preview5Jam = document.getElementById('preview5Jam');
    const preview8Jam = document.getElementById('preview8Jam');
    
    // Current tarif elements
    const currentVehicleIcon = document.getElementById('currentVehicleIcon');
    const currentVehicleName = document.getElementById('currentVehicleName');
    const currentFirstHour = document.getElementById('currentFirstHour');
    const currentPerHour = document.getElementById('currentPerHour');
    const currentTotal3Hours = document.getElementById('currentTotal3Hours');
    const pageTitle = document.getElementById('pageTitle');
    const formTitle = document.getElementById('formTitle');
    const formSubtitle = document.getElementById('formSubtitle');
    
    // Get URL parameters
    const urlParams = new URLSearchParams(window.location.search);
    const type = urlParams.get('type');
    const isNew = type === 'baru';
    
    // Sample data (in real app, this would come from API)
    const tarifData = {
        'roda_dua': {
            name: 'Roda Dua',
            satuJamPertama: 5000,
            tarifPerJam: 3000,
            iconClass: 'roda-dua'
        },
        'roda_empat': {
            name: 'Roda Empat',
            satuJamPertama: 10000,
            tarifPerJam: 7000,
            iconClass: 'roda-empat'
        },
        'roda_enam': {
            name: 'Roda Enam',
            satuJamPertama: 15000,
            tarifPerJam: 10000,
            iconClass: 'roda-enam'
        },
        'roda_lebih': {
            name: 'Lebih dari Enam',
            satuJamPertama: 25000,
            tarifPerJam: 18000,
            iconClass: 'roda-lebih'
        }
    };
    
    // Format currency
    function formatCurrency(amount) {
        return new Intl.NumberFormat('id-ID', {
            style: 'currency',
            currency: 'IDR',
            minimumFractionDigits: 0
        }).format(amount);
    }
    
    // Calculate total cost
    function calculateTotalCost(jamPertama, perJam, hours) {
        if (hours <= 1) return jamPertama;
        return jamPertama + (hours - 1) * perJam;
    }
    
    // Update preview
    function updatePreview() {
        const jamPertama = parseInt(satuJamPertama.value) || 0;
        const perJam = parseInt(tarifPerJam.value) || 0;
        
        preview1Jam.textContent = formatCurrency(calculateTotalCost(jamPertama, perJam, 1));
        preview3Jam.textContent = formatCurrency(calculateTotalCost(jamPertama, perJam, 3));
        preview5Jam.textContent = formatCurrency(calculateTotalCost(jamPertama, perJam, 5));
        preview8Jam.textContent = formatCurrency(calculateTotalCost(jamPertama, perJam, 8));
        
        // Enable save button if form is valid
        saveBtn.disabled = !tarifForm.checkValidity() || jamPertama <= 0 || perJam <= 0;
    }
    
    // Load current tarif data
    function loadCurrentTarif() {
        if (isNew) {
            // New tarif mode
            pageTitle.textContent = 'Tambah Tarif Baru';
            formTitle.textContent = 'Tambah Tarif Parkir Baru';
            formSubtitle.textContent = 'Tambahkan tarif parkir untuk jenis kendaraan baru';
            currentVehicleName.textContent = 'Tarif Baru';
            currentFirstHour.textContent = formatCurrency(0);
            currentPerHour.textContent = formatCurrency(0);
            currentTotal3Hours.textContent = formatCurrency(0);
            
            // Reset vehicle icon
            currentVehicleIcon.className = 'vehicle-icon-large';
            currentVehicleIcon.innerHTML = `
                <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                </svg>
            `;
            
            // Enable jenis kendaraan selection
            jenisKendaraan.disabled = false;
        } else if (tarifData[type]) {
            // Edit existing tarif mode
            const data = tarifData[type];
            
            pageTitle.textContent = `Edit Tarif - ${data.name}`;
            formTitle.textContent = `Edit Tarif ${data.name}`;
            formSubtitle.textContent = `Perbarui tarif parkir untuk ${data.name}`;
            
            // Set current values
            currentVehicleName.textContent = data.name;
            currentFirstHour.textContent = formatCurrency(data.satuJamPertama);
            currentPerHour.textContent = formatCurrency(data.tarifPerJam);
            currentTotal3Hours.textContent = formatCurrency(calculateTotalCost(data.satuJamPertama, data.tarifPerJam, 3));
            
            // Set vehicle icon
            currentVehicleIcon.className = `vehicle-icon-large ${data.iconClass}`;
            currentVehicleIcon.innerHTML = getVehicleIcon(data.iconClass);
            
            // Set form values
            jenisKendaraan.value = type;
            satuJamPertama.value = data.satuJamPertama;
            tarifPerJam.value = data.tarifPerJam;
            
            // Disable jenis kendaraan selection in edit mode
            jenisKendaraan.disabled = true;
        } else {
            // Invalid type, redirect to tarif page
            window.location.href = 'tarif.html';
            return;
        }
        
        // Update preview
        updatePreview();
    }
    
    // Get vehicle icon based on type
    function getVehicleIcon(iconClass) {
        const icons = {
            'roda-dua': `
                <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                </svg>
            `,
            'roda-empat': `
                <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
                </svg>
            `,
            'roda-enam': `
                <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 10l-2 1m0 0l-2-1m2 1v2.5M20 7l-2 1m2-1l-2-1m2 1v2.5M14 4l-2-1-2 1M4 7l2-1M4 7l2 1M4 7v2.5M12 21l-2-1m2 1l2-1m-2 1v-2.5M6 18l-2-1v-2.5M18 18l2-1v-2.5" />
                </svg>
            `,
            'roda-lebih': `
                <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
                </svg>
            `
        };
        
        return icons[iconClass] || icons['roda-dua'];
    }
    
    // Save tarif dengan loading state
    function saveTarif() {
        if (!tarifForm.checkValidity()) {
            showNotification('Harap isi semua field yang diperlukan', 'error');
            return;
        }
        
        const jenis = jenisKendaraan.value;
        const jamPertama = parseInt(satuJamPertama.value);
        const perJam = parseInt(tarifPerJam.value);
        
        if (jamPertama <= 0 || perJam <= 0) {
            showNotification('Tarif harus lebih besar dari 0', 'error');
            return;
        }
        
        // Set loading state
        setSaveButtonLoading(true);
        
        // Simulate API call delay
        setTimeout(() => {
            // In real app, this would be an API call
            try {
                if (isNew) {
                    // Add new tarif
                    if (tarifData[jenis]) {
                        showNotification('Tarif untuk jenis kendaraan ini sudah ada', 'error');
                        setSaveButtonLoading(false);
                        return;
                    }
                    
                    // Show success message
                    showNotification('Tarif baru berhasil ditambahkan!', 'success');
                } else {
                    // Update existing tarif
                    showNotification('Tarif berhasil diperbarui!', 'success');
                }
                
                // Redirect back to tarif page after success
                setTimeout(() => {
                    window.location.href = 'tarif.html';
                }, 1500);
                
            } catch (error) {
                showNotification('Terjadi kesalahan saat menyimpan tarif', 'error');
                setSaveButtonLoading(false);
            }
        }, 1500); // Simulate API delay
    }

    // Set loading state for save button
    function setSaveButtonLoading(loading) {
        const saveBtn = document.getElementById('saveTarifBtn');
        if (loading) {
            saveBtn.classList.add('loading');
            saveBtn.disabled = true;
        } else {
            saveBtn.classList.remove('loading');
            saveBtn.disabled = false;
        }
    }

    // Show notification
    function showNotification(message, type) {
        // Remove existing notifications
        const existingNotifications = document.querySelectorAll('.notification');
        existingNotifications.forEach(notification => notification.remove());
        
        // Create notification element
        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        
        const icon = type === 'success' ? 
            `<svg class="notification-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>` :
            `<svg class="notification-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>`;
        
        notification.innerHTML = `
            ${icon}
            <div class="notification-content">${message}</div>
        `;
        
        document.body.appendChild(notification);
        
        // Auto remove after 3 seconds
        setTimeout(() => {
            if (notification.parentNode) {
                notification.remove();
            }
        }, 3000);
    }
    
    // Event listeners
    satuJamPertama.addEventListener('input', updatePreview);
    tarifPerJam.addEventListener('input', updatePreview);
    jenisKendaraan.addEventListener('change', updatePreview);
    
    saveBtn.addEventListener('click', saveTarif);
    
    // Initialize
    loadCurrentTarif();
    
    console.log('Edit tarif page loaded successfully');
});
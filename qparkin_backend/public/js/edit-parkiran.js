// Edit Parkiran JavaScript - Updated with Floor Status Support
document.addEventListener('DOMContentLoaded', function() {
    // Form elements
    const editForm = document.getElementById('editParkiranForm');
    const namaParkiran = document.getElementById('namaParkiran');
    const kodeParkiran = document.getElementById('kodeParkiran');
    const statusParkiran = document.getElementById('statusParkiran');
    const jumlahLantai = document.getElementById('jumlahLantai');
    const lantaiContainer = document.getElementById('lantaiContainer');
    const saveBtn = document.getElementById('saveParkiranBtn');
    
    // Preview elements
    const previewNama = document.getElementById('previewNama');
    const previewStatus = document.getElementById('previewStatus');
    const previewLantai = document.getElementById('previewLantai');
    const previewSlot = document.getElementById('previewSlot');
    const previewKode = document.getElementById('previewKode');
    const previewLantaiList = document.getElementById('previewLantaiList');
    
    // Delete modal elements
    const deleteBtn = document.getElementById('deleteBtn');
    const deleteModal = document.getElementById('deleteModal');
    const confirmDelete = document.getElementById('confirmDelete');
    const confirmDeleteBtn = document.getElementById('confirmDeleteBtn');
    const closeModal = document.querySelector('.close');
    const cancelModalBtn = document.querySelector('.close-modal');
    
    // Get parkiran data from blade (injected via @json)
    const parkiranData = window.parkiranData || {};
    const floorsData = window.floorsData || [];
    
    // Initialize
    function initialize() {
        generateLantaiFields();
        setupEventListeners();
        updatePreview();
    }
    
    // Setup event listeners
    function setupEventListeners() {
        // Form input events
        namaParkiran.addEventListener('input', updatePreview);
        kodeParkiran.addEventListener('input', updatePreview);
        statusParkiran.addEventListener('change', updatePreview);
        jumlahLantai.addEventListener('change', handleJumlahLantaiChange);
        
        // Save button
        saveBtn.addEventListener('click', saveParkiran);
        
        // Delete button
        if (deleteBtn) {
            deleteBtn.addEventListener('click', showDeleteModal);
        }
        
        // Delete modal events
        if (closeModal) closeModal.addEventListener('click', hideDeleteModal);
        if (cancelModalBtn) cancelModalBtn.addEventListener('click', hideDeleteModal);
        if (confirmDelete) confirmDelete.addEventListener('input', handleDeleteConfirmation);
        if (confirmDeleteBtn) confirmDeleteBtn.addEventListener('click', deleteParkiran);
        
        // Close modal when clicking outside
        window.addEventListener('click', function(event) {
            if (event.target === deleteModal) {
                hideDeleteModal();
            }
        });
    }
    
    // Generate lantai fields based on current data
    function generateLantaiFields() {
        const jumlahLantaiValue = parseInt(jumlahLantai.value) || floorsData.length || 1;
        lantaiContainer.innerHTML = '';
        
        for (let i = 0; i < jumlahLantaiValue; i++) {
            const floorData = floorsData[i] || {};
            const floorNumber = i + 1;
            const floorName = floorData.floor_name || `Lantai ${floorNumber}`;
            const totalSlots = floorData.total_slots || 20;
            const floorStatus = floorData.status || 'active';
            const jenisKendaraan = floorData.jenis_kendaraan || 'Roda Empat';
            
            const lantaiItem = document.createElement('div');
            lantaiItem.className = 'lantai-item';
            lantaiItem.innerHTML = `
                <div class="lantai-header">
                    <h5>Lantai ${floorNumber}</h5>
                </div>
                <div class="lantai-fields">
                    <div class="lantai-field">
                        <label for="namaLantai${floorNumber}">Nama Lantai *</label>
                        <input type="text" id="namaLantai${floorNumber}" name="lantai[${i}][nama]" 
                               value="${floorName}" required 
                               onchange="updatePreview()">
                        <span class="field-hint">Contoh: Lantai ${floorNumber}, Basement ${floorNumber}</span>
                    </div>
                    <div class="lantai-field">
                        <label for="slotLantai${floorNumber}">Jumlah Slot *</label>
                        <input type="number" id="slotLantai${floorNumber}" name="lantai[${i}][jumlah_slot]" 
                               min="1" max="200" value="${totalSlots}" required 
                               onchange="updatePreview()">
                        <span class="field-hint">Slot akan ter-generate otomatis dengan kode unik</span>
                    </div>
                    <div class="lantai-field">
                        <label for="jenisKendaraanLantai${floorNumber}">Jenis Kendaraan *</label>
                        <select id="jenisKendaraanLantai${floorNumber}" name="lantai[${i}][jenis_kendaraan]" 
                                required onchange="updatePreview()">
                            <option value="Roda Dua" ${jenisKendaraan === 'Roda Dua' ? 'selected' : ''}>Roda Dua (Motor)</option>
                            <option value="Roda Tiga" ${jenisKendaraan === 'Roda Tiga' ? 'selected' : ''}>Roda Tiga</option>
                            <option value="Roda Empat" ${jenisKendaraan === 'Roda Empat' ? 'selected' : ''}>Roda Empat (Mobil)</option>
                            <option value="Lebih dari Enam" ${jenisKendaraan === 'Lebih dari Enam' ? 'selected' : ''}>Lebih dari Enam (Truk/Bus)</option>
                        </select>
                        <span class="field-hint">Jenis kendaraan untuk lantai ini</span>
                    </div>
                    <div class="lantai-field">
                        <label for="statusLantai${floorNumber}">Status Lantai *</label>
                        <select id="statusLantai${floorNumber}" name="lantai[${i}][status]" 
                                onchange="updatePreview()">
                            <option value="active" ${floorStatus === 'active' ? 'selected' : ''}>Aktif (Normal)</option>
                            <option value="maintenance" ${floorStatus === 'maintenance' ? 'selected' : ''}>Maintenance (Tidak Bookable)</option>
                            <option value="inactive" ${floorStatus === 'inactive' ? 'selected' : ''}>Tidak Aktif</option>
                        </select>
                        <span class="field-hint">Jika maintenance, slot di lantai ini tidak bisa di-booking</span>
                    </div>
                </div>
                <div class="lantai-info">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    <span>Kode slot: <strong id="slotCodePreview${floorNumber}">-</strong></span>
                </div>
            `;
            lantaiContainer.appendChild(lantaiItem);
        }
        
        updatePreview();
    }
    
    // Handle jumlah lantai change
    function handleJumlahLantaiChange() {
        generateLantaiFields();
    }
    
    // Update preview
    function updatePreview() {
        // Update basic info
        previewNama.textContent = namaParkiran.value || parkiranData.nama_parkiran || 'Nama Parkiran';
        const kodeValue = kodeParkiran.value || parkiranData.kode_parkiran || '-';
        previewKode.textContent = kodeValue;
        
        // Update status
        const status = statusParkiran.value;
        previewStatus.textContent = getStatusText(status);
        previewStatus.className = `preview-status ${status}`;
        
        // Calculate totals
        const jumlahLantaiValue = parseInt(jumlahLantai.value) || 0;
        let totalSlot = 0;
        const lantaiDetails = [];
        
        for (let i = 1; i <= jumlahLantaiValue; i++) {
            const namaInput = document.getElementById(`namaLantai${i}`);
            const slotInput = document.getElementById(`slotLantai${i}`);
            const statusInput = document.getElementById(`statusLantai${i}`);
            const jenisKendaraanInput = document.getElementById(`jenisKendaraanLantai${i}`);
            
            if (namaInput && slotInput && statusInput && jenisKendaraanInput) {
                const slotCount = parseInt(slotInput.value) || 0;
                totalSlot += slotCount;
                
                lantaiDetails.push({
                    lantai: i,
                    nama: namaInput.value,
                    slot: slotCount,
                    status: statusInput.value,
                    jenisKendaraan: jenisKendaraanInput.value
                });
                
                // Update slot code preview
                const slotCodePreview = document.getElementById(`slotCodePreview${i}`);
                if (slotCodePreview && kodeValue !== '-') {
                    const firstSlot = `${kodeValue}-L${i}-001`;
                    const lastSlot = `${kodeValue}-L${i}-${String(slotCount).padStart(3, '0')}`;
                    slotCodePreview.textContent = slotCount > 0 ? `${firstSlot} s/d ${lastSlot}` : '-';
                }
            }
        }
        
        // Update preview numbers
        previewLantai.textContent = jumlahLantaiValue;
        previewSlot.textContent = totalSlot;
        
        // Update lantai list
        updateLantaiListPreview(lantaiDetails);
    }
    
    // Update lantai list preview
    function updateLantaiListPreview(lantaiDetails) {
        previewLantaiList.innerHTML = '';
        
        lantaiDetails.forEach(detail => {
            const statusBadge = getStatusBadge(detail.status);
            const lantaiItem = document.createElement('div');
            lantaiItem.className = 'preview-lantai-item';
            lantaiItem.innerHTML = `
                <span>${detail.nama} (${detail.jenisKendaraan})</span>
                <span>${detail.slot} slot ${statusBadge}</span>
            `;
            previewLantaiList.appendChild(lantaiItem);
        });
    }
    
    // Get status text
    function getStatusText(status) {
        const statusMap = {
            'Tersedia': 'Tersedia',
            'Ditutup': 'Ditutup'
        };
        return statusMap[status] || status;
    }
    
    // Get status badge for floor
    function getStatusBadge(status) {
        const badgeMap = {
            'active': '<span style="color: #10b981;">●</span>',
            'maintenance': '<span style="color: #f59e0b;">● Maintenance</span>',
            'inactive': '<span style="color: #ef4444;">● Inactive</span>'
        };
        return badgeMap[status] || '';
    }
    
    // Save parkiran
    async function saveParkiran() {
        if (!editForm.checkValidity()) {
            showNotification('Harap isi semua field yang diperlukan', 'error');
            return;
        }
        
        const nama = namaParkiran.value.trim();
        const kode = kodeParkiran.value.trim().toUpperCase();
        const status = statusParkiran.value;
        const jumlahLantaiValue = parseInt(jumlahLantai.value);
        
        if (!nama || !kode || !status) {
            showNotification('Harap isi semua field yang diperlukan', 'error');
            return;
        }
        
        if (kode.length < 2 || kode.length > 10) {
            showNotification('Kode parkiran harus 2-10 karakter', 'error');
            return;
        }
        
        // Collect lantai data
        const lantaiData = [];
        let totalSlot = 0;
        
        for (let i = 1; i <= jumlahLantaiValue; i++) {
            const namaInput = document.getElementById(`namaLantai${i}`);
            const slotInput = document.getElementById(`slotLantai${i}`);
            const statusInput = document.getElementById(`statusLantai${i}`);
            const jenisKendaraanInput = document.getElementById(`jenisKendaraanLantai${i}`);
            
            if (namaInput && slotInput && statusInput && jenisKendaraanInput) {
                const namaLantai = namaInput.value.trim();
                const slotCount = parseInt(slotInput.value) || 0;
                const statusLantai = statusInput.value;
                const jenisKendaraan = jenisKendaraanInput.value;
                
                if (!namaLantai) {
                    showNotification(`Nama lantai ${i} tidak boleh kosong`, 'error');
                    return;
                }
                
                if (slotCount < 1) {
                    showNotification(`Jumlah slot lantai ${i} harus minimal 1`, 'error');
                    return;
                }
                
                if (!jenisKendaraan) {
                    showNotification(`Jenis kendaraan lantai ${i} harus dipilih`, 'error');
                    return;
                }
                
                totalSlot += slotCount;
                
                lantaiData.push({
                    nama: namaLantai,
                    jumlah_slot: slotCount,
                    jenis_kendaraan: jenisKendaraan,
                    status: statusLantai
                });
            }
        }
        
        if (totalSlot === 0) {
            showNotification('Total slot parkir harus lebih dari 0', 'error');
            return;
        }
        
        // Prepare data for backend
        const formData = {
            nama_parkiran: nama,
            kode_parkiran: kode,
            status: status,
            jumlah_lantai: jumlahLantaiValue,
            lantai: lantaiData
        };
        
        console.log('Sending data to backend:', formData);
        
        // Set loading state
        setSaveButtonLoading(true);
        
        try {
            // Get CSRF token
            const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') 
                           || document.querySelector('input[name="_token"]')?.value;
            
            if (!csrfToken) {
                showNotification('CSRF token tidak ditemukan. Silakan refresh halaman.', 'error');
                setSaveButtonLoading(false);
                return;
            }
            
            // Get parkiran ID
            const parkiranId = document.getElementById('parkiranId')?.value || parkiranData.id_parkiran;
            
            if (!parkiranId) {
                showNotification('ID parkiran tidak ditemukan. Silakan refresh halaman.', 'error');
                setSaveButtonLoading(false);
                return;
            }
            
            // Send to backend
            const response = await fetch(`/admin/parkiran/${parkiranId}`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    'X-CSRF-TOKEN': csrfToken
                },
                body: JSON.stringify(formData)
            });
            
            const result = await response.json();
            
            if (result.success) {
                showNotification('Parkiran berhasil diperbarui!', 'success');
                
                // Redirect after success
                setTimeout(() => {
                    window.location.href = '/admin/parkiran';
                }, 1500);
            } else {
                showNotification(result.message || 'Gagal memperbarui parkiran', 'error');
                setSaveButtonLoading(false);
            }
            
        } catch (error) {
            console.error('Error saving parkiran:', error);
            showNotification('Terjadi kesalahan saat menyimpan parkiran: ' + error.message, 'error');
            setSaveButtonLoading(false);
        }
    }
    
    // Set loading state for save button
    function setSaveButtonLoading(loading) {
        if (loading) {
            saveBtn.classList.add('loading');
            saveBtn.disabled = true;
        } else {
            saveBtn.classList.remove('loading');
            saveBtn.disabled = false;
        }
    }
    
    // Show delete confirmation modal
    function showDeleteModal() {
        deleteModal.style.display = 'block';
        confirmDelete.value = '';
        confirmDeleteBtn.disabled = true;
    }
    
    // Hide delete confirmation modal
    function hideDeleteModal() {
        deleteModal.style.display = 'none';
        confirmDelete.value = '';
        confirmDeleteBtn.disabled = true;
    }
    
    // Handle delete confirmation input
    function handleDeleteConfirmation() {
        const input = confirmDelete.value.trim().toUpperCase();
        confirmDeleteBtn.disabled = input !== 'HAPUS';
    }
    
    // Delete parkiran
    async function deleteParkiran() {
        setSaveButtonLoading(true);
        confirmDeleteBtn.disabled = true;
        
        try {
            // Get CSRF token
            const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
            
            if (!csrfToken) {
                showNotification('CSRF token tidak ditemukan', 'error');
                setSaveButtonLoading(false);
                return;
            }
            
            // Get parkiran ID
            const parkiranId = document.getElementById('parkiranId')?.value || parkiranData.id_parkiran;
            
            if (!parkiranId) {
                showNotification('ID parkiran tidak ditemukan', 'error');
                setSaveButtonLoading(false);
                return;
            }
            
            // Send delete request
            const response = await fetch(`/admin/parkiran/${parkiranId}`, {
                method: 'DELETE',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    'X-CSRF-TOKEN': csrfToken
                }
            });
            
            const result = await response.json();
            
            if (result.success) {
                showNotification('Parkiran berhasil dihapus!', 'success');
                
                // Redirect after success
                setTimeout(() => {
                    window.location.href = '/admin/parkiran';
                }, 1500);
            } else {
                showNotification(result.message || 'Gagal menghapus parkiran', 'error');
                setSaveButtonLoading(false);
                confirmDeleteBtn.disabled = false;
            }
            
        } catch (error) {
            console.error('Error deleting parkiran:', error);
            showNotification('Terjadi kesalahan saat menghapus parkiran', 'error');
            setSaveButtonLoading(false);
            confirmDeleteBtn.disabled = false;
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
    
    // Make functions global for inline event handlers
    window.updatePreview = updatePreview;
    
    // Initialize
    initialize();
    
    console.log('Edit parkiran page loaded successfully with floor status support');
});

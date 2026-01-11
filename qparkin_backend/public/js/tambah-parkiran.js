// Tambah Parkiran JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Elements
    const tambahForm = document.getElementById('tambahParkiranForm');
    const saveBtn = document.getElementById('saveParkiranBtn');
    const lantaiContainer = document.getElementById('lantaiContainer');
    
    // Form elements
    const namaParkiran = document.getElementById('namaParkiran');
    const kodeParkiran = document.getElementById('kodeParkiran');
    const statusParkiran = document.getElementById('statusParkiran');
    const jenisKendaraan = document.getElementById('jenisKendaraan');
    const jumlahLantai = document.getElementById('jumlahLantai');
    
    // Preview elements
    const previewNama = document.getElementById('previewNama');
    const previewStatus = document.getElementById('previewStatus');
    const previewLantai = document.getElementById('previewLantai');
    const previewSlot = document.getElementById('previewSlot');
    const previewKode = document.getElementById('previewKode');
    const previewJenisKendaraan = document.getElementById('previewJenisKendaraan');
    const previewLantaiList = document.getElementById('previewLantaiList');
    
    // Initialize
    function initialize() {
        generateLantaiFields(3); // Default 3 lantai
        updatePreview();
        setupEventListeners();
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
    }
    
    // Handle jumlah lantai change
    function handleJumlahLantaiChange() {
        const jumlah = parseInt(jumlahLantai.value) || 1;
        generateLantaiFields(jumlah);
        updatePreview();
    }
    
    // Generate lantai fields
    function generateLantaiFields(jumlah) {
        lantaiContainer.innerHTML = '';
        
        for (let i = 1; i <= jumlah; i++) {
            const lantaiItem = document.createElement('div');
            lantaiItem.className = 'lantai-item';
            lantaiItem.innerHTML = `
                <div class="lantai-header">
                    <h5>Lantai ${i}</h5>
                </div>
                <div class="lantai-fields">
                    <div class="lantai-field">
                        <label for="namaLantai${i}">Nama Lantai</label>
                        <input type="text" id="namaLantai${i}" name="namaLantai${i}" 
                               value="Lantai ${i}" required 
                               onchange="updatePreview()">
                        <span class="field-hint">Contoh: Lantai ${i}, Basement ${i}</span>
                    </div>
                    <div class="lantai-field">
                        <label for="slotLantai${i}">Jumlah Slot *</label>
                        <input type="number" id="slotLantai${i}" name="slotLantai${i}" 
                               min="1" max="200" value="20" required 
                               onchange="updatePreview()">
                        <span class="field-hint">Slot akan ter-generate otomatis dengan kode unik</span>
                    </div>
                    <div class="lantai-field">
                        <label for="jenisKendaraanLantai${i}">Jenis Kendaraan *</label>
                        <select id="jenisKendaraanLantai${i}" name="jenisKendaraanLantai${i}" 
                                required onchange="updatePreview()">
                            <option value="Roda Dua">Roda Dua (Motor)</option>
                            <option value="Roda Tiga">Roda Tiga</option>
                            <option value="Roda Empat" selected>Roda Empat (Mobil)</option>
                            <option value="Lebih dari Enam">Lebih dari Enam (Truk/Bus)</option>
                        </select>
                        <span class="field-hint">Jenis kendaraan untuk lantai ini</span>
                    </div>
                </div>
                <div class="lantai-info">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    <span>Kode slot: <strong id="slotCodePreview${i}">-</strong></span>
                </div>
            `;
            lantaiContainer.appendChild(lantaiItem);
        }
    }
    
    // Update preview
    function updatePreview() {
        // Update basic info
        previewNama.textContent = namaParkiran.value || 'Nama Parkiran';
        const kodeValue = kodeParkiran.value || '-';
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
            const jenisKendaraanInput = document.getElementById(`jenisKendaraanLantai${i}`);
            
            if (namaInput && slotInput && jenisKendaraanInput) {
                const slotCount = parseInt(slotInput.value) || 0;
                totalSlot += slotCount;
                
                lantaiDetails.push({
                    lantai: i,
                    nama: namaInput.value,
                    slot: slotCount,
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
            const lantaiItem = document.createElement('div');
            lantaiItem.className = 'preview-lantai-item';
            lantaiItem.innerHTML = `
                <span>${detail.nama} (${detail.jenisKendaraan})</span>
                <span>${detail.slot} slot</span>
            `;
            previewLantaiList.appendChild(lantaiItem);
        });
    }
    
    // Get status text
    function getStatusText(status) {
        const statusMap = {
            'Tersedia': 'Aktif',
            'maintenance': 'Maintenance',
            'Ditutup': 'Tidak Aktif'
        };
        return statusMap[status] || 'Status';
    }
    
    // Save parkiran
    async function saveParkiran() {
        console.log('=== SAVE PARKIRAN DEBUG ===');
        
        if (!tambahForm.checkValidity()) {
            showNotification('Harap isi semua field yang diperlukan', 'error');
            return;
        }
        
        const nama = namaParkiran.value.trim();
        const kode = kodeParkiran.value.trim().toUpperCase();
        const status = statusParkiran.value;
        const jumlahLantaiValue = parseInt(jumlahLantai.value);
        
        console.log('Basic fields:', { nama, kode, status, jumlahLantaiValue });
        
        if (!nama || !kode || !status) {
            showNotification('Harap isi semua field yang diperlukan', 'error');
            return;
        }
        
        if (kode.length < 2 || kode.length > 10) {
            showNotification('Kode parkiran harus 2-10 karakter', 'error');
            return;
        }
        
        // Collect lantai data in format expected by backend
        const lantaiData = [];
        let totalSlot = 0;
        
        console.log('Collecting lantai data for', jumlahLantaiValue, 'floors');
        
        for (let i = 1; i <= jumlahLantaiValue; i++) {
            const namaInput = document.getElementById(`namaLantai${i}`);
            const slotInput = document.getElementById(`slotLantai${i}`);
            const jenisKendaraanInput = document.getElementById(`jenisKendaraanLantai${i}`);
            
            console.log(`Floor ${i}:`, {
                namaInput: namaInput ? namaInput.value : 'NOT FOUND',
                slotInput: slotInput ? slotInput.value : 'NOT FOUND',
                jenisKendaraanInput: jenisKendaraanInput ? jenisKendaraanInput.value : 'NOT FOUND'
            });
            
            if (namaInput && slotInput && jenisKendaraanInput) {
                const namaLantai = namaInput.value.trim();
                const slotCount = parseInt(slotInput.value) || 0;
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
                
                // Format sesuai backend: lantai.*.nama, lantai.*.jumlah_slot, lantai.*.jenis_kendaraan
                lantaiData.push({
                    nama: namaLantai,
                    jumlah_slot: slotCount,
                    jenis_kendaraan: jenisKendaraan
                });
            } else {
                console.error(`Floor ${i} inputs not found!`);
                showNotification(`Field lantai ${i} tidak ditemukan. Silakan refresh halaman.`, 'error');
                return;
            }
        }
        
        console.log('Collected lantai data:', lantaiData);
        console.log('Total slots:', totalSlot);
        
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
        
        console.log('Final payload to backend:', JSON.stringify(formData, null, 2));
        
        // Set loading state
        setSaveButtonLoading(true);
        
        try {
            // Get CSRF token
            const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') 
                           || document.querySelector('input[name="_token"]')?.value;
            
            console.log('CSRF Token:', csrfToken ? 'Found' : 'NOT FOUND');
            
            if (!csrfToken) {
                showNotification('CSRF token tidak ditemukan. Silakan refresh halaman.', 'error');
                setSaveButtonLoading(false);
                return;
            }
            
            // Send to backend
            console.log('Sending POST request to /admin/parkiran/store');
            const response = await fetch('/admin/parkiran/store', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    'X-CSRF-TOKEN': csrfToken
                },
                body: JSON.stringify(formData)
            });
            
            console.log('Response status:', response.status);
            console.log('Response headers:', response.headers);
            
            const result = await response.json();
            console.log('Response data:', result);
            
            if (result.success) {
                showNotification('Parkiran berhasil ditambahkan!', 'success');
                
                // Redirect after success
                setTimeout(() => {
                    window.location.href = '/admin/parkiran';
                }, 1500);
            } else {
                showNotification(result.message || 'Gagal menambahkan parkiran', 'error');
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
    
    console.log('Tambah parkiran page loaded successfully');
});

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
    const jumlahLantai = document.getElementById('jumlahLantai');
    
    // Preview elements
    const previewNama = document.getElementById('previewNama');
    const previewStatus = document.getElementById('previewStatus');
    const previewLantai = document.getElementById('previewLantai');
    const previewSlot = document.getElementById('previewSlot');
    const previewKode = document.getElementById('previewKode');
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
                        <label for="slotLantai${i}">Jumlah Slot</label>
                        <input type="number" id="slotLantai${i}" name="slotLantai${i}" 
                               min="1" max="100" value="20" required 
                               onchange="updatePreview()">
                    </div>
                    <div class="lantai-field">
                        <label for="penamaanLantai${i}">Penamaan Slot</label>
                        <select id="penamaanLantai${i}" name="penamaanLantai${i}" 
                                onchange="updatePreview()">
                            <option value="huruf">Huruf (A, B, C)</option>
                            <option value="angka">Angka (1, 2, 3)</option>
                            <option value="gabungan" selected>Gabungan (A1, A2)</option>
                        </select>
                    </div>
                </div>
            `;
            lantaiContainer.appendChild(lantaiItem);
        }
    }
    
    // Update preview
    function updatePreview() {
        // Update basic info
        previewNama.textContent = namaParkiran.value || 'Nama Parkiran';
        previewKode.textContent = kodeParkiran.value || '-';
        
        // Update status
        const status = statusParkiran.value;
        previewStatus.textContent = getStatusText(status);
        previewStatus.className = `preview-status ${status}`;
        
        // Calculate totals
        const jumlahLantaiValue = parseInt(jumlahLantai.value) || 0;
        let totalSlot = 0;
        const lantaiDetails = [];
        
        for (let i = 1; i <= jumlahLantaiValue; i++) {
            const slotInput = document.getElementById(`slotLantai${i}`);
            const penamaanSelect = document.getElementById(`penamaanLantai${i}`);
            
            if (slotInput && penamaanSelect) {
                const slotCount = parseInt(slotInput.value) || 0;
                totalSlot += slotCount;
                
                lantaiDetails.push({
                    lantai: i,
                    slot: slotCount,
                    penamaan: penamaanSelect.value
                });
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
                <span>Lantai ${detail.lantai}</span>
                <span>${detail.slot} slot</span>
            `;
            previewLantaiList.appendChild(lantaiItem);
        });
    }
    
    // Get status text
    function getStatusText(status) {
        const statusMap = {
            'active': 'Aktif',
            'maintenance': 'Maintenance',
            'inactive': 'Tidak Aktif'
        };
        return statusMap[status] || 'Status';
    }
    
    // Save parkiran
    function saveParkiran() {
        if (!tambahForm.checkValidity()) {
            showNotification('Harap isi semua field yang diperlukan', 'error');
            return;
        }
        
        const nama = namaParkiran.value.trim();
        const kode = kodeParkiran.value.trim();
        const status = statusParkiran.value;
        const jumlahLantaiValue = parseInt(jumlahLantai.value);
        
        if (!nama || !kode || !status) {
            showNotification('Harap isi semua field yang diperlukan', 'error');
            return;
        }
        
        if (kode.length < 2 || kode.length > 5) {
            showNotification('Kode parkiran harus 2-5 karakter', 'error');
            return;
        }
        
        // Collect lantai data
        const lantaiData = [];
        let totalSlot = 0;
        
        for (let i = 1; i <= jumlahLantaiValue; i++) {
            const slotInput = document.getElementById(`slotLantai${i}`);
            const penamaanSelect = document.getElementById(`penamaanLantai${i}`);
            
            if (slotInput && penamaanSelect) {
                const slotCount = parseInt(slotInput.value) || 0;
                totalSlot += slotCount;
                
                lantaiData.push({
                    lantai: i,
                    totalSlot: slotCount,
                    penamaan: penamaanSelect.value,
                    tersedia: slotCount // Initially all available
                });
            }
        }
        
        if (totalSlot === 0) {
            showNotification('Total slot parkir harus lebih dari 0', 'error');
            return;
        }
        
        // Set loading state
        setSaveButtonLoading(true);
        
        // Simulate API call
        setTimeout(() => {
            try {
                // Create parkiran data
                const parkiranData = {
                    id: 'parkiran_' + kode.toLowerCase(),
                    name: nama,
                    kode: kode,
                    status: status,
                    totalLantai: jumlahLantaiValue,
                    totalSlot: totalSlot,
                    tersedia: totalSlot,
                    terisi: 0,
                    lantaiDetail: lantaiData,
                    createdAt: new Date().toISOString()
                };
                
                // In real app, this would be API call to save data
                console.log('Saving parkiran data:', parkiranData);
                
                // Show success message
                showNotification('Parkiran baru berhasil ditambahkan!', 'success');
                
                // Redirect to parkiran page after success
                setTimeout(() => {
                    window.location.href = 'parkiran.html';
                }, 1500);
                
            } catch (error) {
                showNotification('Terjadi kesalahan saat menyimpan parkiran', 'error');
                setSaveButtonLoading(false);
            }
        }, 2000);
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
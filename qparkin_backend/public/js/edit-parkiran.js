// Edit Parkiran JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Elements
    const loadingOverlay = document.getElementById('loadingOverlay');
    const progressFill = document.getElementById('progressFill');
    const progressText = document.getElementById('progressText');
    const parkiranContainer = document.querySelector('.parkiran-edit-container');
    
    const pageTitle = document.getElementById('pageTitle');
    const formTitle = document.getElementById('formTitle');
    const formSubtitle = document.getElementById('formSubtitle');
    
    // Current info elements
    const currentParkiranName = document.getElementById('currentParkiranName');
    const currentKode = document.getElementById('currentKode');
    const currentStatus = document.getElementById('currentStatus');
    const currentLantai = document.getElementById('currentLantai');
    const currentTotalSlot = document.getElementById('currentTotalSlot');
    const lastUpdated = document.getElementById('lastUpdated');
    
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
    const deleteParkiranName = document.getElementById('deleteParkiranName');
    const confirmDelete = document.getElementById('confirmDelete');
    const confirmDeleteBtn = document.getElementById('confirmDeleteBtn');
    const closeModal = document.querySelector('.close');
    const cancelModalBtn = document.querySelector('.modal .btn-cancel');
    
    // Get URL parameters
    const urlParams = new URLSearchParams(window.location.search);
    const parkiranId = urlParams.get('id');
    
    // Current parkiran data
    let currentParkiranData = null;
    
    // Initialize
    async function initialize() {
        if (!parkiranId) {
            window.location.href = 'parkiran.html';
            return;
        }
        
        await showLoadingOverlay();
        await loadParkiranData();
        await setupEventListeners();
        await generateLantaiFields();
        await updatePreview();
        await hideLoadingOverlay();
    }
    
    // Show loading overlay
    async function showLoadingOverlay() {
        parkiranContainer.classList.add('loading-blur');
        loadingOverlay.classList.remove('hidden');
        
        const steps = [
            { progress: 25, text: 'Memuat data parkiran...' },
            { progress: 50, text: 'Mengambil konfigurasi lantai...' },
            { progress: 75, text: 'Menyiapkan form edit...' },
            { progress: 100, text: 'Siap!' }
        ];
        
        for (const step of steps) {
            await updateProgress(step.progress, step.text);
            await delay(400 + Math.random() * 400);
        }
    }
    
    // Update progress bar
    async function updateProgress(percent, text) {
        return new Promise(resolve => {
            progressFill.style.width = `${percent}%`;
            progressText.textContent = `${percent}%`;
            
            if (text) {
                const loadingText = document.querySelector('.loading-content p');
                if (loadingText) {
                    loadingText.textContent = text;
                }
            }
            
            setTimeout(resolve, 100);
        });
    }
    
    // Hide loading overlay
    async function hideLoadingOverlay() {
        await updateProgress(100, 'Data siap diedit!');
        await delay(600);
        
        parkiranContainer.classList.remove('loading-blur');
        loadingOverlay.classList.add('hidden');
        
        setTimeout(() => {
            if (loadingOverlay.parentNode) {
                loadingOverlay.style.display = 'none';
            }
        }, 500);
    }
    
    // Utility delay function
    function delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
    
    // Sample data (in real app, this would come from API)
    const parkiranData = {
        'parkiran_mawar': {
            name: 'Parkiran Mawar',
            kode: 'MWR',
            status: 'active',
            createdAt: '2025-03-15',
            updatedAt: '2025-03-20',
            totalLantai: 5,
            totalSlot: 250,
            lantaiDetail: [
                { lantai: 1, totalSlot: 50, penamaan: 'gabungan' },
                { lantai: 2, totalSlot: 50, penamaan: 'gabungan' },
                { lantai: 3, totalSlot: 50, penamaan: 'gabungan' },
                { lantai: 4, totalSlot: 50, penamaan: 'gabungan' },
                { lantai: 5, totalSlot: 50, penamaan: 'gabungan' }
            ]
        },
        'parkiran_melati': {
            name: 'Parkiran Melati',
            kode: 'MLT',
            status: 'active',
            createdAt: '2025-02-20',
            updatedAt: '2025-03-18',
            totalLantai: 3,
            totalSlot: 150,
            lantaiDetail: [
                { lantai: 1, totalSlot: 50, penamaan: 'gabungan' },
                { lantai: 2, totalSlot: 50, penamaan: 'gabungan' },
                { lantai: 3, totalSlot: 50, penamaan: 'gabungan' }
            ]
        },
        'parkiran_anggrek': {
            name: 'Parkiran Anggrek',
            kode: 'AGR',
            status: 'maintenance',
            createdAt: '2025-01-10',
            updatedAt: '2025-03-15',
            totalLantai: 4,
            totalSlot: 200,
            lantaiDetail: [
                { lantai: 1, totalSlot: 50, penamaan: 'gabungan' },
                { lantai: 2, totalSlot: 50, penamaan: 'gabungan' },
                { lantai: 3, totalSlot: 50, penamaan: 'gabungan' },
                { lantai: 4, totalSlot: 50, penamaan: 'gabungan' }
            ]
        }
    };
    
    // Load parkiran data
    async function loadParkiranData() {
        await delay(800);
        
        if (!parkiranData[parkiranId]) {
            showError('Parkiran tidak ditemukan');
            return;
        }
        
        currentParkiranData = parkiranData[parkiranId];
        
        // Update page titles
        pageTitle.textContent = `Edit ${currentParkiranData.name}`;
        formTitle.textContent = `Edit ${currentParkiranData.name}`;
        formSubtitle.textContent = 'Perbarui informasi dan konfigurasi parkiran';
        
        // Update current info
        currentParkiranName.textContent = currentParkiranData.name;
        currentKode.textContent = currentParkiranData.kode;
        currentStatus.textContent = getStatusText(currentParkiranData.status);
        currentLantai.textContent = currentParkiranData.totalLantai;
        currentTotalSlot.textContent = currentParkiranData.totalSlot;
        lastUpdated.textContent = formatDate(currentParkiranData.updatedAt);
        
        // Update form values
        namaParkiran.value = currentParkiranData.name;
        kodeParkiran.value = currentParkiranData.kode;
        statusParkiran.value = currentParkiranData.status;
        jumlahLantai.value = currentParkiranData.totalLantai;
        
        // Update delete modal
        deleteParkiranName.textContent = currentParkiranData.name;
    }
    
    // Show error message
    function showError(message) {
        const errorHTML = `
            <div class="error-container">
                <div class="error-icon">
                    <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                </div>
                <h3>Terjadi Kesalahan</h3>
                <p>${message}</p>
                <button onclick="window.location.href='parkiran.html'" class="btn-back">
                    Kembali ke Parkiran
                </button>
            </div>
        `;
        
        document.querySelector('.admin-content').innerHTML = errorHTML;
        hideLoadingOverlay();
    }
    
    // Setup event listeners
    async function setupEventListeners() {
        await delay(300);
        
        // Form input events
        namaParkiran.addEventListener('input', updatePreview);
        kodeParkiran.addEventListener('input', updatePreview);
        statusParkiran.addEventListener('change', updatePreview);
        jumlahLantai.addEventListener('change', handleJumlahLantaiChange);
        
        // Save button
        saveBtn.addEventListener('click', saveParkiran);
        
        // Delete button
        deleteBtn.addEventListener('click', showDeleteModal);
        
        // Delete modal events
        closeModal.addEventListener('click', hideDeleteModal);
        cancelModalBtn.addEventListener('click', hideDeleteModal);
        confirmDelete.addEventListener('input', handleDeleteConfirmation);
        confirmDeleteBtn.addEventListener('click', deleteParkiran);
        
        // Close modal when clicking outside
        window.addEventListener('click', function(event) {
            if (event.target === deleteModal) {
                hideDeleteModal();
            }
        });
    }
    
    // Generate lantai fields based on current data
    async function generateLantaiFields() {
        await delay(400);
        
        if (!currentParkiranData) return;
        
        lantaiContainer.innerHTML = '';
        
        currentParkiranData.lantaiDetail.forEach(lantai => {
            const lantaiItem = document.createElement('div');
            lantaiItem.className = 'lantai-item';
            lantaiItem.innerHTML = `
                <div class="lantai-header">
                    <h5>Lantai ${lantai.lantai}</h5>
                </div>
                <div class="lantai-fields">
                    <div class="lantai-field">
                        <label for="slotLantai${lantai.lantai}">Jumlah Slot</label>
                        <input type="number" id="slotLantai${lantai.lantai}" name="slotLantai${lantai.lantai}" 
                               min="1" max="100" value="${lantai.totalSlot}" required 
                               onchange="updatePreview()">
                    </div>
                    <div class="lantai-field">
                        <label for="penamaanLantai${lantai.lantai}">Penamaan Slot</label>
                        <select id="penamaanLantai${lantai.lantai}" name="penamaanLantai${lantai.lantai}" 
                                onchange="updatePreview()">
                            <option value="huruf" ${lantai.penamaan === 'huruf' ? 'selected' : ''}>Huruf (A, B, C)</option>
                            <option value="angka" ${lantai.penamaan === 'angka' ? 'selected' : ''}>Angka (1, 2, 3)</option>
                            <option value="gabungan" ${lantai.penamaan === 'gabungan' ? 'selected' : ''}>Gabungan (A1, A2)</option>
                        </select>
                    </div>
                </div>
            `;
            lantaiContainer.appendChild(lantaiItem);
        });
    }
    
    // Handle jumlah lantai change
    function handleJumlahLantaiChange() {
        const jumlah = parseInt(jumlahLantai.value) || 1;
        generateLantaiFieldsFromScratch(jumlah);
        updatePreview();
    }
    
    // Generate lantai fields from scratch
    function generateLantaiFieldsFromScratch(jumlah) {
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
        previewNama.textContent = namaParkiran.value || currentParkiranData.name;
        previewKode.textContent = kodeParkiran.value || currentParkiranData.kode;
        
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
        
        // Enable/disable save button based on form validity
        saveBtn.disabled = !editForm.checkValidity() || totalSlot === 0;
    }
    
    // Update lantai list preview
    function updateLantaiListPreview(lantaiDetails) {
        previewLantaiList.innerHTML = '';
        
        const lantaiItems = document.createElement('div');
        lantaiItems.className = 'preview-lantai-items';
        
        lantaiDetails.forEach(detail => {
            const lantaiItem = document.createElement('div');
            lantaiItem.className = 'preview-lantai-item';
            lantaiItem.innerHTML = `
                <span>Lantai ${detail.lantai}</span>
                <span>${detail.slot} slot (${getPenamaanText(detail.penamaan)})</span>
            `;
            lantaiItems.appendChild(lantaiItem);
        });
        
        previewLantaiList.appendChild(lantaiItems);
    }
    
    // Get status text
    function getStatusText(status) {
        const statusMap = {
            'active': 'Aktif',
            'maintenance': 'Maintenance',
            'inactive': 'Tidak Aktif'
        };
        return statusMap[status] || status;
    }
    
    // Get penamaan text
    function getPenamaanText(penamaan) {
        const penamaanMap = {
            'huruf': 'Huruf',
            'angka': 'Angka',
            'gabungan': 'Gabungan'
        };
        return penamaanMap[penamaan] || penamaan;
    }
    
    // Format date
    function formatDate(dateString) {
        const options = { day: 'numeric', month: 'short', year: 'numeric' };
        return new Date(dateString).toLocaleDateString('id-ID', options);
    }
    
    // Save parkiran
    async function saveParkiran() {
        if (!editForm.checkValidity()) {
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
                    penamaan: penamaanSelect.value
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
                // Update parkiran data
                const updatedData = {
                    ...currentParkiranData,
                    name: nama,
                    kode: kode,
                    status: status,
                    totalLantai: jumlahLantaiValue,
                    totalSlot: totalSlot,
                    lantaiDetail: lantaiData,
                    updatedAt: new Date().toISOString()
                };
                
                // In real app, this would be API call to update data
                console.log('Updating parkiran data:', updatedData);
                
                // Show success message
                showNotification('Parkiran berhasil diperbarui!', 'success');
                
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
        
        // Simulate API call
        setTimeout(() => {
            try {
                // In real app, this would be API call to delete data
                console.log('Deleting parkiran:', parkiranId);
                
                // Show success message
                showNotification('Parkiran berhasil dihapus!', 'success');
                
                // Redirect to parkiran page after success
                setTimeout(() => {
                    window.location.href = 'parkiran.html';
                }, 1500);
                
            } catch (error) {
                showNotification('Terjadi kesalahan saat menghapus parkiran', 'error');
                setSaveButtonLoading(false);
                confirmDeleteBtn.disabled = false;
            }
        }, 2000);
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
    
    // Add error styles to CSS
    const errorStyles = `
        .error-container {
            text-align: center;
            padding: 60px 20px;
            background: white;
            border-radius: 12px;
            border: 1px solid #e2e8f0;
            margin: 20px;
        }
        
        .error-icon {
            color: #ef4444;
            margin-bottom: 20px;
        }
        
        .error-icon svg {
            width: 48px;
            height: 48px;
        }
        
        .error-container h3 {
            font-size: 1.5rem;
            font-weight: 700;
            color: #dc2626;
            margin-bottom: 8px;
        }
        
        .error-container p {
            color: #64748b;
            margin-bottom: 24px;
        }
        
        .error-container .btn-back {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            background: #6366f1;
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            font-size: 0.875rem;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.3s ease;
        }
        
        .error-container .btn-back:hover {
            background: #4f46e5;
            transform: translateY(-2px);
        }
    `;
    
    // Inject error styles
    const styleSheet = document.createElement('style');
    styleSheet.textContent = errorStyles;
    document.head.appendChild(styleSheet);
    
    // Make functions global for inline event handlers
    window.updatePreview = updatePreview;
    
    // Initialize
    initialize();
    
    console.log('Edit parkiran page loaded successfully');
});
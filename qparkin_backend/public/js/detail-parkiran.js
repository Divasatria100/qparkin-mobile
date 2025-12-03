// Detail Parkiran JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Elements
    const loadingOverlay = document.getElementById('loadingOverlay');
    const progressFill = document.getElementById('progressFill');
    const progressText = document.getElementById('progressText');
    const parkiranContainer = document.querySelector('.parkiran-detail-container');
    
    const pageTitle = document.getElementById('pageTitle');
    const detailNama = document.getElementById('detailNama');
    const detailStatus = document.getElementById('detailStatus');
    const detailKode = document.getElementById('detailKode');
    const detailCreatedAt = document.getElementById('detailCreatedAt');
    const editBtn = document.getElementById('editBtn');
    
    // Stats elements
    const statLantai = document.getElementById('statLantai');
    const statTotalSlot = document.getElementById('statTotalSlot');
    const statTersedia = document.getElementById('statTersedia');
    const statTerisi = document.getElementById('statTerisi');
    const chartFill = document.getElementById('chartFill');
    const utilizationPercent = document.getElementById('utilizationPercent');
    
    // Container elements
    const lantaiContainer = document.getElementById('lantaiContainer');
    const filterLantai = document.getElementById('filterLantai');
    const filterStatus = document.getElementById('filterStatus');
    const slotGrid = document.getElementById('slotGrid');
    
    // Get URL parameters
    const urlParams = new URLSearchParams(window.location.search);
    const parkiranId = urlParams.get('id');
    
    // Initialize
    async function initialize() {
        if (!parkiranId) {
            window.location.href = 'parkiran.html';
            return;
        }
        
        await showLoadingOverlay();
        await loadParkiranData();
        await setupEventListeners();
        await renderLantaiCards();
        await setupFilters();
        await renderAllSlots();
        await hideLoadingOverlay();
    }
    
    // Show loading overlay
    async function showLoadingOverlay() {
        // Add blur effect to content
        parkiranContainer.classList.add('loading-blur');
        
        // Show overlay
        loadingOverlay.classList.remove('hidden');
        
        // Simulate progress steps
        const steps = [
            { progress: 20, text: 'Memuat data parkiran...' },
            { progress: 40, text: 'Mengambil informasi lantai...' },
            { progress: 60, text: 'Memproses data slot...' },
            { progress: 80, text: 'Menyiapkan tampilan...' },
            { progress: 100, text: 'Selesai!' }
        ];
        
        for (const step of steps) {
            await updateProgress(step.progress, step.text);
            await delay(400 + Math.random() * 400); // Random delay between 400-800ms
        }
    }
    
    // Update progress bar
    async function updateProgress(percent, text) {
        return new Promise(resolve => {
            progressFill.style.width = `${percent}%`;
            progressText.textContent = `${percent}%`;
            
            // Update loading text if provided
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
        // Final progress update
        await updateProgress(100, 'Data parkiran siap!');
        await delay(600);
        
        // Remove blur effect first
        parkiranContainer.classList.remove('loading-blur');
        
        // Hide overlay
        loadingOverlay.classList.add('hidden');
        
        // Remove overlay from DOM after animation
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
            totalLantai: 5,
            totalSlot: 250,
            tersedia: 45,
            terisi: 205,
            lantaiDetail: [
                {
                    lantai: 1,
                    totalSlot: 50,
                    tersedia: 10,
                    terisi: 40,
                    penamaan: 'gabungan',
                    slots: generateSlots(1, 50, 'gabungan', 40)
                },
                {
                    lantai: 2,
                    totalSlot: 50,
                    tersedia: 8,
                    terisi: 42,
                    penamaan: 'gabungan',
                    slots: generateSlots(2, 50, 'gabungan', 42)
                },
                {
                    lantai: 3,
                    totalSlot: 50,
                    tersedia: 12,
                    terisi: 38,
                    penamaan: 'gabungan',
                    slots: generateSlots(3, 50, 'gabungan', 38)
                },
                {
                    lantai: 4,
                    totalSlot: 50,
                    tersedia: 9,
                    terisi: 41,
                    penamaan: 'gabungan',
                    slots: generateSlots(4, 50, 'gabungan', 41)
                },
                {
                    lantai: 5,
                    totalSlot: 50,
                    tersedia: 6,
                    terisi: 44,
                    penamaan: 'gabungan',
                    slots: generateSlots(5, 50, 'gabungan', 44)
                }
            ]
        },
        'parkiran_melati': {
            name: 'Parkiran Melati',
            kode: 'MLT',
            status: 'active',
            createdAt: '2025-02-20',
            totalLantai: 3,
            totalSlot: 150,
            tersedia: 25,
            terisi: 125,
            lantaiDetail: [
                {
                    lantai: 1,
                    totalSlot: 50,
                    tersedia: 5,
                    terisi: 45,
                    penamaan: 'gabungan',
                    slots: generateSlots(1, 50, 'gabungan', 45)
                },
                {
                    lantai: 2,
                    totalSlot: 50,
                    tersedia: 10,
                    terisi: 40,
                    penamaan: 'gabungan',
                    slots: generateSlots(2, 50, 'gabungan', 40)
                },
                {
                    lantai: 3,
                    totalSlot: 50,
                    tersedia: 10,
                    terisi: 40,
                    penamaan: 'gabungan',
                    slots: generateSlots(3, 50, 'gabungan', 40)
                }
            ]
        },
        'parkiran_anggrek': {
            name: 'Parkiran Anggrek',
            kode: 'AGR',
            status: 'maintenance',
            createdAt: '2025-01-10',
            totalLantai: 4,
            totalSlot: 200,
            tersedia: 0,
            terisi: 0,
            lantaiDetail: [
                {
                    lantai: 1,
                    totalSlot: 50,
                    tersedia: 0,
                    terisi: 0,
                    penamaan: 'gabungan',
                    slots: generateSlots(1, 50, 'gabungan', 0)
                },
                {
                    lantai: 2,
                    totalSlot: 50,
                    tersedia: 0,
                    terisi: 0,
                    penamaan: 'gabungan',
                    slots: generateSlots(2, 50, 'gabungan', 0)
                },
                {
                    lantai: 3,
                    totalSlot: 50,
                    tersedia: 0,
                    terisi: 0,
                    penamaan: 'gabungan',
                    slots: generateSlots(3, 50, 'gabungan', 0)
                },
                {
                    lantai: 4,
                    totalSlot: 50,
                    tersedia: 0,
                    terisi: 0,
                    penamaan: 'gabungan',
                    slots: generateSlots(4, 50, 'gabungan', 0)
                }
            ]
        }
    };
    
    // Load parkiran data
    async function loadParkiranData() {
        await delay(800); // Simulate API delay
        
        if (!parkiranData[parkiranId]) {
            showError('Parkiran tidak ditemukan');
            return;
        }
        
        const data = parkiranData[parkiranId];
        
        // Update page title and headers
        pageTitle.textContent = `Detail ${data.name}`;
        detailNama.textContent = data.name;
        detailKode.textContent = data.kode;
        detailCreatedAt.textContent = formatDate(data.createdAt);
        
        // Update status
        updateStatus(data.status);
        
        // Update stats
        statLantai.textContent = data.totalLantai;
        statTotalSlot.textContent = data.totalSlot;
        statTersedia.textContent = data.tersedia;
        statTerisi.textContent = data.terisi;
        
        // Update utilization chart
        const utilization = Math.round((data.terisi / data.totalSlot) * 100);
        chartFill.style.width = `${utilization}%`;
        utilizationPercent.textContent = `${utilization}%`;
        
        // Update edit button link
        editBtn.href = `edit-parkiran.html?id=${parkiranId}`;
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
    
    // Update status display
    function updateStatus(status) {
        const statusMap = {
            'active': { text: 'Aktif', class: 'active' },
            'maintenance': { text: 'Maintenance', class: 'maintenance' },
            'inactive': { text: 'Tidak Aktif', class: 'inactive' }
        };
        
        const statusInfo = statusMap[status] || statusMap['active'];
        detailStatus.textContent = statusInfo.text;
        detailStatus.className = `status-badge ${statusInfo.class}`;
    }
    
    // Format date
    function formatDate(dateString) {
        const options = { day: 'numeric', month: 'short', year: 'numeric' };
        return new Date(dateString).toLocaleDateString('id-ID', options);
    }
    
    // Setup event listeners
    async function setupEventListeners() {
        await delay(300);
        
        // View controls
        const viewBtns = document.querySelectorAll('.view-btn');
        viewBtns.forEach(btn => {
            btn.addEventListener('click', function() {
                viewBtns.forEach(b => b.classList.remove('active'));
                this.classList.add('active');
                toggleView(this.dataset.view);
            });
        });
        
        // Filter events
        filterLantai.addEventListener('change', filterSlots);
        filterStatus.addEventListener('change', filterSlots);
    }
    
    // Toggle view between grid and list
    function toggleView(view) {
        lantaiContainer.className = `lantai-container ${view}-view`;
    }
    
    // Setup filters
    async function setupFilters() {
        await delay(400);
        
        const data = parkiranData[parkiranId];
        
        // Populate lantai filter
        filterLantai.innerHTML = '<option value="all">Semua Lantai</option>';
        data.lantaiDetail.forEach(lantai => {
            const option = document.createElement('option');
            option.value = lantai.lantai;
            option.textContent = `Lantai ${lantai.lantai}`;
            filterLantai.appendChild(option);
        });
    }
    
    // Render lantai cards
    async function renderLantaiCards() {
        await delay(600);
        
        const data = parkiranData[parkiranId];
        
        lantaiContainer.innerHTML = '';
        data.lantaiDetail.forEach(lantai => {
            const lantaiCard = document.createElement('div');
            lantaiCard.className = 'lantai-card';
            lantaiCard.innerHTML = `
                <div class="lantai-header">
                    <div class="lantai-title">Lantai ${lantai.lantai}</div>
                    <div class="lantai-stats">
                        <div class="lantai-stat">
                            <span class="value">${lantai.totalSlot}</span>
                            <span class="label">Total</span>
                        </div>
                        <div class="lantai-stat">
                            <span class="value" style="color: #059669">${lantai.tersedia}</span>
                            <span class="label">Tersedia</span>
                        </div>
                        <div class="lantai-stat">
                            <span class="value" style="color: #dc2626">${lantai.terisi}</span>
                            <span class="label">Terisi</span>
                        </div>
                    </div>
                </div>
                <div class="lantai-slots" id="slotsLantai${lantai.lantai}">
                    ${renderSlotPreview(lantai.slots)}
                </div>
            `;
            lantaiContainer.appendChild(lantaiCard);
        });
    }
    
    // Render slot preview for lantai cards
    function renderSlotPreview(slots) {
        // Show only first 20 slots for preview
        const previewSlots = slots.slice(0, 20);
        return previewSlots.map(slot => `
            <div class="slot-item ${slot.status}" title="${slot.kode} - ${getStatusText(slot.status)}">
                ${slot.kode.replace(/[^A-Z0-9]/g, '').substring(0, 2)}
            </div>
        `).join('');
    }
    
    // Render all slots for detail view
    async function renderAllSlots() {
        await delay(800);
        
        const data = parkiranData[parkiranId];
        let allSlots = [];
        
        data.lantaiDetail.forEach(lantai => {
            allSlots = allSlots.concat(lantai.slots);
        });
        
        renderSlots(allSlots);
    }
    
    // Render slots to grid
    function renderSlots(slots) {
        slotGrid.innerHTML = '';
        
        slots.forEach(slot => {
            const slotItem = document.createElement('div');
            slotItem.className = `slot-detail-item ${slot.status}`;
            slotItem.innerHTML = `
                <div class="slot-code">${slot.kode}</div>
                <div class="slot-lantai">Lantai ${slot.lantai}</div>
                <div class="slot-status ${slot.status}">${getStatusText(slot.status)}</div>
            `;
            slotGrid.appendChild(slotItem);
        });
    }
    
    // Filter slots based on selected filters
    function filterSlots() {
        const selectedLantai = filterLantai.value;
        const selectedStatus = filterStatus.value;
        const data = parkiranData[parkiranId];
        
        let filteredSlots = [];
        
        data.lantaiDetail.forEach(lantai => {
            if (selectedLantai === 'all' || selectedLantai === lantai.lantai.toString()) {
                const lantaiSlots = lantai.slots.filter(slot => {
                    return selectedStatus === 'all' || slot.status === selectedStatus;
                });
                filteredSlots = filteredSlots.concat(lantaiSlots);
            }
        });
        
        renderSlots(filteredSlots);
    }
    
    // Get status text
    function getStatusText(status) {
        const statusMap = {
            'available': 'Tersedia',
            'occupied': 'Terisi',
            'maintenance': 'Maintenance'
        };
        return statusMap[status] || status;
    }
    
    // Generate sample slots data
    function generateSlots(lantai, total, penamaan, occupiedCount) {
        const slots = [];
        const occupiedSlots = new Set();
        
        // Randomly select occupied slots
        while (occupiedSlots.size < occupiedCount) {
            const randomSlot = Math.floor(Math.random() * total) + 1;
            occupiedSlots.add(randomSlot);
        }
        
        for (let i = 1; i <= total; i++) {
            let kode;
            if (penamaan === 'huruf') {
                kode = `${lantai}${String.fromCharCode(64 + i)}`;
            } else if (penamaan === 'angka') {
                kode = `${lantai}-${i}`;
            } else {
                // gabungan
                const row = Math.ceil(i / 10);
                const col = ((i - 1) % 10) + 1;
                kode = `${lantai}${String.fromCharCode(64 + row)}${col}`;
            }
            
            let status = occupiedSlots.has(i) ? 'occupied' : 'available';
            
            // Randomly set some slots as maintenance
            if (status === 'available' && Math.random() < 0.05) {
                status = 'maintenance';
            }
            
            slots.push({
                kode: kode,
                lantai: lantai,
                status: status
            });
        }
        
        return slots;
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
    
    // Initialize
    initialize();
    
    console.log('Detail parkiran page loaded successfully');
});
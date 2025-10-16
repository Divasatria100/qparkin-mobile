// Admin Kendaraan JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Elements
    const searchInput = document.getElementById('searchInput');
    const statusFilter = document.getElementById('statusFilter');
    const jenisFilter = document.getElementById('jenisFilter');
    const startDate = document.getElementById('startDate');
    const endDate = document.getElementById('endDate');
    const tableBody = document.querySelector('.data-table tbody');
    const exportBtn = document.querySelector('.export-btn');
    
    // Modal Elements
    const deleteModal = document.getElementById('deleteModal');
    const closeModal = document.querySelector('.close');
    const cancelBtn = document.querySelector('.btn-cancel');
    const confirmDeleteBtn = document.querySelector('.btn-confirm-delete');
    const deleteId = document.getElementById('deleteId');
    const deletePlat = document.getElementById('deletePlat');
    
    // Original data (in a real app, this would come from an API)
    let originalData = [];
    let filteredData = [];
    let kendaraanToDelete = null;
    
    // Set default dates (today)
    function setDefaultDates() {
        const today = new Date().toISOString().split('T')[0];
        startDate.value = today;
        endDate.value = today;
    }
    
    // Initialize data
    function initializeData() {
        const rows = tableBody.querySelectorAll('tr');
        originalData = Array.from(rows).map(row => {
            const cells = row.querySelectorAll('td');
            return {
                id: cells[0].textContent,
                plat: cells[1].textContent,
                jenisKendaraan: cells[2].textContent,
                jenisPengguna: cells[3].querySelector('.badge').textContent.toLowerCase(),
                status: cells[4].querySelector('.status').textContent.toLowerCase().replace(' ', '_'),
                tanggal: new Date().toISOString().split('T')[0], // Simulated date
                element: row
            };
        });
        filteredData = [...originalData];
    }
    
    // Filter data
    function filterData() {
        const searchTerm = searchInput.value.toLowerCase();
        const statusValue = statusFilter.value;
        const jenisValue = jenisFilter.value;
        const startValue = startDate.value;
        const endValue = endDate.value;
        
        filteredData = originalData.filter(item => {
            const matchesSearch = 
                item.id.toLowerCase().includes(searchTerm) ||
                item.plat.toLowerCase().includes(searchTerm) ||
                item.jenisKendaraan.toLowerCase().includes(searchTerm);
            
            const matchesStatus = !statusValue || item.status === statusValue;
            const matchesJenis = !jenisValue || item.jenisPengguna === jenisValue;
            
            // Date filtering (simulated - in real app would use actual dates)
            const matchesDate = true; // Simplified for demo
            
            return matchesSearch && matchesStatus && matchesJenis && matchesDate;
        });
        
        renderTable();
    }
    
    // Render table
    function renderTable() {
        // Hide all rows first
        originalData.forEach(item => {
            item.element.style.display = 'none';
        });
        
        // Show filtered rows
        filteredData.forEach(item => {
            item.element.style.display = '';
        });
        
        // Reorder rows to maintain filtered order
        filteredData.forEach((item, index) => {
            tableBody.appendChild(item.element);
        });
    }
    
    // Export data
    function exportData() {
        // In a real application, this would generate and download a CSV/Excel file
        console.log('Exporting data:', filteredData);
        
        // Show success message
        const originalText = exportBtn.textContent;
        exportBtn.textContent = 'Mengekspor...';
        exportBtn.disabled = true;
        
        setTimeout(() => {
            exportBtn.textContent = 'Data Berhasil Diekspor!';
            setTimeout(() => {
                exportBtn.textContent = originalText;
                exportBtn.disabled = false;
            }, 2000);
        }, 1000);
    }
    
    // Modal functions
    function showDeleteModal(id, plat) {
        kendaraanToDelete = id;
        deleteId.textContent = id;
        deletePlat.textContent = plat;
        deleteModal.style.display = 'block';
    }
    
    function hideDeleteModal() {
        deleteModal.style.display = 'none';
        kendaraanToDelete = null;
    }
    
    function confirmDelete() {
        if (kendaraanToDelete) {
            // In real app, this would be an API call
            console.log('Deleting kendaraan:', kendaraanToDelete);
            
            // Remove from UI
            const rowToDelete = originalData.find(item => item.id === kendaraanToDelete);
            if (rowToDelete) {
                rowToDelete.element.remove();
                originalData = originalData.filter(item => item.id !== kendaraanToDelete);
                filteredData = filteredData.filter(item => item.id !== kendaraanToDelete);
            }
            
            // Show success message (you could add a toast notification here)
            alert(`Data kendaraan ${kendaraanToDelete} berhasil dihapus`);
            
            hideDeleteModal();
        }
    }
    
    // Global functions for buttons
    window.viewDetail = function(id) {
        // Redirect to detail page
        window.location.href = `detail-kendaraan.html?id=${id}`;
    };
    
    window.editKendaraan = function(id) {
        // In real app, this would open an edit modal or redirect to edit page
        console.log('Editing kendaraan:', id);
        alert(`Edit kendaraan ${id} - Fitur akan datang!`);
    };
    
    window.hapusKendaraan = function(id) {
        const plat = originalData.find(item => item.id === id)?.plat || '';
        showDeleteModal(id, plat);
    };
    
    // Event listeners
    if (searchInput) {
        searchInput.addEventListener('input', filterData);
    }
    
    if (statusFilter) {
        statusFilter.addEventListener('change', filterData);
    }
    
    if (jenisFilter) {
        jenisFilter.addEventListener('change', filterData);
    }
    
    if (startDate && endDate) {
        startDate.addEventListener('change', filterData);
        endDate.addEventListener('change', filterData);
    }
    
    if (exportBtn) {
        exportBtn.addEventListener('click', exportData);
    }
    
    // Modal event listeners
    if (closeModal) {
        closeModal.addEventListener('click', hideDeleteModal);
    }
    
    if (cancelBtn) {
        cancelBtn.addEventListener('click', hideDeleteModal);
    }
    
    if (confirmDeleteBtn) {
        confirmDeleteBtn.addEventListener('click', confirmDelete);
    }
    
    // Close modal when clicking outside
    window.addEventListener('click', function(event) {
        if (event.target === deleteModal) {
            hideDeleteModal();
        }
    });
    
    // Initialize
    setDefaultDates();
    initializeData();
    
    // Log initialization
    console.log('Kendaraan page loaded successfully');
    console.log('Search, filter, and action functionality initialized');
});
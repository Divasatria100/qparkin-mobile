// Edit Parkiran JavaScript
document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('editParkiranForm');
    const jumlahLantaiInput = document.getElementById('jumlahLantai');
    const lantaiContainer = document.getElementById('lantaiContainer');
    const saveBtn = document.getElementById('saveParkiranBtn');
    const deleteBtn = document.getElementById('deleteBtn');
    
    // Form inputs
    const namaInput = document.getElementById('namaParkiran');
    const kodeInput = document.getElementById('kodeParkiran');
    const statusInput = document.getElementById('statusParkiran');

    // Preview elements
    const previewNama = document.getElementById('previewNama');
    const previewStatus = document.getElementById('previewStatus');
    const previewLantai = document.getElementById('previewLantai');
    const previewSlot = document.getElementById('previewSlot');
    const previewKode = document.getElementById('previewKode');
    const previewLantaiList = document.getElementById('previewLantaiList');

    // Modal
    const deleteModal = document.getElementById('deleteModal');
    const confirmDeleteInput = document.getElementById('confirmDelete');
    const confirmDeleteBtn = document.getElementById('confirmDeleteBtn');
    const closeModalBtns = document.querySelectorAll('.close, .close-modal');

    // Initialize with existing data
    generateLantaiFields(floorsData.length);
    updatePreview();

    // Generate lantai fields
    jumlahLantaiInput.addEventListener('input', function() {
        const jumlah = parseInt(this.value) || 0;
        generateLantaiFields(jumlah);
        updatePreview();
    });

    function generateLantaiFields(jumlah) {
        lantaiContainer.innerHTML = '';
        
        for (let i = 1; i <= jumlah; i++) {
            const existingFloor = floorsData[i - 1];
            const lantaiCard = document.createElement('div');
            lantaiCard.className = 'lantai-card';
            lantaiCard.innerHTML = `
                <div class="lantai-header">
                    <h5>Lantai ${i}</h5>
                    <span class="lantai-number">#${i}</span>
                </div>
                <div class="lantai-body">
                    <div class="form-group">
                        <label for="lantai_nama_${i}">Nama Lantai *</label>
                        <input type="text" id="lantai_nama_${i}" name="lantai[${i-1}][nama]" 
                               placeholder="Contoh: Lantai ${i}" 
                               value="${existingFloor ? existingFloor.floor_name : 'Lantai ' + i}" required>
                    </div>
                    <div class="form-group">
                        <label for="lantai_slot_${i}">Jumlah Slot *</label>
                        <input type="number" id="lantai_slot_${i}" name="lantai[${i-1}][jumlah_slot]" 
                               min="1" max="200" placeholder="Contoh: 50" 
                               value="${existingFloor ? existingFloor.total_slots : ''}" required>
                        <span class="form-hint">Maksimal 200 slot per lantai</span>
                    </div>
                </div>
            `;
            lantaiContainer.appendChild(lantaiCard);
            
            // Add event listeners
            const namaLantai = lantaiCard.querySelector(`#lantai_nama_${i}`);
            const slotLantai = lantaiCard.querySelector(`#lantai_slot_${i}`);
            namaLantai.addEventListener('input', updatePreview);
            slotLantai.addEventListener('input', updatePreview);
        }
    }

    function updatePreview() {
        previewNama.textContent = namaInput.value || 'Nama Parkiran';
        
        const statusText = statusInput.options[statusInput.selectedIndex]?.text || 'Status';
        previewStatus.textContent = statusText;
        previewStatus.className = 'preview-status';
        if (statusInput.value === 'Tersedia') {
            previewStatus.classList.add('active');
        } else if (statusInput.value === 'maintenance') {
            previewStatus.classList.add('maintenance');
        } else {
            previewStatus.classList.add('closed');
        }
        
        previewKode.textContent = kodeInput.value || '-';
        
        const jumlah = parseInt(jumlahLantaiInput.value) || 0;
        previewLantai.textContent = jumlah;
        
        let totalSlots = 0;
        const lantaiInputs = document.querySelectorAll('[name^="lantai"][name$="[jumlah_slot]"]');
        lantaiInputs.forEach(input => {
            totalSlots += parseInt(input.value) || 0;
        });
        previewSlot.textContent = totalSlots;
        
        previewLantaiList.innerHTML = '';
        for (let i = 1; i <= jumlah; i++) {
            const namaLantai = document.getElementById(`lantai_nama_${i}`)?.value || `Lantai ${i}`;
            const slotLantai = document.getElementById(`lantai_slot_${i}`)?.value || 0;
            
            const lantaiItem = document.createElement('div');
            lantaiItem.className = 'preview-lantai-item';
            lantaiItem.innerHTML = `
                <span>${namaLantai}</span>
                <span>${slotLantai} slot</span>
            `;
            previewLantaiList.appendChild(lantaiItem);
        }
    }

    namaInput.addEventListener('input', updatePreview);
    kodeInput.addEventListener('input', updatePreview);
    statusInput.addEventListener('change', updatePreview);

    // Save button
    saveBtn.addEventListener('click', async function(e) {
        e.preventDefault();
        
        if (!form.checkValidity()) {
            form.reportValidity();
            return;
        }

        saveBtn.disabled = true;
        saveBtn.querySelector('.loading-spinner').style.display = 'inline-block';
        saveBtn.querySelector('.btn-text').textContent = 'Menyimpan...';

        try {
            const formData = new FormData(form);
            const data = {
                nama_parkiran: formData.get('nama_parkiran'),
                kode_parkiran: formData.get('kode_parkiran'),
                status: formData.get('status'),
                jumlah_lantai: parseInt(formData.get('jumlah_lantai')),
                lantai: []
            };

            const jumlah = parseInt(jumlahLantaiInput.value);
            for (let i = 0; i < jumlah; i++) {
                data.lantai.push({
                    nama: formData.get(`lantai[${i}][nama]`),
                    jumlah_slot: parseInt(formData.get(`lantai[${i}][jumlah_slot]`))
                });
            }

            const response = await fetch(`/admin/parkiran/${parkiranData.id_parkiran}/update`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': document.querySelector('input[name="_token"]').value
                },
                body: JSON.stringify(data)
            });

            const result = await response.json();

            if (result.success) {
                alert('Parkiran berhasil diperbarui!');
                window.location.href = '/admin/parkiran';
            } else {
                alert('Gagal memperbarui parkiran: ' + result.message);
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Terjadi kesalahan saat menyimpan data');
        } finally {
            saveBtn.disabled = false;
            saveBtn.querySelector('.loading-spinner').style.display = 'none';
            saveBtn.querySelector('.btn-text').textContent = 'Simpan Perubahan';
        }
    });

    // Delete button
    deleteBtn.addEventListener('click', function() {
        deleteModal.style.display = 'flex';
    });

    // Close modal
    closeModalBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            deleteModal.style.display = 'none';
            confirmDeleteInput.value = '';
            confirmDeleteBtn.disabled = true;
        });
    });

    // Confirm delete input
    confirmDeleteInput.addEventListener('input', function() {
        confirmDeleteBtn.disabled = this.value !== 'HAPUS';
    });

    // Confirm delete button
    confirmDeleteBtn.addEventListener('click', async function() {
        try {
            const response = await fetch(`/admin/parkiran/${parkiranData.id_parkiran}`, {
                method: 'DELETE',
                headers: {
                    'X-CSRF-TOKEN': document.querySelector('input[name="_token"]').value
                }
            });

            const result = await response.json();

            if (result.success) {
                alert('Parkiran berhasil dihapus!');
                window.location.href = '/admin/parkiran';
            } else {
                alert('Gagal menghapus parkiran: ' + result.message);
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Terjadi kesalahan saat menghapus data');
        }
    });

    console.log('Edit parkiran page loaded');
});

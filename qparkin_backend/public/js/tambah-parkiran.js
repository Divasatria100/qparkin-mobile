// Tambah Parkiran JavaScript
document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('tambahParkiranForm');
    const jumlahLantaiInput = document.getElementById('jumlahLantai');
    const lantaiContainer = document.getElementById('lantaiContainer');
    const saveBtn = document.getElementById('saveParkiranBtn');
    
    // Form inputs for preview
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

    // Generate lantai fields when jumlah lantai changes
    jumlahLantaiInput.addEventListener('input', function() {
        const jumlah = parseInt(this.value) || 0;
        generateLantaiFields(jumlah);
        updatePreview();
    });

    function generateLantaiFields(jumlah) {
        lantaiContainer.innerHTML = '';
        
        for (let i = 1; i <= jumlah; i++) {
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
                               placeholder="Contoh: Lantai ${i}, Ground Floor" 
                               value="Lantai ${i}" required>
                    </div>
                    <div class="form-group">
                        <label for="lantai_slot_${i}">Jumlah Slot *</label>
                        <input type="number" id="lantai_slot_${i}" name="lantai[${i-1}][jumlah_slot]" 
                               min="1" max="200" placeholder="Contoh: 50" required>
                        <span class="form-hint">Maksimal 200 slot per lantai</span>
                    </div>
                </div>
            `;
            lantaiContainer.appendChild(lantaiCard);
            
            // Add event listeners for preview update
            const namaLantai = lantaiCard.querySelector(`#lantai_nama_${i}`);
            const slotLantai = lantaiCard.querySelector(`#lantai_slot_${i}`);
            namaLantai.addEventListener('input', updatePreview);
            slotLantai.addEventListener('input', updatePreview);
        }
    }

    // Update preview
    function updatePreview() {
        // Update nama
        previewNama.textContent = namaInput.value || 'Nama Parkiran';
        
        // Update status
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
        
        // Update kode
        previewKode.textContent = kodeInput.value || '-';
        
        // Update jumlah lantai
        const jumlah = parseInt(jumlahLantaiInput.value) || 0;
        previewLantai.textContent = jumlah;
        
        // Calculate total slots
        let totalSlots = 0;
        const lantaiInputs = document.querySelectorAll('[name^="lantai"][name$="[jumlah_slot]"]');
        lantaiInputs.forEach(input => {
            totalSlots += parseInt(input.value) || 0;
        });
        previewSlot.textContent = totalSlots;
        
        // Update lantai list
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

    // Add event listeners for basic inputs
    namaInput.addEventListener('input', updatePreview);
    kodeInput.addEventListener('input', updatePreview);
    statusInput.addEventListener('change', updatePreview);

    // Form submission
    saveBtn.addEventListener('click', async function(e) {
        e.preventDefault();
        
        if (!form.checkValidity()) {
            form.reportValidity();
            return;
        }

        // Show loading
        saveBtn.disabled = true;
        saveBtn.querySelector('.loading-spinner').style.display = 'inline-block';
        saveBtn.querySelector('.btn-text').textContent = 'Menyimpan...';

        try {
            const formData = new FormData(form);
            
            // Convert FormData to JSON
            const data = {
                nama_parkiran: formData.get('nama_parkiran'),
                kode_parkiran: formData.get('kode_parkiran'),
                status: formData.get('status'),
                jumlah_lantai: parseInt(formData.get('jumlah_lantai')),
                lantai: []
            };

            // Collect lantai data
            const jumlah = parseInt(jumlahLantaiInput.value);
            for (let i = 0; i < jumlah; i++) {
                data.lantai.push({
                    nama: formData.get(`lantai[${i}][nama]`),
                    jumlah_slot: parseInt(formData.get(`lantai[${i}][jumlah_slot]`))
                });
            }

            const response = await fetch('/admin/parkiran/store', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': document.querySelector('input[name="_token"]').value
                },
                body: JSON.stringify(data)
            });

            const result = await response.json();

            if (result.success) {
                // Show success message
                alert('Parkiran berhasil ditambahkan!');
                window.location.href = '/admin/parkiran';
            } else {
                alert('Gagal menambahkan parkiran: ' + result.message);
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Terjadi kesalahan saat menyimpan data');
        } finally {
            // Hide loading
            saveBtn.disabled = false;
            saveBtn.querySelector('.loading-spinner').style.display = 'none';
            saveBtn.querySelector('.btn-text').textContent = 'Simpan Parkiran';
        }
    });

    console.log('Tambah parkiran page loaded');
});

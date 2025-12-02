// Ubah Foto JavaScript
document.addEventListener('DOMContentLoaded', function() {
    const uploadArea = document.getElementById('uploadArea');
    const photoInput = document.getElementById('photoInput');
    const previewSection = document.getElementById('previewSection');
    const imagePreview = document.getElementById('imagePreview');
    const removePreview = document.getElementById('removePreview');
    const cropSection = document.getElementById('cropSection');
    const cropImage = document.getElementById('cropImage');
    const savePhotoBtn = document.getElementById('savePhotoBtn');
    const rotateLeft = document.getElementById('rotateLeft');
    const rotateRight = document.getElementById('rotateRight');
    const resetCrop = document.getElementById('resetCrop');

    let currentFile = null;
    let rotation = 0;

    // Upload area click handler
    uploadArea.addEventListener('click', function() {
        photoInput.click();
    });

    // Drag and drop functionality
    uploadArea.addEventListener('dragover', function(e) {
        e.preventDefault();
        uploadArea.classList.add('dragover');
    });

    uploadArea.addEventListener('dragleave', function(e) {
        e.preventDefault();
        uploadArea.classList.remove('dragover');
    });

    uploadArea.addEventListener('drop', function(e) {
        e.preventDefault();
        uploadArea.classList.remove('dragover');
        
        const files = e.dataTransfer.files;
        if (files.length > 0) {
            handleFileSelect(files[0]);
        }
    });

    // File input change handler
    photoInput.addEventListener('change', function(e) {
        if (e.target.files.length > 0) {
            handleFileSelect(e.target.files[0]);
        }
    });

    // Handle file selection
    function handleFileSelect(file) {
        if (!file.type.startsWith('image/')) {
            alert('Silakan pilih file gambar (JPG, PNG, GIF)');
            return;
        }

        if (file.size > 2 * 1024 * 1024) {
            alert('Ukuran file maksimal 2MB');
            return;
        }

        currentFile = file;
        const reader = new FileReader();

        reader.onload = function(e) {
            imagePreview.src = e.target.result;
            cropImage.src = e.target.result;
            previewSection.style.display = 'block';
            cropSection.style.display = 'block';
            savePhotoBtn.disabled = false;
        };

        reader.readAsDataURL(file);
    }

    // Remove preview
    removePreview.addEventListener('click', function() {
        previewSection.style.display = 'none';
        cropSection.style.display = 'none';
        savePhotoBtn.disabled = true;
        currentFile = null;
        photoInput.value = '';
        rotation = 0;
        resetRotation();
    });

    // Rotate left
    rotateLeft.addEventListener('click', function() {
        rotation = (rotation - 90) % 360;
        applyRotation();
    });

    // Rotate right
    rotateRight.addEventListener('click', function() {
        rotation = (rotation + 90) % 360;
        applyRotation();
    });

    // Reset crop
    resetCrop.addEventListener('click', function() {
        rotation = 0;
        resetRotation();
    });

    // Apply rotation to images
    function applyRotation() {
        imagePreview.style.transform = `rotate(${rotation}deg)`;
        cropImage.style.transform = `rotate(${rotation}deg)`;
    }

    // Reset rotation
    function resetRotation() {
        imagePreview.style.transform = 'rotate(0deg)';
        cropImage.style.transform = 'rotate(0deg)';
    }

    // Save photo
    savePhotoBtn.addEventListener('click', function() {
        if (!currentFile) {
            alert('Silakan pilih foto terlebih dahulu');
            return;
        }

        // Simulate upload process
        savePhotoBtn.disabled = true;
        savePhotoBtn.textContent = 'Menyimpan...';

        setTimeout(function() {
            alert('Foto profil berhasil diubah!');
            savePhotoBtn.disabled = false;
            savePhotoBtn.textContent = 'Simpan Foto';
            
            // Redirect back to profile page
            window.location.href = 'profile.html';
        }, 2000);
    });

    // Keyboard shortcuts
    document.addEventListener('keydown', function(e) {
        if (e.ctrlKey && e.key === 'z') {
            e.preventDefault();
            resetRotation();
        }
    });

    console.log('Ubah Foto page loaded successfully');
});
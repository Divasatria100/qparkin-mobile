// Super Admin - Ubah Foto JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Elements
    const uploadArea = document.getElementById('uploadArea');
    const photoInput = document.getElementById('photoInput');
    const previewSection = document.getElementById('previewSection');
    const imagePreview = document.getElementById('imagePreview');
    const removePreview = document.getElementById('removePreview');
    const cropSection = document.getElementById('cropSection');
    const cropImage = document.getElementById('cropImage');
    const rotateLeft = document.getElementById('rotateLeft');
    const rotateRight = document.getElementById('rotateRight');
    const resetCrop = document.getElementById('resetCrop');
    const savePhotoBtn = document.getElementById('savePhotoBtn');
    
    // State variables
    let currentRotation = 0;
    let selectedFile = null;
    
    // Upload area click handler
    uploadArea.addEventListener('click', function() {
        photoInput.click();
    });
    
    // Drag and drop functionality
    uploadArea.addEventListener('dragover', function(e) {
        e.preventDefault();
        uploadArea.classList.add('dragover');
    });
    
    uploadArea.addEventListener('dragleave', function() {
        uploadArea.classList.remove('dragover');
    });
    
    uploadArea.addEventListener('drop', function(e) {
        e.preventDefault();
        uploadArea.classList.remove('dragover');
        
        if (e.dataTransfer.files.length > 0) {
            const file = e.dataTransfer.files[0];
            handleFileSelection(file);
        }
    });
    
    // File input change handler
    photoInput.addEventListener('change', function(e) {
        if (e.target.files.length > 0) {
            const file = e.target.files[0];
            handleFileSelection(file);
        }
    });
    
    // Handle file selection
    function handleFileSelection(file) {
        // Validate file type
        const validTypes = ['image/jpeg', 'image/png', 'image/gif'];
        if (!validTypes.includes(file.type)) {
            alert('Format file tidak didukung. Harap pilih file JPG, PNG, atau GIF.');
            return;
        }
        
        // Validate file size (max 2MB)
        if (file.size > 2 * 1024 * 1024) {
            alert('Ukuran file terlalu besar. Maksimal 2MB.');
            return;
        }
        
        selectedFile = file;
        
        // Show preview
        const reader = new FileReader();
        reader.onload = function(e) {
            imagePreview.src = e.target.result;
            cropImage.src = e.target.result;
            previewSection.style.display = 'block';
            cropSection.style.display = 'block';
            savePhotoBtn.disabled = false;
            
            // Reset rotation
            currentRotation = 0;
            updateImageRotation();
        };
        reader.readAsDataURL(file);
    }
    
    // Remove preview handler
    removePreview.addEventListener('click', function() {
        resetUploadState();
    });
    
    // Rotation handlers
    rotateLeft.addEventListener('click', function() {
        currentRotation -= 90;
        updateImageRotation();
    });
    
    rotateRight.addEventListener('click', function() {
        currentRotation += 90;
        updateImageRotation();
    });
    
    // Reset crop handler
    resetCrop.addEventListener('click', function() {
        resetUploadState();
    });
    
    // Update image rotation
    function updateImageRotation() {
        imagePreview.style.transform = `rotate(${currentRotation}deg)`;
        cropImage.style.transform = `rotate(${currentRotation}deg)`;
    }
    
    // Reset upload state
    function resetUploadState() {
        previewSection.style.display = 'none';
        cropSection.style.display = 'none';
        savePhotoBtn.disabled = true;
        photoInput.value = '';
        selectedFile = null;
        currentRotation = 0;
    }
    
    // Save photo handler
    savePhotoBtn.addEventListener('click', function() {
        if (!selectedFile) {
            alert('Tidak ada foto yang dipilih.');
            return;
        }
        
        // Show loading state
        savePhotoBtn.innerHTML = 'Menyimpan...';
        savePhotoBtn.disabled = true;
        
        // Simulate upload process
        setTimeout(function() {
            // In a real application, you would upload the file to a server here
            // For demonstration, we'll just show a success message
            
            alert('Foto profil berhasil diperbarui!');
            window.location.href = 'super-profile.html';
        }, 1500);
    });
    
    // Keyboard navigation support
    document.addEventListener('keydown', function(e) {
        // ESC key resets upload
        if (e.key === 'Escape' && previewSection.style.display !== 'none') {
            resetUploadState();
        }
    });
    
    // Add loading animation for better UX
    window.addEventListener('load', function() {
        document.body.classList.add('loaded');
        
        // Remove initial loading animation
        setTimeout(() => {
            const loadingElements = document.querySelectorAll('.loading');
            loadingElements.forEach(el => el.classList.remove('loading'));
        }, 500);
    });
    
    // Error handling for missing elements
    function checkRequiredElements() {
        const required = [uploadArea, photoInput, previewSection, imagePreview];
        required.forEach(el => {
            if (!el) {
                console.warn('Required element not found:', el);
            }
        });
    }
    
    checkRequiredElements();
    
    console.log('Super Admin - Ubah Foto initialized successfully');
});
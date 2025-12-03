// Super Admin - Edit Informasi JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Elements
    const editForm = document.getElementById('editInfoForm');
    const resetBtn = document.getElementById('resetBtn');
    const saveBtn = document.getElementById('saveBtn');
    
    // Form fields
    const namaLengkap = document.getElementById('namaLengkap');
    const email = document.getElementById('email');
    const telepon = document.getElementById('telepon');
    const whatsapp = document.getElementById('whatsapp');
    const alamat = document.getElementById('alamat');
    
    // Error elements
    const namaError = document.getElementById('namaError');
    const emailError = document.getElementById('emailError');
    const teleponError = document.getElementById('teleponError');
    const whatsappError = document.getElementById('whatsappError');
    const alamatError = document.getElementById('alamatError');
    
    // Original values for reset
    const originalValues = {
        namaLengkap: namaLengkap.value,
        email: email.value,
        telepon: telepon.value,
        whatsapp: whatsapp.value,
        alamat: alamat.value
    };
    
    // Validation functions
    function validateNama() {
        const value = namaLengkap.value.trim();
        if (!value) {
            showError(namaLengkap, namaError, 'Nama lengkap wajib diisi');
            return false;
        }
        if (value.length < 2) {
            showError(namaLengkap, namaError, 'Nama lengkap minimal 2 karakter');
            return false;
        }
        showSuccess(namaLengkap, namaError);
        return true;
    }
    
    function validateEmail() {
        const value = email.value.trim();
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        
        if (!value) {
            showError(email, emailError, 'Email wajib diisi');
            return false;
        }
        if (!emailRegex.test(value)) {
            showError(email, emailError, 'Format email tidak valid');
            return false;
        }
        showSuccess(email, emailError);
        return true;
    }
    
    function validateTelepon() {
        const value = telepon.value.trim();
        if (!value) {
            showSuccess(telepon, teleponError);
            return true; // Optional field
        }
        
        const teleponRegex = /^\+?[\d\s-()]{10,}$/;
        if (!teleponRegex.test(value)) {
            showError(telepon, teleponError, 'Format nomor telepon tidak valid');
            return false;
        }
        showSuccess(telepon, teleponError);
        return true;
    }
    
    function validateWhatsApp() {
        const value = whatsapp.value.trim();
        if (!value) {
            showSuccess(whatsapp, whatsappError);
            return true; // Optional field
        }
        
        const whatsappRegex = /^\+?[\d\s-()]{10,}$/;
        if (!whatsappRegex.test(value)) {
            showError(whatsapp, whatsappError, 'Format nomor WhatsApp tidak valid');
            return false;
        }
        showSuccess(whatsapp, whatsappError);
        return true;
    }
    
    function validateAlamat() {
        const value = alamat.value.trim();
        if (!value) {
            showSuccess(alamat, alamatError);
            return true; // Optional field
        }
        
        if (value.length < 10) {
            showError(alamat, alamatError, 'Alamat terlalu pendek');
            return false;
        }
        showSuccess(alamat, alamatError);
        return true;
    }
    
    // Helper functions
    function showError(input, errorElement, message) {
        input.parentElement.classList.add('error');
        input.parentElement.classList.remove('success');
        errorElement.textContent = message;
    }
    
    function showSuccess(input, errorElement) {
        input.parentElement.classList.remove('error');
        input.parentElement.classList.add('success');
        errorElement.textContent = '';
    }
    
    function clearAllErrors() {
        const errorElements = [namaError, emailError, teleponError, whatsappError, alamatError];
        const inputs = [namaLengkap, email, telepon, whatsapp, alamat];
        
        errorElements.forEach(element => element.textContent = '');
        inputs.forEach(input => {
            input.parentElement.classList.remove('error', 'success');
        });
    }
    
    function validateForm() {
        const isNamaValid = validateNama();
        const isEmailValid = validateEmail();
        const isTeleponValid = validateTelepon();
        const isWhatsAppValid = validateWhatsApp();
        const isAlamatValid = validateAlamat();
        
        return isNamaValid && isEmailValid && isTeleponValid && isWhatsAppValid && isAlamatValid;
    }
    
    // Real-time validation
    namaLengkap.addEventListener('input', validateNama);
    email.addEventListener('input', validateEmail);
    telepon.addEventListener('input', validateTelepon);
    whatsapp.addEventListener('input', validateWhatsApp);
    alamat.addEventListener('input', validateAlamat);
    
    // Reset button handler
    resetBtn.addEventListener('click', function() {
        if (confirm('Apakah Anda yakin ingin mengembalikan semua perubahan?')) {
            namaLengkap.value = originalValues.namaLengkap;
            email.value = originalValues.email;
            telepon.value = originalValues.telepon;
            whatsapp.value = originalValues.whatsapp;
            alamat.value = originalValues.alamat;
            
            clearAllErrors();
            
            // Show reset confirmation
            showTemporaryMessage('Perubahan berhasil direset', 'success');
        }
    });
    
    // Form submission handler
    editForm.addEventListener('submit', function(e) {
        e.preventDefault();
        
        if (validateForm()) {
            // Show loading state
            saveBtn.innerHTML = 'Menyimpan...';
            saveBtn.disabled = true;
            
            // Simulate API call
            setTimeout(function() {
                // Update original values
                originalValues.namaLengkap = namaLengkap.value;
                originalValues.email = email.value;
                originalValues.telepon = telepon.value;
                originalValues.whatsapp = whatsapp.value;
                originalValues.alamat = alamat.value;
                
                // Show success message
                showTemporaryMessage('Informasi berhasil diperbarui!', 'success');
                
                // Restore button state
                saveBtn.innerHTML = 'Simpan Perubahan';
                saveBtn.disabled = false;
                
                // Optional: Redirect after success
                setTimeout(() => {
                    window.location.href = 'super-profile.html';
                }, 1500);
                
            }, 1500);
        } else {
            // Scroll to first error
            const firstError = document.querySelector('.form-group.error');
            if (firstError) {
                firstError.scrollIntoView({ 
                    behavior: 'smooth', 
                    block: 'center' 
                });
            }
        }
    });
    
    // Show temporary message
    function showTemporaryMessage(message, type) {
        // Remove existing messages
        const existingMessage = document.querySelector('.success-message');
        if (existingMessage) {
            existingMessage.remove();
        }
        
        const messageDiv = document.createElement('div');
        messageDiv.className = `success-message ${type}`;
        messageDiv.innerHTML = `
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span>${message}</span>
        `;
        
        editForm.insertBefore(messageDiv, editForm.firstChild);
        
        // Auto remove after 3 seconds
        setTimeout(() => {
            if (messageDiv.parentElement) {
                messageDiv.remove();
            }
        }, 3000);
    }
    
    // Keyboard shortcuts
    document.addEventListener('keydown', function(e) {
        // Ctrl + Enter to submit form
        if (e.ctrlKey && e.key === 'Enter') {
            e.preventDefault();
            editForm.dispatchEvent(new Event('submit'));
        }
        
        // ESC to cancel
        if (e.key === 'Escape') {
            if (confirm('Batalkan perubahan?')) {
                window.location.href = 'super-profile.html';
            }
        }
    });
    
    // Auto-save indicator (optional)
    let hasUnsavedChanges = false;
    
    const formInputs = [namaLengkap, email, telepon, whatsapp, alamat];
    formInputs.forEach(input => {
        input.addEventListener('input', function() {
            hasUnsavedChanges = true;
            // You could add auto-save functionality here
        });
    });
    
    // Warn before leaving with unsaved changes
    window.addEventListener('beforeunload', function(e) {
        if (hasUnsavedChanges) {
            e.preventDefault();
            e.returnValue = 'Anda memiliki perubahan yang belum disimpan. Yakin ingin meninggalkan halaman?';
        }
    });
    
    // Reset unsaved changes flag on form submission
    editForm.addEventListener('submit', function() {
        hasUnsavedChanges = false;
    });
    
    // Initialize form validation
    validateForm();
    
    console.log('Super Admin - Edit Informasi initialized successfully');
});
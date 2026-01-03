// Edit Informasi JavaScript
document.addEventListener('DOMContentLoaded', function() {
    const editForm = document.getElementById('editInfoForm');
    const resetBtn = document.getElementById('resetBtn');
    const saveBtn = document.getElementById('saveBtn');
    
    // Store original values for reset functionality
    const originalValues = {};
    
    // Initialize form
    function initializeForm() {
        const formElements = editForm.querySelectorAll('input, textarea, select');
        
        formElements.forEach(element => {
            if (element.type !== 'checkbox') {
                originalValues[element.name] = element.value;
            } else {
                originalValues[element.name] = element.checked;
            }
        });
    }
    
    // Form validation
    function validateForm() {
        let isValid = true;
        const errors = {};
        
        // Clear previous errors
        clearErrors();
        
        // Validate required fields
        const namaLengkap = document.getElementById('namaLengkap').value.trim();
        const email = document.getElementById('email').value.trim();
        const namaMall = document.getElementById('namaMall').value.trim();
        
        if (!namaLengkap) {
            errors.namaLengkap = 'Nama lengkap wajib diisi';
            isValid = false;
        } else if (namaLengkap.length < 2) {
            errors.namaLengkap = 'Nama lengkap minimal 2 karakter';
            isValid = false;
        }
        
        if (!email) {
            errors.email = 'Email wajib diisi';
            isValid = false;
        } else if (!isValidEmail(email)) {
            errors.email = 'Format email tidak valid';
            isValid = false;
        }
        
        if (!namaMall) {
            errors.namaMall = 'Nama mall wajib diisi';
            isValid = false;
        }
        
        // Validate phone numbers if provided
        const telepon = document.getElementById('telepon').value.trim();
        const whatsapp = document.getElementById('whatsapp').value.trim();
        
        if (telepon && !isValidPhone(telepon)) {
            errors.telepon = 'Format nomor telepon tidak valid';
            isValid = false;
        }
        
        if (whatsapp && !isValidPhone(whatsapp)) {
            errors.whatsapp = 'Format nomor WhatsApp tidak valid';
            isValid = false;
        }
        
        // Validate address length
        const alamat = document.getElementById('alamat').value.trim();
        if (alamat && alamat.length < 10) {
            errors.alamat = 'Alamat terlalu pendek (minimal 10 karakter)';
            isValid = false;
        }
        
        // Display errors
        Object.keys(errors).forEach(field => {
            const errorElement = document.getElementById(field + 'Error');
            if (errorElement) {
                errorElement.textContent = errors[field];
                const formGroup = errorElement.closest('.form-group');
                formGroup.classList.add('error');
            }
        });
        
        return isValid;
    }
    
    // Clear all error messages
    function clearErrors() {
        const errorMessages = document.querySelectorAll('.error-message');
        errorMessages.forEach(element => {
            element.textContent = '';
        });
        
        const errorGroups = document.querySelectorAll('.form-group.error');
        errorGroups.forEach(group => {
            group.classList.remove('error');
        });
    }
    
    // Email validation
    function isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }
    
    // Phone validation
    function isValidPhone(phone) {
        const phoneRegex = /^[\+]?[0-9\s\-\(\)]+$/;
        return phoneRegex.test(phone.replace(/\s/g, ''));
    }
    
    // Check if form has changes
    function hasFormChanges() {
        const formElements = editForm.querySelectorAll('input, textarea, select');
        
        for (let element of formElements) {
            if (element.type === 'checkbox') {
                if (element.checked !== originalValues[element.name]) {
                    return true;
                }
            } else {
                if (element.value !== originalValues[element.name]) {
                    return true;
                }
            }
        }
        
        return false;
    }
    
    // Reset form to original values
    function resetForm() {
        const formElements = editForm.querySelectorAll('input, textarea, select');
        
        formElements.forEach(element => {
            if (element.type === 'checkbox') {
                element.checked = originalValues[element.name];
            } else {
                element.value = originalValues[element.name];
            }
        });
        
        clearErrors();
        showNotification('Form telah direset ke nilai semula', 'info');
    }
    
    // Show notification
    function showNotification(message, type = 'success') {
        // Remove existing notification
        const existingNotification = document.querySelector('.form-notification');
        if (existingNotification) {
            existingNotification.remove();
        }
        
        // Create notification
        const notification = document.createElement('div');
        notification.className = `form-notification ${type}`;
        notification.innerHTML = `
            <span>${message}</span>
            <button class="notification-close">&times;</button>
        `;
        
        // Add styles
        notification.style.cssText = `
            position: fixed;
            top: 80px;
            right: 20px;
            background: ${type === 'success' ? '#22c55e' : type === 'error' ? '#ef4444' : '#f59e0b'};
            color: white;
            padding: 12px 16px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            display: flex;
            align-items: center;
            gap: 12px;
            z-index: 1000;
            animation: slideIn 0.3s ease;
        `;
        
        // Close button
        const closeBtn = notification.querySelector('.notification-close');
        closeBtn.style.cssText = `
            background: none;
            border: none;
            color: white;
            font-size: 18px;
            cursor: pointer;
            padding: 0;
            width: 20px;
            height: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
        `;
        
        closeBtn.addEventListener('click', () => {
            notification.remove();
        });
        
        document.body.appendChild(notification);
        
        // Auto remove after 5 seconds
        setTimeout(() => {
            if (notification.parentNode) {
                notification.remove();
            }
        }, 5000);
    }
    
    // Form submission
    editForm.addEventListener('submit', function(e) {
        e.preventDefault();
        
        if (!validateForm()) {
            showNotification('Terdapat kesalahan dalam form. Silakan periksa kembali.', 'error');
            return;
        }
        
        if (!hasFormChanges()) {
            showNotification('Tidak ada perubahan yang perlu disimpan.', 'info');
            return;
        }
        
        // Simulate save process
        saveBtn.disabled = true;
        saveBtn.classList.add('loading');
        
        setTimeout(() => {
            // Update original values
            const formElements = editForm.querySelectorAll('input, textarea, select');
            formElements.forEach(element => {
                if (element.type === 'checkbox') {
                    originalValues[element.name] = element.checked;
                } else {
                    originalValues[element.name] = element.value;
                }
            });
            
            saveBtn.disabled = false;
            saveBtn.classList.remove('loading');
            showNotification('Informasi berhasil diperbarui!');
            
            // Optional: Redirect back to profile
            // setTimeout(() => {
            //     window.location.href = 'profile.html';
            // }, 2000);
            
        }, 2000);
    });
    
    // Reset button
    resetBtn.addEventListener('click', function(e) {
        e.preventDefault();
        
        if (hasFormChanges()) {
            if (confirm('Anda yakin ingin mengembalikan semua perubahan?')) {
                resetForm();
            }
        } else {
            showNotification('Tidak ada perubahan yang perlu direset.', 'info');
        }
    });
    
    // Real-time validation for specific fields
    const realTimeValidationFields = ['namaLengkap', 'email', 'telepon', 'whatsapp', 'alamat'];
    
    realTimeValidationFields.forEach(fieldName => {
        const field = document.getElementById(fieldName);
        if (field) {
            field.addEventListener('blur', function() {
                validateField(fieldName);
            });
        }
    });
    
    // Validate individual field
    function validateField(fieldName) {
        const field = document.getElementById(fieldName);
        const value = field.value.trim();
        let isValid = true;
        let errorMessage = '';
        
        switch (fieldName) {
            case 'namaLengkap':
                if (!value) {
                    isValid = false;
                    errorMessage = 'Nama lengkap wajib diisi';
                } else if (value.length < 2) {
                    isValid = false;
                    errorMessage = 'Nama lengkap minimal 2 karakter';
                }
                break;
                
            case 'email':
                if (!value) {
                    isValid = false;
                    errorMessage = 'Email wajib diisi';
                } else if (!isValidEmail(value)) {
                    isValid = false;
                    errorMessage = 'Format email tidak valid';
                }
                break;
                
            case 'telepon':
            case 'whatsapp':
                if (value && !isValidPhone(value)) {
                    isValid = false;
                    errorMessage = 'Format nomor telepon tidak valid';
                }
                break;
                
            case 'alamat':
                if (value && value.length < 10) {
                    isValid = false;
                    errorMessage = 'Alamat terlalu pendek (minimal 10 karakter)';
                }
                break;
        }
        
        const errorElement = document.getElementById(fieldName + 'Error');
        const formGroup = errorElement.closest('.form-group');
        
        if (isValid) {
            errorElement.textContent = '';
            formGroup.classList.remove('error');
            formGroup.classList.add('success');
        } else {
            errorElement.textContent = errorMessage;
            formGroup.classList.remove('success');
            formGroup.classList.add('error');
        }
    }
    
    // Warn before leaving if there are unsaved changes
    window.addEventListener('beforeunload', function(e) {
        if (hasFormChanges()) {
            e.preventDefault();
            e.returnValue = 'Anda memiliki perubahan yang belum disimpan. Yakin ingin meninggalkan halaman?';
        }
    });
    
    // Initialize the form
    initializeForm();
    
    console.log('Edit Informasi page loaded successfully');
});
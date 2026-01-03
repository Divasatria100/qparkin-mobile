// Super Edit Mall JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Initialize edit mall functionality
    initEditMallForm();
});

function initEditMallForm() {
    const form = document.getElementById('editMallForm');
    const adminActionSelect = document.getElementById('adminAction');
    const changeAdminGroup = document.getElementById('changeAdminGroup');
    const newAdminGroup = document.getElementById('newAdminGroup');
    const cancelBtn = document.getElementById('cancelBtn');
    const resetBtn = document.getElementById('resetBtn');
    const deleteBtn = document.getElementById('deleteBtn');
    const submitBtn = document.getElementById('submitBtn');

    // Get mall data from URL parameter
    const urlParams = new URLSearchParams(window.location.search);
    const mallName = urlParams.get('mall');
    
    if (mallName) {
        document.title = `Edit Mall - ${mallName} - QPARKIN`;
        loadMallData(mallName);
    }

    // Admin action change handler
    if (adminActionSelect) {
        adminActionSelect.addEventListener('change', function() {
            const value = this.value;
            
            // Hide both groups first
            changeAdminGroup.style.display = 'none';
            newAdminGroup.style.display = 'none';
            
            // Show selected group
            if (value === 'change') {
                changeAdminGroup.style.display = 'block';
            } else if (value === 'new') {
                newAdminGroup.style.display = 'block';
            }
        });
    }

    // Cancel button handler
    if (cancelBtn) {
        cancelBtn.addEventListener('click', function() {
            if (hasFormChanges() && !confirm('Ada perubahan yang belum disimpan. Apakah Anda yakin ingin meninggalkan halaman?')) {
                return;
            }
            window.location.href = 'super-manajemen-mall.html';
        });
    }

    // Reset button handler
    if (resetBtn) {
        resetBtn.addEventListener('click', function() {
            if (confirm('Apakah Anda yakin ingin mengembalikan semua perubahan?')) {
                resetFormToOriginal();
            }
        });
    }

    // Delete button handler
    if (deleteBtn) {
        deleteBtn.addEventListener('click', function() {
            deleteMall();
        });
    }

    // Form submission handler
    if (form) {
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            updateMall();
        });
    }

    // Track form changes
    setupChangeTracking();

    // Real-time validation
    setupRealTimeValidation();

    // Auto-calculate total slots
    setupSlotCalculation();
}

function loadMallData(mallName) {
    // In a real application, this would fetch data from an API
    // For now, we'll simulate loading data
    console.log(`Loading data for mall: ${mallName}`);
    
    // Show loading state
    showNotification('Memuat data mall...', 'info');
    
    // Simulate API call
    setTimeout(() => {
        // Data would be populated from API response
        // For demo, we're using the pre-filled values in HTML
        showNotification('Data mall berhasil dimuat', 'success');
        
        // Store original values for change tracking
        storeOriginalValues();
    }, 1000);
}

function storeOriginalValues() {
    const form = document.getElementById('editMallForm');
    const formData = new FormData(form);
    
    window.originalFormData = {};
    for (let [key, value] of formData.entries()) {
        window.originalFormData[key] = value;
    }
    
    // Store checkbox states
    const checkboxes = form.querySelectorAll('input[type="checkbox"]');
    window.originalCheckboxStates = {};
    checkboxes.forEach(checkbox => {
        window.originalCheckboxStates[checkbox.name + '-' + checkbox.value] = checkbox.checked;
    });
}

function setupChangeTracking() {
    const form = document.getElementById('editMallForm');
    const inputs = form.querySelectorAll('input, select, textarea');
    
    inputs.forEach(input => {
        input.addEventListener('input', function() {
            markFieldAsChanged(this);
            updateSaveButtonState();
        });
        
        input.addEventListener('change', function() {
            markFieldAsChanged(this);
            updateSaveButtonState();
        });
    });
    
    // Checkbox change tracking
    const checkboxes = form.querySelectorAll('input[type="checkbox"]');
    checkboxes.forEach(checkbox => {
        checkbox.addEventListener('change', function() {
            markFieldAsChanged(this);
            updateSaveButtonState();
        });
    });
}

function markFieldAsChanged(field) {
    if (field.type === 'checkbox') {
        const originalKey = field.name + '-' + field.value;
        const originalState = window.originalCheckboxStates[originalKey];
        
        if (field.checked !== originalState) {
            field.classList.add('changed');
        } else {
            field.classList.remove('changed');
        }
    } else {
        const originalValue = window.originalFormData[field.name];
        
        if (field.value !== originalValue) {
            field.classList.add('changed');
        } else {
            field.classList.remove('changed');
        }
    }
}

function hasFormChanges() {
    const changedFields = document.querySelectorAll('.changed');
    return changedFields.length > 0;
}

function updateSaveButtonState() {
    const submitBtn = document.getElementById('submitBtn');
    const hasChanges = hasFormChanges();
    
    if (submitBtn) {
        if (hasChanges) {
            submitBtn.disabled = false;
            submitBtn.innerHTML = `
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                </svg>
                Simpan Perubahan
            `;
        } else {
            submitBtn.disabled = true;
            submitBtn.innerHTML = `
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                </svg>
                Tidak Ada Perubahan
            `;
        }
    }
}

function resetFormToOriginal() {
    const form = document.getElementById('editMallForm');
    
    // Reset input fields
    Object.keys(window.originalFormData).forEach(key => {
        const field = form.querySelector(`[name="${key}"]`);
        if (field && field.type !== 'checkbox') {
            field.value = window.originalFormData[key];
            field.classList.remove('changed');
        }
    });
    
    // Reset checkboxes
    const checkboxes = form.querySelectorAll('input[type="checkbox"]');
    checkboxes.forEach(checkbox => {
        const originalKey = checkbox.name + '-' + checkbox.value;
        const originalState = window.originalCheckboxStates[originalKey];
        checkbox.checked = originalState;
        checkbox.classList.remove('changed');
    });
    
    // Reset select fields to their original visual state
    const selects = form.querySelectorAll('select');
    selects.forEach(select => {
        select.classList.remove('changed');
    });
    
    updateSaveButtonState();
    showNotification('Perubahan telah direset', 'info');
}

function setupRealTimeValidation() {
    const requiredFields = document.querySelectorAll('input[required], select[required], textarea[required]');
    
    requiredFields.forEach(field => {
        field.addEventListener('blur', function() {
            validateField(this);
        });
        
        field.addEventListener('input', function() {
            clearFieldError(this);
        });
    });

    // Email validation
    const emailField = document.getElementById('email');
    if (emailField) {
        emailField.addEventListener('blur', function() {
            if (this.value && !isValidEmail(this.value)) {
                showFieldError(this, 'Format email tidak valid');
            }
        });
    }

    // Phone validation
    const phoneField = document.getElementById('phone');
    if (phoneField) {
        phoneField.addEventListener('blur', function() {
            if (this.value && !isValidPhone(this.value)) {
                showFieldError(this, 'Format telepon tidak valid');
            }
        });
    }

    // Website validation
    const websiteField = document.getElementById('website');
    if (websiteField) {
        websiteField.addEventListener('blur', function() {
            if (this.value && !isValidUrl(this.value)) {
                showFieldError(this, 'Format website tidak valid');
            }
        });
    }
}

function setupSlotCalculation() {
    const carSlots = document.getElementById('carSlots');
    const motorcycleSlots = document.getElementById('motorcycleSlots');
    const disabledSlots = document.getElementById('disabledSlots');
    const totalSlots = document.getElementById('totalSlots');

    const slotFields = [carSlots, motorcycleSlots, disabledSlots];
    
    slotFields.forEach(field => {
        if (field) {
            field.addEventListener('input', function() {
                calculateTotalSlots();
            });
        }
    });

    if (totalSlots) {
        totalSlots.addEventListener('input', function() {
            clearFieldError(this);
        });
    }
}

function calculateTotalSlots() {
    const carSlots = parseInt(document.getElementById('carSlots')?.value) || 0;
    const motorcycleSlots = parseInt(document.getElementById('motorcycleSlots')?.value) || 0;
    const disabledSlots = parseInt(document.getElementById('disabledSlots')?.value) || 0;
    const totalSlotsField = document.getElementById('totalSlots');

    const calculatedTotal = carSlots + motorcycleSlots + disabledSlots;
    
    if (totalSlotsField) {
        if (calculatedTotal > 0) {
            totalSlotsField.value = calculatedTotal;
            markFieldAsChanged(totalSlotsField);
        }
    }
}

function validateField(field) {
    const value = field.value.trim();
    const fieldName = field.name;
    let isValid = true;
    let errorMessage = '';

    // Required field validation
    if (field.hasAttribute('required') && !value) {
        isValid = false;
        errorMessage = 'Field ini wajib diisi';
    }

    // Specific field validations
    if (isValid && value) {
        switch (fieldName) {
            case 'email':
                if (!isValidEmail(value)) {
                    isValid = false;
                    errorMessage = 'Format email tidak valid';
                }
                break;
            case 'phone':
                if (!isValidPhone(value)) {
                    isValid = false;
                    errorMessage = 'Format telepon tidak valid';
                }
                break;
            case 'website':
                if (!isValidUrl(value)) {
                    isValid = false;
                    errorMessage = 'Format website tidak valid';
                }
                break;
            case 'totalSlots':
                if (parseInt(value) < 1) {
                    isValid = false;
                    errorMessage = 'Total slot harus lebih dari 0';
                }
                break;
        }
    }

    if (!isValid) {
        showFieldError(field, errorMessage);
    } else {
        clearFieldError(field);
    }

    return isValid;
}

function showFieldError(field, message) {
    field.classList.add('form-error-state');
    const errorElement = document.getElementById(field.id + 'Error');
    if (errorElement) {
        errorElement.textContent = message;
        errorElement.classList.add('show');
    }
}

function clearFieldError(field) {
    field.classList.remove('form-error-state');
    const errorElement = document.getElementById(field.id + 'Error');
    if (errorElement) {
        errorElement.classList.remove('show');
    }
}

function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

function isValidPhone(phone) {
    const phoneRegex = /^[\+]?[(]?[0-9]{1,4}[)]?[-\s\.]?[0-9]{1,4}[-\s\.]?[0-9]{1,9}$/;
    return phoneRegex.test(phone.replace(/\s/g, ''));
}

function isValidUrl(url) {
    try {
        new URL(url);
        return true;
    } catch {
        return false;
    }
}

function validateForm() {
    const requiredFields = document.querySelectorAll('input[required], select[required], textarea[required]');
    let isValid = true;

    requiredFields.forEach(field => {
        if (!validateField(field)) {
            isValid = false;
        }
    });

    return isValid;
}

function updateMall() {
    if (!validateForm()) {
        showNotification('Harap periksa kembali form yang diisi', 'error');
        return;
    }

    if (!hasFormChanges()) {
        showNotification('Tidak ada perubahan yang perlu disimpan', 'info');
        return;
    }

    const formData = collectFormData();
    const submitBtn = document.getElementById('submitBtn');

    // Show loading state
    setButtonLoading(submitBtn, true);

    // Simulate API call
    setTimeout(() => {
        // Reset loading state
        setButtonLoading(submitBtn, false);

        // Update original values
        storeOriginalValues();
        updateSaveButtonState();

        // Show success message
        showNotification('Data mall berhasil diperbarui', 'success');
    }, 2000);
}

function deleteMall() {
    const mallName = document.getElementById('mallName').value;
    
    if (confirm(`Apakah Anda yakin ingin menghapus mall "${mallName}"? Tindakan ini tidak dapat dibatalkan dan semua data terkait akan dihapus.`)) {
        const deleteBtn = document.getElementById('deleteBtn');
        
        // Show loading state
        setButtonLoading(deleteBtn, true);
        
        // Simulate API call
        setTimeout(() => {
            showNotification(`Mall "${mallName}" berhasil dihapus`, 'success');
            
            // Redirect to management page
            setTimeout(() => {
                window.location.href = 'super-manajemen-mall.html';
            }, 1500);
        }, 2000);
    }
}

function collectFormData() {
    const form = document.getElementById('editMallForm');
    const formData = new FormData(form);
    
    // Add update timestamp
    formData.append('updatedAt', new Date().toISOString());
    formData.append('updatedBy', 'Super Admin');
    
    // Collect checkbox values
    const facilities = [];
    document.querySelectorAll('input[name="facilities"]:checked').forEach(checkbox => {
        facilities.push(checkbox.value);
    });
    formData.append('facilities', facilities.join(','));

    return Object.fromEntries(formData);
}

function setButtonLoading(button, isLoading) {
    if (isLoading) {
        button.disabled = true;
        button.classList.add('btn-loading');
    } else {
        button.disabled = false;
        button.classList.remove('btn-loading');
    }
}

function showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `fixed top-4 right-4 z-50 p-4 rounded-lg shadow-lg transition-all duration-300 transform translate-x-full ${
        type === 'success' ? 'bg-green-500 text-white' :
        type === 'error' ? 'bg-red-500 text-white' :
        'bg-blue-500 text-white'
    }`;
    notification.textContent = message;
    
    // Add to page
    document.body.appendChild(notification);
    
    // Animate in
    setTimeout(() => {
        notification.classList.remove('translate-x-full');
    }, 100);
    
    // Remove after delay
    setTimeout(() => {
        notification.classList.add('translate-x-full');
        setTimeout(() => {
            document.body.removeChild(notification);
        }, 300);
    }, 4000);
}

// Handle page refresh/closing with unsaved changes
window.addEventListener('beforeunload', function(e) {
    if (hasFormChanges()) {
        e.preventDefault();
        e.returnValue = 'Ada perubahan yang belum disimpan. Apakah Anda yakin ingin meninggalkan halaman?';
        return e.returnValue;
    }
});

// Export functions for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        initEditMallForm,
        validateForm,
        updateMall,
        deleteMall
    };
}
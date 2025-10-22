// Super Tambah Mall JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Initialize add mall functionality
    initAddMallForm();
});

function initAddMallForm() {
    const form = document.getElementById('addMallForm');
    const adminTypeSelect = document.getElementById('adminType');
    const existingAdminGroup = document.getElementById('existingAdminGroup');
    const newAdminGroup = document.getElementById('newAdminGroup');
    const cancelBtn = document.getElementById('cancelBtn');
    const saveDraftBtn = document.getElementById('saveDraftBtn');
    const submitBtn = document.getElementById('submitBtn');

    // Admin type change handler
    if (adminTypeSelect) {
        adminTypeSelect.addEventListener('change', function() {
            const value = this.value;
            
            // Hide both groups first
            existingAdminGroup.style.display = 'none';
            newAdminGroup.style.display = 'none';
            
            // Show selected group
            if (value === 'existing') {
                existingAdminGroup.style.display = 'block';
            } else if (value === 'new') {
                newAdminGroup.style.display = 'block';
            }
        });
    }

    // Cancel button handler
    if (cancelBtn) {
        cancelBtn.addEventListener('click', function() {
            if (confirm('Apakah Anda yakin ingin membatalkan? Semua data yang belum disimpan akan hilang.')) {
                window.location.href = 'super-manajemen-mall.html';
            }
        });
    }

    // Save draft button handler
    if (saveDraftBtn) {
        saveDraftBtn.addEventListener('click', function() {
            saveMall('draft');
        });
    }

    // Form submission handler
    if (form) {
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            saveMall('active');
        });
    }

    // Real-time validation
    setupRealTimeValidation();

    // Auto-calculate total slots
    setupSlotCalculation();

    // Generate mall code from name
    setupMallCodeGeneration();
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

function setupMallCodeGeneration() {
    const mallName = document.getElementById('mallName');
    const mallCode = document.getElementById('mallCode');

    if (mallName && mallCode) {
        mallName.addEventListener('blur', function() {
            if (!mallCode.value) {
                generateMallCode(this.value);
            }
        });
    }
}

function generateMallCode(mallName) {
    if (!mallName) return;

    // Simple code generation from mall name
    const code = mallName
        .toUpperCase()
        .split(' ')
        .map(word => word.charAt(0))
        .join('')
        .substring(0, 4);

    const mallCodeField = document.getElementById('mallCode');
    if (mallCodeField) {
        mallCodeField.value = code;
        validateField(mallCodeField);
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
            case 'mallCode':
                if (!/^[A-Z0-9]{2,6}$/.test(value)) {
                    isValid = false;
                    errorMessage = 'Kode mall harus 2-6 karakter huruf/angka';
                }
                break;
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

    // Additional validation for admin type
    const adminType = document.getElementById('adminType').value;
    if (adminType === 'existing') {
        const existingAdmin = document.getElementById('existingAdmin').value;
        if (!existingAdmin) {
            isValid = false;
            showFieldError(document.getElementById('existingAdmin'), 'Pilih admin yang bertanggung jawab');
        }
    } else if (adminType === 'new') {
        const adminName = document.getElementById('adminName').value;
        const adminEmail = document.getElementById('adminEmail').value;
        const adminPhone = document.getElementById('adminPhone').value;
        
        if (!adminName || !adminEmail || !adminPhone) {
            isValid = false;
            alert('Harap lengkapi semua data admin baru');
        }
    }

    return isValid;
}

function saveMall(status) {
    if (!validateForm()) {
        showNotification('Harap periksa kembali form yang diisi', 'error');
        return;
    }

    const formData = collectFormData(status);
    const submitBtn = document.getElementById('submitBtn');
    const saveDraftBtn = document.getElementById('saveDraftBtn');

    // Show loading state
    if (status === 'active') {
        setButtonLoading(submitBtn, true);
    } else {
        setButtonLoading(saveDraftBtn, true);
    }

    // Simulate API call
    setTimeout(() => {
        // Reset loading state
        if (status === 'active') {
            setButtonLoading(submitBtn, false);
        } else {
            setButtonLoading(saveDraftBtn, false);
        }

        // Show success message
        const action = status === 'draft' ? 'disimpan sebagai draft' : 'ditambahkan';
        showNotification(`Mall berhasil ${action}`, 'success');

        // Redirect to management page after success
        if (status === 'active') {
            setTimeout(() => {
                window.location.href = 'super-manajemen-mall.html';
            }, 2000);
        }
    }, 2000);
}

function collectFormData(status) {
    const form = document.getElementById('addMallForm');
    const formData = new FormData(form);
    
    // Add status and additional data
    formData.append('status', status);
    formData.append('createdAt', new Date().toISOString());
    
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

// Export functions for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        initAddMallForm,
        validateForm,
        saveMall
    };
}
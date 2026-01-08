// Enhanced signup.js with proper AJAX submission
// This file contains the improved version with backend integration

// Validate Google Maps URL
function validateGoogleMapsUrl(url) {
    if (!url || url.trim() === '') {
        return false;
    }
    
    // Check if URL starts with https:// and contains google.com or maps
    const urlPattern = /^https:\/\/(www\.)?google\.(com|co\.[a-z]{2})\/(maps|url)/i;
    const shortUrlPattern = /^https:\/\/maps\.app\.goo\.gl\//i;
    
    return urlPattern.test(url) || shortUrlPattern.test(url);
}

// Show error helper
function showError(errorId) {
    const errorElement = document.getElementById(errorId);
    if (errorElement) {
        errorElement.classList.add('show');
        const formGroup = errorElement.closest('.form-group');
        if (formGroup) {
            formGroup.classList.add('error');
        }
    }
}

// Show notification helper
function showNotification(message, type) {
    // Simple notification implementation
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.textContent = message;
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 15px 20px;
        background: ${type === 'success' ? '#10b981' : '#ef4444'};
        color: white;
        border-radius: 8px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        z-index: 9999;
        animation: slideIn 0.3s ease;
    `;
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.remove();
    }, 3000);
}

// Form submission with AJAX
document.addEventListener('DOMContentLoaded', function() {
    const signupForm = document.getElementById('signupForm');
    const submitBtn = document.getElementById('submitBtn');
    
    if (!signupForm || !submitBtn) return;
    
    signupForm.addEventListener('submit', function(e) {
        e.preventDefault();
        
        // Get form values
        const name = document.getElementById('name').value.trim();
        const email = document.getElementById('email').value.trim();
        const mallName = document.getElementById('mallName').value.trim();
        const googleMapsUrl = document.getElementById('googleMapsUrl').value.trim();
        const mallPhoto = document.getElementById('mallPhoto').files[0];
        const password = document.getElementById('password').value;
        const confirmPassword = document.getElementById('confirmPassword').value;
        
        let isValid = true;
        
        // Reset errors
        document.querySelectorAll('.error-message').forEach(el => {
            el.classList.remove('show');
        });
        document.querySelectorAll('.form-group').forEach(el => {
            el.classList.remove('error');
        });

        // Validate name
        if (name.length < 5) {
            showError('nameError');
            isValid = false;
        }
        
        // Validate email
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            showError('emailError');
            isValid = false;
        }
        
        // Validate mall name
        if (mallName.length < 3) {
            showError('mallNameError');
            isValid = false;
        }
        
        // Validate Google Maps URL
        if (!validateGoogleMapsUrl(googleMapsUrl)) {
            const errorElement = document.getElementById('googleMapsUrlError');
            if (errorElement) {
                errorElement.textContent = 'Please enter a valid Google Maps URL (must start with https:// and contain google.com or maps.app.goo.gl)';
            }
            showError('googleMapsUrlError');
            isValid = false;
        }
        
        // Validate mall photo
        if (!mallPhoto) {
            showError('mallPhotoError');
            isValid = false;
        }
        
        // Validate password
        if (password.length < 6) {
            showError('passwordError');
            isValid = false;
        }
        
        // Validate password confirmation
        if (password !== confirmPassword) {
            showError('confirmPasswordError');
            isValid = false;
        }
        
        if (!isValid) {
            showNotification('Harap perbaiki error dalam form', 'error');
            return;
        }
        
        // Show loading state
        submitBtn.classList.add('loading');
        submitBtn.querySelector('.btn-text').textContent = 'Mengirim...';
        submitBtn.querySelector('.btn-loader').classList.remove('hidden');
        submitBtn.disabled = true;
        
        // Prepare FormData
        const formData = new FormData(signupForm);
        
        // Get CSRF token
        const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') 
                       || document.querySelector('input[name="_token"]')?.value;
        
        // Send AJAX request
        fetch('/register', {
            method: 'POST',
            body: formData,
            headers: {
                'X-Requested-With': 'XMLHttpRequest',
                'Accept': 'application/json',
                'X-CSRF-TOKEN': csrfToken
            }
        })
        .then(response => {
            if (!response.ok) {
                return response.json().then(err => Promise.reject(err));
            }
            return response.json();
        })
        .then(data => {
            // Success - show notification and redirect
            showNotification('Registrasi berhasil! Mengarahkan...', 'success');
            
            setTimeout(() => {
                if (data.redirect) {
                    window.location.href = data.redirect;
                } else {
                    window.location.href = '/success-signup';
                }
            }, 1000);
        })
        .catch(error => {
            console.error('Registration error:', error);
            
            // Reset button state
            submitBtn.classList.remove('loading');
            submitBtn.querySelector('.btn-text').textContent = 'Submit Request';
            submitBtn.querySelector('.btn-loader').classList.add('hidden');
            submitBtn.disabled = false;
            
            // Show error notification
            if (error.errors) {
                // Laravel validation errors
                const firstError = Object.values(error.errors)[0];
                if (Array.isArray(firstError) && firstError.length > 0) {
                    showNotification(firstError[0], 'error');
                }
                
                // Show all field errors
                Object.keys(error.errors).forEach(key => {
                    const errorId = key.replace(/_/g, '') + 'Error';
                    const errorElement = document.getElementById(errorId);
                    if (errorElement) {
                        errorElement.textContent = error.errors[key][0];
                        showError(errorId);
                    }
                });
            } else if (error.message) {
                showNotification(error.message, 'error');
            } else {
                showNotification('Terjadi kesalahan. Silakan coba lagi.', 'error');
            }
        });
    });
    
    // Password toggle functionality
    const passwordToggles = document.querySelectorAll('.password-toggle');
    passwordToggles.forEach(toggle => {
        toggle.addEventListener('click', function() {
            const input = this.previousElementSibling;
            const icon = this.querySelector('i');
            
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            }
        });
    });
    
    // Photo upload functionality
    const mallPhoto = document.getElementById('mallPhoto');
    const uploadBtn = document.getElementById('uploadBtn');
    const previewArea = document.getElementById('previewArea');
    const previewImage = document.getElementById('previewImage');
    const removePhoto = document.getElementById('removePhoto');
    
    if (uploadBtn) {
        uploadBtn.addEventListener('click', () => mallPhoto.click());
    }
    
    if (mallPhoto) {
        mallPhoto.addEventListener('change', function() {
            if (this.files && this.files[0]) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    previewImage.src = e.target.result;
                    previewArea.classList.remove('hidden');
                    uploadBtn.style.display = 'none';
                };
                reader.readAsDataURL(this.files[0]);
            }
        });
    }
    
    if (removePhoto) {
        removePhoto.addEventListener('click', function() {
            mallPhoto.value = '';
            previewArea.classList.add('hidden');
            uploadBtn.style.display = 'flex';
        });
    }
});

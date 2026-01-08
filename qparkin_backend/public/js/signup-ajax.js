// Enhanced signup.js with proper AJAX submission
// This file contains the improved version with backend integration

// Form submission with AJAX (replace the existing form submission handler)
function setupFormSubmissionWithAjax() {
    const signupForm = document.getElementById('signupForm');
    const submitBtn = document.getElementById('submitBtn');
    
    signupForm.addEventListener('submit', function(e) {
        e.preventDefault();
        
        // Get form values
        const name = document.getElementById('name').value.trim();
        const email = document.getElementById('email').value.trim();
        const mallName = document.getElementById('mallName').value.trim();
        const location = document.getElementById('location').value.trim();
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
        
        // Validate location
        if (location.length < 5) {
            showError('locationError');
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
        
        // Add coordinates if marker exists
        if (typeof marker !== 'undefined' && marker && marker.getPosition()) {
            const position = marker.getPosition();
            formData.append('latitude', position.lat());
            formData.append('longitude', position.lng());
        }
        
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
                    const errorId = key + 'Error';
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
}

// Call this function in DOMContentLoaded if you want to use AJAX
// Replace the existing form submission handler with:
// setupFormSubmissionWithAjax();

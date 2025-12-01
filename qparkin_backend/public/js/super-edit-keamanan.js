// Super Admin - Ubah Keamanan JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Elements
    const changePasswordForm = document.getElementById('changePasswordForm');
    const currentPassword = document.getElementById('currentPassword');
    const newPassword = document.getElementById('newPassword');
    const confirmPassword = document.getElementById('confirmPassword');
    const savePasswordBtn = document.getElementById('savePasswordBtn');
    const enable2FABtn = document.getElementById('enable2FABtn');
    const logoutAllBtn = document.getElementById('logoutAllBtn');
    
    // Error elements
    const currentPasswordError = document.getElementById('currentPasswordError');
    const newPasswordError = document.getElementById('newPasswordError');
    const confirmPasswordError = document.getElementById('confirmPasswordError');
    
    // Password strength elements
    const strengthFill = document.getElementById('strengthFill');
    const strengthText = document.getElementById('strengthText');
    
    // Password requirement elements
    const reqLength = document.getElementById('reqLength');
    const reqUppercase = document.getElementById('reqUppercase');
    const reqLowercase = document.getElementById('reqLowercase');
    const reqNumber = document.getElementById('reqNumber');
    const reqSpecial = document.getElementById('reqSpecial');
    const reqNoCommon = document.getElementById('reqNoCommon');
    
    // Common passwords for validation
    const commonPasswords = [
        'password', '12345678', 'qwerty', 'admin', 'superadmin',
        'password123', 'admin123', 'qparkin2024', 'superadmin123'
    ];
    
    // Toggle password visibility
    function setupPasswordToggles() {
        const toggleButtons = document.querySelectorAll('.toggle-password');
        
        toggleButtons.forEach(button => {
            button.addEventListener('click', function() {
                const targetId = this.getAttribute('data-target');
                const passwordInput = document.getElementById(targetId);
                const eyeIcon = this.querySelector('.eye-icon');
                const eyeOffIcon = this.querySelector('.eye-off-icon');
                
                if (passwordInput.type === 'password') {
                    passwordInput.type = 'text';
                    eyeIcon.style.display = 'none';
                    eyeOffIcon.style.display = 'block';
                } else {
                    passwordInput.type = 'password';
                    eyeIcon.style.display = 'block';
                    eyeOffIcon.style.display = 'none';
                }
            });
        });
    }
    
    // Password strength checker
    function checkPasswordStrength(password) {
        let strength = 0;
        const requirements = {
            length: password.length >= 12,
            uppercase: /[A-Z]/.test(password),
            lowercase: /[a-z]/.test(password),
            number: /[0-9]/.test(password),
            special: /[^A-Za-z0-9]/.test(password),
            notCommon: !commonPasswords.includes(password.toLowerCase())
        };
        
        // Update requirement indicators
        updateRequirementIndicator(reqLength, requirements.length);
        updateRequirementIndicator(reqUppercase, requirements.uppercase);
        updateRequirementIndicator(reqLowercase, requirements.lowercase);
        updateRequirementIndicator(reqNumber, requirements.number);
        updateRequirementIndicator(reqSpecial, requirements.special);
        updateRequirementIndicator(reqNoCommon, requirements.notCommon);
        
        // Calculate strength score
        Object.values(requirements).forEach(met => {
            if (met) strength++;
        });
        
        // Update strength bar and text
        updateStrengthDisplay(strength);
        
        return strength;
    }
    
    function updateRequirementIndicator(element, isValid) {
        if (isValid) {
            element.classList.add('valid');
        } else {
            element.classList.remove('valid');
        }
    }
    
    function updateStrengthDisplay(strength) {
        strengthFill.className = 'strength-fill';
        
        if (strength <= 2) {
            strengthFill.classList.add('weak');
            strengthText.textContent = 'Lemah';
            strengthText.style.color = '#ef4444';
        } else if (strength <= 4) {
            strengthFill.classList.add('medium');
            strengthText.textContent = 'Cukup';
            strengthText.style.color = '#f59e0b';
        } else {
            strengthFill.classList.add('strong');
            strengthText.textContent = 'Kuat';
            strengthText.style.color = '#22c55e';
        }
    }
    
    // Validation functions
    function validateCurrentPassword() {
        const value = currentPassword.value.trim();
        if (!value) {
            showError(currentPassword, currentPasswordError, 'Kata sandi saat ini wajib diisi');
            return false;
        }
        // In a real application, you would verify against the current password
        showSuccess(currentPassword, currentPasswordError);
        return true;
    }
    
    function validateNewPassword() {
        const value = newPassword.value;
        const strength = checkPasswordStrength(value);
        
        if (!value) {
            showError(newPassword, newPasswordError, 'Kata sandi baru wajib diisi');
            return false;
        }
        
        if (value.length < 12) {
            showError(newPassword, newPasswordError, 'Kata sandi minimal 12 karakter');
            return false;
        }
        
        if (strength < 4) {
            showError(newPassword, newPasswordError, 'Kata sandi terlalu lemah');
            return false;
        }
        
        showSuccess(newPassword, newPasswordError);
        return true;
    }
    
    function validateConfirmPassword() {
        const value = confirmPassword.value;
        const newPasswordValue = newPassword.value;
        
        if (!value) {
            showError(confirmPassword, confirmPasswordError, 'Konfirmasi kata sandi wajib diisi');
            return false;
        }
        
        if (value !== newPasswordValue) {
            showError(confirmPassword, confirmPasswordError, 'Kata sandi tidak cocok');
            return false;
        }
        
        showSuccess(confirmPassword, confirmPasswordError);
        return true;
    }
    
    // Helper functions
    function showError(input, errorElement, message) {
        input.style.borderColor = '#ef4444';
        errorElement.textContent = message;
    }
    
    function showSuccess(input, errorElement) {
        input.style.borderColor = '#22c55e';
        errorElement.textContent = '';
    }
    
    function clearAllErrors() {
        const errorElements = [currentPasswordError, newPasswordError, confirmPasswordError];
        const inputs = [currentPassword, newPassword, confirmPassword];
        
        errorElements.forEach(element => element.textContent = '');
        inputs.forEach(input => {
            input.style.borderColor = '#d1d5db';
        });
    }
    
    function validatePasswordForm() {
        const isCurrentValid = validateCurrentPassword();
        const isNewValid = validateNewPassword();
        const isConfirmValid = validateConfirmPassword();
        
        return isCurrentValid && isNewValid && isConfirmValid;
    }
    
    // Real-time validation
    currentPassword.addEventListener('input', validateCurrentPassword);
    newPassword.addEventListener('input', validateNewPassword);
    confirmPassword.addEventListener('input', validateConfirmPassword);
    
    // Password form submission
    changePasswordForm.addEventListener('submit', function(e) {
        e.preventDefault();
        
        if (validatePasswordForm()) {
            // Show loading state
            savePasswordBtn.innerHTML = 'Mengubah...';
            savePasswordBtn.disabled = true;
            
            // Simulate API call
            setTimeout(function() {
                // Show success message
                showTemporaryMessage('Kata sandi berhasil diubah!', 'success');
                
                // Clear form
                changePasswordForm.reset();
                clearAllErrors();
                checkPasswordStrength('');
                
                // Restore button state
                savePasswordBtn.innerHTML = 'Ubah Kata Sandi';
                savePasswordBtn.disabled = false;
                
            }, 2000);
        }
    });
    
    // Two Factor Authentication
    enable2FABtn.addEventListener('click', function() {
        if (confirm('Apakah Anda yakin ingin mengaktifkan verifikasi 2 langkah? Pastikan Anda memiliki aplikasi autentikator seperti Google Authenticator.')) {
            // Show loading state
            enable2FABtn.innerHTML = 'Mengaktifkan...';
            enable2FABtn.disabled = true;
            
            // Simulate setup process
            setTimeout(function() {
                showTemporaryMessage('Verifikasi 2 langkah berhasil diaktifkan!', 'success');
                
                // Update UI
                const badge = document.querySelector('.section-badge.inactive');
                badge.textContent = 'Aktif';
                badge.classList.remove('inactive');
                badge.style.background = 'linear-gradient(135deg, #22c55e 0%, #16a34a 100%)';
                
                enable2FABtn.textContent = 'Kelola Verifikasi 2 Langkah';
                enable2FABtn.disabled = false;
                
            }, 1500);
        }
    });
    
    // Session management
    function setupSessionLogout() {
        const logoutButtons = document.querySelectorAll('.btn-logout-session');
        
        logoutButtons.forEach(button => {
            button.addEventListener('click', function() {
                const session = this.getAttribute('data-session');
                const device = this.closest('.session-item').querySelector('strong').textContent;
                
                if (confirm(`Keluar dari sesi ${device}?`)) {
                    // Show loading
                    this.innerHTML = 'Mengeluarkan...';
                    this.disabled = true;
                    
                    setTimeout(() => {
                        if (session === 'current') {
                            // If logging out from current session, redirect to login
                            window.location.href = '../pages/signin.html';
                        } else {
                            // Remove the session item
                            this.closest('.session-item').remove();
                            showTemporaryMessage('Sesi berhasil dikeluarkan', 'success');
                        }
                    }, 1000);
                }
            });
        });
    }
    
    // Logout all other sessions
    logoutAllBtn.addEventListener('click', function() {
        if (confirm('Keluar dari semua sesi lain? Anda akan tetap login di perangkat ini.')) {
            this.innerHTML = 'Mengeluarkan...';
            this.disabled = true;
            
            setTimeout(() => {
                const otherSessions = document.querySelectorAll('.session-item:not(.current)');
                otherSessions.forEach(session => session.remove());
                
                showTemporaryMessage('Semua sesi lain berhasil dikeluarkan', 'success');
                this.innerHTML = 'Keluar dari Semua Sesi Lain';
                this.disabled = false;
            }, 1500);
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
        
        securityContainer.insertBefore(messageDiv, securityContainer.firstChild);
        
        // Auto remove after 3 seconds
        setTimeout(() => {
            if (messageDiv.parentElement) {
                messageDiv.remove();
            }
        }, 3000);
    }
    
    // Additional security toggles
    function setupSecurityToggles() {
        const toggles = document.querySelectorAll('.toggle-switch input');
        
        toggles.forEach(toggle => {
            toggle.addEventListener('change', function() {
                const setting = this.closest('.security-option').querySelector('h4').textContent;
                const action = this.checked ? 'diaktifkan' : 'dinonaktifkan';
                
                showTemporaryMessage(`${setting} berhasil ${action}`, 'success');
            });
        });
    }
    
    // Initialize
    const securityContainer = document.querySelector('.security-container');
    
    setupPasswordToggles();
    setupSessionLogout();
    setupSecurityToggles();
    
    // Initialize password strength
    checkPasswordStrength('');
    
    console.log('Super Admin - Ubah Keamanan initialized successfully');
});
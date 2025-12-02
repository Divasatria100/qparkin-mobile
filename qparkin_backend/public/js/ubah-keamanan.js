// Ubah Keamanan JavaScript
document.addEventListener('DOMContentLoaded', function() {
    const changePasswordForm = document.getElementById('changePasswordForm');
    const currentPassword = document.getElementById('currentPassword');
    const newPassword = document.getElementById('newPassword');
    const confirmPassword = document.getElementById('confirmPassword');
    const savePasswordBtn = document.getElementById('savePasswordBtn');
    const enable2FABtn = document.getElementById('enable2FABtn');
    const logoutAllBtn = document.getElementById('logoutAllBtn');
    const togglePasswordBtns = document.querySelectorAll('.toggle-password');

    // Toggle password visibility
    togglePasswordBtns.forEach(button => {
        button.addEventListener('click', function() {
            const targetId = this.getAttribute('data-target');
            const targetInput = document.getElementById(targetId);
            const eyeIcon = this.querySelector('.eye-icon');
            const eyeOffIcon = this.querySelector('.eye-off-icon');

            if (targetInput.type === 'password') {
                targetInput.type = 'text';
                eyeIcon.style.display = 'none';
                eyeOffIcon.style.display = 'block';
            } else {
                targetInput.type = 'password';
                eyeIcon.style.display = 'block';
                eyeOffIcon.style.display = 'none';
            }
        });
    });

    // Password strength checker
    newPassword.addEventListener('input', function() {
        checkPasswordStrength(this.value);
        validatePasswordRequirements(this.value);
    });

    // Confirm password validation
    confirmPassword.addEventListener('input', function() {
        validateConfirmPassword();
    });

    // Password strength calculation
    function checkPasswordStrength(password) {
        const strengthFill = document.getElementById('strengthFill');
        const strengthText = document.getElementById('strengthText');
        
        let strength = 0;
        let feedback = '';

        // Check length
        if (password.length >= 8) strength += 1;
        
        // Check for uppercase letters
        if (/[A-Z]/.test(password)) strength += 1;
        
        // Check for lowercase letters
        if (/[a-z]/.test(password)) strength += 1;
        
        // Check for numbers
        if (/[0-9]/.test(password)) strength += 1;
        
        // Check for special characters
        if (/[^A-Za-z0-9]/.test(password)) strength += 1;

        // Update strength indicator
        strengthFill.className = 'strength-fill';
        switch (strength) {
            case 0:
            case 1:
                strengthFill.classList.add('weak');
                strengthText.textContent = 'Kata sandi lemah';
                strengthText.style.color = '#ef4444';
                break;
            case 2:
            case 3:
                strengthFill.classList.add('medium');
                strengthText.textContent = 'Kata sandi cukup';
                strengthText.style.color = '#f59e0b';
                break;
            case 4:
            case 5:
                strengthFill.classList.add('strong');
                strengthText.textContent = 'Kata sandi kuat';
                strengthText.style.color = '#22c55e';
                break;
        }
    }

    // Validate password requirements
    function validatePasswordRequirements(password) {
        const requirements = {
            length: password.length >= 8,
            uppercase: /[A-Z]/.test(password),
            lowercase: /[a-z]/.test(password),
            number: /[0-9]/.test(password),
            special: /[^A-Za-z0-9]/.test(password)
        };

        Object.keys(requirements).forEach(req => {
            const element = document.getElementById(`req${req.charAt(0).toUpperCase() + req.slice(1)}`);
            if (element) {
                if (requirements[req]) {
                    element.classList.add('valid');
                } else {
                    element.classList.remove('valid');
                }
            }
        });

        return Object.values(requirements).every(req => req);
    }

    // Validate confirm password
    function validateConfirmPassword() {
        const confirmError = document.getElementById('confirmPasswordError');
        
        if (confirmPassword.value !== newPassword.value) {
            confirmError.textContent = 'Kata sandi tidak cocok';
            return false;
        } else {
            confirmError.textContent = '';
            return true;
        }
    }

    // Form validation
    function validateForm() {
        let isValid = true;
        
        // Clear previous errors
        clearErrors();

        // Validate current password
        if (!currentPassword.value.trim()) {
            showError('currentPassword', 'Kata sandi saat ini wajib diisi');
            isValid = false;
        }

        // Validate new password
        if (!newPassword.value.trim()) {
            showError('newPassword', 'Kata sandi baru wajib diisi');
            isValid = false;
        } else if (newPassword.value.length < 8) {
            showError('newPassword', 'Kata sandi minimal 8 karakter');
            isValid = false;
        } else if (!validatePasswordRequirements(newPassword.value)) {
            showError('newPassword', 'Kata sandi tidak memenuhi persyaratan');
            isValid = false;
        }

        // Validate confirm password
        if (!confirmPassword.value.trim()) {
            showError('confirmPassword', 'Konfirmasi kata sandi wajib diisi');
            isValid = false;
        } else if (!validateConfirmPassword()) {
            isValid = false;
        }

        // Check if new password is same as current
        if (currentPassword.value === newPassword.value && currentPassword.value.trim() !== '') {
            showError('newPassword', 'Kata sandi baru harus berbeda dari kata sandi saat ini');
            isValid = false;
        }

        return isValid;
    }

    // Show error message
    function showError(fieldName, message) {
        const errorElement = document.getElementById(fieldName + 'Error');
        if (errorElement) {
            errorElement.textContent = message;
        }
    }

    // Clear all errors
    function clearErrors() {
        const errorElements = document.querySelectorAll('.error-message');
        errorElements.forEach(element => {
            element.textContent = '';
        });
    }

    // Show notification
    function showNotification(message, type = 'success') {
        // Remove existing notification
        const existingNotification = document.querySelector('.security-notification');
        if (existingNotification) {
            existingNotification.remove();
        }

        // Create notification
        const notification = document.createElement('div');
        notification.className = `security-notification ${type}`;
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

    // Change password form submission
    changePasswordForm.addEventListener('submit', function(e) {
        e.preventDefault();

        if (!validateForm()) {
            showNotification('Terdapat kesalahan dalam form. Silakan periksa kembali.', 'error');
            return;
        }

        // Simulate password change process
        savePasswordBtn.disabled = true;
        savePasswordBtn.classList.add('loading');
        savePasswordBtn.textContent = 'Mengubah...';

        setTimeout(() => {
            // Reset form
            changePasswordForm.reset();
            clearErrors();
            checkPasswordStrength('');
            validatePasswordRequirements('');

            savePasswordBtn.disabled = false;
            savePasswordBtn.classList.remove('loading');
            savePasswordBtn.textContent = 'Ubah Kata Sandi';

            showNotification('Kata sandi berhasil diubah!');
        }, 2000);
    });

    // Enable 2FA
    enable2FABtn.addEventListener('click', function() {
        if (confirm('Anda akan mengaktifkan verifikasi 2 langkah. Pastikan Anda memiliki aplikasi autentikator seperti Google Authenticator.')) {
            enable2FABtn.disabled = true;
            enable2FABtn.textContent = 'Mengaktifkan...';

            setTimeout(() => {
                // Simulate 2FA setup completion
                const badge = document.querySelector('.section-badge.inactive');
                const button = document.getElementById('enable2FABtn');

                if (badge) {
                    badge.textContent = 'Aktif';
                    badge.classList.remove('inactive');
                }

                if (button) {
                    button.textContent = 'Nonaktifkan Verifikasi 2 Langkah';
                    button.disabled = false;
                }

                showNotification('Verifikasi 2 langkah berhasil diaktifkan!');
            }, 2000);
        }
    });

    // Logout from all other sessions
    logoutAllBtn.addEventListener('click', function() {
        if (confirm('Anda yakin ingin keluar dari semua sesi lain? Anda akan tetap login di perangkat ini.')) {
            logoutAllBtn.disabled = true;
            logoutAllBtn.textContent = 'Memproses...';

            setTimeout(() => {
                // Remove all sessions except current
                const sessions = document.querySelectorAll('.session-item:not(.current)');
                sessions.forEach(session => {
                    session.remove();
                });

                logoutAllBtn.disabled = false;
                logoutAllBtn.textContent = 'Keluar dari Semua Sesi Lain';

                showNotification('Berhasil keluar dari semua sesi lain.');
            }, 1500);
        }
    });

    // Logout from specific session
    document.addEventListener('click', function(e) {
        if (e.target.classList.contains('btn-logout-session')) {
            const sessionId = e.target.getAttribute('data-session');
            const sessionItem = e.target.closest('.session-item');

            if (sessionId === 'current') {
                showNotification('Tidak dapat keluar dari sesi saat ini.', 'error');
                return;
            }

            if (confirm('Keluar dari sesi ini?')) {
                e.target.disabled = true;
                e.target.textContent = 'Memproses...';

                setTimeout(() => {
                    sessionItem.remove();
                    showNotification('Berhasil keluar dari sesi.');
                }, 1000);
            }
        }
    });

    // Real-time validation
    currentPassword.addEventListener('blur', function() {
        if (!this.value.trim()) {
            showError('currentPassword', 'Kata sandi saat ini wajib diisi');
        } else {
            document.getElementById('currentPasswordError').textContent = '';
        }
    });

    newPassword.addEventListener('blur', function() {
        if (!this.value.trim()) {
            showError('newPassword', 'Kata sandi baru wajib diisi');
        } else if (this.value.length < 8) {
            showError('newPassword', 'Kata sandi minimal 8 karakter');
        } else {
            document.getElementById('newPasswordError').textContent = '';
        }
    });

    console.log('Ubah Keamanan page loaded successfully');
});
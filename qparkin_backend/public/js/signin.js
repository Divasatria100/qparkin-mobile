document.addEventListener('DOMContentLoaded', function() {
    // Elements
    const signinForm = document.getElementById('signinForm');
    const emailInput = document.getElementById('email');
    const passwordInput = document.getElementById('password');
    const passwordToggle = document.getElementById('passwordToggle');
    const submitBtn = document.getElementById('submitBtn');
    const emailError = document.getElementById('emailError');
    const passwordError = document.getElementById('passwordError');
    const loginForm = document.getElementById('loginForm');
    const successMessage = document.getElementById('successMessage');
    const notification = document.getElementById('notification');

    // Laravel will handle authentication via form submission
    // No dummy users needed - backend handles this

    // Password visibility toggle
    passwordToggle.addEventListener('click', function() {
        const isPassword = passwordInput.type === 'password';
        passwordInput.type = isPassword ? 'text' : 'password';
        passwordToggle.querySelector('.eye-icon').classList.toggle('show-password', !isPassword);
    });

    // Real-time validation
    emailInput.addEventListener('input', function() {
        validateEmail();
    });

    passwordInput.addEventListener('input', function() {
        validatePassword();
    });

    // Form submission - Let Laravel handle it naturally
    // Just add loading state for better UX
    if (signinForm) {
        signinForm.addEventListener('submit', function(e) {
            const isEmailValid = validateEmail();
            const isPasswordValid = validatePassword();
            
            if (isEmailValid && isPasswordValid) {
                submitBtn.classList.add('loading');
                // Form will submit naturally to Laravel backend
            } else {
                e.preventDefault();
                gentleFeedback();
                // Don't show notification, error messages are enough
            }
        });
    }

    // Gentle feedback for login card on error
    function gentleFeedback() {
        loginForm.classList.add('error-feedback');
        setTimeout(() => {
            loginForm.classList.remove('error-feedback');
        }, 600);
    }

    // Check for Laravel validation errors and show gentle feedback
    const alertError = document.querySelector('.alert-error');
    if (alertError) {
        gentleFeedback();
        // Auto-hide alert after 6 seconds with smooth fade
        setTimeout(() => {
            alertError.style.transition = 'opacity 0.4s ease-out, transform 0.4s ease-out';
            alertError.style.opacity = '0';
            alertError.style.transform = 'translateY(-8px)';
            setTimeout(() => {
                alertError.style.display = 'none';
            }, 400);
        }, 6000);
    }

    // Validation functions
    function validateEmail() {
        const value = emailInput.value.trim();
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        const isValid = emailRegex.test(value);
        
        if (value === '') {
            setFieldError(emailInput, emailError, false);
            return false;
        }
        
        setFieldError(emailInput, emailError, !isValid);
        return isValid;
    }

    function validatePassword() {
        const value = passwordInput.value;
        const isValid = value.length >= 6;
        
        if (value === '') {
            setFieldError(passwordInput, passwordError, false);
            return false;
        }
        
        setFieldError(passwordInput, passwordError, !isValid);
        return isValid;
    }

    function setFieldError(input, errorElement, showError) {
        const formGroup = input.closest('.form-group');
        
        if (showError) {
            formGroup.classList.add('error');
            errorElement.classList.add('show');
        } else {
            formGroup.classList.remove('error');
            errorElement.classList.remove('show');
        }
        
        // Add has-value class for floating label
        if (input.value.trim() !== '') {
            input.classList.add('has-value');
        } else {
            input.classList.remove('has-value');
        }
    }

    function showNotification(message, type) {
        if (!notification) {
            // Create notification element if it doesn't exist
            const notif = document.createElement('div');
            notif.id = 'notification';
            notif.className = `notification ${type}`;
            notif.textContent = message;
            document.body.appendChild(notif);
            
            setTimeout(() => {
                notif.classList.add('show');
            }, 10);
            
            setTimeout(() => {
                notif.classList.remove('show');
                setTimeout(() => notif.remove(), 300);
            }, 5000);
        } else {
            notification.textContent = message;
            notification.className = `notification ${type} show`;
            
            setTimeout(() => {
                notification.classList.remove('show');
            }, 5000);
        }
    }

    // Initialize floating labels for pre-filled values
    document.querySelectorAll('input').forEach(input => {
        if (input.value) {
            input.classList.add('has-value');
        }
    });
});

// Pastikan label tidak menutupi input
document.querySelectorAll('input').forEach(input => {
    input.addEventListener('focus', function() {
        this.classList.add('has-value');
    });
    
    input.addEventListener('blur', function() {
        if (this.value.trim() === '') {
            this.classList.remove('has-value');
        }
    });
    
    // Inisialisasi untuk nilai yang sudah ada
    if (input.value.trim() !== '') {
        input.classList.add('has-value');
    }
});
document.addEventListener('DOMContentLoaded', function() {
    // Elements
    const signinForm = document.getElementById('signinForm');
    const usernameInput = document.getElementById('username');
    const passwordInput = document.getElementById('password');
    const passwordToggle = document.getElementById('passwordToggle');
    const submitBtn = document.getElementById('submitBtn');
    const usernameError = document.getElementById('usernameError');
    const passwordError = document.getElementById('passwordError');
    const loginForm = document.getElementById('loginForm');
    const successMessage = document.getElementById('successMessage');
    const notification = document.getElementById('notification');

    // Password visibility toggle
    passwordToggle.addEventListener('click', function() {
        const isPassword = passwordInput.type === 'password';
        passwordInput.type = isPassword ? 'text' : 'password';
        passwordToggle.querySelector('.eye-icon').classList.toggle('show-password', !isPassword);
    });

    // Real-time validation
    usernameInput.addEventListener('input', function() {
        validateUsername();
    });

    passwordInput.addEventListener('input', function() {
        validatePassword();
    });

    // Form submission
    signinForm.addEventListener('submit', function(e) {
        e.preventDefault();
        
        const isUsernameValid = validateUsername();
        const isPasswordValid = validatePassword();
        
        if (isUsernameValid && isPasswordValid) {
            // Show loading state
            submitBtn.classList.add('loading');
            
            // Submit the form (actual form submission)
            this.submit();
        } else {
            showNotification('Please fix the errors before submitting', 'error');
        }
    });

    // Validation functions
    function validateUsername() {
        const value = usernameInput.value.trim();
        const isValid = value.length >= 3;
        
        if (value === '') {
            setFieldError(usernameInput, usernameError, false);
            return false;
        }
        
        setFieldError(usernameInput, usernameError, !isValid);
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
        notification.textContent = message;
        notification.className = `notification ${type} show`;
        
        setTimeout(() => {
            notification.classList.remove('show');
        }, 5000);
    }

    // Initialize floating labels for pre-filled values
    document.querySelectorAll('input').forEach(input => {
        if (input.value) {
            input.classList.add('has-value');
        }
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

    // Handle Laravel validation errors
    const urlParams = new URLSearchParams(window.location.search);
    const error = urlParams.get('error');
    if (error) {
        showNotification(error, 'error');
    }
});
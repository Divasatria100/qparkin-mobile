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

    // Data dummy untuk login
    const dummyUsers = [
        {
            username: 'qparkin',
            password: '123456',
            role: 'superadmin',
            redirectUrl: '../superadmin/dashboard.html'
        },
        {
            username: 'panbil',
            password: '123456',
            role: 'admin',
            redirectUrl: '../admin/dashboard.html'
        }
    ];

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
            
            // Simulate API call dengan validasi data dummy
            setTimeout(() => {
                submitBtn.classList.remove('loading');
                
                const username = usernameInput.value.trim();
                const password = passwordInput.value;
                
                // Cari user yang sesuai
                const user = dummyUsers.find(u => u.username === username && u.password === password);
                
                if (user) {
                    // Login berhasil
                    showNotification('Login successful!', 'success');
                    
                    // Show success message
                    loginForm.style.display = 'none';
                    successMessage.classList.add('show');
                    
                    // Redirect ke halaman yang sesuai setelah delay
                    setTimeout(() => {
                        window.location.href = user.redirectUrl;
                    }, 2000);
                    
                    // Simpan data login ke localStorage (opsional)
                    localStorage.setItem('currentUser', JSON.stringify({
                        username: user.username,
                        role: user.role,
                        loginTime: new Date().toISOString()
                    }));
                    
                } else {
                    // Login gagal
                    showNotification('Invalid username or password', 'error');
                    
                    // Reset form
                    usernameInput.value = '';
                    passwordInput.value = '';
                    usernameInput.classList.remove('has-value');
                    passwordInput.classList.remove('has-value');
                    
                    // Focus ke username input
                    usernameInput.focus();
                }
            }, 1500);
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
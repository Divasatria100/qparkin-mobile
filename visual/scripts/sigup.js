document.addEventListener('DOMContentLoaded', function() {
    const signupForm = document.getElementById('signupForm');
    const submitBtn = document.getElementById('submitBtn');
    const btnText = submitBtn.querySelector('.btn-text');
    const btnLoader = submitBtn.querySelector('.btn-loader');
    const successMessage = document.getElementById('successMessage');
    const notification = document.getElementById('notification');
    const passwordToggle = document.getElementById('passwordToggle');
    const passwordField = document.getElementById('password');
    const confirmPasswordField = document.getElementById('confirmPassword');

    // Password toggle functionality
    passwordToggle.addEventListener('click', function() {
        const type = passwordField.getAttribute('type') === 'password' ? 'text' : 'password';
        passwordField.setAttribute('type', type);
        this.classList.toggle('active');
    });

    // Form submission
    signupForm.addEventListener('submit', function(e) {
        e.preventDefault();
        
        // Basic validation
        const fullName = document.getElementById('fullName').value.trim();
        const email = document.getElementById('email').value.trim();
        const username = document.getElementById('username').value.trim();
        const password = document.getElementById('password').value;
        const confirmPassword = document.getElementById('confirmPassword').value;
        const role = document.getElementById('role').value;
        const reason = document.getElementById('reason').value.trim();

        let isValid = true;

        // Reset error messages
        document.querySelectorAll('.error-message').forEach(el => {
            el.style.display = 'none';
        });

        // Validate full name
        if (fullName.length < 2) {
            document.getElementById('fullNameError').style.display = 'block';
            isValid = false;
        }

        // Validate email
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            document.getElementById('emailError').style.display = 'block';
            isValid = false;
        }

        // Validate username
        if (username.length < 3) {
            document.getElementById('usernameError').style.display = 'block';
            isValid = false;
        }

        // Validate password
        if (password.length < 6) {
            document.getElementById('passwordError').style.display = 'block';
            isValid = false;
        }

        // Validate password confirmation
        if (password !== confirmPassword) {
            document.getElementById('confirmPasswordError').style.display = 'block';
            isValid = false;
        }

        // Validate role
        if (!role) {
            document.getElementById('roleError').style.display = 'block';
            isValid = false;
        }

        // Validate reason
        if (reason.length < 10) {
            document.getElementById('reasonError').style.display = 'block';
            isValid = false;
        }

        if (!isValid) return;

        // Show loading state
        btnText.textContent = 'Submitting...';
        btnLoader.style.display = 'inline-block';
        submitBtn.disabled = true;

        // Simulate API call to submit request to superadmin
        setTimeout(() => {
            // Hide form and show success message
            document.getElementById('signupForm').style.display = 'none';
            successMessage.style.display = 'block';
            
            // In a real application, you would send the data to your backend here
            console.log('Account request submitted:', {
                fullName,
                email,
                username,
                role,
                reason
            });
            
            // Show notification
            showNotification('Request submitted successfully!', 'success');
        }, 1500);
    });

    // Function to show notification
    function showNotification(message, type) {
        notification.textContent = message;
        notification.className = 'notification ' + type;
        notification.style.display = 'block';
        
        setTimeout(() => {
            notification.style.display = 'none';
        }, 5000);
    }
});
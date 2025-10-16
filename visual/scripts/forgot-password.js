document.addEventListener('DOMContentLoaded', function() {
    // Elements
    const forgotPasswordForm = document.getElementById('forgotPasswordForm');
    const submitBtn = document.getElementById('submitBtn');
    const btnText = submitBtn.querySelector('.btn-text');
    const btnLoader = submitBtn.querySelector('.btn-loader');
    const notification = document.getElementById('notification');
    const emailInput = document.getElementById('email');
    const emailError = document.getElementById('emailError');

    // Real-time validation
    emailInput.addEventListener('input', function() {
        validateEmail();
    });

    emailInput.addEventListener('blur', function() {
        validateEmail();
    });

    // Email validation function
    function validateEmail() {
        const email = emailInput.value.trim();
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        
        if (email === '') {
            hideError(emailInput, emailError);
            return false;
        }
        
        if (!emailRegex.test(email)) {
            showError(emailInput, emailError, 'Please enter a valid email address');
            return false;
        }
        
        hideError(emailInput, emailError);
        return true;
    }

    // Error handling functions
    function showError(input, errorElement, message) {
        errorElement.textContent = message;
        errorElement.classList.add('show');
        input.parentElement.parentElement.classList.add('error');
    }

    function hideError(input, errorElement) {
        errorElement.classList.remove('show');
        input.parentElement.parentElement.classList.remove('error');
    }

    // Show notification function
    function showNotification(message, type) {
        notification.textContent = message;
        notification.className = `notification ${type} show`;
        
        setTimeout(() => {
            notification.classList.remove('show');
        }, 5000);
    }

    // Form submission
    forgotPasswordForm.addEventListener('submit', function(e) {
        e.preventDefault();
        
        // Validate form
        const isEmailValid = validateEmail();
        
        if (!isEmailValid) {
            showNotification('Please fix the errors before submitting', 'error');
            return;
        }

        // Show loading state
        submitBtn.classList.add('loading');
        submitBtn.querySelector('.btn-text').textContent = 'Mengirim...';
        submitBtn.querySelector('.btn-loader').classList.remove('hidden');
        submitBtn.disabled = true;

        const email = emailInput.value.trim();

        // Simulate API call to send reset instructions
        setTimeout(() => {
            // In a real application, you would send the email to your backend here
            console.log('Password reset requested for:', email);
            
            // Redirect to success page
            window.location.href = 'success-forgot.html';
            
            // Reset loading state (though redirect will happen)
            submitBtn.classList.remove('loading');
            submitBtn.disabled = false;
        }, 1500);
    });

    // Add input focus effects
    const inputs = document.querySelectorAll('input');
    inputs.forEach(input => {
        input.addEventListener('focus', function() {
            this.parentElement.classList.add('focused');
        });
        
        input.addEventListener('blur', function() {
            if (this.value === '') {
                this.parentElement.classList.remove('focused');
            }
        });
        
        // Check if input has value on page load
        if (input.value !== '') {
            input.parentElement.classList.add('focused');
        }
    });
});
document.addEventListener('DOMContentLoaded', function() {
    // Elements
    const notification = document.getElementById('notification');
    const successIcon = document.querySelector('.success-icon-large');

    // Add pulsing animation to success icon
    setInterval(() => {
        successIcon.style.transform = 'scale(1.05)';
        setTimeout(() => {
            successIcon.style.transform = 'scale(1)';
        }, 500);
    }, 1000);

    // Add entry animation to detail items
    const detailItems = document.querySelectorAll('.detail-item');
    detailItems.forEach((item, index) => {
        item.style.opacity = '0';
        item.style.transform = 'translateY(20px)';
        
        setTimeout(() => {
            item.style.transition = 'all 0.5s ease';
            item.style.opacity = '1';
            item.style.transform = 'translateY(0)';
        }, 300 + (index * 100));
    });

    // Check if there's a success message in URL parameters
    const urlParams = new URLSearchParams(window.location.search);
    const successMessage = urlParams.get('success');
    
    if (successMessage) {
        showNotification(decodeURIComponent(successMessage), 'success');
    }

    // Show notification function
    function showNotification(message, type) {
        notification.textContent = message;
        notification.className = `notification ${type} show`;
        
        setTimeout(() => {
            notification.classList.remove('show');
        }, 5000);
    }
});
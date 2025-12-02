document.addEventListener('DOMContentLoaded', function() {
    // Elements
    const notification = document.getElementById('notification');
    const errorIcon = document.querySelector('.error-icon-large');

    // Add pulsing animation to error icon
    setInterval(() => {
        errorIcon.style.transform = 'scale(1.05)';
        setTimeout(() => {
            errorIcon.style.transform = 'scale(1)';
        }, 500);
    }, 1500);

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

    // Add error notification animation
    function showErrorNotification(message) {
        notification.textContent = message;
        notification.className = 'notification error show';
        
        setTimeout(() => {
            notification.className = 'notification error';
        }, 5000);
    }

    // Check if there's an error message in URL parameters
    const urlParams = new URLSearchParams(window.location.search);
    const errorMessage = urlParams.get('error');
    
    if (errorMessage) {
        showErrorNotification(decodeURIComponent(errorMessage));
    }
});
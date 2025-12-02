// Global variables
let map;
let marker;
let autocomplete;

// Initialize Google Maps
function initMap() {
    console.log('Initializing Google Maps...');
    
    try {
        // Create map with satellite view
        map = new google.maps.Map(document.getElementById('map'), {
            center: { lat: -6.2088, lng: 106.8456 }, // Jakarta
            zoom: 12,
            mapTypeId: google.maps.MapTypeId.SATELLITE,
            styles: [
                {
                    "featureType": "all",
                    "elementType": "labels",
                    "stylers": [{ "visibility": "on" }]
                }
            ]
        });

        // Create red marker
        marker = new google.maps.Marker({
            map: map,
            draggable: true,
            icon: {
                url: 'https://maps.google.com/mapfiles/ms/icons/red-dot.png',
                scaledSize: new google.maps.Size(32, 32),
                anchor: new google.maps.Point(16, 32)
            }
        });

        // Initialize autocomplete
        const locationInput = document.getElementById('location');
        autocomplete = new google.maps.places.Autocomplete(
            locationInput,
            {
                types: ['establishment'],
                componentRestrictions: { country: 'id' }
            }
        );

        // Bind autocomplete to the search button
        document.getElementById('locationSearch').addEventListener('click', function() {
            locationInput.focus();
            // Trigger places dropdown
            const event = new Event('focus', { bubbles: true });
            locationInput.dispatchEvent(event);
        });

        // When place is selected
        autocomplete.addListener('place_changed', function() {
            const place = autocomplete.getPlace();
            if (!place.geometry) {
                console.log("No details available for: '" + place.name + "'");
                return;
            }

            // Update map
            map.setCenter(place.geometry.location);
            map.setZoom(16);
            marker.setPosition(place.geometry.location);
            marker.setVisible(true);

            // Update location input with formatted address
            locationInput.value = place.formatted_address || place.name;
            
            // Add class to trigger label animation
            locationInput.classList.add('has-value');

            // Hide overlay
            document.querySelector('.map-overlay').style.display = 'none';
            hideError('locationError');
            
            // Show notification
            showNotification('Lokasi berhasil dipilih', 'success');
        });

        // When marker is dragged
        marker.addListener('dragend', function() {
            updateLocationFromMarker(marker.getPosition());
        });

        // When map is clicked
        map.addListener('click', function(event) {
            marker.setPosition(event.latLng);
            marker.setVisible(true);
            updateLocationFromMarker(event.latLng);
            document.querySelector('.map-overlay').style.display = 'none';
            hideError('locationError');
        });

        // Handle manual input changes
        locationInput.addEventListener('input', function() {
            if (this.value.trim().length > 0) {
                this.classList.add('has-value');
            } else {
                this.classList.remove('has-value');
            }
        });

        console.log('Google Maps initialized successfully');

    } catch (error) {
        console.error('Error initializing Google Maps:', error);
        // Fallback: Show manual location input
        document.getElementById('mapContainer').innerHTML = `
            <div style="padding: 20px; text-align: center; color: #666;">
                <i class="fas fa-map-marker-alt" style="font-size: 2rem; margin-bottom: 10px;"></i>
                <p>Maps tidak dapat dimuat. Silakan ketik alamat lengkap mall Anda.</p>
            </div>
        `;
    }
}

// Update location from marker position
function updateLocationFromMarker(position) {
    const geocoder = new google.maps.Geocoder();
    const locationInput = document.getElementById('location');
    
    geocoder.geocode({ location: position }, (results, status) => {
        if (status === 'OK' && results[0]) {
            locationInput.value = results[0].formatted_address;
            locationInput.classList.add('has-value');
            showNotification('Lokasi berhasil dipilih dari peta', 'success');
        }
    });
}

// Enhanced Photo upload functionality
function setupPhotoUpload() {
    const mallPhotoInput = document.getElementById('mallPhoto');
    const uploadBtn = document.getElementById('uploadBtn');
    const previewArea = document.getElementById('previewArea');
    const previewImage = document.getElementById('previewImage');
    const removePhoto = document.getElementById('removePhoto');

    // Handle file selection via button
    uploadBtn.addEventListener('click', function() {
        mallPhotoInput.click();
    });

    // Handle file selection
    mallPhotoInput.addEventListener('change', function(e) {
        if (e.target.files.length > 0) {
            handleImageUpload(e.target.files[0]);
        }
    });

    // Remove photo
    removePhoto.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        resetPhotoUpload();
    });

    // Drag and drop functionality
    const uploadContainer = document.querySelector('.photo-upload-container');
    
    uploadContainer.addEventListener('dragover', function(e) {
        e.preventDefault();
        uploadBtn.style.background = '#e2e8f0';
        uploadBtn.style.borderColor = '#6366f1';
    });

    uploadContainer.addEventListener('dragleave', function(e) {
        e.preventDefault();
        uploadBtn.style.background = '#f8fafc';
        uploadBtn.style.borderColor = '#cbd5e1';
    });

    uploadContainer.addEventListener('drop', function(e) {
        e.preventDefault();
        uploadBtn.style.background = '#f8fafc';
        uploadBtn.style.borderColor = '#cbd5e1';
        
        if (e.dataTransfer.files.length > 0) {
            handleImageUpload(e.dataTransfer.files[0]);
        }
    });
}

// Handle image upload
function handleImageUpload(file) {
    const previewImage = document.getElementById('previewImage');
    const previewArea = document.getElementById('previewArea');
    const uploadBtn = document.getElementById('uploadBtn');
    
    if (!file.type.startsWith('image/')) {
        showNotification('Harap pilih file gambar (JPG, PNG, etc.)', 'error');
        return;
    }

    // Check file size (max 2MB)
    if (file.size > 2 * 1024 * 1024) {
        showNotification('Ukuran file terlalu besar. Maksimal 2MB.', 'error');
        return;
    }

    const reader = new FileReader();
    reader.onload = function(e) {
        previewImage.src = e.target.result;
        previewArea.classList.remove('hidden');
        uploadBtn.style.display = 'none';
        hideError('mallPhotoError');
        showNotification('Foto berhasil diupload', 'success');
    };
    reader.onerror = function() {
        showNotification('Error membaca file', 'error');
    };
    reader.readAsDataURL(file);
}

// Reset photo upload
function resetPhotoUpload() {
    const mallPhotoInput = document.getElementById('mallPhoto');
    const previewArea = document.getElementById('previewArea');
    const uploadBtn = document.getElementById('uploadBtn');
    
    mallPhotoInput.value = '';
    previewArea.classList.add('hidden');
    uploadBtn.style.display = 'flex';
    showNotification('Foto dihapus', 'success');
}

// Form validation helpers
function showError(errorId) {
    const errorElement = document.getElementById(errorId);
    errorElement.classList.add('show');
    errorElement.parentElement.classList.add('error');
}

function hideError(errorId) {
    const errorElement = document.getElementById(errorId);
    errorElement.classList.remove('show');
    errorElement.parentElement.classList.remove('error');
}

// Notification function
function showNotification(message, type) {
    const notification = document.getElementById('notification');
    notification.textContent = message;
    notification.className = `notification ${type} show`;
    
    setTimeout(() => {
        notification.classList.remove('show');
    }, 4000);
}

// Error handling untuk Google Maps
window.gm_authFailure = function() {
    console.error('Google Maps authentication failed');
    showNotification('Maps tidak dapat dimuat. Silakan ketik alamat manual.', 'error');
};

// DOM Content Loaded
document.addEventListener('DOMContentLoaded', function() {
    // Elements
    const signupForm = document.getElementById('signupForm');
    const signupCard = document.getElementById('signupCard');
    const successMessage = document.getElementById('successMessage');
    const submitBtn = document.getElementById('submitBtn');
    
    // Password toggles
    const passwordToggle = document.getElementById('passwordToggle');
    const confirmPasswordToggle = document.getElementById('confirmPasswordToggle');
    const passwordField = document.getElementById('password');
    const confirmPasswordField = document.getElementById('confirmPassword');
    
    // Initialize photo upload
    setupPhotoUpload();

    // Enhanced input label handling
    document.querySelectorAll('input').forEach(input => {
        // Check initial values
        if (input.value) {
            input.classList.add('has-value');
        }
        
        // Handle input events
        input.addEventListener('input', function() {
            if (this.value) {
                this.classList.add('has-value');
            } else {
                this.classList.remove('has-value');
            }
        });
        
        // Handle focus events
        input.addEventListener('focus', function() {
            this.parentElement.classList.add('focused');
        });
        
        input.addEventListener('blur', function() {
            this.parentElement.classList.remove('focused');
        });
    });

    // Password toggle functionality
    passwordToggle.addEventListener('click', function() {
        const type = passwordField.getAttribute('type') === 'password' ? 'text' : 'password';
        passwordField.setAttribute('type', type);
        this.innerHTML = type === 'password' ? '<i class="fas fa-eye"></i>' : '<i class="fas fa-eye-slash"></i>';
    });
    
    confirmPasswordToggle.addEventListener('click', function() {
        const type = confirmPasswordField.getAttribute('type') === 'password' ? 'text' : 'password';
        confirmPasswordField.setAttribute('type', type);
        this.innerHTML = type === 'password' ? '<i class="fas fa-eye"></i>' : '<i class="fas fa-eye-slash"></i>';
    });

    // Form submission
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
        
        // Simulate API call and redirect after 2 seconds
        setTimeout(() => {
            // Log data (dalam real app, kirim ke backend)
            console.log('Account request submitted:', {
                name,
                email,
                mallName,
                location,
                mallPhoto: mallPhoto.name,
                coordinates: marker ? marker.getPosition().toJSON() : null
            });
            
            // Redirect to success page
            window.location.href = 'success-signup.html';
        }, 2000);
    });
});
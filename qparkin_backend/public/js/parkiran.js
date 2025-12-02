// Parkiran JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Sample data (in real app, this would come from API)
    const parkiranData = {
        'parkiran_mawar': {
            name: 'Parkiran Mawar',
            status: 'active',
            lantai: 5,
            totalSlot: 250,
            tersedia: 45,
            terisi: 205,
            lantaiDetail: [
                { lantai: 1, total: 50, tersedia: 10 },
                { lantai: 2, total: 50, tersedia: 8 },
                { lantai: 3, total: 50, tersedia: 12 },
                { lantai: 4, total: 50, tersedia: 9 },
                { lantai: 5, total: 50, tersedia: 6 }
            ]
        },
        'parkiran_melati': {
            name: 'Parkiran Melati',
            status: 'active',
            lantai: 3,
            totalSlot: 150,
            tersedia: 25,
            terisi: 125,
            lantaiDetail: [
                { lantai: 1, total: 50, tersedia: 5 },
                { lantai: 2, total: 50, tersedia: 10 },
                { lantai: 3, total: 50, tersedia: 10 }
            ]
        },
        'parkiran_anggrek': {
            name: 'Parkiran Anggrek',
            status: 'maintenance',
            lantai: 4,
            totalSlot: 200,
            tersedia: 0,
            terisi: 0,
            lantaiDetail: [
                { lantai: 1, total: 50, tersedia: 0 },
                { lantai: 2, total: 50, tersedia: 0 },
                { lantai: 3, total: 50, tersedia: 0 },
                { lantai: 4, total: 50, tersedia: 0 }
            ]
        }
    };

    // Initialize parkiran cards with real data
    function initializeParkiranCards() {
        // In real app, this would fetch data from API and render cards dynamically
        console.log('Parkiran data loaded:', parkiranData);
        
        // Update dynamic data if needed
        updateParkiranStats();
    }

    // Update parkiran statistics (if needed for real-time data)
    function updateParkiranStats() {
        // In real app, this would fetch real-time data from API
        console.log('Updating parkiran statistics...');
    }

    // Global functions for any remaining functionality
    window.lihatDetail = function(parkiranId) {
        // Redirect to detail page with ID
        window.location.href = `detail-parkiran.html?id=${parkiranId}`;
    };

    window.editParkiran = function(parkiranId) {
        // Redirect to edit page with ID
        window.location.href = `edit-parkiran.html?id=${parkiranId}`;
    };

    // Initialize
    initializeParkiranCards();
    
    console.log('Parkiran management page loaded successfully');
});
// Admin Tarif JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Sample data (in real app, this would come from API)
    const tarifData = {
        'roda_dua': {
            satuJamPertama: 5000,
            tarifPerJam: 3000
        },
        'roda_empat': {
            satuJamPertama: 10000,
            tarifPerJam: 7000
        },
        'roda_enam': {
            satuJamPertama: 15000,
            tarifPerJam: 10000
        },
        'roda_lebih': {
            satuJamPertama: 25000,
            tarifPerJam: 18000
        }
    };
    
    // Format currency
    function formatCurrency(amount) {
        return new Intl.NumberFormat('id-ID', {
            style: 'currency',
            currency: 'IDR',
            minimumFractionDigits: 0
        }).format(amount);
    }
    
    // Calculate total cost
    function calculateTotalCost(jamPertama, perJam, hours) {
        if (hours <= 1) return jamPertama;
        return jamPertama + (hours - 1) * perJam;
    }
    
    // Update tarif card
    function updateTarifCard(type, data) {
        const jamPertama = data.satuJamPertama;
        const perJam = data.tarifPerJam;
        
        const elementPertama = document.getElementById(`${type}Pertama`);
        const elementPerJam = document.getElementById(`${type}PerJam`);
        const elementTotal = document.getElementById(`${type}Total`);
        
        if (elementPertama) elementPertama.textContent = formatCurrency(jamPertama);
        if (elementPerJam) elementPerJam.textContent = formatCurrency(perJam);
        if (elementTotal) elementTotal.textContent = formatCurrency(calculateTotalCost(jamPertama, perJam, 3));
    }
    
    // Load tarif data
    function loadTarifData() {
        // Update cards with current data
        updateTarifCard('rodaDua', tarifData.roda_dua);
        updateTarifCard('rodaEmpat', tarifData.roda_empat);
        updateTarifCard('rodaEnam', tarifData.roda_enam);
        updateTarifCard('rodaLebih', tarifData.roda_lebih);
    }
    
    // Initialize
    loadTarifData();
    
    console.log('Tarif management page loaded successfully');
});
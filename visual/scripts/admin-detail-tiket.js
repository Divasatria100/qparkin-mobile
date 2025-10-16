// Admin Detail Tiket JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Get transaction ID from URL
    const urlParams = new URLSearchParams(window.location.search);
    const transactionId = urlParams.get('id') || 'TRX001245';
    
    // Sample data (in real app, this would come from API)
    const tiketData = {
        'TRX001245': {
            id: 'TRX001245',
            plat: 'B 1234 ABC',
            jenisKendaraan: 'Roda 4',
            jenisPengguna: 'umum',
            status: 'sedang_parkir',
            lokasiParkir: 'A-15',
            zonaParkir: 'Zona A',
            tanggalMasuk: '2025-03-15',
            jamMasuk: '09:15:23',
            tanggalKeluar: null,
            jamKeluar: null,
            durasiParkir: null,
            estimasiBiaya: 15000,
            statusPembayaran: 'unpaid',
            metodePembayaran: null,
            totalBiaya: 15000,
            waktuPembayaran: null,
            referensiPembayaran: null,
            diskon: 0,
            riwayat: [
                {
                    title: 'Kendaraan Masuk',
                    time: '15 Mar 2025, 09:15:23',
                    description: 'Kendaraan masuk melalui gerbang timur'
                },
                {
                    title: 'Parkir di Zona A',
                    time: '15 Mar 2025, 09:17:45',
                    description: 'Parkir di spot A-15, Zona A'
                }
            ]
        },
        'TRX001244': {
            id: 'TRX001244',
            plat: 'B 5678 DEF',
            jenisKendaraan: 'Roda 2',
            jenisPengguna: 'booking',
            status: 'selesai',
            lokasiParkir: 'B-08',
            zonaParkir: 'Zona B',
            tanggalMasuk: '2025-03-15',
            jamMasuk: '10:30:15',
            tanggalKeluar: '2025-03-15',
            jamKeluar: '11:45:30',
            durasiParkir: '1 jam 15 menit',
            estimasiBiaya: 5000,
            statusPembayaran: 'paid',
            metodePembayaran: 'qris',
            totalBiaya: 5000,
            waktuPembayaran: '15 Mar 2025, 11:46:12',
            referensiPembayaran: 'QRIS-001244',
            diskon: 0,
            riwayat: [
                {
                    title: 'Kendaraan Masuk',
                    time: '15 Mar 2025, 10:30:15',
                    description: 'Kendaraan masuk melalui gerbang utara'
                },
                {
                    title: 'Parkir di Zona B',
                    time: '15 Mar 2025, 10:32:20',
                    description: 'Parkir di spot B-08, Zona B'
                },
                {
                    title: 'Kendaraan Keluar',
                    time: '15 Mar 2025, 11:45:30',
                    description: 'Kendaraan keluar melalui gerbang utara'
                },
                {
                    title: 'Pembayaran Berhasil',
                    time: '15 Mar 2025, 11:46:12',
                    description: 'Pembayaran via QRIS berhasil'
                }
            ]
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
    
    // Format date
    function formatDate(dateString) {
        if (!dateString) return '-';
        const date = new Date(dateString);
        return date.toLocaleDateString('id-ID', {
            day: 'numeric',
            month: 'long',
            year: 'numeric'
        });
    }
    
    // Load data
    function loadTiketData() {
        const data = tiketData[transactionId] || tiketData['TRX001245'];
        
        // Update page title
        document.title = `Detail ${data.id} - QPARKIN`;
        
        // Update breadcrumb
        document.querySelector('.breadcrumb span:last-child').textContent = `Detail ${data.id}`;
        
        // Update main information
        document.getElementById('transactionId').textContent = data.id;
        document.getElementById('platNumber').textContent = data.plat;
        document.getElementById('vehicleType').textContent = data.jenisKendaraan;
        document.getElementById('userType').textContent = data.jenisPengguna === 'umum' ? 'Umum' : 'Booking';
        document.getElementById('userType').className = `badge ${data.jenisPengguna}`;
        document.getElementById('parkingLocation').textContent = data.lokasiParkir;
        document.getElementById('parkingZone').textContent = data.zonaParkir;
        
        // Update status
        const mainStatus = document.getElementById('mainStatus');
        mainStatus.textContent = data.status === 'sedang_parkir' ? 'Sedang Parkir' : 'Selesai';
        mainStatus.className = `status-badge ${data.status === 'sedang_parkir' ? 'sedang-parkir' : 'selesai'}`;
        
        // Update parking time
        document.getElementById('entryDate').textContent = formatDate(data.tanggalMasuk);
        document.getElementById('entryTime').textContent = data.jamMasuk;
        document.getElementById('exitDate').textContent = data.tanggalKeluar ? formatDate(data.tanggalKeluar) : '-';
        document.getElementById('exitTime').textContent = data.jamKeluar || '-';
        document.getElementById('parkingDuration').textContent = data.durasiParkir || '-';
        document.getElementById('estimatedCost').textContent = formatCurrency(data.estimasiBiaya);
        
        // Update payment information
        const paymentStatus = document.getElementById('paymentStatus');
        paymentStatus.textContent = data.statusPembayaran === 'paid' ? 'Lunas' : 
                                  data.statusPembayaran === 'pending' ? 'Menunggu' : 'Belum Bayar';
        paymentStatus.className = `payment-status ${data.statusPembayaran}`;
        
        document.getElementById('paymentMethod').textContent = data.metodePembayaran ? 
            data.metodePembayaran.toUpperCase() : '-';
        document.getElementById('totalCost').textContent = formatCurrency(data.totalBiaya);
        document.getElementById('paymentTime').textContent = data.waktuPembayaran || '-';
        document.getElementById('paymentReference').textContent = data.referensiPembayaran || '-';
        document.getElementById('discount').textContent = formatCurrency(data.diskon);
        
        // Update QR code info
        document.getElementById('qrId').textContent = data.id;
        
        // Update activity timeline
        updateActivityTimeline(data.riwayat);
        
        // Generate QR code
        generateQRCode(data.id);
    }
    
    // Update activity timeline
    function updateActivityTimeline(activities) {
        const timeline = document.querySelector('.activity-timeline');
        
        // Clear existing items except the future item
        const existingItems = timeline.querySelectorAll('.timeline-item:not(.future)');
        existingItems.forEach(item => item.remove());
        
        // Add activities
        activities.forEach(activity => {
            const timelineItem = document.createElement('div');
            timelineItem.className = 'timeline-item';
            timelineItem.innerHTML = `
                <div class="timeline-marker"></div>
                <div class="timeline-content">
                    <div class="timeline-title">${activity.title}</div>
                    <div class="timeline-time">${activity.time}</div>
                    <div class="timeline-description">${activity.description}</div>
                </div>
            `;
            timeline.insertBefore(timelineItem, timeline.querySelector('.timeline-item.future'));
        });
    }
    
    // Generate QR code (simulated)
    // function generateQRCode(id) {
    //     const qrCode = document.getElementById('qrCode');
    //     // In real app, this would generate actual QR code
    //     // For demo, we'll create a simple representation
    //     qrCode.innerHTML = `
    //         <div style="text-align: center; padding: 20px;">
    //             <div style="font-size: 2rem; margin-bottom: 10px;">QR</div>
    //             <div style="font-weight: bold; color: #6366f1;">${id}</div>
    //             <div style="font-size: 0.875rem; color: #64748b; margin-top: 8px;">QPARKIN PARKING</div>
    //         </div>
    //     `;
    // }
    
    // Print detail
    window.printDetail = function() {
        window.print();
    };
    
    // Go back
    window.goBack = function() {
        window.history.back();
    };
    
    // Download QR code
    window.downloadQRCode = function() {
        // In real app, this would download actual QR code image
        alert('Fitur download QR code akan datang!');
    };
    
    // Initialize
    loadTiketData();
    
    console.log('Detail kendaraan page loaded for ID:', transactionId);
});
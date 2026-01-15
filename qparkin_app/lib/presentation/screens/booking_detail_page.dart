import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/booking_model.dart';
import '../../config/design_constants.dart';

/// Halaman Detail Booking
/// 
/// Menampilkan informasi lengkap booking setelah pembayaran berhasil
/// Termasuk informasi mall, slot, waktu, biaya, dan QR code
class BookingDetailPage extends StatelessWidget {
  final BookingModel booking;

  const BookingDetailPage({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Detail Booking'),
        backgroundColor: DesignConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Success Header
            _buildSuccessHeader(),
            
            const SizedBox(height: 16),
            
            // Booking Information
            _buildBookingInfo(),
            
            const SizedBox(height: 16),
            
            // Mall & Parking Information
            _buildParkingInfo(),
            
            const SizedBox(height: 16),
            
            // Time Information
            _buildTimeInfo(),
            
            const SizedBox(height: 16),
            
            // Cost Information
            _buildCostInfo(),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            _buildActionButtons(context),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DesignConstants.primaryColor,
            DesignConstants.primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 64,
              color: DesignConstants.successColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Pembayaran Berhasil!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Booking Anda telah dikonfirmasi',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingInfo() {
    return _buildCard(
      title: 'Informasi Booking',
      children: [
        _buildInfoRow(
          icon: Icons.confirmation_number,
          label: 'ID Booking',
          value: '#${booking.idBooking}',
        ),
        const Divider(height: 24),
        _buildInfoRow(
          icon: Icons.info_outline,
          label: 'Status',
          value: _getStatusText(booking.status),
          valueColor: _getStatusColor(booking.status),
        ),
      ],
    );
  }

  Widget _buildParkingInfo() {
    return _buildCard(
      title: 'Lokasi Parkir',
      children: [
        _buildInfoRow(
          icon: Icons.store,
          label: 'Mall',
          value: booking.namaMall ?? '-',
        ),
        const Divider(height: 24),
        _buildInfoRow(
          icon: Icons.local_parking,
          label: 'Slot Parkir',
          value: booking.kodeSlot ?? 'Auto-assign',
        ),
        if (booking.floorName != null) ...[
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.layers,
            label: 'Lantai',
            value: booking.floorName!,
          ),
        ],
        if (booking.jenisKendaraan != null) ...[
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.directions_car,
            label: 'Jenis Kendaraan',
            value: booking.jenisKendaraan!,
          ),
        ],
      ],
    );
  }

  Widget _buildTimeInfo() {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    
    return _buildCard(
      title: 'Waktu Booking',
      children: [
        _buildInfoRow(
          icon: Icons.access_time,
          label: 'Waktu Mulai',
          value: dateFormat.format(booking.waktuMulai),
        ),
        const Divider(height: 24),
        _buildInfoRow(
          icon: Icons.timer,
          label: 'Durasi',
          value: '${booking.durasiBooking} jam',
        ),
        const Divider(height: 24),
        _buildInfoRow(
          icon: Icons.event_available,
          label: 'Waktu Selesai',
          value: dateFormat.format(booking.waktuSelesai),
        ),
      ],
    );
  }

  Widget _buildCostInfo() {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return _buildCard(
      title: 'Rincian Biaya',
      children: [
        _buildInfoRow(
          icon: Icons.payments,
          label: 'Total Biaya',
          value: currencyFormat.format(booking.biayaEstimasi),
          valueStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: DesignConstants.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DesignConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    TextStyle? valueStyle,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: DesignConstants.primaryColor.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: DesignConstants.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: valueStyle ?? TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? DesignConstants.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // View Active Parking Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/activity',
                  arguments: {'initialTab': 0},
                );
              },
              icon: const Icon(Icons.local_parking),
              label: const Text(
                'Lihat Parkir Aktif',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignConstants.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignConstants.cardBorderRadius),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Back to Home Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              icon: const Icon(Icons.home),
              label: const Text(
                'Kembali ke Beranda',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: DesignConstants.primaryColor,
                side: const BorderSide(
                  color: DesignConstants.primaryColor,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignConstants.cardBorderRadius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'aktif':
        return 'Aktif';
      case 'selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      case 'pending_payment':
        return 'Menunggu Pembayaran';
      default:
        return status ?? '-';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'aktif':
        return DesignConstants.successColor;
      case 'selesai':
        return DesignConstants.textSecondary;
      case 'dibatalkan':
        return DesignConstants.errorColor;
      case 'pending_payment':
        return DesignConstants.warningColor;
      default:
        return DesignConstants.textPrimary;
    }
  }
}

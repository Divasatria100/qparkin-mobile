import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../config/design_constants.dart';
import '../../logic/providers/active_parking_provider.dart';
import '../../data/services/auth_service.dart';

/// Halaman Simulasi Scan Gate
/// 
/// Menampilkan QR code booking aktif dan tombol simulasi masuk parkiran
/// Menggantikan fitur IoT scanner dengan simulasi manual
class GateSimulationPage extends StatefulWidget {
  const GateSimulationPage({super.key});

  @override
  State<GateSimulationPage> createState() => _GateSimulationPageState();
}

class _GateSimulationPageState extends State<GateSimulationPage> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadActiveParking();
  }

  Future<void> _loadActiveParking() async {
    final provider = context.read<ActiveParkingProvider>();
    final token = await AuthService().getToken();
    
    // Always refresh to get latest data
    debugPrint('[GateSimulation] Loading active parking...');
    await provider.fetchActiveParking(token: token);
    debugPrint('[GateSimulation] Has active parking: ${provider.hasActiveParking}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Scan Gate Parkir'),
        backgroundColor: DesignConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ActiveParkingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState();
          }

          if (provider.errorMessage != null) {
            return _buildErrorState(provider.errorMessage!);
          }

          if (!provider.hasActiveParking) {
            return _buildEmptyState();
          }

          final parking = provider.activeParking!;
          return _buildContent(parking);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              DesignConstants.primaryColor,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat data booking...',
            style: TextStyle(
              fontSize: 16,
              color: DesignConstants.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: DesignConstants.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: DesignConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: DesignConstants.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadActiveParking,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_2_outlined,
              size: 80,
              color: DesignConstants.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak Ada Booking Aktif',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: DesignConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Anda belum memiliki booking parkir yang aktif.\nSilakan buat booking terlebih dahulu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: DesignConstants.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              icon: const Icon(Icons.home),
              label: const Text('Kembali ke Beranda'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(parking) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            _buildInfoCard(parking),
            
            const SizedBox(height: 24),
            
            // QR Code Card
            _buildQRCodeCard(parking),
            
            const SizedBox(height: 24),
            
            // Instructions
            _buildInstructions(),
            
            const SizedBox(height: 24),
            
            // Action Button
            _buildActionButton(parking),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(parking) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DesignConstants.primaryColor,
            DesignConstants.primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: DesignConstants.primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_parking,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parking.namaMall,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Slot: ${parking.kodeSlot}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.directions_car,
                  label: 'Kendaraan',
                  value: parking.platNomor,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.confirmation_number,
                  label: 'ID Booking',
                  value: '#${parking.idTransaksi}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildQRCodeCard(parking) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'QR Code Booking',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DesignConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tunjukkan QR code ini ke petugas gate',
            style: TextStyle(
              fontSize: 13,
              color: DesignConstants.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: DesignConstants.primaryLight,
                width: 2,
              ),
            ),
            child: QrImageView(
              data: parking.qrCode,
              version: QrVersions.auto,
              size: 220,
              backgroundColor: Colors.white,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: DesignConstants.backgroundSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              parking.qrCode,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: DesignConstants.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignConstants.infoColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignConstants.cardBorderRadius),
        border: Border.all(
          color: DesignConstants.infoColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: DesignConstants.infoColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Cara Masuk Parkiran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: DesignConstants.infoColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInstructionItem('1', 'Tunjukkan QR code ke petugas gate'),
          _buildInstructionItem('2', 'Atau tekan tombol "Simulasi Masuk" di bawah'),
          _buildInstructionItem('3', 'Gate akan terbuka secara otomatis'),
          _buildInstructionItem('4', 'Parkir di slot yang telah ditentukan'),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: DesignConstants.infoColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: DesignConstants.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(parking) {
    return ElevatedButton.icon(
      onPressed: _isProcessing ? null : () => _simulateGateEntry(parking),
      icon: _isProcessing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.login, size: 24),
      label: Text(
        _isProcessing ? 'Memproses...' : 'Simulasi Masuk Parkiran',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: DesignConstants.successColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignConstants.cardBorderRadius),
        ),
        elevation: 4,
      ),
    );
  }

  Future<void> _simulateGateEntry(parking) async {
    setState(() => _isProcessing = true);

    // Simulate gate processing delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isProcessing = false);

    if (!mounted) return;

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignConstants.cardBorderRadius),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DesignConstants.successColor.withValues(alpha: 0.1),
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
              'Gate Terbuka!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: DesignConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Silakan masuk ke area parkir\ndan parkir di slot ${parking.kodeSlot}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: DesignConstants.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Durasi parkir akan dimulai sekarang',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: DesignConstants.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Navigate to Activity Page (tab Aktivitas)
              Navigator.pushReplacementNamed(
                context,
                '/activity',
                arguments: {'initialTab': 0}, // Tab 0 = Aktivitas
              );
            },
            child: const Text('Lihat Aktivitas'),
          ),
        ],
      ),
    );
  }
}

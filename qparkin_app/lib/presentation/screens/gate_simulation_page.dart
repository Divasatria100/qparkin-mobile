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

  // DUMMY DATA untuk demo
  final String _dummyQRCode = 'QPARKIN-DEMO-2024-001';

  @override
  void initState() {
    super.initState();
    // No need to load data - using dummy
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
      body: _buildDummyContent(),
    );
  }

  Widget _buildDummyContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // QR Code Card
            _buildQRCodeCard(),
            
            const SizedBox(height: 24),
            
            // Instructions
            _buildInstructions(),
            
            const SizedBox(height: 24),
            
            // Action Button
            _buildActionButton(),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }



  Widget _buildQRCodeCard() {
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
              data: _dummyQRCode,
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
              _dummyQRCode,
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

  Widget _buildActionButton() {
    return ElevatedButton.icon(
      onPressed: _isProcessing ? null : _simulateGateEntry,
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

  Future<void> _simulateGateEntry() async {
    setState(() => _isProcessing = true);

    // Simulate gate processing delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isProcessing = false);

    if (!mounted) return;

    // Enable demo mode in provider before navigating
    final provider = Provider.of<ActiveParkingProvider>(context, listen: false);
    provider.enableDemoMode();

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
              'Silakan masuk ke area parkir\ndan parkir di slot yang telah ditentukan',
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

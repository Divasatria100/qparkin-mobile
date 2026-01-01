import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/vehicle_model.dart';
import '../../logic/providers/profile_provider.dart';

/// Vehicle Detail Page
/// Displays detailed information about a specific vehicle
/// Allows editing, deletion, and setting as active vehicle
class VehicleDetailPage extends StatelessWidget {
  final VehicleModel vehicle;

  const VehicleDetailPage({
    super.key,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detail Kendaraan',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFF573ED1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF7C5ED1),
                    Color(0xFF573ED1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  // Vehicle photo (if available)
                  if (vehicle.fotoUrl != null && vehicle.fotoUrl!.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        vehicle.fotoUrl!,
                        width: 200,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // If image fails to load, show vehicle icon instead
                          return Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              _getVehicleIcon(vehicle.jenisKendaraan),
                              size: 40,
                              color: const Color(0xFF573ED1),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 200,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    // Vehicle icon (if no photo)
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getVehicleIcon(vehicle.jenisKendaraan),
                        size: 40,
                        color: const Color(0xFF573ED1),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Vehicle name
                  Text(
                    '${vehicle.merk} ${vehicle.tipe}',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Plate number
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      vehicle.platNomor,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF573ED1),
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  if (vehicle.isActive) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Aktif',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Vehicle information
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Kendaraan',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E3A8C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(context),
                  const SizedBox(height: 24),

                  // Action buttons
                  if (!vehicle.isActive)
                    _buildSetActiveButton(context),
                  const SizedBox(height: 12),
                  _buildEditButton(context),
                  const SizedBox(height: 12),
                  _buildDeleteButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.directions_car,
            label: 'Jenis Kendaraan',
            value: vehicle.jenisKendaraan,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.business,
            label: 'Merk',
            value: vehicle.merk,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.category,
            label: 'Tipe',
            value: vehicle.tipe,
          ),
          if (vehicle.warna != null) ...[
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.palette,
              label: 'Warna',
              value: vehicle.warna!,
            ),
          ],
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.credit_card,
            label: 'Plat Nomor',
            value: vehicle.platNomor,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF573ED1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF573ED1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSetActiveButton(BuildContext context) {
    return Semantics(
      label: 'Tombol jadikan kendaraan aktif',
      hint: 'Ketuk untuk menjadikan kendaraan ini sebagai kendaraan aktif',
      button: true,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () => _handleSetActive(context),
          icon: const Icon(Icons.check_circle_outline),
          label: const Text(
            'Jadikan Kendaraan Aktif',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Semantics(
      label: 'Tombol edit kendaraan',
      hint: 'Ketuk untuk mengedit informasi kendaraan',
      button: true,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () => _handleEdit(context),
          icon: const Icon(Icons.edit),
          label: const Text(
            'Edit Kendaraan',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF573ED1),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return Semantics(
      label: 'Tombol hapus kendaraan',
      hint: 'Ketuk untuk menghapus kendaraan ini',
      button: true,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton.icon(
          onPressed: () => _handleDelete(context),
          icon: const Icon(Icons.delete_outline),
          label: const Text(
            'Hapus Kendaraan',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getVehicleIcon(String jenisKendaraan) {
    switch (jenisKendaraan.toLowerCase()) {
      case 'roda dua':
        return Icons.two_wheeler;
      case 'roda tiga':
        return Icons.electric_rickshaw;
      case 'roda empat':
        return Icons.directions_car;
      default:
        return Icons.local_shipping;
    }
  }

  Future<void> _handleSetActive(BuildContext context) async {
    final provider = context.read<ProfileProvider>();
    
    try {
      await provider.setActiveVehicle(vehicle.idKendaraan);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${vehicle.merk} ${vehicle.tipe} dijadikan kendaraan aktif',
              style: const TextStyle(fontFamily: 'Nunito'),
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Gagal mengubah kendaraan aktif',
              style: TextStyle(fontFamily: 'Nunito'),
            ),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _handleEdit(BuildContext context) async {
    // TODO: Navigate to edit vehicle page when implemented
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Fitur edit kendaraan akan segera tersedia',
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Hapus Kendaraan',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus ${vehicle.merk} ${vehicle.tipe} (${vehicle.platNomor})?\n\nTindakan ini tidak dapat dibatalkan.',
            style: const TextStyle(
              fontFamily: 'Nunito',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Batal',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  color: Color(0xFF8E8E93),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Hapus',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    // If user confirmed deletion
    if (confirmed == true && context.mounted) {
      final provider = context.read<ProfileProvider>();
      
      try {
        await provider.deleteVehicle(vehicle.idKendaraan);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Kendaraan ${vehicle.merk} ${vehicle.tipe} berhasil dihapus',
                style: const TextStyle(fontFamily: 'Nunito'),
              ),
              backgroundColor: const Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Gagal menghapus kendaraan',
                style: TextStyle(fontFamily: 'Nunito'),
              ),
              backgroundColor: Colors.red[400],
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }
}

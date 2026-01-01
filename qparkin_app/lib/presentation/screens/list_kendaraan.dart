// 📄 lib/presentation/screens/list_kendaraan.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/profile_provider.dart';
import '../../data/models/vehicle_model.dart';
import 'tambah_kendaraan.dart';
import 'vehicle_detail_page.dart';
import '../../utils/page_transitions.dart';

/// Vehicle List Page
/// Displays all registered vehicles with ability to add, view, and delete
/// Integrates with ProfileProvider for state management
class VehicleListPage extends StatefulWidget {
  const VehicleListPage({super.key});

  @override
  State<VehicleListPage> createState() => _VehicleListPageState();
}

class _VehicleListPageState extends State<VehicleListPage> {
  @override
  void initState() {
    super.initState();
    // Fetch vehicles when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchVehicles();
    });
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

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Nunito'),
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red[400] : const Color(0xFF4CAF50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.only(bottom: 60, left: 20, right: 20),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, VehicleModel vehicle) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[700],
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Hapus Kendaraan',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus ${vehicle.merk} ${vehicle.tipe} (${vehicle.platNomor})?',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Batal',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  color: Color(0xFF8E8E93),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteVehicle(vehicle);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red[50],
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Hapus',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  color: Colors.red[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteVehicle(VehicleModel vehicle) async {
    try {
      await context.read<ProfileProvider>().deleteVehicle(vehicle.idKendaraan);
      _showSnackbar('${vehicle.merk} ${vehicle.tipe} berhasil dihapus!');
    } catch (e) {
      _showSnackbar('Gagal menghapus kendaraan', isError: true);
    }
  }

  Future<void> _navigateToAddVehicle() async {
    final result = await Navigator.of(context).push<bool>(
      PageTransitions.slideFromRight(
        page: const VehicleSelectionPage(),
      ),
    );

    // Refresh vehicle list if vehicle was added
    if (result == true && mounted) {
      context.read<ProfileProvider>().fetchVehicles();
    }
  }

  void _navigateToVehicleDetail(VehicleModel vehicle) {
    Navigator.of(context).push(
      PageTransitions.slideFromRight(
        page: VehicleDetailPage(vehicle: vehicle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              Column(
                children: [
                  // Header - consistent with other pages
                  Container(
                    width: double.infinity,
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
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                              tooltip: 'Kembali',
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'List Kendaraan',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Expanded(
                    child: provider.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF573ED1)),
                            ),
                          )
                        : provider.vehicles.isEmpty
                            ? _buildEmptyState()
                            : _buildVehicleList(provider.vehicles),
                  ),
                ],
              ),

              // Floating action button
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton(
                  onPressed: _navigateToAddVehicle,
                  backgroundColor: const Color(0xFF573ED1),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Kendaraan',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan kendaraan pertama Anda dengan menekan tombol + di bawah',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleList(List<VehicleModel> vehicles) {
    return RefreshIndicator(
      onRefresh: () => context.read<ProfileProvider>().fetchVehicles(),
      color: const Color(0xFF573ED1),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Kendaraan Terdaftar',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...vehicles.map((vehicle) => _buildVehicleCard(vehicle)).toList(),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(VehicleModel vehicle) {
    return GestureDetector(
      onTap: () => _navigateToVehicleDetail(vehicle),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: vehicle.isActive 
                ? const Color(0xFF573ED1)
                : Colors.grey.shade200,
            width: vehicle.isActive ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: vehicle.isActive
                  ? const Color(0xFF573ED1).withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: vehicle.isActive ? 16 : 8,
              offset: Offset(0, vehicle.isActive ? 4 : 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Vehicle icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF573ED1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getVehicleIcon(vehicle.jenisKendaraan),
                color: const Color(0xFF573ED1),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Vehicle info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${vehicle.merk} ${vehicle.tipe}',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (vehicle.isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Aktif',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vehicle.platNomor,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (vehicle.warna != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      vehicle.warna!,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Delete button
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red[600],
                size: 24,
              ),
              onPressed: () {
                _showDeleteConfirmation(context, vehicle);
              },
              tooltip: 'Hapus kendaraan',
            ),
          ],
        ),
      ),
    );
  }
}


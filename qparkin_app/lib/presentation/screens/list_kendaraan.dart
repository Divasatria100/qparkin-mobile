// 📄 lib/presentation/screens/list_kendaraan.dart
import 'package:flutter/material.dart';
import 'tambah_kendaraan.dart'; // ✅ import halaman tambah kendaraan
import '../../utils/page_transitions.dart';

class VehicleListPage extends StatefulWidget {
  const VehicleListPage({super.key});

  @override
  State<VehicleListPage> createState() => _VehicleListPageState();
}

class _VehicleListPageState extends State<VehicleListPage> {
  int selectedIndex = 0;

  final List<Map<String, dynamic>> vehicles = [
    {
      'name': 'Suzuki',
      'plate': 'AB 123 ABL',
      'icon': Icons.two_wheeler,
    },
    {
      'name': 'Mercedes G 63',
      'plate': 'A 61026',
      'icon': Icons.directions_car,
    },
  ];

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF323232),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.only(bottom: 60, left: 20, right: 20),
      ),
    );
  }

  void _addNewVehicle(Map<String, dynamic> newVehicle) {
    setState(() {
      vehicles.add(newVehicle);
    });
    showSnackbar("${newVehicle['name']} berhasil ditambahkan!");
  }

  void _showDeleteConfirmation(BuildContext context, int index, Map<String, dynamic> vehicle) {
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
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus ${vehicle['name']} (${vehicle['plate']})?',
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
                _deleteVehicle(index, vehicle);
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
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteVehicle(int index, Map<String, dynamic> vehicle) {
    setState(() {
      vehicles.removeAt(index);
      if (selectedIndex >= vehicles.length) {
        selectedIndex = vehicles.length - 1;
      }
      if (selectedIndex < 0) selectedIndex = 0;
    });
    showSnackbar("${vehicle['name']} berhasil dihapus!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F9),
      body: Stack(
        children: [
          Column(
            children: [
              // 🔹 Header dengan 1 logo PNG “Qparkin”
              Container(
                width: double.infinity,
                height: 180,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF42CBF8),
                      Color(0xFF573ED1),
                      Color(0xFF39108A),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  child: Stack(
                    children: [
                      // Tombol Back
                      Positioned(
                        left: 16,
                        top: 8,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: 'Kembali',
                        ),
                      ),
                      // Logo
                      Center(
                        child: Image.asset(
                          'assets/images/qparkin.png',
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 🔹 Konten
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'List Kendaraan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(vehicles.length, (index) {
                        final vehicle = vehicles[index];
                        final isSelected = selectedIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                            showSnackbar('${vehicle['name']} diklik');
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(isSelected ? 12 : 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(
                                      color: const Color(0xFF5B9FFF),
                                      width: 2,
                                    )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vehicle['name']!,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF333333),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        vehicle['plate']!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF999999),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE3F2FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    vehicle['icon'],
                                    color: const Color(0xFF5B9FFF),
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Tombol Hapus
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    _showDeleteConfirmation(context, index, vehicle);
                                  },
                                  tooltip: 'Hapus kendaraan',
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 🔹 Tombol tambah kendaraan
          Positioned(
            top: 420,
            right: 30,
            child: GestureDetector(
              onTap: () async {
                final newVehicle = await Navigator.of(context).push<Map<String, dynamic>>(
                  PageTransitions.slideFromRight(
                    page: const VehicleSelectionPage(),
                  ),
                );

                if (newVehicle != null) {
                  _addNewVehicle(newVehicle);
                }
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF7BA3FF),
                      Color(0xFF5B8FFF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5B9FFF).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
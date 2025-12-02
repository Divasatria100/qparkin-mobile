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
                  child: Center(
                    child: Image.asset(
                      'assets/images/qparkin.png',
                      height: 60,
                      fit: BoxFit.contain,
                    ),
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
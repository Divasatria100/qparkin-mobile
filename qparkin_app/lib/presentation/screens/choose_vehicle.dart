// lib/presentation/screens/choose_vehicle_page.dart
import 'package:flutter/material.dart';

class ChooseVehiclePage extends StatefulWidget {
  const ChooseVehiclePage({super.key});

  @override
  State<ChooseVehiclePage> createState() => _ChooseVehiclePageState();
}

class _ChooseVehiclePageState extends State<ChooseVehiclePage> {
  int _currentIndex = 2; // Scan tab aktif
  int? _selectedVehicleIndex;

  final List<Map<String, dynamic>> vehicles = [
    {
      'name': 'Suzuki',
      'plate': 'AB 123 ABL',
      'type': 'motor',
    },
    {
      'name': 'Mercedes G 63',
      'plate': 'A 61026',
      'type': 'mobil',
    },
  ];

  void _showVehicleDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Header Dialog
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilih Kendaraan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF6B4CE6)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // List Kendaraan
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  final isSelected = _selectedVehicleIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedVehicleIndex = index;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFFE8E4F3) 
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected 
                              ? const Color(0xFF6B4CE6) 
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Icon Kendaraan
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6B4CE6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              vehicle['type'] == 'motor' 
                                  ? Icons.two_wheeler 
                                  : Icons.local_shipping,
                              color: const Color(0xFF6B4CE6),
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Info Kendaraan
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vehicle['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3142),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  vehicle['plate'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Checkmark jika dipilih
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF6B4CE6),
                              size: 28,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Tombol Lanjutkan
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B4CE6), Color(0xFF00BCD4)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton(
                  onPressed: _selectedVehicleIndex != null
                      ? () {
                          Navigator.pop(context);
                          // Proses lanjutkan
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Lanjutkan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Header dengan Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6B4CE6), Color(0xFF00BCD4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            child: Row(
              children: const [
                Icon(Icons.local_parking, color: Colors.white, size: 32),
                SizedBox(width: 8),
                Text(
                  'parkin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Konten
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lokasi Pusat Perbelanjaan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Card Lokasi
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8E4F3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.business,
                            color: Color(0xFF6B4CE6),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Mega Mall Batam Centre',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D3142),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '(± 1.3 km)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Jl. Engku Putri no.1, Batam Centre',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tombol Pilih Kendaraan
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6B4CE6), Color(0xFF00BCD4)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6B4CE6).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _showVehicleDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Pilih Kendaraan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Info Kendaraan Terpilih
                  if (_selectedVehicleIndex != null) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Kendaraan Dipilih',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8E4F3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF6B4CE6),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6B4CE6).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              vehicles[_selectedVehicleIndex!]['type'] == 'motor'
                                  ? Icons.two_wheeler
                                  : Icons.local_shipping,
                              color: const Color(0xFF6B4CE6),
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vehicles[_selectedVehicleIndex!]['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3142),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  vehicles[_selectedVehicleIndex!]['plate'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF6B4CE6),
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF6B4CE6),
          unselectedItemColor: Colors.grey,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              label: 'Aktivitas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              label: 'Notifikasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
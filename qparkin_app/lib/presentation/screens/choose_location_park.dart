// lib/presentation/screens/choose_location_park_page.dart
import 'package:flutter/material.dart';

class ChooseLocationParkPage extends StatefulWidget {
  const ChooseLocationParkPage({super.key});

  @override
  State<ChooseLocationParkPage> createState() => _ChooseLocationParkPageState();
}

class _ChooseLocationParkPageState extends State<ChooseLocationParkPage> {
  int _currentIndex = 2; // Scan tab aktif
  String? _selectedParkingArea;
  String? _selectedSlot;

  final List<Map<String, dynamic>> parkingAreas = [
    {
      'name': 'Parkir Mawar (Mobil)',
      'slots': 120,
      'available': true,
    },
    {
      'name': 'Parkir Mawar (Mobil)',
      'slots': 120,
      'available': true,
    },
    {
      'name': 'Parkir Mawar (Mobil)',
      'slots': 120,
      'available': true,
    },
    {
      'name': 'Parkir Mawar (Mobil)',
      'slots': 120,
      'available': true,
    },
  ];

  final List<Map<String, dynamic>> parkingSlots = [
    {'code': 'A101', 'slots': 15},
    {'code': 'B102', 'slots': 15},
    {'code': 'C103', 'slots': 15},
    {'code': 'D104', 'slots': 15},
    {'code': 'E105', 'slots': 15},
    {'code': 'F106', 'slots': 15},
    {'code': 'G107', 'slots': 15},
  ];

  void _showParkingSlots(String parkingArea) {
    setState(() {
      _selectedParkingArea = parkingArea;
    });
  }

  void _backToAreaList() {
    setState(() {
      _selectedParkingArea = null;
      _selectedSlot = null;
    });
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
            child: _selectedParkingArea == null
                ? _buildParkingAreaList()
                : _buildParkingSlotList(),
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

  // Widget untuk List Area Parkir
  Widget _buildParkingAreaList() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Dialog Header
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Area Parkir',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF6B4CE6)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Mega Mall, Batam Center',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                // Search Field
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Pilih Area Parkir',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // List Area Parkir
                ...parkingAreas.asMap().entries.map((entry) {
                  final index = entry.key;
                  final area = entry.value;
                  return GestureDetector(
                    onTap: () => _showParkingSlots(area['name']),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8E4F3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.business,
                              color: Color(0xFF6B4CE6),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  area['name'],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D3142),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      size: 14,
                                      color: Color(0xFF00BCD4),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${area['slots']} Slot',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Tersedia',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk List Slot Parkir
  Widget _buildParkingSlotList() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Dialog Header
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Area Parkir',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF6B4CE6)),
                      onPressed: _backToAreaList,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Mega Mall, Batam Center',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                // Search Field
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Pilih Area Parkir',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // List Slot Parkir
                ...parkingSlots.map((slot) {
                  final isSelected = _selectedSlot == slot['code'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSlot = slot['code'];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFFE8E4F3) 
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                              ? const Color(0xFF6B4CE6) 
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            slot['code'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected 
                                  ? const Color(0xFF6B4CE6)
                                  : Colors.grey[600],
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone_android,
                                size: 16,
                                color: Color(0xFF00BCD4),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${slot['slots']} Slot',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Tersedia',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
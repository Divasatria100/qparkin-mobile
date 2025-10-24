import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class PointScreen extends StatefulWidget {
  const PointScreen({super.key});

  @override
  State<PointScreen> createState() => _PointScreenState();
}

class _PointScreenState extends State<PointScreen> {
  int _currentIndex = 2; // misal tab ke-3 untuk "Scan"

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header gradasi + logo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: const [
                Text(
                  'Qparkin',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // Card "Point Saya"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Point Saya',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.blue, size: 18),
                          SizedBox(width: 6),
                          Text(
                            '201 Points',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Image(
                    image: AssetImage('assets/images/qparkin_logo.png'),
                    width: 48,
                    height: 48,
                  ),
                ],
              ),
            ),
          ),

          // Judul "Riwayat Poin"
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Riwayat Poin',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // List poin statis
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                _PointCard(
                  title: 'Mega Mall Batam Centre',
                  address: 'Jl. Engku Putri no.1, Batam Centre',
                  date: '15 Mar 2024',
                  pointText: '+20 POIN',
                  pointColor: Color(0xFFD6F5D6),
                  textColor: Colors.green,
                ),
                _PointCard(
                  title: 'Mega Mall Batam Centre',
                  address: 'Jl. Engku Putri no.1, Batam Centre',
                  date: '15 Mar 2024',
                  pointText: '-20 POIN',
                  pointColor: Color(0xFFFFE5E5),
                  textColor: Colors.red,
                ),
                _PointCard(
                  title: 'Mega Mall Batam Centre',
                  address: 'Jl. Engku Putri no.1, Batam Centre',
                  date: '15 Mar 2024',
                  pointText: '+20 POIN',
                  pointColor: Color(0xFFD6F5D6),
                  textColor: Colors.green,
                ),
                _PointCard(
                  title: 'Mega Mall Batam Centre',
                  address: 'Jl. Engku Putri no.1, Batam Centre',
                  date: '15 Mar 2024',
                  pointText: '-20 POIN',
                  pointColor: Color(0xFFFFE5E5),
                  textColor: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),

      // --- BOTTOM NAV BAR INCLUDE ---
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

// --- Widget Kartu Riwayat ---
class _PointCard extends StatelessWidget {
  final String title;
  final String address;
  final String date;
  final String pointText;
  final Color pointColor;
  final Color textColor;

  const _PointCard({
    required this.title,
    required this.address,
    required this.date,
    required this.pointText,
    required this.pointColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Detail kiri
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    address,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Badge poin kanan
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: pointColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              pointText,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

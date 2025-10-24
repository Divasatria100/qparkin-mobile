import 'package:flutter/material.dart';

class CustomAnimatedNavBar extends StatefulWidget {
    const CustomAnimatedNavBar({Key? key}) : super(key: key);

    @override
    State<CustomAnimatedNavBar> createState() => _CustomAnimatedNavBarState();
}

class _CustomAnimatedNavBarState extends State<CustomAnimatedNavBar> {
    int _selectedIndex = 0;

    void _onItemTapped(int index) {
        setState(() {
        _selectedIndex = index;
        });
    }

    @override
    Widget build(BuildContext context) {
        return Container(
        height: 80,
        decoration: BoxDecoration(
            color: Colors.purple.shade600,
            borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
            ),
        ),
        child: Stack(
            children: [
            // Animated Indicator Circle
            AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: _getIndicatorPosition(),
                top: 10,
                child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.purple.shade300.withOpacity(0.5),
                    shape: BoxShape.circle,
                ),
                ),
            ),
            // Menu Items
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                _buildItem(
                    index: 0,
                    icon: Icons.home,
                    label: 'Beranda',
                ),
                _buildItem(
                    index: 1,
                    icon: Icons.directions_car,
                    label: 'Parkir',
                ),
                _buildItem(
                    index: 2,
                    icon: Icons.person,
                    label: 'Profil',
                ),
                ],
            ),
            ],
        ),
        );
    }

    Widget _buildItem({
        required int index,
        required IconData icon,
        required String label,
    }) {
        final isSelected = _selectedIndex == index;

        return Expanded(
        child: GestureDetector(
            onTap: () => _onItemTapped(index),
            behavior: HitTestBehavior.opaque,
            child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Icon(
                    icon,
                    color: Colors.white,
                    size: 24.0,
                ),
                const SizedBox(height: 4),
                Text(
                    label,
                    style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                ),
                ],
            ),
            ),
        ),
        );
    }

    double _getIndicatorPosition() {
        final screenWidth = MediaQuery.of(context).size.width;
        final itemWidth = screenWidth / 3;
        final indicatorWidth = 50.0;

        return (itemWidth * _selectedIndex) + (itemWidth - indicatorWidth) / 2;
    }
}

// Contoh Penggunaan di Scaffold
// class BottomNavExample extends StatelessWidget {
//     const BottomNavExample({Key? key}) : super(key: key);

//     @override
//     Widget build(BuildContext context) {
//         return Scaffold(
//         appBar: AppBar(
//             title: const Text('Custom Animated Nav Bar'),
//             backgroundColor: Colors.deepPurple,
//         ),
//         body: const Center(
//             child: Text('Content Area'),
//         ),
//         bottomNavigationBar: const CustomAnimatedNavBar(),
//         );
//     }
// }
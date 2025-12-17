import 'package:flutter/material.dart';
import '../screens/qr_scan_screen.dart';

typedef _LetIndexPage = bool Function(int value);

class CurvedNavigationBar extends StatefulWidget {
  final List<IconData> icons;
  final List<String> labels;
  final int index;
  final Color color;
  final Color? buttonBackgroundColor;
  final Color backgroundColor;
  final ValueChanged<int>? onTap;
  final _LetIndexPage letIndexChange;
  final double height;
  final double? maxWidth;

  CurvedNavigationBar({
    Key? key,
    this.icons = const [
      Icons.home,
      Icons.history,
      Icons.map,
      Icons.person,
    ],
    this.labels = const [
      'Beranda',
      'Aktivitas',
      'Peta',
      'Profil',
    ],
    this.index = 0,
    this.color = Colors.white,
    this.buttonBackgroundColor = const Color(0xFFFB923C),
    this.backgroundColor = Colors.white,
    this.onTap,
    _LetIndexPage? letIndexChange,
    this.height = 90.0,
    this.maxWidth,
  })  : letIndexChange = letIndexChange ?? ((_) => true),
        assert(icons.isNotEmpty),
        assert(labels.isNotEmpty),
        assert(icons.length == labels.length),
        assert(0 <= index && index < icons.length),
        assert(0 <= height && height <= 90.0),
        assert(maxWidth == null || 0 <= maxWidth),
        super(key: key);

  @override
  CurvedNavigationBarState createState() => CurvedNavigationBarState();
}

class CurvedNavigationBarState extends State<CurvedNavigationBar> {
  // Cache decoration as a getter to avoid late initialization issues
  BoxDecoration get _containerDecoration => BoxDecoration(
    color: widget.backgroundColor,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(30),
      topRight: Radius.circular(30),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, -5),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: widget.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: _containerDecoration,
              child: BottomAppBar(
                shape: const CircularNotchedRectangle(),
                notchMargin: 8,
                color: Colors.transparent,
                padding: EdgeInsets.zero,
                elevation: 0,
                child: Row(
                  children: [
                    _buildNavItem(0),
                    _buildNavItem(1),
                    const SizedBox(width: 60),
                    _buildNavItem(2),
                    _buildNavItem(3),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -12,
              left: 0,
              right: 0,
              child: Center(
                child: RepaintBoundary(
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const QrScanScreen(),
                        ),
                      );
                    },
                    backgroundColor: widget.buttonBackgroundColor,
                    elevation: 6,
                    child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isActive = index == widget.index;
    final color = isActive ? widget.buttonBackgroundColor : Colors.black;
    
    return Expanded(
      child: RepaintBoundary(
        child: GestureDetector(
          onTap: () => _buttonTap(index),
          child: Container(
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icons[index],
                  size: 24,
                  color: color,
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    widget.labels[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void setPage(int index) {
    _buttonTap(index);
  }

  void _buttonTap(int index) {
    if (!widget.letIndexChange(index)) {
      return;
    }
    if (widget.onTap != null) {
      widget.onTap!(index);
    }
    setState(() {});
  }
}

class BottomNavWithFab extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onFabPressed;

  const BottomNavWithFab({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.onFabPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(), // Placeholder, actual body will be in parent Scaffold
      floatingActionButton: FloatingActionButton(
        onPressed: onFabPressed,
        backgroundColor: const Color(0xFFFB923C),
        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
        elevation: 6,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 75.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home, 'Beranda'),
              _buildNavItem(1, Icons.history, 'Aktivitas'),
              const SizedBox(width: 48), // Space for FAB
              _buildNavItem(2, Icons.notifications, 'Notifikasi'),
              _buildNavItem(3, Icons.person, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = index == currentIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: isActive ? const Color(0xFFFB923C) : Colors.black,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? const Color(0xFFFB923C) : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

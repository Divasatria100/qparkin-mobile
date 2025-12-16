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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 8,
              color: Colors.transparent,
              padding: EdgeInsets.zero,
              elevation: 0,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _buttonTap(0),
                      child: Container(
                        color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.icons[0],
                              size: 24,
                              color: 0 == widget.index ? widget.buttonBackgroundColor : Colors.black,
                            ),
                            const SizedBox(height: 4),
                            Flexible(
                              child: Text(
                                widget.labels[0],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: 0 == widget.index ? widget.buttonBackgroundColor : Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _buttonTap(1),
                      child: Container(
                        color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.icons[1],
                              size: 24,
                              color: 1 == widget.index ? widget.buttonBackgroundColor : Colors.black,
                            ),
                            const SizedBox(height: 4),
                            Flexible(
                              child: Text(
                                widget.labels[1],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: 1 == widget.index ? widget.buttonBackgroundColor : Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 60),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _buttonTap(2),
                      child: Container(
                        color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.icons[2],
                              size: 24,
                              color: 2 == widget.index ? widget.buttonBackgroundColor : Colors.black,
                            ),
                            const SizedBox(height: 4),
                            Flexible(
                              child: Text(
                                widget.labels[2],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: 2 == widget.index ? widget.buttonBackgroundColor : Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _buttonTap(3),
                      child: Container(
                        color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.icons[3],
                              size: 24,
                              color: 3 == widget.index ? widget.buttonBackgroundColor : Colors.black,
                            ),
                            const SizedBox(height: 4),
                            Flexible(
                              child: Text(
                                widget.labels[3],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: 3 == widget.index ? widget.buttonBackgroundColor : Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -15,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => QrScanScreen(),
                    ),
                  );
                },
                backgroundColor: widget.buttonBackgroundColor,
                child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
                elevation: 6,
              ),
            ),
          ),
        ],
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

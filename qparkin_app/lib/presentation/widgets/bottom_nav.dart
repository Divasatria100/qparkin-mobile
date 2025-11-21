import 'package:flutter/material.dart';

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
      Icons.notifications,
      Icons.person,
    ],
    this.labels = const [
      'Beranda',
      'Aktivitas',
      'Notifikasi',
      'Profil',
    ],
    this.index = 0,
    this.color = Colors.white,
    this.buttonBackgroundColor = const Color(0xFFFB923C),
    this.backgroundColor = Colors.white,
    this.onTap,
    _LetIndexPage? letIndexChange,
    this.height = 75.0,
    this.maxWidth,
  })  : letIndexChange = letIndexChange ?? ((_) => true),
        assert(icons.isNotEmpty),
        assert(labels.isNotEmpty),
        assert(icons.length == labels.length),
        assert(0 <= index && index < icons.length),
        assert(0 <= height && height <= 75.0),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = widget.maxWidth ?? constraints.maxWidth;
          return Container(
            width: maxWidth,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: List.generate(widget.icons.length, (index) {
                final isActive = index == widget.index;
                return Expanded(
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
                            color: isActive ? widget.buttonBackgroundColor : Colors.black,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.labels[index],
                            style: TextStyle(
                              fontSize: 10,
                              color: isActive ? widget.buttonBackgroundColor : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        },
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
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
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

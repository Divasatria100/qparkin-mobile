import 'package:flutter/material.dart';

/// Map control buttons widget
/// 
/// Provides floating action buttons for map controls:
/// - "My Location" button to center on current location
/// 
/// Requirements: 2.3
class MapControls extends StatefulWidget {
  final VoidCallback onMyLocationPressed;

  const MapControls({
    Key? key,
    required this.onMyLocationPressed,
  }) : super(key: key);

  @override
  State<MapControls> createState() => _MapControlsState();
}

class _MapControlsState extends State<MapControls>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // My Location Button
          ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onTap: widget.onMyLocationPressed,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _isPressed 
                      ? const Color(0xFF4A32B0) 
                      : const Color(0xFF573ED1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF573ED1).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.my_location,
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

/// Simple map control button widget
/// 
/// A reusable button component for map controls with consistent styling
class MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  const MapControlButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final button = FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: const Color(0xFF573ED1),
      foregroundColor: Colors.white,
      elevation: 4,
      child: Icon(icon, size: 28),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

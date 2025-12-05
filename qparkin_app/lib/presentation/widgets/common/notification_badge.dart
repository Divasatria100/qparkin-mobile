import 'package:flutter/material.dart';

/// A badge widget that displays a count indicator
class NotificationBadge extends StatelessWidget {
  final int count;
  final Color? backgroundColor;
  final Color? textColor;
  final double size;

  const NotificationBadge({
    super.key,
    required this.count,
    this.backgroundColor,
    this.textColor,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(size * 0.2),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.red,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      constraints: BoxConstraints(
        minWidth: size,
        minHeight: size,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: size * 0.6,
            fontWeight: FontWeight.w700,
            fontFamily: 'Nunito',
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../utils/responsive_helper.dart';

/// Empty state widget for point history
/// Displays when there are no point transactions to show
class PointEmptyState extends StatelessWidget {
  const PointEmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(context, 18);
    final bodyFontSize = ResponsiveHelper.getResponsiveFontSize(context, 14);
    final iconSize = ResponsiveHelper.getIconSize(context, 120);

    return Semantics(
      label: 'Belum ada riwayat poin. Mulai parkir untuk mendapatkan poin reward',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon/Illustration
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: AppTheme.brandIndigo.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.history,
                  size: iconSize * 0.5,
                  color: AppTheme.brandIndigo.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 24),
              
              // Main message
              Text(
                'Belum ada riwayat poin',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Call-to-action text
              Text(
                'Mulai parkir untuk mendapatkan poin reward.\nSetiap transaksi parkir akan memberikan poin yang dapat digunakan untuk diskon.',
                style: TextStyle(
                  fontSize: bodyFontSize,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

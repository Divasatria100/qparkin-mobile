import 'package:flutter/material.dart';

/// Helper class for showing point-related notifications
///
/// Provides methods to display various types of notifications:
/// - Point earned notifications (after parking payment)
/// - Point usage confirmations (after using points for payment)
/// - Penalty warnings (when points are deducted)
///
/// Requirements: 7.1, 7.2, 7.3, 7.4
class NotificationHelper {
  /// Show notification when points are earned
  ///
  /// Requirements: 7.1, 7.4
  static void showPointsEarned(
    BuildContext context, {
    required int points,
    VoidCallback? onViewDetails,
  }) {
    _showNotificationDialog(
      context,
      title: 'Poin Didapat! 🎉',
      message: 'Anda mendapatkan $points poin dari transaksi parkir ini.',
      icon: Icons.stars_rounded,
      iconColor: Colors.amber,
      backgroundColor: Colors.green.shade50,
      onViewDetails: onViewDetails,
    );
  }

  /// Show notification when points are used for payment
  ///
  /// Requirements: 7.2, 7.4
  static void showPointsUsed(
    BuildContext context, {
    required int points,
    required int remainingBalance,
    VoidCallback? onViewDetails,
  }) {
    _showNotificationDialog(
      context,
      title: 'Poin Digunakan ✓',
      message:
          'Anda telah menggunakan $points poin untuk pembayaran.\nSisa saldo: $remainingBalance poin',
      icon: Icons.check_circle_rounded,
      iconColor: Colors.blue,
      backgroundColor: Colors.blue.shade50,
      onViewDetails: onViewDetails,
    );
  }

  /// Show notification when points are deducted due to penalty
  ///
  /// Requirements: 7.3, 7.4
  static void showPenaltyDeduction(
    BuildContext context, {
    required int points,
    required String reason,
    VoidCallback? onViewDetails,
  }) {
    _showNotificationDialog(
      context,
      title: 'Pengurangan Poin ⚠️',
      message: 'Poin Anda dikurangi $points karena:\n$reason',
      icon: Icons.warning_rounded,
      iconColor: Colors.orange,
      backgroundColor: Colors.orange.shade50,
      onViewDetails: onViewDetails,
    );
  }

  /// Show a simple snackbar notification
  ///
  /// Used for quick feedback without blocking the UI
  static void showSnackbar(
    BuildContext context, {
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Internal method to show notification dialog
  static void _showNotificationDialog(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    VoidCallback? onViewDetails,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with background
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 48,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    // Close button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        child: const Text(
                          'Tutup',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                    ),

                    if (onViewDetails != null) ...[
                      const SizedBox(width: 12),

                      // View details button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onViewDetails();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: const Color(0xFF1E88E5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Lihat Detail',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// MapErrorDialog - Reusable error dialog component for map-related errors
///
/// Provides specific dialogs for:
/// - Permission errors (denied, permanently denied)
/// - GPS disabled errors
/// - Network errors
/// - General errors
///
/// Requirements: 5.1, 5.2, 5.3
class MapErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final String primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;

  const MapErrorDialog({
    Key? key,
    required this.title,
    required this.message,
    this.icon = Icons.error_outline,
    this.iconColor = Colors.red,
    this.primaryButtonText = 'OK',
    this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: iconColor,
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Buttons
            Column(
              children: [
                // Primary button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onPrimaryPressed ?? () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF573ED1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      primaryButtonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Secondary button (if provided)
                if (secondaryButtonText != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: onSecondaryPressed ?? () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        secondaryButtonText!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
  }

  /// Show permission denied dialog
  ///
  /// Displays when user denies location permission.
  /// Provides option to retry or continue without location.
  ///
  /// Requirements: 5.1, 2.1
  static Future<void> showPermissionDenied(
    BuildContext context, {
    VoidCallback? onRetry,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MapErrorDialog(
        title: 'Izin Lokasi Ditolak',
        message: 'Aplikasi memerlukan izin lokasi untuk menampilkan posisi Anda pada peta dan menghitung rute. Anda masih dapat melihat lokasi mall tanpa izin ini.',
        icon: Icons.location_off,
        iconColor: Colors.orange,
        primaryButtonText: 'Coba Lagi',
        onPrimaryPressed: () {
          Navigator.of(context).pop();
          if (onRetry != null) onRetry();
        },
        secondaryButtonText: 'Lanjutkan Tanpa Lokasi',
        onSecondaryPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Show permission permanently denied dialog
  ///
  /// Displays when user permanently denies location permission.
  /// Provides option to open app settings or continue without location.
  ///
  /// Requirements: 5.5, 2.4
  static Future<void> showPermissionPermanentlyDenied(
    BuildContext context,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MapErrorDialog(
        title: 'Izin Lokasi Dibutuhkan',
        message: 'Izin lokasi telah ditolak secara permanen. Untuk menggunakan fitur lokasi, silakan aktifkan izin di pengaturan aplikasi:\n\nPengaturan > Aplikasi > QParkin > Izin > Lokasi',
        icon: Icons.settings,
        iconColor: Colors.orange,
        primaryButtonText: 'Buka Pengaturan',
        onPrimaryPressed: () async {
          Navigator.of(context).pop();
          await openAppSettings();
        },
        secondaryButtonText: 'Lanjutkan Tanpa Lokasi',
        onSecondaryPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Show GPS disabled dialog
  ///
  /// Displays when GPS/location services are disabled on device.
  /// Provides option to open location settings.
  ///
  /// Requirements: 5.2
  static Future<void> showGPSDisabled(
    BuildContext context, {
    VoidCallback? onOpenSettings,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MapErrorDialog(
        title: 'GPS Tidak Aktif',
        message: 'Layanan lokasi tidak aktif. Silakan aktifkan GPS di pengaturan perangkat Anda untuk menggunakan fitur lokasi.',
        icon: Icons.gps_off,
        iconColor: Colors.orange,
        primaryButtonText: 'Buka Pengaturan',
        onPrimaryPressed: () async {
          Navigator.of(context).pop();
          if (onOpenSettings != null) {
            onOpenSettings();
          } else {
            await openAppSettings();
          }
        },
        secondaryButtonText: 'Lanjutkan Tanpa GPS',
        onSecondaryPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Show network error dialog
  ///
  /// Displays when network connection is unavailable.
  /// Provides option to retry.
  ///
  /// Requirements: 5.1, 5.3
  static Future<void> showNetworkError(
    BuildContext context, {
    VoidCallback? onRetry,
  }) {
    return showDialog(
      context: context,
      builder: (context) => MapErrorDialog(
        title: 'Koneksi Bermasalah',
        message: 'Tidak dapat terhubung ke internet. Periksa koneksi Anda dan coba lagi. Peta mungkin tidak dapat memuat dengan sempurna.',
        icon: Icons.wifi_off,
        iconColor: Colors.red,
        primaryButtonText: 'Coba Lagi',
        onPrimaryPressed: () {
          Navigator.of(context).pop();
          if (onRetry != null) onRetry();
        },
        secondaryButtonText: 'Tutup',
      ),
    );
  }

  /// Show route calculation error dialog
  ///
  /// Displays when route calculation fails.
  /// Provides option to retry.
  ///
  /// Requirements: 4.5
  static Future<void> showRouteCalculationError(
    BuildContext context, {
    VoidCallback? onRetry,
  }) {
    return showDialog(
      context: context,
      builder: (context) => MapErrorDialog(
        title: 'Gagal Menghitung Rute',
        message: 'Tidak dapat menghitung rute ke lokasi tujuan. Periksa koneksi internet Anda dan coba lagi.',
        icon: Icons.directions_off,
        iconColor: Colors.red,
        primaryButtonText: 'Coba Lagi',
        onPrimaryPressed: () {
          Navigator.of(context).pop();
          if (onRetry != null) onRetry();
        },
        secondaryButtonText: 'Tutup',
      ),
    );
  }

  /// Show location timeout error dialog
  ///
  /// Displays when getting location times out.
  /// Provides option to retry.
  ///
  /// Requirements: 5.1
  static Future<void> showLocationTimeout(
    BuildContext context, {
    VoidCallback? onRetry,
  }) {
    return showDialog(
      context: context,
      builder: (context) => MapErrorDialog(
        title: 'Lokasi Tidak Tersedia',
        message: 'Tidak dapat mendapatkan lokasi Anda. Pastikan GPS aktif dan sinyal GPS kuat, lalu coba lagi.',
        icon: Icons.location_searching,
        iconColor: Colors.orange,
        primaryButtonText: 'Coba Lagi',
        onPrimaryPressed: () {
          Navigator.of(context).pop();
          if (onRetry != null) onRetry();
        },
        secondaryButtonText: 'Tutup',
      ),
    );
  }

  /// Show general error dialog
  ///
  /// Displays for unexpected errors.
  ///
  /// Requirements: 5.1
  static Future<void> showGeneralError(
    BuildContext context, {
    String? errorMessage,
    VoidCallback? onRetry,
  }) {
    return showDialog(
      context: context,
      builder: (context) => MapErrorDialog(
        title: 'Terjadi Kesalahan',
        message: errorMessage ?? 'Terjadi kesalahan yang tidak terduga. Silakan coba lagi.',
        icon: Icons.error_outline,
        iconColor: Colors.red,
        primaryButtonText: onRetry != null ? 'Coba Lagi' : 'OK',
        onPrimaryPressed: onRetry != null
            ? () {
                Navigator.of(context).pop();
                onRetry();
              }
            : null,
        secondaryButtonText: onRetry != null ? 'Tutup' : null,
      ),
    );
  }
}

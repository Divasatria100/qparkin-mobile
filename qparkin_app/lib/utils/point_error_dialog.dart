import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import 'point_error_handler.dart';

/// Utility class for showing error dialogs and snackbars for point operations
///
/// Requirements: 1.4, 8.3, 10.2, 10.3, 10.5
class PointErrorDialog {
  /// Show error dialog with retry option
  ///
  /// Requirements: 10.2, 10.3
  static Future<void> showErrorDialog({
    required BuildContext context,
    required dynamic error,
    String? title,
    VoidCallback? onRetry,
  }) async {
    final errorMessage = PointErrorHandler.getUserFriendlyMessage(error);
    final errorCode = PointErrorHandler.classifyError(error);
    final requiresInternet = PointErrorHandler.requiresInternetMessage(error);
    
    // Log error
    PointErrorHandler.logError(error, context: 'showErrorDialog');

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                requiresInternet ? Icons.wifi_off : Icons.error_outline,
                color: AppTheme.brandRed,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title ?? (requiresInternet ? 'Tidak Ada Koneksi' : 'Terjadi Kesalahan'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                requiresInternet
                    ? 'Memerlukan koneksi internet untuk melakukan aksi ini.'
                    : errorMessage,
                style: const TextStyle(fontSize: 14),
              ),
              if (errorCode != PointErrorHandler.errorCodeUnknown) ...[
                const SizedBox(height: 12),
                Text(
                  'Kode Error: $errorCode',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (onRetry != null && PointErrorHandler.isRetryable(error))
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: const Text('Coba Lagi'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  /// Show error snackbar with retry option
  ///
  /// Requirements: 8.3, 10.2, 10.3
  static void showErrorSnackBar({
    required BuildContext context,
    required dynamic error,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    final errorMessage = PointErrorHandler.getUserFriendlyMessage(error);
    final requiresInternet = PointErrorHandler.requiresInternetMessage(error);
    final isRetryable = PointErrorHandler.isRetryable(error);
    
    // Log error
    PointErrorHandler.logError(error, context: 'showErrorSnackBar');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              requiresInternet ? Icons.wifi_off : Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                requiresInternet
                    ? 'Memerlukan koneksi internet'
                    : errorMessage,
              ),
            ),
          ],
        ),
        duration: duration,
        backgroundColor: AppTheme.brandRed,
        behavior: SnackBarBehavior.floating,
        action: isRetryable && onRetry != null
            ? SnackBarAction(
                label: 'Coba Lagi',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Show success snackbar
  ///
  /// Requirements: 8.2
  static void showSuccessSnackBar({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        duration: duration,
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show network required dialog for actions that need internet
  ///
  /// Requirements: 10.5
  static Future<void> showNetworkRequiredDialog({
    required BuildContext context,
    String? action,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.wifi_off,
                color: AppTheme.brandRed,
                size: 28,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Koneksi Diperlukan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            action != null
                ? 'Memerlukan koneksi internet untuk $action. Silakan periksa koneksi Anda dan coba lagi.'
                : 'Memerlukan koneksi internet untuk melakukan aksi ini. Silakan periksa koneksi Anda dan coba lagi.',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Mengerti'),
            ),
          ],
        );
      },
    );
  }

  /// Show timeout error dialog with retry
  ///
  /// Requirements: 8.3, 10.3
  static Future<void> showTimeoutDialog({
    required BuildContext context,
    VoidCallback? onRetry,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.access_time,
                color: Colors.orange,
                size: 28,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Koneksi Lambat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'Koneksi internet Anda lambat. Silakan coba lagi atau periksa koneksi Anda.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            if (onRetry != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: const Text('Coba Lagi'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }
}

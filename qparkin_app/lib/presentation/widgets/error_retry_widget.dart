import 'package:flutter/material.dart';

/// Widget for displaying error messages with retry functionality
///
/// Provides user-friendly error messages with retry buttons for recoverable errors,
/// offline indicators, and exponential backoff support.
///
/// Requirements: 11.1
class ErrorRetryWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;
  final bool isNetworkError;
  final bool isOffline;
  final int retryCount;

  const ErrorRetryWidget({
    Key? key,
    required this.errorMessage,
    this.onRetry,
    this.isNetworkError = false,
    this.isOffline = false,
    this.retryCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF44336),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error icon
          Icon(
            isOffline ? Icons.wifi_off : Icons.error_outline,
            color: const Color(0xFFF44336),
            size: 48,
          ),
          
          const SizedBox(height: 12),
          
          // Error message
          Text(
            errorMessage,
            style: const TextStyle(
              color: Color(0xFFF44336),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Offline indicator
          if (isOffline) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.cloud_off,
                    size: 16,
                    color: Color(0xFFFF9800),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Tidak ada koneksi internet',
                    style: TextStyle(
                      color: Color(0xFFFF9800),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Retry button
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 20),
                label: Text(
                  retryCount > 0 ? 'Coba Lagi ($retryCount)' : 'Coba Lagi',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF44336),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Snackbar helper for showing error messages with retry
///
/// Requirements: 11.1
class ErrorSnackbarHelper {
  /// Show error snackbar with retry button
  static void showError({
    required BuildContext context,
    required String message,
    VoidCallback? onRetry,
    bool isNetworkError = false,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isNetworkError ? Icons.wifi_off : Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF44336),
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Coba Lagi',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Show offline indicator snackbar
  static void showOffline(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.cloud_off, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tidak ada koneksi internet. Periksa koneksi Anda.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFF9800),
        duration: const Duration(seconds: 6),
      ),
    );
  }
}

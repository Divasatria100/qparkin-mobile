import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/providers/point_provider.dart';
import 'notification_helper.dart';
import 'point_notification_integration.dart';

/// Example implementations for point notification system
///
/// This file provides concrete examples of how to integrate point notifications
/// in various scenarios throughout the QPARKIN app.
///
/// Requirements: 7.1, 7.2, 7.3, 7.4, 7.5

/// Example 1: Show notification after parking transaction completes
///
/// Call this in the payment completion handler after a parking transaction
/// is successfully completed and points are awarded.
///
/// Requirements: 7.1, 7.4
Future<void> showPointsEarnedAfterParking(
  BuildContext context, {
  required int pointsEarned,
  required String transactionId,
}) async {
  if (pointsEarned <= 0) return;

  // Show notification dialog
  await PointNotificationIntegration.notifyPointsEarned(
    context,
    pointsEarned: pointsEarned,
  );

  debugPrint('[PointNotification] Showed points earned notification: $pointsEarned points');
}

/// Example 2: Show notification when points are used for payment
///
/// Call this in the payment page after successfully using points to pay
/// for parking.
///
/// Requirements: 7.2, 7.4
Future<void> showPointsUsedForPayment(
  BuildContext context, {
  required int pointsUsed,
  required String transactionId,
}) async {
  if (pointsUsed <= 0) return;

  final pointProvider = context.read<PointProvider>();

  // Use points via provider
  final success = await pointProvider.usePoints(
    amount: pointsUsed,
    transactionId: transactionId,
  );

  if (success) {
    // Show success notification
    await PointNotificationIntegration.notifyPointsUsed(
      context,
      pointsUsed: pointsUsed,
    );

    debugPrint('[PointNotification] Showed points used notification: $pointsUsed points');
  } else {
    // Show error message
    PointNotificationIntegration.showError(
      context,
      message: 'Gagal menggunakan poin. Silakan coba lagi.',
    );

    debugPrint('[PointNotification] Failed to use points');
  }
}

/// Example 3: Show penalty notification when user violates rules
///
/// Call this when a penalty is detected (e.g., overstay, cancellation)
/// that results in point deduction.
///
/// Requirements: 7.3, 7.4
Future<void> showPenaltyNotification(
  BuildContext context, {
  required int penaltyPoints,
  required String reason,
}) async {
  if (penaltyPoints <= 0) return;

  // Show penalty warning notification
  await PointNotificationIntegration.notifyPenalty(
    context,
    penaltyPoints: penaltyPoints,
    reason: reason,
  );

  debugPrint('[PointNotification] Showed penalty notification: $penaltyPoints points, reason: $reason');
}

/// Example 4: Integration in parking transaction completion flow
///
/// This shows how to integrate point notifications in the complete
/// parking transaction flow.
///
/// Requirements: 7.1, 7.4
class ParkingTransactionCompletionExample {
  static Future<void> onTransactionComplete(
    BuildContext context, {
    required String transactionId,
    required double totalCost,
    required int pointsEarned,
  }) async {
    // 1. Process payment
    debugPrint('[Transaction] Processing payment for transaction $transactionId');

    // 2. Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pembayaran berhasil!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // 3. Wait a moment for payment confirmation to be visible
    await Future.delayed(const Duration(seconds: 2));

    // 4. Show points earned notification
    if (pointsEarned > 0) {
      await showPointsEarnedAfterParking(
        context,
        pointsEarned: pointsEarned,
        transactionId: transactionId,
      );
    }

    // 5. Navigate to transaction history or home
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}

/// Example 5: Integration in payment page with points
///
/// This shows how to integrate point usage in the payment flow.
///
/// Requirements: 7.2, 7.4
class PaymentWithPointsExample {
  static Future<void> processPaymentWithPoints(
    BuildContext context, {
    required String transactionId,
    required double totalCost,
    required int pointsToUse,
  }) async {
    final pointProvider = context.read<PointProvider>();

    // 1. Validate points availability
    final currentBalance = pointProvider.balance ?? 0;
    if (pointsToUse > currentBalance) {
      PointNotificationIntegration.showError(
        context,
        message: 'Poin tidak mencukupi. Saldo Anda: $currentBalance poin',
      );
      return;
    }

    // 2. Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // 3. Use points
      final success = await pointProvider.usePoints(
        amount: pointsToUse,
        transactionId: transactionId,
      );

      // 4. Close loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (success) {
        // 5. Show success notification
        await showPointsUsedForPayment(
          context,
          pointsUsed: pointsToUse,
          transactionId: transactionId,
        );

        // 6. Navigate to success page
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('/payment-success');
        }
      } else {
        // Show error
        if (context.mounted) {
          PointNotificationIntegration.showError(
            context,
            message: 'Gagal menggunakan poin. Silakan coba lagi.',
          );
        }
      }
    } catch (e) {
      // Close loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error
      if (context.mounted) {
        PointNotificationIntegration.showError(
          context,
          message: 'Terjadi kesalahan: ${e.toString()}',
        );
      }
    }
  }
}

/// Example 6: Integration in penalty detection system
///
/// This shows how to integrate penalty notifications when violations
/// are detected.
///
/// Requirements: 7.3, 7.4
class PenaltyDetectionExample {
  static Future<void> onOverstayDetected(
    BuildContext context, {
    required String bookingId,
    required int overstayMinutes,
    required int penaltyPoints,
  }) async {
    // 1. Calculate penalty
    debugPrint('[Penalty] Overstay detected: $overstayMinutes minutes');

    // 2. Apply penalty in backend
    // (This would be done via API call)

    // 3. Show penalty notification
    await showPenaltyNotification(
      context,
      penaltyPoints: penaltyPoints,
      reason: 'Melebihi durasi booking sebanyak $overstayMinutes menit',
    );

    // 4. Refresh point balance
    final pointProvider = context.read<PointProvider>();
    await pointProvider.fetchBalance();
  }

  static Future<void> onBookingCancellation(
    BuildContext context, {
    required String bookingId,
    required int penaltyPoints,
  }) async {
    // 1. Process cancellation
    debugPrint('[Penalty] Booking cancelled: $bookingId');

    // 2. Apply penalty in backend
    // (This would be done via API call)

    // 3. Show penalty notification
    await showPenaltyNotification(
      context,
      penaltyPoints: penaltyPoints,
      reason: 'Pembatalan booking tanpa pemberitahuan',
    );

    // 4. Refresh point balance
    final pointProvider = context.read<PointProvider>();
    await pointProvider.fetchBalance();
  }
}

/// Example 7: Quick success/error messages
///
/// Use these for simple feedback without blocking the UI.
class QuickNotificationExamples {
  static void showSuccess(BuildContext context, String message) {
    PointNotificationIntegration.showSuccess(context, message: message);
  }

  static void showError(BuildContext context, String message) {
    PointNotificationIntegration.showError(context, message: message);
  }

  // Example usage scenarios
  static void onPointsRefreshed(BuildContext context) {
    showSuccess(context, 'Data poin berhasil diperbarui');
  }

  static void onPointsRefreshFailed(BuildContext context) {
    showError(context, 'Gagal memperbarui data poin');
  }

  static void onInsufficientPoints(BuildContext context, int required, int available) {
    showError(
      context,
      'Poin tidak mencukupi. Dibutuhkan: $required, Tersedia: $available',
    );
  }
}

/// Usage Instructions:
///
/// 1. In parking transaction completion:
/// ```dart
/// await ParkingTransactionCompletionExample.onTransactionComplete(
///   context,
///   transactionId: 'TRX123',
///   totalCost: 15000,
///   pointsEarned: 50,
/// );
/// ```
///
/// 2. In payment page with points:
/// ```dart
/// await PaymentWithPointsExample.processPaymentWithPoints(
///   context,
///   transactionId: 'TRX123',
///   totalCost: 15000,
///   pointsToUse: 100,
/// );
/// ```
///
/// 3. When overstay is detected:
/// ```dart
/// await PenaltyDetectionExample.onOverstayDetected(
///   context,
///   bookingId: 'BKG123',
///   overstayMinutes: 30,
///   penaltyPoints: 25,
/// );
/// ```
///
/// 4. Quick feedback messages:
/// ```dart
/// QuickNotificationExamples.showSuccess(context, 'Operasi berhasil');
/// QuickNotificationExamples.showError(context, 'Terjadi kesalahan');
/// ```

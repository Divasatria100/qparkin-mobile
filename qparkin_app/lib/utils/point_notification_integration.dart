import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/providers/point_provider.dart';
import 'notification_helper.dart';

/// Integration helper for point notifications
///
/// Provides convenience methods to trigger point notifications
/// in various scenarios throughout the app.
///
/// Requirements: 7.1, 7.2, 7.3, 7.4
class PointNotificationIntegration {
  /// Show notification when points are earned from parking transaction
  ///
  /// Call this after a parking transaction is completed and points are awarded.
  ///
  /// Example:
  /// ```dart
  /// PointNotificationIntegration.notifyPointsEarned(
  ///   context,
  ///   pointsEarned: 50,
  /// );
  /// ```
  ///
  /// Requirements: 7.1, 7.4
  static Future<void> notifyPointsEarned(
    BuildContext context, {
    required int pointsEarned,
  }) async {
    if (pointsEarned <= 0) return;

    // Show notification dialog
    NotificationHelper.showPointsEarned(
      context,
      points: pointsEarned,
      onViewDetails: () {
        Navigator.pushNamed(context, '/point');
      },
    );

    // Refresh point balance in background
    final pointProvider = context.read<PointProvider>();
    await pointProvider.fetchBalance();
  }

  /// Show notification when points are used for payment
  ///
  /// Call this after successfully using points for a payment.
  ///
  /// Example:
  /// ```dart
  /// PointNotificationIntegration.notifyPointsUsed(
  ///   context,
  ///   pointsUsed: 100,
  /// );
  /// ```
  ///
  /// Requirements: 7.2, 7.4
  static Future<void> notifyPointsUsed(
    BuildContext context, {
    required int pointsUsed,
  }) async {
    if (pointsUsed <= 0) return;

    final pointProvider = context.read<PointProvider>();
    final remainingBalance = pointProvider.balance ?? 0;

    // Show notification dialog
    NotificationHelper.showPointsUsed(
      context,
      points: pointsUsed,
      remainingBalance: remainingBalance,
      onViewDetails: () {
        Navigator.pushNamed(context, '/point');
      },
    );
  }

  /// Show notification when points are deducted due to penalty
  ///
  /// Call this when a penalty is applied that deducts points.
  ///
  /// Example:
  /// ```dart
  /// PointNotificationIntegration.notifyPenalty(
  ///   context,
  ///   penaltyPoints: 25,
  ///   reason: 'Melebihi durasi booking (overstay)',
  /// );
  /// ```
  ///
  /// Requirements: 7.3, 7.4
  static Future<void> notifyPenalty(
    BuildContext context, {
    required int penaltyPoints,
    required String reason,
  }) async {
    if (penaltyPoints <= 0) return;

    // Show warning notification
    NotificationHelper.showPenaltyDeduction(
      context,
      points: penaltyPoints,
      reason: reason,
      onViewDetails: () {
        Navigator.pushNamed(context, '/point');
      },
    );

    // Refresh point balance in background
    final pointProvider = context.read<PointProvider>();
    await pointProvider.fetchBalance();
  }

  /// Show simple success message for point-related actions
  ///
  /// Use this for quick feedback without blocking the UI.
  ///
  /// Example:
  /// ```dart
  /// PointNotificationIntegration.showSuccess(
  ///   context,
  ///   message: 'Poin berhasil digunakan',
  /// );
  /// ```
  static void showSuccess(BuildContext context, {required String message}) {
    NotificationHelper.showSnackbar(
      context,
      message: message,
      isError: false,
    );
  }

  /// Show error message for point-related actions
  ///
  /// Use this to inform users of errors in point operations.
  ///
  /// Example:
  /// ```dart
  /// PointNotificationIntegration.showError(
  ///   context,
  ///   message: 'Gagal menggunakan poin',
  /// );
  /// ```
  static void showError(BuildContext context, {required String message}) {
    NotificationHelper.showSnackbar(
      context,
      message: message,
      isError: true,
    );
  }
}

/// Example usage in payment flow:
///
/// ```dart
/// // After parking transaction completes
/// void _onParkingTransactionComplete(Transaction transaction) async {
///   final pointsEarned = transaction.pointsEarned;
///   
///   if (pointsEarned > 0) {
///     await PointNotificationIntegration.notifyPointsEarned(
///       context,
///       pointsEarned: pointsEarned,
///     );
///   }
/// }
///
/// // When using points for payment
/// void _onUsePoints(int pointsToUse) async {
///   final pointProvider = context.read<PointProvider>();
///   
///   final success = await pointProvider.usePoints(
///     amount: pointsToUse,
///     transactionId: currentTransactionId,
///   );
///   
///   if (success) {
///     await PointNotificationIntegration.notifyPointsUsed(
///       context,
///       pointsUsed: pointsToUse,
///     );
///   } else {
///     PointNotificationIntegration.showError(
///       context,
///       message: 'Gagal menggunakan poin',
///     );
///   }
/// }
///
/// // When penalty is applied
/// void _onPenaltyApplied(int penaltyAmount, String reason) async {
///   await PointNotificationIntegration.notifyPenalty(
///     context,
///     penaltyPoints: penaltyAmount,
///     reason: reason,
///   );
/// }
/// ```

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/point_history_model.dart';

/// A list item widget displaying a single point history entry
///
/// Features:
/// - Color-coding by transaction type (earned = green, used = red)
/// - Displays formatted values with Rupiah equivalent
/// - Shows transaction date and description
/// - Accessibility support
/// - Tap interaction support
///
/// Example usage:
/// ```dart
/// PointHistoryItem(
///   history: pointHistory,
///   onTap: () => showDetails(pointHistory),
/// )
/// ```
class PointHistoryItem extends StatelessWidget {
  final PointHistoryModel history;
  final VoidCallback? onTap;

  const PointHistoryItem({
    Key? key,
    required this.history,
    this.onTap,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    // Color-code based on transaction type
    final isEarned = history.isEarned;
    final amountColor = isEarned ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
    final statusColor = isEarned ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
    final statusText = isEarned ? 'Diperoleh' : 'Digunakan';
    final iconData = isEarned ? Icons.add_circle : Icons.remove_circle;
    
    final accessibilityLabel = '$statusText ${history.absolutePoints} poin, '
        'setara ${history.formattedValue}. ${history.keterangan}. '
        'Tanggal ${_formatDate(history.waktu)}';

    return Semantics(
      label: accessibilityLabel,
      button: onTap != null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon indicator
                  ExcludeSemantics(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        iconData,
                        color: statusColor,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: ExcludeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description
                          Text(
                            history.keterangan,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Date
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(history.waktu),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Amount and value
                  ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Point amount
                        Text(
                          '${isEarned ? '+' : '-'}${history.absolutePoints}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: amountColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Rupiah equivalent
                        Text(
                          history.formattedValue,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
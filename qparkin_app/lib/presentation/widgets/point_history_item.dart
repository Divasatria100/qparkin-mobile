import 'package:flutter/material.dart';
import '../../data/models/point_history_model.dart';

/// A list item widget displaying a single point history entry
/// Shows date, amount, and description with color-coding for additions/deductions
/// Optimized with const constructor where possible
class PointHistoryItem extends StatelessWidget {
  final PointHistory history;
  final VoidCallback? onTap;

  const PointHistoryItem({
    Key? key,
    required this.history,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Color-code based on transaction type
    final amountColor = history.isAddition ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
    final statusColor = history.isAddition ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
    final statusText = history.isAddition ? 'Diperoleh' : 'Digunakan';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon indicator
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                history.isAddition ? Icons.add_circle : Icons.remove_circle,
                color: statusColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title (keterangan) - Bold black
                  Text(
                    history.keterangan,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Status - Green/Red
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 14,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Additional info (if available from keterangan)
                  if (history.keterangan.contains('|'))
                    Text(
                      history.keterangan.split('|').last.trim(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF757575),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 2),
                  // Date - Gray
                  Text(
                    history.formattedDate,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Amount
            Text(
              history.formattedAmount,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
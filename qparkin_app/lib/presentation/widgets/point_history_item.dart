import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../data/models/point_history_model.dart';
import '../../utils/responsive_helper.dart';

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
    final bodyFontSize = ResponsiveHelper.getResponsiveFontSize(context, 14);
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(context, 16);
    final amountFontSize = ResponsiveHelper.getResponsiveFontSize(context, 18);

    // Color-code based on transaction type
    final amountColor = history.isAddition 
        ? Colors.green.shade600 
        : AppTheme.brandRed;
    
    final iconData = history.isAddition 
        ? Icons.add_circle_outline 
        : Icons.remove_circle_outline;

    return Semantics(
      label: _getSemanticLabel(),
      button: onTap != null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 48, // Minimum touch target
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon indicator
                ExcludeSemantics(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: amountColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      iconData,
                      color: amountColor,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Content (description and date)
                Expanded(
                  child: ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description
                        Text(
                          history.keterangan,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Date
                        Text(
                          history.formattedDate,
                          style: TextStyle(
                            fontSize: bodyFontSize,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Amount
                ExcludeSemantics(
                  child: Text(
                    history.formattedAmount,
                    style: TextStyle(
                      fontSize: amountFontSize,
                      fontWeight: FontWeight.bold,
                      color: amountColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getSemanticLabel() {
    final type = history.isAddition ? 'Penambahan' : 'Pengurangan';
    final amount = history.poin;
    final description = history.keterangan;
    final date = history.formattedDate;
    
    String label = '$type poin. $amount poin. $description. $date';
    
    if (onTap != null && history.hasTransaction) {
      label += '. Ketuk untuk melihat detail transaksi';
    }
    
    return label;
  }
}

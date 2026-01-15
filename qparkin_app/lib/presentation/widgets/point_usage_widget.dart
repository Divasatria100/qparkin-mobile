import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/point_provider.dart';
import '../../data/services/point_service.dart';
import '../../utils/responsive_helper.dart';

/// Widget for selecting and using points for booking discount
///
/// Features:
/// - Toggle to enable/disable point usage
/// - Slider to select point amount
/// - Real-time discount calculation
/// - Validation messages
/// - Maximum discount indicator (30%)
/// - Accessibility support
///
/// Business Rules:
/// - 1 poin = Rp100 discount
/// - Maximum 30% discount of parking cost
/// - Minimum 10 points to use
///
/// Example usage:
/// ```dart
/// PointUsageWidget(
///   parkingCost: 100000,
///   onPointsSelected: (points) {
///     setState(() {
///       _selectedPoints = points;
///       _discount = points * 100;
///     });
///   },
/// )
/// ```
class PointUsageWidget extends StatefulWidget {
  /// Total parking cost in Rupiah
  final int parkingCost;
  
  /// Callback when points are selected
  final Function(int points) onPointsSelected;
  
  /// Initial points to use (optional)
  final int? initialPoints;
  
  /// Callback when widget is expanded (optional)
  final VoidCallback? onExpanded;

  const PointUsageWidget({
    Key? key,
    required this.parkingCost,
    required this.onPointsSelected,
    this.initialPoints,
    this.onExpanded,
  }) : super(key: key);

  @override
  State<PointUsageWidget> createState() => _PointUsageWidgetState();
}

class _PointUsageWidgetState extends State<PointUsageWidget> {
  bool _isEnabled = false;
  double _selectedPoints = 0;
  
  @override
  void initState() {
    super.initState();
    if (widget.initialPoints != null && widget.initialPoints! > 0) {
      _isEnabled = true;
      _selectedPoints = widget.initialPoints!.toDouble();
    }
  }

  @override
  void didUpdateWidget(PointUsageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset if parking cost changes
    if (oldWidget.parkingCost != widget.parkingCost) {
      setState(() {
        _isEnabled = false;
        _selectedPoints = 0;
      });
      widget.onPointsSelected(0);
    }
  }

  void _togglePointUsage(bool value, PointProvider provider) {
    setState(() {
      _isEnabled = value;
      if (!value) {
        _selectedPoints = 0;
        widget.onPointsSelected(0);
      } else {
        // Set to minimum when enabled
        final maxPoints = provider.calculateMaxUsablePoints(widget.parkingCost);
        if (maxPoints >= PointService.minRedemption) {
          _selectedPoints = PointService.minRedemption.toDouble();
          widget.onPointsSelected(_selectedPoints.toInt());
        }
        
        // Trigger auto-scroll callback when expanded
        if (widget.onExpanded != null) {
          // Delay to allow widget to expand first
          Future.delayed(const Duration(milliseconds: 100), () {
            widget.onExpanded!();
          });
        }
      }
    });
  }

  void _onSliderChanged(double value, PointProvider provider) {
    setState(() {
      _selectedPoints = value;
    });
    widget.onPointsSelected(value.toInt());
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Consumer<PointProvider>(
      builder: (context, provider, child) {
        final maxUsablePoints = provider.calculateMaxUsablePoints(widget.parkingCost);
        final hasEnoughPoints = provider.balance >= PointService.minRedemption;
        final canUsePoints = hasEnoughPoints && maxUsablePoints >= PointService.minRedemption;
        
        // Calculate discount
        final discountAmount = _isEnabled 
            ? provider.calculateAvailableDiscount(widget.parkingCost)
            : 0;
        final currentDiscount = _isEnabled 
            ? _selectedPoints.toInt() * PointService.redemptionValue
            : 0;
        
        // Get validation error
        final validationError = _isEnabled && _selectedPoints > 0
            ? provider.validatePointUsage(_selectedPoints.toInt(), widget.parkingCost)
            : null;

        return Semantics(
          label: 'Penggunaan poin untuk diskon',
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isEnabled 
                    ? const Color(0xFF573ED1).withOpacity(0.3)
                    : Colors.grey.shade200,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with toggle
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _isEnabled
                              ? const Color(0xFF573ED1).withOpacity(0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.stars,
                          color: _isEnabled
                              ? const Color(0xFF573ED1)
                              : Colors.grey.shade400,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Title and balance
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gunakan Poin',
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Saldo: ${provider.balance} poin (${provider.equivalentValue})',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Toggle switch
                      Semantics(
                        label: _isEnabled 
                            ? 'Penggunaan poin aktif' 
                            : 'Penggunaan poin nonaktif',
                        hint: canUsePoints
                            ? 'Ketuk untuk ${_isEnabled ? 'menonaktifkan' : 'mengaktifkan'} penggunaan poin'
                            : 'Poin tidak mencukupi',
                        child: Switch(
                          value: _isEnabled,
                          onChanged: canUsePoints 
                              ? (value) => _togglePointUsage(value, provider)
                              : null,
                          activeColor: const Color(0xFF573ED1),
                        ),
                      ),
                    ],
                  ),
                ),

                // Point selection slider (when enabled)
                if (_isEnabled && canUsePoints) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Selected points display
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Poin yang digunakan',
                              style: TextStyle(
                                fontSize: isTablet ? 15 : 13,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${_selectedPoints.toInt()} poin',
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF573ED1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Discount amount
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Diskon',
                              style: TextStyle(
                                fontSize: isTablet ? 15 : 13,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Rp${currentDiscount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4CAF50),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Slider
                        Semantics(
                          label: 'Pilih jumlah poin',
                          value: '${_selectedPoints.toInt()} poin dari maksimal $maxUsablePoints poin',
                          hint: 'Geser untuk mengubah jumlah poin',
                          child: SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: const Color(0xFF573ED1),
                              inactiveTrackColor: const Color(0xFF573ED1).withOpacity(0.2),
                              thumbColor: const Color(0xFF573ED1),
                              overlayColor: const Color(0xFF573ED1).withOpacity(0.2),
                              valueIndicatorColor: const Color(0xFF573ED1),
                              valueIndicatorTextStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: Slider(
                              value: _selectedPoints,
                              min: PointService.minRedemption.toDouble(),
                              max: maxUsablePoints.toDouble(),
                              divisions: maxUsablePoints - PointService.minRedemption,
                              label: '${_selectedPoints.toInt()} poin',
                              onChanged: (value) => _onSliderChanged(value, provider),
                            ),
                          ),
                        ),
                        
                        // Min/Max labels
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Min: ${PointService.minRedemption} poin',
                              style: TextStyle(
                                fontSize: isTablet ? 13 : 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            Text(
                              'Max: $maxUsablePoints poin',
                              style: TextStyle(
                                fontSize: isTablet ? 13 : 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        
                        // Maximum discount indicator
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFFFB74D).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Color(0xFFFF9800),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Maksimal diskon 30% dari total biaya (${maxUsablePoints} poin = Rp${(maxUsablePoints * PointService.redemptionValue).toStringAsFixed(0)})',
                                  style: TextStyle(
                                    fontSize: isTablet ? 13 : 11,
                                    color: const Color(0xFFE65100),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Validation error
                        if (validationError != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    validationError,
                                    style: TextStyle(
                                      fontSize: isTablet ? 13 : 11,
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // Insufficient points message
                if (!canUsePoints) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              !hasEnoughPoints
                                  ? 'Poin tidak mencukupi. Minimum ${PointService.minRedemption} poin untuk menggunakan diskon.'
                                  : 'Biaya parkir terlalu rendah untuk menggunakan poin. Minimum diskon Rp${(PointService.minRedemption * PointService.redemptionValue).toStringAsFixed(0)}.',
                              style: TextStyle(
                                fontSize: isTablet ? 13 : 11,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

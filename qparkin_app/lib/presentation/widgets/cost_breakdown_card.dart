import 'package:flutter/material.dart';
import '../../utils/responsive_helper.dart';

/// Widget to display parking cost breakdown with animated number changes
/// Shows first hour rate, additional hours, and total estimated cost
class CostBreakdownCard extends StatefulWidget {
  final double firstHourRate;
  final double additionalHoursRate;
  final int additionalHours;
  final double totalCost;

  const CostBreakdownCard({
    Key? key,
    required this.firstHourRate,
    required this.additionalHoursRate,
    required this.additionalHours,
    required this.totalCost,
  }) : super(key: key);

  @override
  State<CostBreakdownCard> createState() => _CostBreakdownCardState();
}

class _CostBreakdownCardState extends State<CostBreakdownCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _previousTotal = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: widget.totalCost).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _previousTotal = widget.totalCost;
    _animationController.forward();
  }

  @override
  void didUpdateWidget(CostBreakdownCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalCost != widget.totalCost) {
      _animation = Tween<double>(
        begin: _previousTotal,
        end: widget.totalCost,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
        ),
      );
      _previousTotal = widget.totalCost;
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    final totalCostText = _formatCurrency(widget.totalCost);
    final firstHourText = _formatCurrency(widget.firstHourRate);
    final additionalText = widget.additionalHours > 0 
        ? '${widget.additionalHours} jam berikutnya ${_formatCurrency(widget.additionalHoursRate)}' 
        : '';
    
    final borderRadius = ResponsiveHelper.getBorderRadius(context);
    final padding = ResponsiveHelper.getCardPadding(context);
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(context, 16);
    final bodyFontSize = ResponsiveHelper.getResponsiveFontSize(context, 14);
    final totalFontSize = ResponsiveHelper.getResponsiveFontSize(context, 20);
    final captionFontSize = ResponsiveHelper.getResponsiveFontSize(context, 12);
    
    return Semantics(
      label: 'Estimasi biaya parkir. Jam pertama $firstHourText. ${widget.additionalHours > 0 ? additionalText : ""}. Total estimasi $totalCostText',
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.1),
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estimasi Biaya',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              
              Divider(
                color: Colors.grey.shade200,
                height: 1,
              ),
              
              const SizedBox(height: 12),
              
              // First Hour Rate
              _buildBreakdownItem(
                'Jam pertama',
                _formatCurrency(widget.firstHourRate),
              ),
              
              const SizedBox(height: 8),
              
              // Additional Hours Rate
              if (widget.additionalHours > 0)
                _buildBreakdownItem(
                  '${widget.additionalHours} jam berikutnya',
                  _formatCurrency(widget.additionalHoursRate),
                ),
              
              const SizedBox(height: 12),
              
              Divider(
                color: Colors.grey.shade200,
                height: 1,
              ),
              
              const SizedBox(height: 12),
              
              // Total Cost with Animation
              Semantics(
                label: 'Total estimasi biaya $totalCostText',
                liveRegion: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Total Estimasi',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Text(
                            _formatCurrency(_animation.value),
                            style: TextStyle(
                              fontSize: totalFontSize,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF573ED1),
                            ),
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Info Box
              Semantics(
                label: 'Informasi. Biaya final dihitung saat keluar',
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Semantics(
                        label: 'Ikon informasi',
                        child: Icon(
                          Icons.info,
                          color: const Color(0xFF2196F3),
                          size: captionFontSize + 4,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Biaya final dihitung saat keluar',
                          style: TextStyle(
                            fontSize: captionFontSize,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownItem(String label, String amount) {
    final bodyFontSize = ResponsiveHelper.getResponsiveFontSize(context, 14);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bodyFontSize,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: bodyFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

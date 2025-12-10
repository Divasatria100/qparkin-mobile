import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/responsive_helper.dart';

/// PointUsageCard - Widget for selecting points to use for payment
///
/// Displays current point balance, allows user to select amount of points
/// to use, and shows the cost reduction based on point conversion.
///
/// Requirements: 6.1, 6.2, 6.3
class PointUsageCard extends StatefulWidget {
  final int availablePoints;
  final double totalCost;
  final double pointConversionRate; // e.g., 100 points = 1000 rupiah (rate = 10)
  final Function(int pointsToUse) onPointsChanged;
  final bool isLoading;

  const PointUsageCard({
    Key? key,
    required this.availablePoints,
    required this.totalCost,
    this.pointConversionRate = 10.0, // Default: 100 points = Rp 1,000
    required this.onPointsChanged,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<PointUsageCard> createState() => _PointUsageCardState();
}

class _PointUsageCardState extends State<PointUsageCard> {
  bool _usePoints = false;
  int _pointsToUse = 0;
  final TextEditingController _pointsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pointsController.text = '0';
  }

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  /// Calculate maximum points that can be used
  int get _maxUsablePoints {
    // Maximum points based on total cost
    final maxPointsForCost = (widget.totalCost / widget.pointConversionRate).floor();
    
    // Return the minimum of available points and max points for cost
    return widget.availablePoints < maxPointsForCost 
        ? widget.availablePoints 
        : maxPointsForCost;
  }

  /// Calculate cost reduction based on points
  double get _costReduction {
    return _pointsToUse * widget.pointConversionRate;
  }

  /// Calculate final cost after point reduction
  double get _finalCost {
    final reduced = widget.totalCost - _costReduction;
    return reduced > 0 ? reduced : 0;
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final borderRadius = ResponsiveHelper.getBorderRadius(context);

    return Semantics(
      label: 'Kartu penggunaan poin',
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with toggle
              _buildHeader(),
              
              if (_usePoints) ...[
                const SizedBox(height: 16),
                
                // Available points display
                _buildAvailablePoints(),
                
                const SizedBox(height: 16),
                
                // Point selector
                _buildPointSelector(),
                
                const SizedBox(height: 16),
                
                // Cost breakdown
                _buildCostBreakdown(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build header with "Gunakan Poin" toggle
  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.stars,
          color: const Color(0xFFFFC107),
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gunakan Poin',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${widget.availablePoints} poin tersedia',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Semantics(
          label: _usePoints 
              ? 'Nonaktifkan penggunaan poin' 
              : 'Aktifkan penggunaan poin',
          child: Switch(
            value: _usePoints,
            onChanged: widget.isLoading ? null : (value) {
              setState(() {
                _usePoints = value;
                if (!value) {
                  _pointsToUse = 0;
                  _pointsController.text = '0';
                  widget.onPointsChanged(0);
                }
              });
            },
            activeColor: const Color(0xFF573ED1),
          ),
        ),
      ],
    );
  }

  /// Build available points display
  Widget _buildAvailablePoints() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x1A573ED1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFF573ED1),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Maksimal ${_maxUsablePoints} poin dapat digunakan',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build point selector with slider and input
  Widget _buildPointSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          'Jumlah Poin',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        
        // Input field
        Row(
          children: [
            Expanded(
              child: Semantics(
                label: 'Input jumlah poin yang akan digunakan',
                child: TextField(
                  controller: _pointsController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    hintText: '0',
                    suffixText: 'poin',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    final points = int.tryParse(value) ?? 0;
                    setState(() {
                      _pointsToUse = points > _maxUsablePoints 
                          ? _maxUsablePoints 
                          : points;
                      if (_pointsToUse != points) {
                        _pointsController.text = _pointsToUse.toString();
                        _pointsController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _pointsController.text.length),
                        );
                      }
                      widget.onPointsChanged(_pointsToUse);
                    });
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Semantics(
              label: 'Gunakan semua poin',
              button: true,
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : () {
                  setState(() {
                    _pointsToUse = _maxUsablePoints;
                    _pointsController.text = _maxUsablePoints.toString();
                    widget.onPointsChanged(_pointsToUse);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF573ED1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Maks'),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Slider
        if (_maxUsablePoints > 0)
          Semantics(
            label: 'Slider untuk memilih jumlah poin',
            child: Slider(
              value: _pointsToUse.toDouble(),
              min: 0,
              max: _maxUsablePoints.toDouble(),
              divisions: _maxUsablePoints > 0 ? _maxUsablePoints : 1,
              activeColor: const Color(0xFF573ED1),
              onChanged: widget.isLoading ? null : (value) {
                setState(() {
                  _pointsToUse = value.toInt();
                  _pointsController.text = _pointsToUse.toString();
                  widget.onPointsChanged(_pointsToUse);
                });
              },
            ),
          ),
      ],
    );
  }

  /// Build cost breakdown showing reduction
  Widget _buildCostBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          // Original cost
          _buildCostRow(
            label: 'Biaya Parkir',
            value: _formatCurrency(widget.totalCost),
            isTotal: false,
          ),
          
          if (_pointsToUse > 0) ...[
            const SizedBox(height: 8),
            
            // Point reduction
            _buildCostRow(
              label: 'Potongan Poin ($_pointsToUse poin)',
              value: '- ${_formatCurrency(_costReduction)}',
              isTotal: false,
              valueColor: const Color(0xFF4CAF50),
            ),
            
            const SizedBox(height: 8),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 8),
          ],
          
          // Final cost
          _buildCostRow(
            label: 'Total Bayar',
            value: _formatCurrency(_finalCost),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  /// Build cost row
  Widget _buildCostRow({
    required String label,
    required String value,
    required bool isTotal,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black87 : Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? (isTotal ? const Color(0xFF573ED1) : Colors.black87),
          ),
        ),
      ],
    );
  }

  /// Format currency
  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }
}

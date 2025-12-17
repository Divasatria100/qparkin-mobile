import 'package:flutter/material.dart';
import '../../data/models/point_filter_model.dart';

/// Bottom sheet widget for filtering point history
///
/// Provides UI for users to filter point transactions by:
/// - Type (All/Earned/Used)
/// - Date range
/// - Amount range
///
/// Features:
/// - Filter type chips (All, Diperoleh, Digunakan)
/// - Date range picker
/// - Amount range inputs (min/max points)
/// - Apply and Reset actions
/// - Accessibility support
///
/// Example usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   builder: (context) => FilterBottomSheet(
///     currentFilter: provider.currentFilter,
///     onApply: (filter) => provider.applyFilter(filter),
///   ),
/// )
/// ```
class FilterBottomSheet extends StatefulWidget {
  final PointFilterModel currentFilter;
  final Function(PointFilterModel) onApply;

  const FilterBottomSheet({
    Key? key,
    required this.currentFilter,
    required this.onApply,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late PointFilterType _selectedType;
  int? _minAmount;
  int? _maxAmount;
  
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.currentFilter.type;
    _minAmount = widget.currentFilter.minAmount;
    _maxAmount = widget.currentFilter.maxAmount;
    
    if (_minAmount != null) {
      _minController.text = _minAmount.toString();
    }
    if (_maxAmount != null) {
      _maxController.text = _maxAmount.toString();
    }
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final filter = PointFilterModel(
      type: _selectedType,
      minAmount: _minAmount,
      maxAmount: _maxAmount,
    );
    widget.onApply(filter);
    Navigator.pop(context);
  }

  void _resetFilter() {
    setState(() {
      _selectedType = PointFilterType.all;
      _minAmount = null;
      _maxAmount = null;
      _minController.clear();
      _maxController.clear();
    });
  }



  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Riwayat Poin',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: _resetFilter,
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        color: Color(0xFF573ED1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Type filter
              const Text(
                'Tipe Transaksi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTypeChip(PointFilterType.all, 'Semua'),
                  _buildTypeChip(PointFilterType.earned, 'Diperoleh'),
                  _buildTypeChip(PointFilterType.used, 'Digunakan'),
                ],
              ),
              const SizedBox(height: 24),

              // Amount range filter
              const Text(
                'Rentang Jumlah Poin',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minController,
                      decoration: InputDecoration(
                        labelText: 'Min',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _minAmount = int.tryParse(value);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _maxController,
                      decoration: InputDecoration(
                        labelText: 'Max',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _maxAmount = int.tryParse(value);
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applyFilter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF573ED1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Terapkan Filter',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(PointFilterType value, String label) {
    final isSelected = _selectedType == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = value;
        });
      },
      backgroundColor: Colors.grey[100],
      selectedColor: const Color(0xFF573ED1).withOpacity(0.1),
      checkmarkColor: const Color(0xFF573ED1),
      labelStyle: TextStyle(
        color: isSelected
            ? const Color(0xFF573ED1)
            : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? const Color(0xFF573ED1)
              : Colors.transparent,
        ),
      ),
    );
  }


}

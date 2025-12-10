import 'package:flutter/material.dart';
import '../../data/models/point_filter_model.dart';
import '../../config/app_theme.dart';
import '../../utils/responsive_helper.dart';

/// Bottom sheet widget for filtering point history
/// Allows users to filter by type (All, Addition, Deduction) and period
class FilterBottomSheet extends StatefulWidget {
  final PointFilter currentFilter;
  final Function(PointFilter) onApply;

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
  late PointFilterPeriod _selectedPeriod;
 
  @override
  void initState() {
    super.initState();
    _selectedType = widget.currentFilter.type;
    _selectedPeriod = widget.currentFilter.period;
  }

  void _applyFilter() {
    final newFilter = PointFilter(
      type: _selectedType,
      period: _selectedPeriod,
    );
    widget.onApply(newFilter);
    Navigator.pop(context);
  }

  void _resetFilter() {
    setState(() {
      _selectedType = PointFilterType.all;
      _selectedPeriod = PointFilterPeriod.allTime;
    });
  }

  int get _activeFilterCount {
    int count = 0;
    if (_selectedType != PointFilterType.all) count++;
    if (_selectedPeriod != PointFilterPeriod.allTime) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = ResponsiveHelper.getBottomSheetMaxHeight(context);
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Filter Riwayat',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  if (_activeFilterCount > 0)
                    Semantics(
                      label: '$_activeFilterCount filter aktif',
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(87, 62, 209, 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExcludeSemantics(
                          child: Text(
                            '$_activeFilterCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content - Make scrollable
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type Filter Section
                      Text(
                        'Jenis Transaksi',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _buildTypeFilterOptions(),
                      const SizedBox(height: 24),

                      // Period Filter Section
                      Text(
                        'Periode Waktu',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _buildPeriodFilterOptions(),
                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: Semantics(
                              button: true,
                              label: 'Tombol reset filter',
                              hint: 'Ketuk untuk menghapus semua filter',
                              child: OutlinedButton(
                                onPressed: _resetFilter,
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: const BorderSide(
                                    color: Color.fromRGBO(87, 62, 209, 1),
                                    width: 1.5,
                                  ),
                                  foregroundColor: Color.fromRGBO(87, 62, 209, 1),
                                ),
                                child: const Text(
                                  'Reset',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Semantics(
                              button: true,
                              label: 'Tombol terapkan filter',
                              hint: 'Ketuk untuk menerapkan filter yang dipilih',
                              child: ElevatedButton(
                                onPressed: _applyFilter,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: Color.fromRGBO(87, 62, 209, 1),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text(
                                  'Terapkan Filter',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeFilterOptions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildFilterChip(
          label: 'Semua',
          isSelected: _selectedType == PointFilterType.all,
          onTap: () {
            setState(() {
              _selectedType = PointFilterType.all;
            });
          },
        ),
        _buildFilterChip(
          label: 'Penambahan',
          isSelected: _selectedType == PointFilterType.addition,
          onTap: () {
            setState(() {
              _selectedType = PointFilterType.addition;
            });
          },
          icon: Icons.add_circle_outline,
          iconColor: Colors.green,
        ),
        _buildFilterChip(
          label: 'Pengurangan',
          isSelected: _selectedType == PointFilterType.deduction,
          onTap: () {
            setState(() {
              _selectedType = PointFilterType.deduction;
            });
          },
          icon: Icons.remove_circle_outline,
          iconColor: Colors.red,
        ),
      ],
    );
  }

  Widget _buildPeriodFilterOptions() {
    return Column(
      children: [
        _buildPeriodOption(
          label: 'Semua Waktu',
          period: PointFilterPeriod.allTime,
        ),
        const SizedBox(height: 8),
        _buildPeriodOption(
          label: 'Bulan Ini',
          period: PointFilterPeriod.thisMonth,
        ),
        const SizedBox(height: 8),
        _buildPeriodOption(
          label: '3 Bulan Terakhir',
          period: PointFilterPeriod.last3Months,
        ),
        const SizedBox(height: 8),
        _buildPeriodOption(
          label: '6 Bulan Terakhir',
          period: PointFilterPeriod.last6Months,
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
    Color? iconColor,
  }) {
    return Semantics(
      button: true,
      label: 'Filter $label',
      hint: isSelected ? 'Dipilih' : 'Ketuk untuk memilih',
      selected: isSelected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color.fromRGBO(87, 62, 209, 1) : Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color.fromRGBO(87, 62, 209, 1) : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                ExcludeSemantics(
                  child: Icon(
                    icon,
                    size: 18,
                    color: isSelected ? Colors.white : iconColor,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              ExcludeSemantics(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodOption({
    required String label,
    required PointFilterPeriod period,
  }) {
    final isSelected = _selectedPeriod == period;
    return Semantics(
      button: true,
      label: 'Periode $label',
      hint: isSelected ? 'Dipilih' : 'Ketuk untuk memilih',
      selected: isSelected,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 48,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color.fromRGBO(87, 62, 209, 0.1) : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color.fromRGBO(87, 62, 209, 1) : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? const Color.fromRGBO(87, 62, 209, 1) : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color.fromRGBO(87, 62, 209, 1),
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

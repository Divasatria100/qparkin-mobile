import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/parking_floor_model.dart';
import 'shimmer_loading.dart';

/// Widget to display list of parking floors with availability information
/// Allows users to select a floor for slot reservation
///
/// Requirements: 1.1-1.9, 9.1-9.10, 13.1-13.10, 15.1-15.9
class FloorSelectorWidget extends StatefulWidget {
  final List<ParkingFloorModel> floors;
  final ParkingFloorModel? selectedFloor;
  final Function(ParkingFloorModel) onFloorSelected;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const FloorSelectorWidget({
    Key? key,
    required this.floors,
    this.selectedFloor,
    required this.onFloorSelected,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  }) : super(key: key);

  @override
  State<FloorSelectorWidget> createState() => _FloorSelectorWidgetState();
}

class _FloorSelectorWidgetState extends State<FloorSelectorWidget> {
  int _focusedIndex = 0;
  final Map<int, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    _initializeFocusNodes();
  }

  @override
  void didUpdateWidget(FloorSelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.floors.length != widget.floors.length) {
      _initializeFocusNodes();
    }
  }

  @override
  void dispose() {
    for (var node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _initializeFocusNodes() {
    // Clear existing nodes
    for (var node in _focusNodes.values) {
      node.dispose();
    }
    _focusNodes.clear();

    // Create focus nodes for each floor
    for (int i = 0; i < widget.floors.length; i++) {
      _focusNodes[i] = FocusNode();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildLoadingState();
    }

    if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty) {
      return _buildErrorState(context);
    }

    if (widget.floors.isEmpty) {
      return _buildEmptyState();
    }

    return _buildFloorList();
  }

  /// Build shimmer loading state for floors
  /// Requirements: 15.1-15.9
  Widget _buildLoadingState() {
    return Semantics(
      label: 'Memuat daftar lantai parkir',
      hint: 'Mohon tunggu, sedang memuat data lantai',
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _FloorCardShimmer(),
          ),
        ),
      ),
    );
  }

  /// Build error state with retry button
  /// Requirements: 15.1-15.9
  Widget _buildErrorState(BuildContext context) {
    return Semantics(
      label: 'Gagal memuat data lantai',
      hint: 'Terjadi kesalahan saat memuat data lantai. Ketuk tombol coba lagi untuk memuat ulang',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.red.shade200,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade700,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat data lantai',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.errorMessage ?? 'Terjadi kesalahan. Silakan coba lagi.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'Tombol coba lagi',
              hint: 'Ketuk untuk memuat ulang data lantai',
              button: true,
              child: ElevatedButton.icon(
                onPressed: widget.onRetry,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF573ED1),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(48, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state when no floors available
  /// Requirements: 15.1-15.9
  Widget _buildEmptyState() {
    return Semantics(
      label: 'Tidak ada lantai parkir tersedia',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.layers_outlined,
              color: Colors.grey.shade400,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada lantai tersedia',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada data lantai parkir untuk mall ini',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build list of floor cards
  /// Requirements: 1.1-1.9, 9.1-9.10, 13.1-13.10
  Widget _buildFloorList() {
    return Column(
      children: List.generate(widget.floors.length, (index) {
        final floor = widget.floors[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _FloorCard(
            floor: floor,
            isSelected: widget.selectedFloor?.idFloor == floor.idFloor,
            focusNode: _focusNodes[index]!,
            onTap: () => _handleFloorSelection(floor),
            onKeyEvent: (event) => _handleKeyEvent(event, index),
          ),
        );
      }),
    );
  }

  /// Handle keyboard navigation for floor selection
  /// Requirements: 9.1-9.10
  KeyEventResult _handleKeyEvent(KeyEvent event, int currentIndex) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    // Arrow Up - move to previous floor
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (currentIndex > 0) {
        setState(() {
          _focusedIndex = currentIndex - 1;
        });
        _focusNodes[_focusedIndex]?.requestFocus();
      }
      return KeyEventResult.handled;
    }

    // Arrow Down - move to next floor
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (currentIndex < widget.floors.length - 1) {
        setState(() {
          _focusedIndex = currentIndex + 1;
        });
        _focusNodes[_focusedIndex]?.requestFocus();
      }
      return KeyEventResult.handled;
    }

    // Enter or Space - select floor
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      final floor = widget.floors[currentIndex];
      if (floor.hasAvailableSlots) {
        _handleFloorSelection(floor);
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  /// Handle floor selection with haptic feedback
  /// Requirements: 1.1-1.9, 9.1-9.10
  void _handleFloorSelection(ParkingFloorModel floor) {
    if (floor.hasAvailableSlots) {
      // Provide haptic feedback
      HapticFeedback.lightImpact();
      widget.onFloorSelected(floor);
    }
  }
}

/// Individual floor card component
/// Requirements: 1.1-1.9, 9.1-9.10, 13.1-13.10
class _FloorCard extends StatelessWidget {
  final ParkingFloorModel floor;
  final bool isSelected;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final KeyEventResult Function(KeyEvent)? onKeyEvent;

  const _FloorCard({
    Key? key,
    required this.floor,
    required this.isSelected,
    required this.focusNode,
    required this.onTap,
    this.onKeyEvent,
  }) : super(key: key);

  Color _getAvailabilityColor() {
    if (!floor.hasAvailableSlots) {
      return Colors.grey.shade400;
    }
    return const Color(0xFF4CAF50); // Green for available
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = floor.hasAvailableSlots;
    final availabilityColor = _getAvailabilityColor();

    return Focus(
      focusNode: focusNode,
      onKeyEvent: onKeyEvent != null
          ? (node, event) => onKeyEvent!(event)
          : null,
      child: Builder(
        builder: (context) {
          final isFocused = Focus.of(context).hasFocus;
          
          return Semantics(
            label: 'Lantai ${floor.floorNumber}, ${floor.floorName}',
            hint: '${floor.availableSlots} slot tersedia. ${isEnabled ? "Ketuk untuk melihat slot" : "Tidak tersedia"}',
            button: true,
            enabled: isEnabled,
            selected: isSelected,
            focused: isFocused,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isEnabled ? onTap : null,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF573ED1).withOpacity(0.05)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isFocused
                          ? const Color(0xFF573ED1)
                          : isSelected
                              ? const Color(0xFF573ED1)
                              : Colors.grey.shade200,
                      width: isFocused || isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Floor number badge
                      _buildFloorBadge(),
                      const SizedBox(width: 16),
                      // Floor info
                      Expanded(
                        child: _buildFloorInfo(availabilityColor),
                      ),
                      // Chevron icon
                      Icon(
                        Icons.chevron_right,
                        size: 24,
                        color: isEnabled ? Colors.grey.shade400 : Colors.grey.shade300,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build floor number badge
  /// Requirements: 1.1-1.9, 13.1-13.10
  Widget _buildFloorBadge() {
    return Semantics(
      label: 'Nomor lantai ${floor.floorNumber}',
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF573ED1)
              : const Color(0xFF573ED1).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            floor.floorNumber.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF573ED1),
            ),
          ),
        ),
      ),
    );
  }

  /// Build floor information section
  /// Requirements: 1.1-1.9, 13.1-13.10
  Widget _buildFloorInfo(Color availabilityColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Floor name
        Semantics(
          label: 'Nama lantai',
          child: Text(
            floor.floorName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Availability info
        Semantics(
          label: 'Ketersediaan slot',
          child: Row(
            children: [
              Icon(
                Icons.local_parking,
                size: 16,
                color: availabilityColor,
              ),
              const SizedBox(width: 4),
              Text(
                floor.availabilityText,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Shimmer loading skeleton for floor card
/// Requirements: 15.1-15.9
class _FloorCardShimmer extends StatelessWidget {
  const _FloorCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Floor badge shimmer
          ShimmerLoading(
            width: 56,
            height: 56,
            borderRadius: BorderRadius.circular(28),
          ),
          const SizedBox(width: 16),
          // Floor info shimmer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerLoading(
                  width: 120,
                  height: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                ShimmerLoading(
                  width: 100,
                  height: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          // Chevron shimmer
          ShimmerLoading(
            width: 24,
            height: 24,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

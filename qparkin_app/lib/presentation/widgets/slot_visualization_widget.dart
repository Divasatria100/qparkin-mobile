import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/parking_slot_model.dart';
import 'shimmer_loading.dart';

/// Widget to display parking slot availability visualization (non-interactive)
/// Shows slot status with color coding but does not allow user interaction
///
/// Requirements: 2.1-2.11, 9.1-9.10, 13.1-13.10, 14.1-14.10
class SlotVisualizationWidget extends StatefulWidget {
  final List<ParkingSlotModel> slots;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRefresh;
  final DateTime? lastUpdated;
  final int availableCount;
  final int totalCount;

  const SlotVisualizationWidget({
    Key? key,
    required this.slots,
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
    this.lastUpdated,
    required this.availableCount,
    required this.totalCount,
  }) : super(key: key);

  @override
  State<SlotVisualizationWidget> createState() => _SlotVisualizationWidgetState();
}

class _SlotVisualizationWidgetState extends State<SlotVisualizationWidget> {
  int _focusedSlotIndex = 0;
  final FocusNode _gridFocusNode = FocusNode();

  @override
  void dispose() {
    _gridFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title, count, and refresh button
        _buildHeader(context),
        const SizedBox(height: 12),
        
        // Color legend for accessibility
        _buildColorLegend(context),
        const SizedBox(height: 16),
        
        // Slot visualization grid or loading/error state
        if (widget.isLoading)
          _buildLoadingState()
        else if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty)
          _buildErrorState(context)
        else if (widget.slots.isEmpty)
          _buildEmptyState()
        else
          _buildSlotGrid(context),
      ],
    );
  }

  /// Build color legend to explain status colors
  /// Requirements: 9.1-9.10 (color contrast and text labels)
  Widget _buildColorLegend(BuildContext context) {
    return Semantics(
      label: 'Keterangan warna status slot',
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          _buildLegendItem(
            color: const Color(0xFF4CAF50),
            label: 'Tersedia',
            icon: Icons.check_circle_outline,
          ),
          _buildLegendItem(
            color: const Color(0xFF9E9E9E),
            label: 'Terisi',
            icon: Icons.cancel_outlined,
          ),
          _buildLegendItem(
            color: const Color(0xFFFF9800),
            label: 'Direservasi',
            icon: Icons.schedule,
          ),
          _buildLegendItem(
            color: const Color(0xFFF44336),
            label: 'Nonaktif',
            icon: Icons.block,
          ),
        ],
      ),
    );
  }

  /// Build individual legend item
  Widget _buildLegendItem({
    required Color color,
    required String label,
    required IconData icon,
  }) {
    return Semantics(
      label: '$label, ditandai dengan warna',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              icon,
              size: 10,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build header with title, count, timestamp, and refresh button
  /// Requirements: 2.1-2.11, 14.1-14.10
  Widget _buildHeader(BuildContext context) {
    return Semantics(
      label: 'Ketersediaan Slot Parkir',
      hint: '${widget.availableCount} slot tersedia dari ${widget.totalCount} total slot',
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  'Ketersediaan Slot',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                // Available count
                Semantics(
                  label: 'Jumlah slot tersedia',
                  child: Text(
                    '${widget.availableCount} slot tersedia dari ${widget.totalCount} total',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Last updated timestamp
                if (widget.lastUpdated != null)
                  Semantics(
                    label: 'Terakhir diperbarui',
                    child: Text(
                      'Terakhir diperbarui: ${_formatTime(widget.lastUpdated!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Refresh button
          if (widget.onRefresh != null)
            Semantics(
              label: 'Tombol perbarui',
              hint: 'Ketuk untuk memperbarui ketersediaan slot',
              button: true,
              child: IconButton(
                onPressed: widget.isLoading ? null : widget.onRefresh,
                icon: widget.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF573ED1),
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.refresh,
                        size: 24,
                        color: Color(0xFF573ED1),
                      ),
                tooltip: 'Perbarui ketersediaan slot',
              ),
            ),
        ],
      ),
    );
  }

  /// Build slot grid with responsive columns and keyboard navigation
  /// Requirements: 2.1-2.11, 9.1-9.10, 13.1-13.10, 14.1-14.10
  Widget _buildSlotGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _calculateColumns(screenWidth);

    return Focus(
      focusNode: _gridFocusNode,
      onKeyEvent: (node, event) => _handleKeyEvent(event, crossAxisCount),
      child: Semantics(
        label: 'Visualisasi slot parkir',
        hint: 'Menampilkan ${widget.totalCount} slot dengan status warna berbeda. Gunakan tombol panah untuk navigasi',
        readOnly: true,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: widget.slots.length,
          itemBuilder: (context, index) {
            return _SlotCard(
              slot: widget.slots[index],
              isFocused: _focusedSlotIndex == index,
            );
          },
        ),
      ),
    );
  }

  /// Handle keyboard navigation for slot grid
  /// Requirements: 9.1-9.10
  KeyEventResult _handleKeyEvent(KeyEvent event, int columns) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    // Arrow Right - move to next slot
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (_focusedSlotIndex < widget.slots.length - 1) {
        setState(() {
          _focusedSlotIndex++;
        });
        _announceSlotFocus();
      }
      return KeyEventResult.handled;
    }

    // Arrow Left - move to previous slot
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (_focusedSlotIndex > 0) {
        setState(() {
          _focusedSlotIndex--;
        });
        _announceSlotFocus();
      }
      return KeyEventResult.handled;
    }

    // Arrow Down - move to slot below
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      final newIndex = _focusedSlotIndex + columns;
      if (newIndex < widget.slots.length) {
        setState(() {
          _focusedSlotIndex = newIndex;
        });
        _announceSlotFocus();
      }
      return KeyEventResult.handled;
    }

    // Arrow Up - move to slot above
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      final newIndex = _focusedSlotIndex - columns;
      if (newIndex >= 0) {
        setState(() {
          _focusedSlotIndex = newIndex;
        });
        _announceSlotFocus();
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  /// Announce focused slot to screen readers
  /// Requirements: 9.1-9.10
  void _announceSlotFocus() {
    // Screen reader will automatically announce the focused slot's semantic label
    // No explicit announcement needed as the Semantics widget handles this
  }

  /// Calculate number of columns based on screen width
  /// Requirements: 14.1-14.10
  int _calculateColumns(double screenWidth) {
    if (screenWidth < 360) return 4;
    if (screenWidth < 414) return 5;
    return 6;
  }

  /// Build loading state with shimmer effect
  /// Requirements: 14.1-14.10
  Widget _buildLoadingState() {
    return Semantics(
      label: 'Memuat visualisasi slot',
      hint: 'Mohon tunggu, sedang memuat data slot',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.0,
        ),
        itemCount: 20,
        itemBuilder: (context, index) {
          return const _SlotCardShimmer();
        },
      ),
    );
  }

  /// Build error state with retry option
  /// Requirements: 2.1-2.11
  Widget _buildErrorState(BuildContext context) {
    return Semantics(
      label: 'Gagal memuat tampilan slot',
      hint: 'Terjadi kesalahan saat memuat data slot. Ketuk tombol coba lagi untuk memuat ulang',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
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
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat tampilan slot',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.errorMessage ?? 'Terjadi kesalahan. Silakan coba lagi.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.onRefresh != null) ...[
              const SizedBox(height: 12),
              Semantics(
                label: 'Tombol coba lagi',
                hint: 'Ketuk untuk memuat ulang data slot',
                button: true,
                child: ElevatedButton.icon(
                  onPressed: widget.onRefresh,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF573ED1),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(48, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build empty state when no slots available
  /// Requirements: 2.1-2.11
  Widget _buildEmptyState() {
    return Semantics(
      label: 'Tidak ada data slot',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.grid_off,
              color: Colors.grey.shade400,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada data slot',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada data slot untuk lantai ini',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Format time for display
  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// Individual slot card component (non-interactive, display-only)
/// Requirements: 2.1-2.11, 9.1-9.10, 13.1-13.10
class _SlotCard extends StatelessWidget {
  final ParkingSlotModel slot;
  final bool isFocused;

  const _SlotCard({
    Key? key,
    required this.slot,
    this.isFocused = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Slot ${slot.slotCode}',
      hint: '${slot.statusLabel}, ${slot.typeLabel}',
      readOnly: true,
      focused: isFocused,
      child: Container(
        decoration: BoxDecoration(
          color: slot.statusColor,
          borderRadius: BorderRadius.circular(8),
          border: isFocused
              ? Border.all(
                  color: const Color(0xFF573ED1),
                  width: 2,
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Slot type icon
            Icon(
              slot.typeIcon,
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(height: 4),
            // Slot code
            Text(
              slot.slotCode,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading skeleton for slot card
/// Requirements: 14.1-14.10
class _SlotCardShimmer extends StatelessWidget {
  const _SlotCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      width: double.infinity,
      height: double.infinity,
      borderRadius: BorderRadius.circular(8),
    );
  }
}

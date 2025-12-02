import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// SlotReservationButton - Action button to request random slot reservation
/// 
/// This widget provides a full-width button that triggers random slot
/// reservation on the selected floor. It includes:
/// - Purple background with white text
/// - Random/casino icon
/// - Loading state during reservation
/// - Disabled state when no floor selected or slots unavailable
/// - Haptic feedback on tap
/// - Screen reader support
///
/// Design Specs:
/// - Full width button (56px height)
/// - Purple background (0xFF573ED1)
/// - White text (16px bold)
/// - 16px rounded corners
/// - Elevation 4
///
/// Requirements: 3.1-3.12, 9.1-9.10, 13.1-13.10
class SlotReservationButton extends StatelessWidget {
  /// Floor name to display in button text
  final String floorName;
  
  /// Whether the button is in loading state
  final bool isLoading;
  
  /// Whether the button is enabled
  final bool isEnabled;
  
  /// Callback when button is tapped
  final VoidCallback? onPressed;
  
  const SlotReservationButton({
    Key? key,
    required this.floorName,
    this.isLoading = false,
    this.isEnabled = true,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Pesan slot acak di $floorName',
      hint: 'Ketuk untuk mereservasi slot secara otomatis di lantai ini',
      button: true,
      enabled: isEnabled && !isLoading && onPressed != null,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: (isEnabled && !isLoading && onPressed != null) ? _handleTap : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled
                ? const Color(0xFF573ED1) // Purple
                : Colors.grey[400], // Grey for disabled
            foregroundColor: Colors.white,
            elevation: isEnabled ? 4 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: isLoading ? _buildLoadingState() : _buildDefaultState(),
        ),
      ),
    );
  }

  /// Build default button state with icon and text
  Widget _buildDefaultState() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.casino, // Random/casino icon
          size: 20,
          color: Colors.white,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            'Pesan Slot Acak di $floorName',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  /// Build loading state with circular progress indicator
  Widget _buildLoadingState() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        SizedBox(width: 12),
        Text(
          'Mereservasi...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  /// Handle button tap with haptic feedback
  void _handleTap() {
    // Provide haptic feedback
    HapticFeedback.lightImpact();
    
    // Call the onPressed callback
    onPressed?.call();
  }
}

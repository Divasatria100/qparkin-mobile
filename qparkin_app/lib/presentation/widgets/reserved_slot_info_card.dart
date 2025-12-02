import 'package:flutter/material.dart';
import '../../data/models/slot_reservation_model.dart';

/// A card widget displaying reserved slot information after successful reservation
/// Shows slot code, floor name, slot type, and expiration time with success styling
class ReservedSlotInfoCard extends StatefulWidget {
  final SlotReservationModel reservation;
  final VoidCallback? onClear;

  const ReservedSlotInfoCard({
    Key? key,
    required this.reservation,
    this.onClear,
  }) : super(key: key);

  @override
  State<ReservedSlotInfoCard> createState() => _ReservedSlotInfoCardState();
}

class _ReservedSlotInfoCardState extends State<ReservedSlotInfoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Slide up animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Scale animation (1.0 -> 1.05 -> 1.0)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.05)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: _buildCard(context),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Semantics(
      label: 'Slot berhasil direservasi: ${widget.reservation.displayName}',
      hint: 'Slot ${widget.reservation.slotCode} di ${widget.reservation.floorName}, ${widget.reservation.typeLabel}',
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success header with checkmark
            _buildSuccessHeader(),
            const SizedBox(height: 12),

            // Slot information
            _buildSlotInfo(),
            const SizedBox(height: 8),

            // Expiration info
            _buildExpirationInfo(),
            const SizedBox(height: 12),

            // Info message
            _buildInfoMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Success checkmark icon
          Semantics(
            label: 'Berhasil',
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Success text
          Expanded(
            child: ExcludeSemantics(
              child: const Text(
                'Slot Berhasil Direservasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ),
          ),

          // Clear button (optional)
          if (widget.onClear != null)
            Semantics(
              label: 'Hapus reservasi',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.close, size: 20),
                color: const Color(0xFF757575),
                onPressed: widget.onClear,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSlotInfo() {
    return ExcludeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slot code and floor
          Text(
            widget.reservation.displayName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 4),

          // Slot type
          Row(
            children: [
              Icon(
                widget.reservation.slotType.icon,
                size: 16,
                color: const Color(0xFF757575),
              ),
              const SizedBox(width: 4),
              Text(
                widget.reservation.typeLabel,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757575),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpirationInfo() {
    final isExpiringSoon = widget.reservation.timeRemaining.inMinutes < 2;

    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isExpiringSoon
              ? const Color(0xFFFF9800).withOpacity(0.1)
              : const Color(0xFF573ED1).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.schedule,
              size: 16,
              color: isExpiringSoon
                  ? const Color(0xFFFF9800)
                  : const Color(0xFF573ED1),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Berlaku hingga: ${widget.reservation.formattedExpirationTime}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isExpiringSoon
                          ? const Color(0xFFFF9800)
                          : const Color(0xFF757575),
                      fontWeight: isExpiringSoon ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (isExpiringSoon) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Sisa waktu: ${widget.reservation.formattedRemainingTime}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFFF9800),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoMessage() {
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              size: 16,
              color: Color(0xFF757575),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Slot ini telah dikunci untuk Anda. Selesaikan booking sebelum waktu habis.',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF757575),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

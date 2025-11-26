import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../data/models/booking_model.dart';

/// BookingConfirmationDialog - Full-screen dialog for successful booking confirmation
///
/// Displays success animation, booking details, QR code for gate entry,
/// and navigation options to Activity Page or Home.
///
/// Requirements: 10.1-10.6
class BookingConfirmationDialog extends StatefulWidget {
  final BookingModel booking;
  final VoidCallback? onViewActivity;
  final VoidCallback? onBackToHome;

  const BookingConfirmationDialog({
    Key? key,
    required this.booking,
    this.onViewActivity,
    this.onBackToHome,
  }) : super(key: key);

  @override
  State<BookingConfirmationDialog> createState() =>
      _BookingConfirmationDialogState();
}

class _BookingConfirmationDialogState
    extends State<BookingConfirmationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for success checkmark
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Scale animation with easeOutBack curve for bounce effect
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  /// Build transparent AppBar with close button
  ///
  /// Requirements: 10.1-10.3
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.black87),
        onPressed: () => _handleClose(context),
        tooltip: 'Tutup',
      ),
    );
  }

  /// Build main body with success animation and booking details
  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Success animation and message
            _buildSuccessHeader(),

            const SizedBox(height: 32),

            // QR Code section
            _buildQRCodeSection(),

            const SizedBox(height: 24),

            // Booking summary
            _buildBookingSummary(),

            const SizedBox(height: 32),

            // Action buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  /// Build success header with animated checkmark
  ///
  /// Requirements: 10.1-10.3
  Widget _buildSuccessHeader() {
    return Column(
      children: [
        // Animated checkmark
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0x4D4CAF50), // 0xFF4CAF50 with 30% opacity
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 80,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Success message
        FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              const Text(
                'Booking Berhasil!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.booking.idTransaksi}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'ID Booking: ${widget.booking.idBooking}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build QR code section with instruction
  ///
  /// Requirements: 10.4
  Widget _buildQRCodeSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'QR Code Masuk',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // QR Code display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 2,
                  ),
                ),
                child: QrImageView(
                  data: widget.booking.qrCode,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                ),
              ),

              const SizedBox(height: 16),

              // Instruction text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0x1A573ED1), // 0xFF573ED1 with 10% opacity
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
                        'Tunjukkan di gerbang masuk',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build compact booking summary
  ///
  /// Requirements: 10.4
  Widget _buildBookingSummary() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detail Booking',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Location
              if (widget.booking.namaMall != null) ...[
                _buildSummaryRow(
                  icon: Icons.location_on,
                  label: 'Lokasi',
                  value: widget.booking.namaMall!,
                ),
                const SizedBox(height: 12),
              ],

              // Slot code
              if (widget.booking.kodeSlot != null) ...[
                _buildSummaryRow(
                  icon: Icons.local_parking,
                  label: 'Slot',
                  value: widget.booking.kodeSlot!,
                ),
                const SizedBox(height: 12),
              ],

              // Vehicle
              if (widget.booking.platNomor != null) ...[
                _buildSummaryRow(
                  icon: Icons.directions_car,
                  label: 'Kendaraan',
                  value: widget.booking.platNomor!,
                ),
                const SizedBox(height: 12),
              ],

              // Time
              _buildSummaryRow(
                icon: Icons.schedule,
                label: 'Waktu',
                value: _formatDateTime(widget.booking.waktuMulai),
              ),
              const SizedBox(height: 12),

              // Duration
              _buildSummaryRow(
                icon: Icons.timer,
                label: 'Durasi',
                value: widget.booking.formattedDuration,
              ),
              const SizedBox(height: 12),

              // Divider
              Divider(color: Colors.grey.shade200),
              const SizedBox(height: 12),

              // Cost
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Estimasi Biaya',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    widget.booking.formattedCost,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF573ED1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build summary row with icon, label, and value
  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF573ED1),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build action buttons at bottom
  ///
  /// Requirements: 10.5-10.6
  Widget _buildActionButtons(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Primary button - View Activity
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _handleViewActivity(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF573ED1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: const Color(0x66573ED1), // 0xFF573ED1 with 40% opacity
              ),
              child: const Text(
                'Lihat Aktivitas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Secondary button - Back to Home
          SizedBox(
            width: double.infinity,
            height: 56,
            child: TextButton(
              onPressed: () => _handleBackToHome(context),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF573ED1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Kembali ke Beranda',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handle close button press
  void _handleClose(BuildContext context) {
    if (widget.onBackToHome != null) {
      widget.onBackToHome!();
    } else {
      Navigator.of(context).pop();
    }
  }

  /// Handle "Lihat Aktivitas" button press
  ///
  /// Requirements: 10.5
  void _handleViewActivity(BuildContext context) {
    if (widget.onViewActivity != null) {
      widget.onViewActivity!();
    } else {
      // Default: pop dialog and navigate to activity page
      Navigator.of(context).pop();
      // TODO: Navigate to Activity Page
      // Navigator.pushReplacementNamed(context, '/activity', arguments: {'initialTab': 0});
    }
  }

  /// Handle "Kembali ke Beranda" button press
  ///
  /// Requirements: 10.6
  void _handleBackToHome(BuildContext context) {
    if (widget.onBackToHome != null) {
      widget.onBackToHome!();
    } else {
      // Default: pop dialog and return to home
      Navigator.of(context).pop();
      // TODO: Navigate to Home Page
      // Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  /// Format DateTime to readable string
  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];

    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day $month $year, $hour:$minute';
  }

  /// Show the booking confirmation dialog
  ///
  /// Static method to display the dialog from anywhere in the app.
  ///
  /// Parameters:
  /// - [context]: BuildContext for navigation
  /// - [booking]: BookingModel with booking details
  /// - [onViewActivity]: Optional callback for "Lihat Aktivitas" button
  /// - [onBackToHome]: Optional callback for "Kembali ke Beranda" button
  ///
  /// Returns: Future that completes when dialog is dismissed
  static Future<void> show(
    BuildContext context, {
    required BookingModel booking,
    VoidCallback? onViewActivity,
    VoidCallback? onBackToHome,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => BookingConfirmationDialog(
          booking: booking,
          onViewActivity: onViewActivity,
          onBackToHome: onBackToHome,
        ),
      ),
    );
  }
}

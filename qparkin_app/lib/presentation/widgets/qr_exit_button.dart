import 'package:flutter/material.dart';
import '../dialogs/qr_exit_dialog.dart';

/// QRExitButton - A prominent action button for displaying exit QR code
/// 
/// This button is the primary call-to-action for drivers to generate and
/// display their exit QR code when they're ready to leave the parking area.
class QRExitButton extends StatelessWidget {
  final String qrCode;
  final bool isEnabled;
  final bool isLoading;
  final String? mallName;
  final String? slotCode;
  final VoidCallback? onPressed;

  const QRExitButton({
    super.key,
    required this.qrCode,
    required this.isEnabled,
    this.isLoading = false,
    this.mallName,
    this.slotCode,
    this.onPressed,
  });

  void _handlePressed(BuildContext context) {
    if (onPressed != null) {
      onPressed!();
    } else {
      // Default behavior: show QR dialog
      _showQRDialog(context);
    }
  }

  Future<void> _showQRDialog(BuildContext context) async {
    try {
      await QRExitDialog.show(
        context,
        qrCode: qrCode,
        mallName: mallName,
        slotCode: slotCode,
      );
    } catch (e) {
      // Handle error gracefully
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menampilkan QR code: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build semantic label for screen readers
    final semanticLabel = isLoading 
        ? 'Memuat QR code keluar'
        : isEnabled 
            ? 'Tombol tampilkan QR keluar. Ketuk untuk menampilkan QR code keluar parkir'
            : 'Tombol tampilkan QR keluar tidak tersedia';
    
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: isEnabled && !isLoading,
      child: SizedBox(
        width: double.infinity,
        height: 56, // Meets minimum 48dp touch target
        child: ElevatedButton(
          onPressed: isEnabled && !isLoading ? () => _handlePressed(context) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled ? const Color(0xFF573ED1) : Colors.grey,
            foregroundColor: Colors.white,
            elevation: isEnabled ? 4 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: Colors.grey.withOpacity(0.5),
            disabledForegroundColor: Colors.white.withOpacity(0.5),
          ),
          child: isLoading
              ? Semantics(
                  label: 'Memuat',
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : ExcludeSemantics(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.qr_code_2,
                        size: 24,
                        color: Colors.white,
                        semanticLabel: 'Ikon QR code',
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Tampilkan QR Keluar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// QRExitDialog - Dialog for displaying exit QR code
/// 
/// This dialog shows the QR code that drivers need to scan at the exit gate
/// to complete their parking session and leave the parking area.
class QRExitDialog extends StatelessWidget {
  final String qrCode;
  final String? mallName;
  final String? slotCode;

  const QRExitDialog({
    super.key,
    required this.qrCode,
    this.mallName,
    this.slotCode,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Dialog QR keluar',
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Semantics(
                    header: true,
                    child: const Text(
                      'QR Keluar',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Semantics(
                    label: 'Tombol tutup dialog',
                    button: true,
                    child: SizedBox(
                      width: 48, // Meets minimum 48dp touch target
                      height: 48,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        color: Colors.grey.shade600,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 8),
            
            // Subtitle
            Semantics(
              label: 'Tunjukkan QR code ini di gerbang keluar',
              child: Text(
                'Tunjukkan QR code ini di gerbang keluar',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // QR Code Display
            Semantics(
              label: 'QR code keluar parkir. Kode: $qrCode',
              image: true,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ExcludeSemantics(
                  child: QrImageView(
                    data: qrCode,
                    version: QrVersions.auto,
                    size: 240,
                    backgroundColor: Colors.white,
                    errorCorrectionLevel: QrErrorCorrectLevel.H,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Location Info (if available)
            if (mallName != null || slotCode != null) ...[
              Semantics(
                label: 'Informasi lokasi: ${mallName ?? ""}${mallName != null && slotCode != null ? ", " : ""}${slotCode != null ? "Slot $slotCode" : ""}',
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF573ED1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      if (mallName != null) ...[
                        ExcludeSemantics(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 18,
                                color: Color(0xFF573ED1),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  mallName!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (mallName != null && slotCode != null)
                        const SizedBox(height: 8),
                      if (slotCode != null) ...[
                        ExcludeSemantics(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_parking,
                                size: 18,
                                color: Color(0xFF573ED1),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Slot: $slotCode',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Close Button
            Semantics(
              label: 'Tombol tutup. Ketuk untuk menutup dialog QR keluar',
              button: true,
              child: SizedBox(
                width: double.infinity,
                height: 56, // Meets minimum 48dp touch target
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF573ED1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: ExcludeSemantics(
                    child: const Text(
                      'Tutup',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
        ),
      ),
    );
  }

  /// Show the QR exit dialog
  static Future<void> show(
    BuildContext context, {
    required String qrCode,
    String? mallName,
    String? slotCode,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => QRExitDialog(
        qrCode: qrCode,
        mallName: mallName,
        slotCode: slotCode,
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Widget for displaying slot unavailability with alternative time suggestions
///
/// Shows clear unavailability message and suggests alternative time slots
/// when parking slots become unavailable during booking.
///
/// Requirements: 11.2
class SlotUnavailableWidget extends StatelessWidget {
  final DateTime currentStartTime;
  final Duration currentDuration;
  final Function(DateTime, Duration)? onSelectAlternative;
  final VoidCallback? onModifyTime;

  const SlotUnavailableWidget({
    Key? key,
    required this.currentStartTime,
    required this.currentDuration,
    this.onSelectAlternative,
    this.onModifyTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final alternatives = _generateAlternatives();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF9800),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning icon and title
          Row(
            children: [
              Icon(
                Icons.event_busy,
                color: const Color(0xFFFF9800),
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Slot Tidak Tersedia',
                      style: TextStyle(
                        color: Color(0xFFFF9800),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Slot parkir penuh untuk waktu yang dipilih',
                      style: TextStyle(
                        color: Color(0xFFFF9800),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFFF9800)),
          const SizedBox(height: 12),

          // Alternative suggestions
          const Text(
            'Waktu Alternatif:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          // Alternative time slots
          ...alternatives.map((alt) => _buildAlternativeCard(
                context,
                alt['time'] as DateTime,
                alt['duration'] as Duration,
                alt['label'] as String,
              )),

          const SizedBox(height: 16),

          // Modify time button
          if (onModifyTime != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onModifyTime,
                icon: const Icon(Icons.edit_calendar, size: 20),
                label: const Text(
                  'Ubah Waktu & Durasi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF9800),
                  side: const BorderSide(
                    color: Color(0xFFFF9800),
                    width: 2,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build alternative time slot card
  Widget _buildAlternativeCard(
    BuildContext context,
    DateTime time,
    Duration duration,
    String label,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onSelectAlternative != null
            ? () => onSelectAlternative!(time, duration)
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.access_time,
                color: const Color(0xFF573ED1),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTimeRange(time, duration),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Generate alternative time slot suggestions
  List<Map<String, dynamic>> _generateAlternatives() {
    final alternatives = <Map<String, dynamic>>[];

    // Alternative 1: 1 hour later
    alternatives.add({
      'time': currentStartTime.add(const Duration(hours: 1)),
      'duration': currentDuration,
      'label': '1 jam lebih lambat',
    });

    // Alternative 2: 2 hours later
    alternatives.add({
      'time': currentStartTime.add(const Duration(hours: 2)),
      'duration': currentDuration,
      'label': '2 jam lebih lambat',
    });

    // Alternative 3: Shorter duration (if current > 1 hour)
    if (currentDuration.inHours > 1) {
      alternatives.add({
        'time': currentStartTime,
        'duration': Duration(hours: currentDuration.inHours - 1),
        'label': 'Durasi lebih pendek (${currentDuration.inHours - 1} jam)',
      });
    }

    return alternatives;
  }

  /// Format time range for display
  String _formatTimeRange(DateTime start, Duration duration) {
    final end = start.add(duration);
    final startStr = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final endStr = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    return '$startStr - $endStr';
  }
}

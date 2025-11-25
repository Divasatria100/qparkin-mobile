import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'validation_error_text.dart';

/// Widget for selecting booking start time and duration
/// Features two-column layout with date/time picker and duration selector
///
/// Requirements: 4.1-4.9, 11.3, 12.1-12.9
class TimeDurationPicker extends StatefulWidget {
  final DateTime? startTime;
  final Duration? duration;
  final Function(DateTime) onStartTimeChanged;
  final Function(Duration) onDurationChanged;
  final String? startTimeError;
  final String? durationError;

  const TimeDurationPicker({
    Key? key,
    required this.startTime,
    required this.duration,
    required this.onStartTimeChanged,
    required this.onDurationChanged,
    this.startTimeError,
    this.durationError,
  }) : super(key: key);

  @override
  State<TimeDurationPicker> createState() => _TimeDurationPickerState();
}

class _TimeDurationPickerState extends State<TimeDurationPicker> {
  final List<Duration> _presetDurations = [
    const Duration(hours: 1),
    const Duration(hours: 2),
    const Duration(hours: 3),
    const Duration(hours: 4),
  ];

  Future<void> _selectDateTime() async {
    final now = DateTime.now();
    final initialDate = widget.startTime ?? now.add(const Duration(minutes: 15));

    // Select date
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 7)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF573ED1),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null) return;

    // Select time
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF573ED1),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime == null) return;

    final newDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    widget.onStartTimeChanged(newDateTime);
  }

  Future<void> _selectCustomDuration() async {
    int hours = widget.duration?.inHours ?? 1;
    int minutes = (widget.duration?.inMinutes ?? 0) % 60;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Pilih Durasi Custom'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Jam',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButton<int>(
                              value: hours,
                              items: List.generate(13, (index) => index)
                                  .map((h) => DropdownMenuItem(
                                        value: h,
                                        child: Text('$h'),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setDialogState(() {
                                  hours = value ?? 1;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Menit',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButton<int>(
                              value: minutes,
                              items: [0, 15, 30, 45]
                                  .map((m) => DropdownMenuItem(
                                        value: m,
                                        child: Text('$m'),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setDialogState(() {
                                  minutes = value ?? 0;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total: ${hours}h ${minutes}m',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF573ED1),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final totalMinutes = (hours * 60) + minutes;
                    if (totalMinutes >= 30) {
                      widget.onDurationChanged(Duration(minutes: totalMinutes));
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Durasi minimal 30 menit'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF573ED1),
                  ),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (minutes == 0) {
      return '$hours jam';
    }
    return '$hours jam $minutes menit';
  }

  DateTime? _calculateEndTime() {
    if (widget.startTime == null || widget.duration == null) {
      return null;
    }
    return widget.startTime!.add(widget.duration!);
  }

  @override
  Widget build(BuildContext context) {
    final endTime = _calculateEndTime();
    final hasStartTimeError = widget.startTimeError != null && widget.startTimeError!.isNotEmpty;
    final hasDurationError = widget.durationError != null && widget.durationError!.isNotEmpty;

    return Column(
      children: [
        Row(
          children: [
            // Start Time Card
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStartTimeCard(hasError: hasStartTimeError),
                  if (hasStartTimeError)
                    ValidationErrorText(errorText: widget.startTimeError),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Duration Card
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDurationCard(hasError: hasDurationError),
                  if (hasDurationError)
                    ValidationErrorText(errorText: widget.durationError),
                ],
              ),
            ),
          ],
        ),
        
        // Calculated End Time Display
        if (endTime != null) ...[
          const SizedBox(height: 12),
          _buildEndTimeDisplay(endTime),
        ],
      ],
    );
  }

  Widget _buildStartTimeCard({bool hasError = false}) {
    final timeLabel = widget.startTime != null
        ? 'Waktu mulai ${DateFormat('HH:mm, dd MMM yyyy').format(widget.startTime!)}'
        : 'Waktu mulai belum dipilih';
    
    return Semantics(
      label: timeLabel,
      hint: 'Ketuk untuk memilih tanggal dan waktu mulai booking',
      button: true,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: hasError
              ? const BorderSide(color: Color(0xFFF44336), width: 2)
              : BorderSide.none,
        ),
        color: hasError ? Colors.red.shade50 : Colors.white,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          onTap: _selectDateTime,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Semantics(
                      label: 'Ikon waktu',
                      child: const Icon(
                        Icons.schedule,
                        color: Color(0xFF573ED1),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Waktu Mulai',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.startTime != null
                      ? DateFormat('HH:mm').format(widget.startTime!)
                      : '--:--',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.startTime != null
                      ? DateFormat('dd MMM yyyy').format(widget.startTime!)
                      : 'Pilih waktu',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDurationCard({bool hasError = false}) {
    final durationLabel = widget.duration != null
        ? 'Durasi booking ${_formatDuration(widget.duration!)}'
        : 'Durasi booking belum dipilih';
    
    return Semantics(
      label: durationLabel,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: hasError
              ? const BorderSide(color: Color(0xFFF44336), width: 2)
              : BorderSide.none,
        ),
        color: hasError ? Colors.red.shade50 : Colors.white,
        shadowColor: Colors.black.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Semantics(
                    label: 'Ikon durasi',
                    child: const Icon(
                      Icons.timer,
                      color: Color(0xFFFF9800),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Durasi',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.duration != null
                    ? _formatDuration(widget.duration!)
                    : '-- jam',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Semantics(
                label: 'Pilihan durasi booking',
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ..._presetDurations.map((duration) {
                      final isSelected = widget.duration == duration;
                      return _buildDurationChip(
                        '${duration.inHours}h',
                        duration,
                        isSelected,
                      );
                    }),
                    _buildCustomChip(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationChip(String label, Duration duration, bool isSelected) {
    return Semantics(
      label: 'Durasi ${duration.inHours} jam${isSelected ? ", terpilih" : ""}',
      hint: 'Ketuk untuk memilih durasi ${duration.inHours} jam',
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: () {
          widget.onDurationChanged(duration);
          // Announce to screen reader
          SemanticsService.announce(
            'Durasi ${duration.inHours} jam dipilih',
            Directionality.of(context),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF573ED1)
                : const Color(0xFF573ED1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF573ED1),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomChip() {
    final isCustom = widget.duration != null &&
        !_presetDurations.contains(widget.duration);
    
    return Semantics(
      label: 'Durasi custom${isCustom ? ", terpilih" : ""}',
      hint: 'Ketuk untuk memilih durasi custom',
      button: true,
      selected: isCustom,
      child: InkWell(
        onTap: _selectCustomDuration,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          decoration: BoxDecoration(
            color: isCustom
                ? const Color(0xFF573ED1)
                : const Color(0xFF573ED1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'Custom',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isCustom ? Colors.white : const Color(0xFF573ED1),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEndTimeDisplay(DateTime endTime) {
    return Semantics(
      label: 'Waktu selesai booking ${DateFormat('HH:mm, dd MMM yyyy').format(endTime)}',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF573ED1).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Semantics(
              label: 'Ikon waktu selesai',
              child: const Icon(
                Icons.event_available,
                color: Color(0xFF573ED1),
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Selesai: ${DateFormat('HH:mm, dd MMM yyyy').format(endTime)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF573ED1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

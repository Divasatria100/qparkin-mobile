import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'base_parking_card.dart';

/// Unified card widget combining time and duration selection
/// 
/// Modern interface with single card layout containing:
/// - Date & time selection with enhanced picker
/// - Large duration chips (80x56px)
/// - Calculated end time display
/// - Responsive layout for different screen sizes
///
/// Requirements: 4.1-4.9, 5.1-5.11, 6.1-6.13, 7.1-7.9, 8.1-8.8, 13.1-13.10
class UnifiedTimeDurationCard extends StatefulWidget {
  final DateTime? startTime;
  final Duration? duration;
  final Function(DateTime) onTimeChanged;
  final Function(Duration) onDurationChanged;
  final String? startTimeError;
  final String? durationError;

  const UnifiedTimeDurationCard({
    Key? key,
    required this.startTime,
    required this.duration,
    required this.onTimeChanged,
    required this.onDurationChanged,
    this.startTimeError,
    this.durationError,
  }) : super(key: key);

  @override
  State<UnifiedTimeDurationCard> createState() => _UnifiedTimeDurationCardState();
}

class _UnifiedTimeDurationCardState extends State<UnifiedTimeDurationCard> with SingleTickerProviderStateMixin {
  // Preset duration options
  final List<Duration> _presetDurations = [
    const Duration(hours: 1),
    const Duration(hours: 2),
    const Duration(hours: 3),
    const Duration(hours: 4),
  ];

  // Animation controller for end time display
  late AnimationController _endTimeAnimationController;
  late Animation<double> _endTimeFadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller for end time fade
    _endTimeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _endTimeFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _endTimeAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Start animation if we have end time
    if (_calculateEndTime() != null) {
      _endTimeAnimationController.forward();
    }
  }

  @override
  void didUpdateWidget(UnifiedTimeDurationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Trigger fade animation when end time changes
    if (oldWidget.startTime != widget.startTime || 
        oldWidget.duration != widget.duration) {
      _endTimeAnimationController.reset();
      if (_calculateEndTime() != null) {
        _endTimeAnimationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _endTimeAnimationController.dispose();
    super.dispose();
  }

  /// Calculate end time based on start time and duration
  DateTime? _calculateEndTime() {
    if (widget.startTime == null || widget.duration == null) {
      return null;
    }
    return widget.startTime!.add(widget.duration!);
  }

  /// Get responsive padding based on screen width
  double _getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 375) return 16.0;
    if (width < 414) return 20.0;
    return 24.0;
  }

  /// Get responsive font size
  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    
    double fontSize = baseSize;
    if (width < 375) {
      fontSize = baseSize - 2;
    } else if (width > 414) {
      fontSize = baseSize + 2;
    }
    
    // Support up to 200% font scaling
    return fontSize * textScaleFactor.clamp(1.0, 2.0);
  }

  /// Check if screen is small (should stack chips vertically)
  bool _isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  @override
  Widget build(BuildContext context) {
    final padding = _getResponsivePadding(context);
    final hasStartTimeError = widget.startTimeError != null && widget.startTimeError!.isNotEmpty;
    final hasDurationError = widget.durationError != null && widget.durationError!.isNotEmpty;
    
    return BaseParkingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context),
          
          SizedBox(height: padding * 0.83), // 20px at 24px padding
          
          // Date & Time Section
          _buildDateTimeSection(context, hasError: hasStartTimeError),
          
          if (hasStartTimeError) ...[
            const SizedBox(height: 8),
            _buildErrorText(widget.startTimeError!),
          ],
          
          SizedBox(height: padding * 0.83),
          
          Divider(color: Colors.grey.shade200, height: 1),
          
          SizedBox(height: padding * 0.83),
          
          // Duration Selection Section
          _buildDurationSection(context, hasError: hasDurationError),
          
          if (hasDurationError) ...[
            const SizedBox(height: 8),
            _buildErrorText(widget.durationError!),
          ],
          
          SizedBox(height: padding * 0.67), // 16px at 24px padding
          
          Divider(color: Colors.grey.shade200, height: 1),
          
          SizedBox(height: padding * 0.67),
          
          // Calculated End Time Display
          if (_calculateEndTime() != null)
            _buildEndTimeDisplay(context),
        ],
      ),
    );
  }

  /// Build card header
  Widget _buildHeader(BuildContext context) {
    final fontSize = _getResponsiveFontSize(context, 18);
    
    return Semantics(
      header: true,
      label: 'Waktu dan Durasi Booking',
      child: Text(
        'Waktu & Durasi Booking',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  /// Build date & time selection section
  Widget _buildDateTimeSection(BuildContext context, {bool hasError = false}) {
    final fontSize = _getResponsiveFontSize(context, 20);
    final labelFontSize = _getResponsiveFontSize(context, 14);
    
    final dateLabel = widget.startTime != null
        ? _formatDate(widget.startTime!)
        : 'Pilih tanggal';
    
    final timeLabel = widget.startTime != null
        ? _formatTime(widget.startTime!)
        : '--:--';
    
    return Semantics(
      label: widget.startTime != null
          ? 'Waktu mulai booking: $dateLabel pukul $timeLabel'
          : 'Waktu mulai booking belum dipilih',
      hint: 'Ketuk untuk memilih tanggal dan waktu',
      button: true,
      child: InkWell(
        onTap: _selectDateTime,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hasError ? Colors.red.shade50 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Calendar icon
              Icon(
                Icons.calendar_today,
                color: hasError ? Colors.red : const Color(0xFF573ED1),
                size: 24,
              ),
              
              const SizedBox(width: 12),
              
              // Date and time display
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateLabel,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeLabel,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: hasError ? Colors.red : const Color(0xFF573ED1),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Chevron icon
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build duration selection section
  Widget _buildDurationSection(BuildContext context, {bool hasError = false}) {
    final fontSize = _getResponsiveFontSize(context, 16);
    final labelFontSize = _getResponsiveFontSize(context, 14);
    final isSmall = _isSmallScreen(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Text(
          'Pilih Durasi',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Duration chips
        Semantics(
          label: 'Pilihan durasi booking',
          child: isSmall
              ? _buildVerticalDurationChips(context)
              : _buildHorizontalDurationChips(context),
        ),
        
        // Selected duration display
        if (widget.duration != null) ...[
          const SizedBox(height: 12),
          Text(
            'Durasi: ${_formatDuration(widget.duration!)}',
            style: TextStyle(
              fontSize: labelFontSize,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }

  /// Build horizontal scrollable duration chips
  Widget _buildHorizontalDurationChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ..._presetDurations.map((duration) {
            final isSelected = widget.duration == duration;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildDurationChip(
                context,
                '${duration.inHours} Jam',
                duration,
                isSelected,
              ),
            );
          }),
          _buildCustomDurationChip(context),
        ],
      ),
    );
  }

  /// Build vertical stacked duration chips for small screens
  Widget _buildVerticalDurationChips(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ..._presetDurations.map((duration) {
          final isSelected = widget.duration == duration;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildDurationChip(
              context,
              '${duration.inHours} Jam',
              duration,
              isSelected,
            ),
          );
        }),
        _buildCustomDurationChip(context),
      ],
    );
  }

  /// Build individual duration chip
  Widget _buildDurationChip(
    BuildContext context,
    String label,
    Duration duration,
    bool isSelected,
  ) {
    final fontSize = _getResponsiveFontSize(context, 16);
    
    return Semantics(
      label: 'Durasi ${duration.inHours} jam${isSelected ? ", terpilih" : ""}',
      hint: 'Ketuk untuk memilih durasi ${duration.inHours} jam',
      button: true,
      selected: isSelected,
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: InkWell(
          onTap: () {
            // Provide haptic feedback
            HapticFeedback.lightImpact();
            
            // Trigger scale animation
            widget.onDurationChanged(duration);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(
              minWidth: 80,
              minHeight: 56,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF573ED1)
                  : const Color(0xFFE8E0FF),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF573ED1).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected) ...[
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF573ED1),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build custom duration chip (> 4 Jam)
  Widget _buildCustomDurationChip(BuildContext context) {
    final fontSize = _getResponsiveFontSize(context, 16);
    final isCustom = widget.duration != null &&
        !_presetDurations.contains(widget.duration);
    
    return Semantics(
      label: 'Durasi custom${isCustom ? ", terpilih" : ""}',
      hint: 'Ketuk untuk memilih durasi custom',
      button: true,
      selected: isCustom,
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: InkWell(
          onTap: () {
            // Provide haptic feedback
            HapticFeedback.lightImpact();
            
            // Open custom duration dialog
            _selectCustomDuration();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(
              minWidth: 80,
              minHeight: 56,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isCustom
                  ? const Color(0xFF573ED1)
                  : const Color(0xFFE8E0FF),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isCustom
                  ? [
                      BoxShadow(
                        color: const Color(0xFF573ED1).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isCustom) ...[
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  '> 4 Jam',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: isCustom ? Colors.white : const Color(0xFF573ED1),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build calculated end time display
  Widget _buildEndTimeDisplay(BuildContext context) {
    final endTime = _calculateEndTime()!;
    final fontSize = _getResponsiveFontSize(context, 16);
    final labelFontSize = _getResponsiveFontSize(context, 14);
    
    final endTimeLabel = '${_formatDate(endTime, abbreviated: true)} - ${_formatTime(endTime)}';
    final durationLabel = widget.duration != null
        ? 'Total: ${_formatDuration(widget.duration!)}'
        : '';
    
    return FadeTransition(
      opacity: _endTimeFadeAnimation,
      child: Semantics(
        label: 'Waktu selesai booking: $endTimeLabel. $durationLabel',
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8E0FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Clock icon
              const Icon(
                Icons.schedule,
                color: Color(0xFF573ED1),
                size: 20,
              ),
              
              const SizedBox(width: 8),
              
              // End time details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selesai:',
                      style: TextStyle(
                        fontSize: labelFontSize,
                        color: const Color(0xFF573ED1),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      endTimeLabel,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF573ED1),
                      ),
                    ),
                    if (widget.duration != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        durationLabel,
                        style: TextStyle(
                          fontSize: labelFontSize - 2,
                          color: const Color(0xFF573ED1),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build error text
  Widget _buildErrorText(String error) {
    return Row(
      children: [
        const Icon(
          Icons.error_outline,
          color: Color(0xFFF44336),
          size: 16,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            error,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFF44336),
            ),
          ),
        ),
      ],
    );
  }

  /// Select date and time with enhanced picker
  Future<void> _selectDateTime() async {
    final now = DateTime.now();
    final initialDate = widget.startTime ?? now.add(const Duration(minutes: 15));

    // Select date with purple theme
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(now) ? initialDate : now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 7)),
      helpText: 'Pilih Tanggal Booking',
      cancelText: 'Batal',
      confirmText: 'OK',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF573ED1),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null) return;

    // Auto-open time picker after date selection
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      helpText: 'Pilih Waktu Booking',
      cancelText: 'Batal',
      confirmText: 'OK',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF573ED1),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (selectedTime == null) return;

    // Combine date and time
    final newDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // Validate: not in the past
    if (newDateTime.isBefore(now)) {
      _showValidationError('Waktu tidak boleh di masa lalu');
      return;
    }

    // Validate: max 7 days in future
    if (newDateTime.isAfter(now.add(const Duration(days: 7)))) {
      _showValidationError('Booking maksimal 7 hari ke depan');
      return;
    }

    widget.onTimeChanged(newDateTime);
  }

  /// Show "Sekarang + 15 menit" quick action
  /// Note: This is implemented as default behavior in the date picker
  /// The initial time is always set to now + 15 minutes

  /// Select custom duration with dialog
  Future<void> _selectCustomDuration() async {
    int hours = widget.duration?.inHours ?? 5;
    int minutes = (widget.duration?.inMinutes ?? 0) % 60;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final totalMinutes = (hours * 60) + minutes;
            final isValid = totalMinutes >= 30;
            
            return AlertDialog(
              title: const Text('Pilih Durasi Custom'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Hours picker
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
                              isExpanded: true,
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
                      
                      // Minutes picker
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
                              isExpanded: true,
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
                  
                  // Total duration preview
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isValid
                          ? const Color(0xFFE8E0FF)
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Total: ${hours}h ${minutes}m',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isValid
                                ? const Color(0xFF573ED1)
                                : Colors.red,
                          ),
                        ),
                        if (!isValid) ...[
                          const SizedBox(height: 4),
                          const Text(
                            'Durasi minimal 30 menit',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ],
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
                  onPressed: isValid
                      ? () {
                          widget.onDurationChanged(Duration(minutes: totalMinutes));
                          Navigator.pop(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF573ED1),
                    disabledBackgroundColor: Colors.grey.shade300,
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

  /// Show validation error snackbar
  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF44336),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Format duration for display
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (minutes == 0) {
      return '$hours jam';
    }
    return '$hours jam $minutes menit';
  }

  /// Safe date formatting with fallback
  String _formatDate(DateTime dateTime, {bool abbreviated = false}) {
    try {
      // Try to use Indonesian locale
      final pattern = abbreviated ? 'EEEE, dd MMM yyyy' : 'EEEE, dd MMMM yyyy';
      return DateFormat(pattern, 'id_ID').format(dateTime);
    } catch (e) {
      // Fallback to manual formatting if locale not initialized
      final weekdays = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
      final monthsFull = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final monthsAbbr = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      
      final weekday = weekdays[dateTime.weekday % 7];
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = abbreviated ? monthsAbbr[dateTime.month - 1] : monthsFull[dateTime.month - 1];
      final year = dateTime.year;
      
      return '$weekday, $day $month $year';
    }
  }

  /// Safe time formatting with fallback
  String _formatTime(DateTime dateTime) {
    try {
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      // Fallback to manual formatting
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
  }
}

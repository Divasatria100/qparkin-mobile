import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Timer data model for ValueNotifier
class TimerData {
  final Duration duration;
  final double progress;
  final String label;

  const TimerData({
    required this.duration,
    required this.progress,
    required this.label,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimerData &&
          runtimeType == other.runtimeType &&
          duration == other.duration &&
          progress == other.progress &&
          label == other.label;

  @override
  int get hashCode => duration.hashCode ^ progress.hashCode ^ label.hashCode;
}

/// A circular timer widget with animated progress ring
/// Displays elapsed or remaining time with a gradient progress indicator
/// Optimized with ValueNotifier to minimize rebuilds
class CircularTimerWidget extends StatefulWidget {
  final DateTime startTime;
  final DateTime? endTime;
  final bool isBooking;
  final Function(Duration) onTimerUpdate;

  const CircularTimerWidget({
    super.key,
    required this.startTime,
    this.endTime,
    required this.isBooking,
    required this.onTimerUpdate,
  });

  @override
  State<CircularTimerWidget> createState() => _CircularTimerWidgetState();
}

class _CircularTimerWidgetState extends State<CircularTimerWidget> with WidgetsBindingObserver {
  Timer? _timer;
  late ValueNotifier<TimerData> _timerNotifier;
  DateTime? _pausedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize ValueNotifier with initial timer data
    final label = widget.isBooking ? 'Sisa Waktu Booking' : 'Durasi Parkir';
    _timerNotifier = ValueNotifier(TimerData(
      duration: Duration.zero,
      progress: 0.0,
      label: label,
    ));
    
    _startTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App going to background - save state
        _pauseTimer();
        break;
      case AppLifecycleState.resumed:
        // App returning to foreground - resume timer
        _resumeTimer();
        break;
      case AppLifecycleState.detached:
        // App being terminated
        _stopTimer();
        break;
      case AppLifecycleState.hidden:
        // App hidden but still running
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
    _timerNotifier.dispose();
    super.dispose();
  }

  void _pauseTimer() {
    _pausedTime = DateTime.now();
    _timer?.cancel();
    _timer = null;
    debugPrint('[CircularTimerWidget] Timer paused');
  }

  void _resumeTimer() {
    if (_pausedTime != null) {
      debugPrint('[CircularTimerWidget] Timer resumed');
      _pausedTime = null;
    }
    _startTimer();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _startTimer() {
    // Stop any existing timer
    _stopTimer();
    
    // Initial update
    _updateDuration();
    
    // Start periodic timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateDuration();
      } else {
        timer.cancel();
      }
    });
  }

  void _updateDuration() {
    if (!mounted) return;
    
    try {
      final now = DateTime.now();
      Duration currentDuration;
      double progress;
      
      if (widget.isBooking && widget.endTime != null) {
        // Calculate remaining time for booking
        currentDuration = widget.endTime!.difference(now);
        
        // If time is up, show zero
        if (currentDuration.isNegative) {
          currentDuration = Duration.zero;
        }
        
        // Calculate progress (1.0 = full time, 0.0 = time up)
        final totalDuration = widget.endTime!.difference(widget.startTime);
        if (totalDuration.inSeconds > 0) {
          progress = currentDuration.inSeconds / totalDuration.inSeconds;
          // Clamp progress between 0 and 1
          progress = progress.clamp(0.0, 1.0);
        } else {
          progress = 0.0;
        }
      } else {
        // Calculate elapsed time for active parking
        currentDuration = now.difference(widget.startTime);
        
        // Ensure duration is not negative
        if (currentDuration.isNegative) {
          currentDuration = Duration.zero;
        }
        
        // For elapsed time, progress goes from 0 to 1 over 24 hours
        // This provides a visual indicator even without end time
        const int maxSeconds = 24 * 60 * 60; // 24 hours
        progress = (currentDuration.inSeconds % maxSeconds) / maxSeconds;
      }
      
      // Update ValueNotifier only if data changed (minimizes rebuilds)
      final label = widget.isBooking ? 'Sisa Waktu Booking' : 'Durasi Parkir';
      final newData = TimerData(
        duration: currentDuration,
        progress: progress,
        label: label,
      );
      
      if (_timerNotifier.value != newData) {
        _timerNotifier.value = newData;
        
        // Notify parent of timer update
        widget.onTimerUpdate(currentDuration);
      }
    } catch (e) {
      // Handle any errors gracefully
      debugPrint('[CircularTimerWidget] Error updating duration: $e');
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Timer parkir',
      liveRegion: true,
      child: Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ValueListenableBuilder<TimerData>(
          valueListenable: _timerNotifier,
          builder: (context, timerData, child) {
            // Announce timer updates to screen reader every minute
            final shouldAnnounce = timerData.duration.inSeconds % 60 == 0 && 
                                   timerData.duration.inSeconds > 0;
            
            return Semantics(
              label: _buildSemanticLabel(timerData),
              liveRegion: shouldAnnounce,
              child: CustomPaint(
                painter: _CircularProgressPainter(
                  progress: timerData.progress,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ExcludeSemantics(
                        child: Text(
                          _formatDuration(timerData.duration),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ExcludeSemantics(
                        child: Text(
                          timerData.label,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build semantic label for screen readers
  String _buildSemanticLabel(TimerData timerData) {
    final hours = timerData.duration.inHours;
    final minutes = timerData.duration.inMinutes % 60;
    final seconds = timerData.duration.inSeconds % 60;
    
    final parts = <String>[];
    if (hours > 0) parts.add('$hours jam');
    if (minutes > 0) parts.add('$minutes menit');
    if (seconds > 0 || parts.isEmpty) parts.add('$seconds detik');
    
    final timeText = parts.join(' ');
    return '${timerData.label}: $timeText';
  }
}

/// Custom painter for circular progress ring with gradient
/// Optimized with shader caching and efficient shouldRepaint logic
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  static Shader? _staticCachedShader;
  static Rect? _staticCachedRect;

  _CircularProgressPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 12) / 2; // Account for ring thickness
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Create gradient shader with static caching for better performance
    // Only recreate if rect size changed
    if (_staticCachedShader == null || _staticCachedRect != rect) {
      _staticCachedShader = const SweepGradient(
        colors: [
          Color(0xFF8D71FA), // Start color
          Color(0xFF3B77DC), // End color
        ],
        startAngle: -math.pi / 2, // Start at top
        endAngle: 3 * math.pi / 2, // Full circle
      ).createShader(rect);
      _staticCachedRect = rect;
    }

    // Draw background circle (light gray)
    final backgroundPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Only draw progress arc if progress > 0
    if (progress > 0) {
      // Draw progress arc with gradient
      final progressPaint = Paint()
        ..shader = _staticCachedShader
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;

      // Calculate sweep angle (clockwise from top)
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        rect,
        -math.pi / 2, // Start at top (12 o'clock position)
        sweepAngle, // Sweep clockwise
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    // Only repaint if progress changed significantly (reduces unnecessary repaints)
    // Use a small threshold to avoid repainting for tiny changes
    const double threshold = 0.0001;
    return (oldDelegate.progress - progress).abs() > threshold;
  }

  @override
  bool shouldRebuildSemantics(_CircularProgressPainter oldDelegate) {
    // Only rebuild semantics if progress changed significantly
    return shouldRepaint(oldDelegate);
  }
}

class TimerState {
  final Duration elapsed;
  final Duration? remaining;
  final double progress; // 0.0 to 1.0 for circular animation
  final bool isOvertime;
  final double currentCost;
  final double? penaltyAmount;

  TimerState({
    required this.elapsed,
    this.remaining,
    required this.progress,
    required this.isOvertime,
    required this.currentCost,
    this.penaltyAmount,
  });

  /// Create initial TimerState with zero values
  factory TimerState.initial() {
    return TimerState(
      elapsed: Duration.zero,
      remaining: null,
      progress: 0.0,
      isOvertime: false,
      currentCost: 0.0,
      penaltyAmount: null,
    );
  }

  /// Create TimerState from JSON
  factory TimerState.fromJson(Map<String, dynamic> json) {
    return TimerState(
      elapsed: Duration(seconds: json['elapsed_seconds'] ?? 0),
      remaining: json['remaining_seconds'] != null
          ? Duration(seconds: json['remaining_seconds'])
          : null,
      progress: _parseDouble(json['progress']),
      isOvertime: json['is_overtime'] == true || json['is_overtime'] == 1,
      currentCost: _parseDouble(json['current_cost']),
      penaltyAmount: json['penalty_amount'] != null
          ? _parseDouble(json['penalty_amount'])
          : null,
    );
  }

  /// Convert TimerState to JSON
  Map<String, dynamic> toJson() {
    return {
      'elapsed_seconds': elapsed.inSeconds,
      'remaining_seconds': remaining?.inSeconds,
      'progress': progress,
      'is_overtime': isOvertime,
      'current_cost': currentCost,
      'penalty_amount': penaltyAmount,
    };
  }

  /// Helper method to safely parse double values from JSON
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Create a copy of this state with updated fields
  TimerState copyWith({
    Duration? elapsed,
    Duration? remaining,
    double? progress,
    bool? isOvertime,
    double? currentCost,
    double? penaltyAmount,
  }) {
    return TimerState(
      elapsed: elapsed ?? this.elapsed,
      remaining: remaining ?? this.remaining,
      progress: progress ?? this.progress,
      isOvertime: isOvertime ?? this.isOvertime,
      currentCost: currentCost ?? this.currentCost,
      penaltyAmount: penaltyAmount ?? this.penaltyAmount,
    );
  }

  /// Format elapsed duration as HH:MM:SS string
  String getFormattedElapsed() {
    return _formatDuration(elapsed);
  }

  /// Format remaining duration as HH:MM:SS string
  String? getFormattedRemaining() {
    if (remaining == null) return null;
    return _formatDuration(remaining!);
  }

  /// Helper method to format Duration as HH:MM:SS
  static String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Calculate progress percentage for circular animation
  /// Returns value between 0.0 and 1.0
  /// If no remaining time (no booking), returns elapsed hours / 24 (capped at 1.0)
  static double calculateProgress({
    required Duration elapsed,
    Duration? remaining,
    DateTime? endTime,
    required DateTime startTime,
  }) {
    if (endTime != null) {
      // Booking mode: calculate based on total booking duration
      final totalDuration = endTime.difference(startTime);
      if (totalDuration.inSeconds <= 0) return 1.0;
      
      final progress = elapsed.inSeconds / totalDuration.inSeconds;
      return progress.clamp(0.0, 1.0);
    } else {
      // Non-booking mode: use elapsed time with 24-hour cycle
      const maxHours = 24;
      final hours = elapsed.inHours;
      final progress = (hours % maxHours) / maxHours;
      return progress.clamp(0.0, 1.0);
    }
  }

  @override
  String toString() {
    return 'TimerState(elapsed: ${getFormattedElapsed()}, '
        'remaining: ${getFormattedRemaining()}, '
        'progress: ${(progress * 100).toStringAsFixed(1)}%, '
        'isOvertime: $isOvertime, '
        'currentCost: Rp ${currentCost.toStringAsFixed(0)}, '
        'penaltyAmount: ${penaltyAmount != null ? "Rp ${penaltyAmount!.toStringAsFixed(0)}" : "null"})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TimerState &&
        other.elapsed == elapsed &&
        other.remaining == remaining &&
        other.progress == progress &&
        other.isOvertime == isOvertime &&
        other.currentCost == currentCost &&
        other.penaltyAmount == penaltyAmount;
  }

  @override
  int get hashCode {
    return elapsed.hashCode ^
        remaining.hashCode ^
        progress.hashCode ^
        isOvertime.hashCode ^
        currentCost.hashCode ^
        penaltyAmount.hashCode;
  }
}

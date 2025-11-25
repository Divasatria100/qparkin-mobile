/// Utility class for validating booking inputs
/// 
/// Provides validation methods for start time, duration, and vehicle selection
/// to ensure booking data meets business rules before submission.
class BookingValidator {
  /// Validates booking start time
  /// 
  /// Checks:
  /// - Start time is not in the past
  /// - Start time is not more than 7 days in the future
  /// - Start time is at least 15 minutes from now (buffer time)
  /// 
  /// Parameters:
  /// - [startTime]: The proposed booking start time
  /// 
  /// Returns: Error message string if invalid, null if valid
  /// 
  /// Examples:
  /// - validateStartTime(DateTime.now().subtract(Duration(hours: 1))) 
  ///   → "Waktu mulai tidak boleh di masa lalu"
  /// - validateStartTime(DateTime.now().add(Duration(days: 8))) 
  ///   → "Booking hanya dapat dilakukan maksimal 7 hari ke depan"
  /// - validateStartTime(DateTime.now().add(Duration(hours: 2))) 
  ///   → null (valid)
  static String? validateStartTime(DateTime? startTime) {
    if (startTime == null) {
      return 'Waktu mulai wajib dipilih';
    }

    final now = DateTime.now();
    final minimumStartTime = now.add(const Duration(minutes: 15));
    final maximumStartTime = now.add(const Duration(days: 7));

    // Check if start time is in the past
    if (startTime.isBefore(now)) {
      return 'Waktu mulai tidak boleh di masa lalu';
    }

    // Check if start time is too soon (less than 15 minutes buffer)
    if (startTime.isBefore(minimumStartTime)) {
      return 'Booking harus dilakukan minimal 15 menit sebelum waktu mulai';
    }

    // Check if start time is too far in the future (more than 7 days)
    if (startTime.isAfter(maximumStartTime)) {
      return 'Booking hanya dapat dilakukan maksimal 7 hari ke depan';
    }

    return null; // Valid
  }

  /// Validates booking duration
  /// 
  /// Checks:
  /// - Duration is not null
  /// - Duration is at least 30 minutes (minimum booking time)
  /// - Duration is not more than 12 hours (maximum booking time)
  /// 
  /// Parameters:
  /// - [duration]: The proposed booking duration
  /// 
  /// Returns: Error message string if invalid, null if valid
  /// 
  /// Examples:
  /// - validateDuration(Duration(minutes: 15)) 
  ///   → "Durasi booking minimal 30 menit"
  /// - validateDuration(Duration(hours: 15)) 
  ///   → "Durasi booking maksimal 12 jam"
  /// - validateDuration(Duration(hours: 2)) 
  ///   → null (valid)
  static String? validateDuration(Duration? duration) {
    if (duration == null) {
      return 'Durasi booking wajib dipilih';
    }

    const minimumDuration = Duration(minutes: 30);
    const maximumDuration = Duration(hours: 12);

    // Check if duration is too short
    if (duration < minimumDuration) {
      return 'Durasi booking minimal 30 menit';
    }

    // Check if duration is too long
    if (duration > maximumDuration) {
      return 'Durasi booking maksimal 12 jam';
    }

    return null; // Valid
  }

  /// Validates vehicle selection
  /// 
  /// Checks:
  /// - Vehicle ID is not null or empty
  /// - Vehicle ID is a valid format (non-empty string)
  /// 
  /// Parameters:
  /// - [vehicleId]: The selected vehicle ID
  /// 
  /// Returns: Error message string if invalid, null if valid
  /// 
  /// Examples:
  /// - validateVehicle(null) → "Kendaraan wajib dipilih"
  /// - validateVehicle("") → "Kendaraan wajib dipilih"
  /// - validateVehicle("VH123") → null (valid)
  static String? validateVehicle(String? vehicleId) {
    if (vehicleId == null || vehicleId.trim().isEmpty) {
      return 'Kendaraan wajib dipilih';
    }

    return null; // Valid
  }

  /// Validates all booking inputs at once
  /// 
  /// Performs comprehensive validation of all booking fields and returns
  /// a map of field names to error messages for any invalid fields.
  /// 
  /// Parameters:
  /// - [startTime]: The proposed booking start time
  /// - [duration]: The proposed booking duration
  /// - [vehicleId]: The selected vehicle ID
  /// 
  /// Returns: Map of field names to error messages. Empty map if all valid.
  /// 
  /// Example:
  /// ```dart
  /// final errors = BookingValidator.validateAll(
  ///   startTime: DateTime.now().subtract(Duration(hours: 1)),
  ///   duration: Duration(minutes: 15),
  ///   vehicleId: null,
  /// );
  /// // Returns: {
  /// //   'startTime': 'Waktu mulai tidak boleh di masa lalu',
  /// //   'duration': 'Durasi booking minimal 30 menit',
  /// //   'vehicleId': 'Kendaraan wajib dipilih'
  /// // }
  /// ```
  static Map<String, String> validateAll({
    DateTime? startTime,
    Duration? duration,
    String? vehicleId,
  }) {
    final errors = <String, String>{};

    // Validate start time
    final startTimeError = validateStartTime(startTime);
    if (startTimeError != null) {
      errors['startTime'] = startTimeError;
    }

    // Validate duration
    final durationError = validateDuration(duration);
    if (durationError != null) {
      errors['duration'] = durationError;
    }

    // Validate vehicle
    final vehicleError = validateVehicle(vehicleId);
    if (vehicleError != null) {
      errors['vehicleId'] = vehicleError;
    }

    return errors;
  }

  /// Checks if all booking inputs are valid
  /// 
  /// Convenience method that returns true if all validations pass.
  /// 
  /// Parameters:
  /// - [startTime]: The proposed booking start time
  /// - [duration]: The proposed booking duration
  /// - [vehicleId]: The selected vehicle ID
  /// 
  /// Returns: true if all inputs are valid, false otherwise
  static bool isValid({
    DateTime? startTime,
    Duration? duration,
    String? vehicleId,
  }) {
    return validateAll(
      startTime: startTime,
      duration: duration,
      vehicleId: vehicleId,
    ).isEmpty;
  }

  /// Formats duration for display in validation messages
  /// 
  /// Parameters:
  /// - [duration]: Duration to format
  /// 
  /// Returns: Human-readable duration string
  /// 
  /// Examples:
  /// - formatDuration(Duration(hours: 2)) → "2 jam"
  /// - formatDuration(Duration(minutes: 30)) → "30 menit"
  /// - formatDuration(Duration(hours: 1, minutes: 30)) → "1 jam 30 menit"
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours == 0) {
      return "$minutes menit";
    } else if (minutes == 0) {
      return "$hours jam";
    } else {
      return "$hours jam $minutes menit";
    }
  }

  /// Validates that end time doesn't exceed reasonable limits
  /// 
  /// Checks that the calculated end time (start time + duration) is valid
  /// and doesn't create unreasonable booking scenarios.
  /// 
  /// Parameters:
  /// - [startTime]: The booking start time
  /// - [duration]: The booking duration
  /// 
  /// Returns: Error message string if invalid, null if valid
  static String? validateEndTime(DateTime? startTime, Duration? duration) {
    if (startTime == null || duration == null) {
      return null; // Let individual validators handle null cases
    }

    final endTime = startTime.add(duration);
    final now = DateTime.now();
    final maxEndTime = now.add(const Duration(days: 7, hours: 12));

    // Check if end time is too far in the future
    if (endTime.isAfter(maxEndTime)) {
      return 'Waktu selesai booking melebihi batas maksimal';
    }

    return null; // Valid
  }
}

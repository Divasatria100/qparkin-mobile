/// Utility class for calculating parking costs based on tariff structure
/// 
/// Handles cost estimation using first hour rate + additional hours formula,
/// currency formatting with thousand separators, and cost breakdown generation.
class CostCalculator {
  /// Calculates estimated parking cost based on duration and tariff rates
  /// 
  /// Formula: first hour rate + (additional hours × hourly rate)
  /// 
  /// Parameters:
  /// - [durationHours]: Total parking duration in hours (can be fractional)
  /// - [firstHourRate]: Rate for the first hour of parking
  /// - [additionalHourRate]: Rate for each additional hour after the first
  /// 
  /// Returns: Total estimated cost as double
  /// 
  /// Edge cases:
  /// - If duration is 0 or negative, returns 0
  /// - If duration is less than 1 hour, charges first hour rate
  /// - Fractional hours are rounded up (e.g., 2.5 hours = 3 hours)
  static double estimateCost({
    required double durationHours,
    required double firstHourRate,
    required double additionalHourRate,
  }) {
    // Handle edge case: 0 or negative duration
    if (durationHours <= 0) {
      return 0.0;
    }

    // Handle edge case: less than 1 hour charges first hour rate
    if (durationHours <= 1.0) {
      return firstHourRate;
    }

    // Calculate additional hours (round up fractional hours)
    final additionalHours = (durationHours - 1).ceilToDouble();
    
    // Calculate total cost: first hour + additional hours
    final totalCost = firstHourRate + (additionalHours * additionalHourRate);
    
    return totalCost;
  }

  /// Formats currency value with thousand separators and "Rp" prefix
  /// 
  /// Parameters:
  /// - [amount]: The amount to format
  /// - [showDecimals]: Whether to show decimal places (default: false)
  /// 
  /// Returns: Formatted string like "Rp 15.000" or "Rp 15.000,50"
  /// 
  /// Examples:
  /// - formatCurrency(5000) → "Rp 5.000"
  /// - formatCurrency(15000) → "Rp 15.000"
  /// - formatCurrency(1500000) → "Rp 1.500.000"
  /// - formatCurrency(5000.50, showDecimals: true) → "Rp 5.000,50"
  static String formatCurrency(double amount, {bool showDecimals = false}) {
    // Handle negative amounts
    final isNegative = amount < 0;
    final absoluteAmount = amount.abs();
    
    // Split into integer and decimal parts
    final integerPart = absoluteAmount.floor();
    final decimalPart = ((absoluteAmount - integerPart) * 100).round();
    
    // Format integer part with thousand separators
    final integerString = integerPart.toString();
    final buffer = StringBuffer();
    
    // Add thousand separators from right to left
    for (int i = 0; i < integerString.length; i++) {
      if (i > 0 && (integerString.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(integerString[i]);
    }
    
    // Build final string
    final result = StringBuffer();
    if (isNegative) {
      result.write('-');
    }
    result.write('Rp ');
    result.write(buffer.toString());
    
    // Add decimal part if requested and non-zero
    if (showDecimals && decimalPart > 0) {
      result.write(',');
      result.write(decimalPart.toString().padLeft(2, '0'));
    }
    
    return result.toString();
  }

  /// Generates a detailed cost breakdown for display
  /// 
  /// Parameters:
  /// - [durationHours]: Total parking duration in hours
  /// - [firstHourRate]: Rate for the first hour
  /// - [additionalHourRate]: Rate for each additional hour
  /// 
  /// Returns: Map containing breakdown details:
  /// - 'firstHourCost': Cost for first hour
  /// - 'additionalHoursCost': Cost for additional hours
  /// - 'additionalHoursCount': Number of additional hours
  /// - 'totalCost': Total estimated cost
  /// - 'formattedFirstHour': Formatted first hour cost string
  /// - 'formattedAdditionalHours': Formatted additional hours cost string
  /// - 'formattedTotal': Formatted total cost string
  static Map<String, dynamic> generateCostBreakdown({
    required double durationHours,
    required double firstHourRate,
    required double additionalHourRate,
  }) {
    // Handle edge case: 0 or negative duration
    if (durationHours <= 0) {
      return {
        'firstHourCost': 0.0,
        'additionalHoursCost': 0.0,
        'additionalHoursCount': 0,
        'totalCost': 0.0,
        'formattedFirstHour': formatCurrency(0),
        'formattedAdditionalHours': formatCurrency(0),
        'formattedTotal': formatCurrency(0),
      };
    }

    final firstHourCost = firstHourRate;
    
    // Calculate additional hours
    final additionalHoursCount = durationHours > 1.0 
        ? (durationHours - 1).ceilToDouble().toInt()
        : 0;
    
    final additionalHoursCost = additionalHoursCount * additionalHourRate;
    final totalCost = firstHourCost + additionalHoursCost;

    return {
      'firstHourCost': firstHourCost,
      'additionalHoursCost': additionalHoursCost,
      'additionalHoursCount': additionalHoursCount,
      'totalCost': totalCost,
      'formattedFirstHour': formatCurrency(firstHourCost),
      'formattedAdditionalHours': formatCurrency(additionalHoursCost),
      'formattedTotal': formatCurrency(totalCost),
    };
  }

  /// Converts duration in minutes to hours (as double)
  /// 
  /// Parameters:
  /// - [minutes]: Duration in minutes
  /// 
  /// Returns: Duration in hours as double
  /// 
  /// Examples:
  /// - minutesToHours(60) → 1.0
  /// - minutesToHours(90) → 1.5
  /// - minutesToHours(150) → 2.5
  static double minutesToHours(int minutes) {
    return minutes / 60.0;
  }

  /// Converts Duration object to hours (as double)
  /// 
  /// Parameters:
  /// - [duration]: Duration object
  /// 
  /// Returns: Duration in hours as double
  static double durationToHours(Duration duration) {
    return duration.inMinutes / 60.0;
  }

  /// Formats duration in human-readable format
  /// 
  /// Parameters:
  /// - [durationHours]: Duration in hours
  /// 
  /// Returns: Formatted string like "2 jam 30 menit" or "1 jam"
  /// 
  /// Examples:
  /// - formatDuration(1.0) → "1 jam"
  /// - formatDuration(2.5) → "2 jam 30 menit"
  /// - formatDuration(0.5) → "30 menit"
  static String formatDuration(double durationHours) {
    if (durationHours <= 0) {
      return "0 menit";
    }

    final hours = durationHours.floor();
    final minutes = ((durationHours - hours) * 60).round();

    if (hours == 0) {
      return "$minutes menit";
    } else if (minutes == 0) {
      return "$hours jam";
    } else {
      return "$hours jam $minutes menit";
    }
  }
}

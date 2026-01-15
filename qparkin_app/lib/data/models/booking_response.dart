import 'booking_model.dart';

class BookingResponse {
  final bool success;
  final String message;
  final BookingModel? booking;
  final String? qrCode;
  final String? errorCode;
  final Map<String, dynamic>? data;

  BookingResponse({
    required this.success,
    required this.message,
    this.booking,
    this.qrCode,
    this.errorCode,
    this.data,
  });

  /// Check if response indicates a network error
  bool get isNetworkError {
    return errorCode == 'NETWORK_ERROR' ||
        errorCode == 'TIMEOUT_ERROR' ||
        errorCode == 'CONNECTION_ERROR';
  }

  /// Check if response indicates slot unavailability
  bool get isSlotUnavailable {
    return errorCode == 'SLOT_UNAVAILABLE' || errorCode == 'NO_SLOTS_AVAILABLE';
  }

  /// Check if response indicates validation error
  bool get isValidationError {
    return errorCode == 'VALIDATION_ERROR' || errorCode == 'INVALID_INPUT';
  }

  /// Check if response indicates server error
  bool get isServerError {
    return errorCode == 'SERVER_ERROR' || errorCode == 'INTERNAL_ERROR';
  }

  /// Check if response indicates booking conflict
  bool get isBookingConflict {
    return errorCode == 'BOOKING_CONFLICT' ||
        errorCode == 'ACTIVE_BOOKING_EXISTS';
  }

  /// Get user-friendly error message
  String getUserFriendlyMessage() {
    if (success) {
      return message;
    }

    if (isNetworkError) {
      return 'Koneksi internet bermasalah. Periksa koneksi Anda.';
    }

    if (isSlotUnavailable) {
      return 'Slot tidak tersedia untuk waktu yang dipilih.';
    }

    if (isValidationError) {
      return 'Mohon lengkapi semua data dengan benar.';
    }

    if (isServerError) {
      return 'Terjadi kesalahan server. Coba lagi nanti.';
    }

    if (isBookingConflict) {
      return 'Anda sudah memiliki booking aktif.';
    }

    return message.isNotEmpty
        ? message
        : 'Terjadi kesalahan. Silakan coba lagi.';
  }

  /// Create BookingResponse from JSON
  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    final success = json['success'] == true || json['success'] == 1;

    BookingModel? booking;
    if (json['booking'] != null) {
      booking = BookingModel.fromJson(json['booking'] as Map<String, dynamic>);
    } else if (json['data'] != null && json['data'] is Map) {
      // Some APIs might return booking data directly in 'data' field
      booking = BookingModel.fromJson(json['data'] as Map<String, dynamic>);
    }
    
    // Debug logging
    if (booking != null) {
      print('[BookingResponse] Parsed booking - idBooking: ${booking.idBooking}, idTransaksi: ${booking.idTransaksi}');
    }

    return BookingResponse(
      success: success,
      message: json['message']?.toString() ?? '',
      booking: booking,
      qrCode: json['qr_code']?.toString() ?? json['qrCode']?.toString(),
      errorCode:
          json['error_code']?.toString() ?? json['errorCode']?.toString(),
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  /// Convert BookingResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'booking': booking?.toJson(),
      'qr_code': qrCode,
      'error_code': errorCode,
      'data': data,
    };
  }

  /// Create a success response
  factory BookingResponse.success({
    required String message,
    required BookingModel booking,
    String? qrCode,
  }) {
    return BookingResponse(
      success: true,
      message: message,
      booking: booking,
      qrCode: qrCode,
    );
  }

  /// Create an error response
  factory BookingResponse.error({
    required String message,
    String? errorCode,
    Map<String, dynamic>? data,
  }) {
    return BookingResponse(
      success: false,
      message: message,
      errorCode: errorCode,
      data: data,
    );
  }

  /// Create a network error response
  factory BookingResponse.networkError() {
    return BookingResponse(
      success: false,
      message: 'Koneksi internet bermasalah',
      errorCode: 'NETWORK_ERROR',
    );
  }

  /// Create a timeout error response
  factory BookingResponse.timeoutError() {
    return BookingResponse(
      success: false,
      message: 'Permintaan timeout. Silakan coba lagi.',
      errorCode: 'TIMEOUT_ERROR',
    );
  }

  /// Create a slot unavailable error response
  factory BookingResponse.slotUnavailable() {
    return BookingResponse(
      success: false,
      message: 'Slot tidak tersedia untuk waktu yang dipilih',
      errorCode: 'SLOT_UNAVAILABLE',
    );
  }

  /// Create a validation error response
  factory BookingResponse.validationError(String message) {
    return BookingResponse(
      success: false,
      message: message,
      errorCode: 'VALIDATION_ERROR',
    );
  }

  @override
  String toString() {
    return 'BookingResponse(success: $success, message: $message, '
        'errorCode: $errorCode, hasBooking: ${booking != null})';
  }
}

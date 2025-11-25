/// Constants for the Booking feature
///
/// This file centralizes all magic numbers, durations, and configuration
/// values used throughout the booking feature for better maintainability.
class BookingConstants {
  // Private constructor to prevent instantiation
  BookingConstants._();

  // ============================================================================
  // TIMING & DELAYS
  // ============================================================================

  /// Debounce delay for cost calculation after duration changes
  /// Prevents excessive recalculations while user is adjusting duration
  static const Duration costCalculationDebounce = Duration(milliseconds: 300);

  /// Debounce delay for availability checks after time/duration changes
  /// Prevents excessive API calls while user is selecting time
  static const Duration availabilityCheckDebounce = Duration(milliseconds: 500);

  /// Interval for periodic availability checks
  /// Automatically refreshes slot availability every 30 seconds
  static const Duration availabilityCheckInterval = Duration(seconds: 30);

  /// Cache expiration duration
  /// Cached data (mall, vehicle, tariff) expires after 30 minutes
  static const Duration cacheExpiration = Duration(minutes: 30);

  /// Retry delay for failed API calls
  /// Initial delay before first retry attempt
  static const Duration retryDelay = Duration(seconds: 1);

  /// Maximum retry attempts for API calls
  static const int maxRetryAttempts = 3;

  // ============================================================================
  // SPACING & LAYOUT
  // ============================================================================

  /// Extra small spacing (4dp)
  static const double spacingXS = 4.0;

  /// Small spacing (8dp)
  static const double spacingS = 8.0;

  /// Medium spacing (12dp)
  static const double spacingM = 12.0;

  /// Large spacing (16dp)
  static const double spacingL = 16.0;

  /// Extra large spacing (24dp)
  static const double spacingXL = 24.0;

  /// Extra extra large spacing (32dp)
  static const double spacingXXL = 32.0;

  /// Border radius for small elements (8dp)
  static const double radiusS = 8.0;

  /// Border radius for medium elements (12dp)
  static const double radiusM = 12.0;

  /// Border radius for large elements (16dp)
  static const double radiusL = 16.0;

  /// Border radius for extra large elements (24dp)
  static const double radiusXL = 24.0;

  /// Minimum touch target size for accessibility (48dp)
  static const double minTouchTarget = 48.0;

  /// Button height (56dp)
  static const double buttonHeight = 56.0;

  /// Card elevation for subtle shadow
  static const double elevationLight = 2.0;

  /// Card elevation for medium shadow
  static const double elevationMedium = 4.0;

  /// Card elevation for prominent shadow
  static const double elevationHeavy = 8.0;

  // ============================================================================
  // VALIDATION RULES
  // ============================================================================

  /// Minimum booking duration (30 minutes)
  static const Duration minBookingDuration = Duration(minutes: 30);

  /// Maximum booking duration (12 hours)
  static const Duration maxBookingDuration = Duration(hours: 12);

  /// Maximum days in advance for booking (7 days)
  static const int maxAdvanceBookingDays = 7;

  /// Default start time offset from current time (15 minutes)
  static const Duration defaultStartTimeOffset = Duration(minutes: 15);

  /// Minimum slots required to allow booking
  static const int minSlotsRequired = 1;

  /// Slot count threshold for "limited" status (3-10 slots)
  static const int limitedSlotsThreshold = 3;

  /// Slot count threshold for "available" status (>10 slots)
  static const int availableSlotsThreshold = 10;

  // ============================================================================
  // DEFAULT VALUES
  // ============================================================================

  /// Default first hour parking rate (Rp 5,000)
  static const double defaultFirstHourRate = 5000.0;

  /// Default additional hour parking rate (Rp 3,000)
  static const double defaultAdditionalHourRate = 3000.0;

  /// Default duration options in hours
  static const List<int> defaultDurationOptions = [1, 2, 3, 4];

  // ============================================================================
  // ANIMATION DURATIONS
  // ============================================================================

  /// Fast animation duration (200ms)
  static const Duration animationFast = Duration(milliseconds: 200);

  /// Medium animation duration (300ms)
  static const Duration animationMedium = Duration(milliseconds: 300);

  /// Slow animation duration (500ms)
  static const Duration animationSlow = Duration(milliseconds: 500);

  /// Shimmer animation duration (1500ms)
  static const Duration shimmerDuration = Duration(milliseconds: 1500);

  // ============================================================================
  // ERROR MESSAGES
  // ============================================================================

  /// Error message for network failures
  static const String errorNetwork =
      'Koneksi internet bermasalah. Periksa koneksi Anda dan coba lagi.';

  /// Error message for timeout
  static const String errorTimeout = 'Permintaan timeout. Silakan coba lagi.';

  /// Error message for slot unavailability
  static const String errorSlotUnavailable =
      'Slot tidak tersedia untuk waktu yang dipilih. Silakan pilih waktu lain.';

  /// Error message for booking conflict
  static const String errorBookingConflict =
      'Anda sudah memiliki booking aktif. Selesaikan booking sebelumnya terlebih dahulu.';

  /// Error message for validation failure
  static const String errorValidation =
      'Mohon lengkapi semua data dengan benar.';

  /// Error message for server error
  static const String errorServer =
      'Terjadi kesalahan server. Silakan coba beberapa saat lagi.';

  /// Error message for authentication failure
  static const String errorAuth =
      'Sesi Anda telah berakhir. Silakan login kembali.';

  /// Generic error message
  static const String errorGeneric = 'Terjadi kesalahan. Silakan coba lagi.';

  // ============================================================================
  // SUCCESS MESSAGES
  // ============================================================================

  /// Success message for booking creation
  static const String successBooking = 'Booking berhasil dibuat!';

  /// Success message for availability refresh
  static const String successRefresh = 'Data berhasil diperbarui';

  // ============================================================================
  // UI TEXT
  // ============================================================================

  /// Page title
  static const String pageTitle = 'Booking Parkir';

  /// Confirm button text
  static const String buttonConfirm = 'Konfirmasi Booking';

  /// Retry button text
  static const String buttonRetry = 'Coba Lagi';

  /// Cancel button text
  static const String buttonCancel = 'Batal';

  /// View activity button text
  static const String buttonViewActivity = 'Lihat Aktivitas';

  /// Back to home button text
  static const String buttonBackHome = 'Kembali ke Beranda';

  /// Loading text
  static const String textLoading = 'Memproses...';

  /// No slots available text
  static const String textNoSlots = 'Tidak ada slot tersedia';

  /// Select vehicle prompt
  static const String textSelectVehicle = 'Pilih Kendaraan';

  /// Add vehicle prompt
  static const String textAddVehicle = 'Tambah Kendaraan';

  /// Duration label
  static const String textDuration = 'Durasi';

  /// Start time label
  static const String textStartTime = 'Waktu Mulai';

  /// End time label
  static const String textEndTime = 'Waktu Selesai';

  /// Estimated cost label
  static const String textEstimatedCost = 'Estimasi Biaya';

  /// Available slots label
  static const String textAvailableSlots = 'Slot Tersedia';

  // ============================================================================
  // API ENDPOINTS (relative paths)
  // ============================================================================

  /// Endpoint for creating booking
  static const String endpointCreateBooking = '/api/booking/create';

  /// Endpoint for checking slot availability
  static const String endpointCheckAvailability =
      '/api/booking/check-availability';

  /// Endpoint for checking active booking
  static const String endpointCheckActive = '/api/booking/check-active';

  /// Endpoint for fetching vehicles
  static const String endpointVehicles = '/api/vehicles';

  /// Endpoint for fetching tariff
  static const String endpointTariff = '/api/tariff';

  // ============================================================================
  // CACHE KEYS
  // ============================================================================

  /// Cache key prefix for mall data
  static const String cacheKeyMall = 'mall_';

  /// Cache key prefix for vehicle data
  static const String cacheKeyVehicles = 'vehicles_';

  /// Cache key prefix for tariff data
  static const String cacheKeyTariff = 'tariff_';

  // ============================================================================
  // LOGGING TAGS
  // ============================================================================

  /// Log tag for BookingProvider
  static const String logTagProvider = '[BookingProvider]';

  /// Log tag for BookingService
  static const String logTagService = '[BookingService]';

  /// Log tag for BookingPage
  static const String logTagPage = '[BookingPage]';

  // ============================================================================
  // FEATURE FLAGS
  // ============================================================================

  /// Enable debug logging
  static const bool enableDebugLogging = true;

  /// Enable performance monitoring
  static const bool enablePerformanceMonitoring = false;

  /// Enable analytics
  static const bool enableAnalytics = false;
}

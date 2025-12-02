import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/booking_provider.dart';
import '../../logic/providers/active_parking_provider.dart';
import '../../data/services/vehicle_service.dart';
import '../../data/models/vehicle_model.dart';
import '../../utils/responsive_helper.dart';
import '../widgets/mall_info_card.dart';
import '../widgets/vehicle_selector.dart';
import '../widgets/floor_selector_widget.dart';
import '../widgets/slot_visualization_widget.dart';
import '../widgets/slot_reservation_button.dart';
import '../widgets/reserved_slot_info_card.dart';
import '../widgets/unified_time_duration_card.dart';
import '../widgets/time_duration_picker.dart';
import '../widgets/slot_availability_indicator.dart';
import '../widgets/cost_breakdown_card.dart';
import '../widgets/booking_summary_card.dart';
import '../widgets/error_retry_widget.dart';
import '../widgets/slot_unavailable_widget.dart';
import '../widgets/booking_conflict_dialog.dart';
import '../dialogs/booking_confirmation_dialog.dart';

/// Main booking page for reserving parking slots
///
/// Allows users to select vehicle, time, duration and confirm booking
/// with real-time slot availability and cost calculation.
///
/// This widget wraps itself with ChangeNotifierProvider to provide
/// BookingProvider to all child widgets.
///
/// Requirements: 1.1-1.5, 12.1-12.9, 15.8
class BookingPage extends StatelessWidget {
  final Map<String, dynamic> mall;

  const BookingPage({
    Key? key,
    required this.mall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookingProvider(),
      child: _BookingPageContent(mall: mall),
    );
  }
}

/// Internal stateful widget for BookingPage content
///
/// Separated to allow Provider access in initState
class _BookingPageContent extends StatefulWidget {
  final Map<String, dynamic> mall;

  const _BookingPageContent({
    Key? key,
    required this.mall,
  }) : super(key: key);

  @override
  State<_BookingPageContent> createState() => _BookingPageContentState();
}

class _BookingPageContentState extends State<_BookingPageContent> {
  late VehicleService _vehicleService;
  String? _authToken;
  BookingProvider? _bookingProvider;
  
  // Track orientation to detect changes
  Orientation? _previousOrientation;

  @override
  void initState() {
    super.initState();
    
    // TODO: Get baseUrl from config and auth token from secure storage
    const baseUrl = 'http://192.168.1.1:8000'; // Placeholder
    _authToken = 'dummy_token'; // Placeholder
    
    _vehicleService = VehicleService(
      baseUrl: baseUrl,
      authToken: _authToken,
    );
    
    // Initialize provider with mall data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      _bookingProvider!.initialize(widget.mall);
      
      // Fetch floors for slot reservation
      if (_authToken != null) {
        _bookingProvider!.fetchFloors(token: _authToken!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Detect orientation changes
    final currentOrientation = MediaQuery.of(context).orientation;
    if (_previousOrientation != null && _previousOrientation != currentOrientation) {
      // Orientation changed - trigger rebuild with preserved state
      // The Provider pattern automatically preserves state
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Force a rebuild to adjust layout for new orientation
        if (mounted) {
          setState(() {});
        }
      });
    }
    _previousOrientation = currentOrientation;
    
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// Build AppBar with back button and title
  ///
  /// Requirements: 1.1-1.5, 12.1-12.9, 13.7
  PreferredSizeWidget _buildAppBar() {
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(context, 20);
    
    return AppBar(
      centerTitle: true,
      title: Text(
        'Booking Parkir',
        style: TextStyle(
          color: Colors.white,
          fontSize: titleFontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color(0xFF573ED1),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: Semantics(
        label: 'Tombol kembali',
        hint: 'Ketuk untuk kembali ke halaman sebelumnya',
        button: true,
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Kembali',
          iconSize: 24,
          constraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
        ),
      ),
    );
  }

  /// Build main body with scrollable content and fixed bottom button
  ///
  /// Requirements: 1.1-1.5, 12.1-12.9, 13.7, 13.6
  Widget _buildBody() {
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final spacing = ResponsiveHelper.getCardSpacing(context);
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    
    // Adjust bottom padding for landscape mode (smaller button area)
    final bottomPadding = isLandscape ? 80.0 : 100.0;
    
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            // Scrollable content
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(padding, padding, padding, bottomPadding),
              child: Column(
                children: [
                  // Error display (if any)
                  if (provider.errorMessage != null && !provider.isLoading)
                    Padding(
                      padding: EdgeInsets.only(bottom: spacing),
                      child: ErrorRetryWidget(
                        errorMessage: provider.errorMessage!,
                        isNetworkError: _isNetworkError(provider.errorMessage!),
                        isOffline: _isOfflineError(provider.errorMessage!),
                        onRetry: _canRetryError(provider.errorMessage!) 
                            ? () => _handleConfirmBooking(provider)
                            : null,
                      ),
                    ),
                  
                  // Mall Info Card
                  MallInfoCard(
                    mallName: widget.mall['name'] ?? widget.mall['nama_mall'] ?? '',
                    address: widget.mall['address'] ?? widget.mall['alamat'] ?? '',
                    distance: widget.mall['distance'] ?? '0 km',
                    availableSlots: provider.availableSlots,
                  ),
                  
                  SizedBox(height: spacing),
                  
                  // Vehicle Selector
                  VehicleSelector(
                    selectedVehicle: provider.selectedVehicle != null
                        ? VehicleModel.fromJson(provider.selectedVehicle!)
                        : null,
                    onVehicleSelected: (vehicle) {
                      if (vehicle != null) {
                        provider.selectVehicle(vehicle.toJson());
                        
                        // Clear validation error when user selects vehicle
                        provider.clearValidationErrors();
                        
                        // Start periodic availability check if all data is set
                        if (provider.startTime != null &&
                            provider.bookingDuration != null &&
                            _authToken != null) {
                          provider.startPeriodicAvailabilityCheck(token: _authToken!);
                        }
                      }
                    },
                    vehicleService: _vehicleService,
                    validationError: provider.validationErrors['vehicleId'],
                  ),
                  
                  SizedBox(height: spacing),
                  
                  // NEW: Floor & Slot Reservation Section
                  _buildSlotReservationSection(provider, spacing),
                  
                  SizedBox(height: spacing),
                  
                  // Unified Time Duration Card (NEW)
                  UnifiedTimeDurationCard(
                    startTime: provider.startTime,
                    duration: provider.bookingDuration,
                    onTimeChanged: (time) {
                      provider.setStartTime(time, token: _authToken);
                      
                      // Clear validation error when user changes time
                      provider.clearValidationErrors();
                      
                      // Start periodic availability check if all data is set
                      if (provider.selectedVehicle != null &&
                          provider.bookingDuration != null &&
                          _authToken != null) {
                        provider.startPeriodicAvailabilityCheck(token: _authToken!);
                      }
                    },
                    onDurationChanged: (duration) {
                      provider.setDuration(duration, token: _authToken);
                      
                      // Clear validation error when user changes duration
                      provider.clearValidationErrors();
                      
                      // Start periodic availability check if all data is set
                      if (provider.selectedVehicle != null &&
                          provider.startTime != null &&
                          _authToken != null) {
                        provider.startPeriodicAvailabilityCheck(token: _authToken!);
                      }
                    },
                    startTimeError: provider.validationErrors['startTime'],
                    durationError: provider.validationErrors['duration'],
                  ),
                  
                  SizedBox(height: spacing),
                  
                  // Slot Availability Indicator
                  if (provider.selectedVehicle != null)
                    SlotAvailabilityIndicator(
                      availableSlots: provider.availableSlots,
                      vehicleType: provider.selectedVehicle!['jenis_kendaraan'] ??
                          provider.selectedVehicle!['jenis'] ??
                          '',
                      isLoading: provider.isCheckingAvailability,
                      onRefresh: () {
                        if (_authToken != null) {
                          provider.refreshAvailability(token: _authToken!);
                        }
                      },
                    ),
                  
                  if (provider.selectedVehicle != null)
                    SizedBox(height: spacing),
                  
                  // Slot unavailability warning with alternatives
                  if (provider.availableSlots == 0 &&
                      provider.startTime != null &&
                      provider.bookingDuration != null &&
                      !provider.isCheckingAvailability)
                    Padding(
                      padding: EdgeInsets.only(bottom: spacing),
                      child: SlotUnavailableWidget(
                        currentStartTime: provider.startTime!,
                        currentDuration: provider.bookingDuration!,
                        onSelectAlternative: (time, duration) {
                          provider.setStartTime(time, token: _authToken);
                          provider.setDuration(duration, token: _authToken);
                          
                          // Trigger availability check
                          if (_authToken != null) {
                            provider.startPeriodicAvailabilityCheck(token: _authToken!);
                          }
                        },
                        onModifyTime: () {
                          // Scroll to time picker (optional enhancement)
                          // For now, just show a message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Silakan ubah waktu dan durasi di atas'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  
                  // Cost Breakdown Card
                  if (provider.bookingDuration != null && provider.costBreakdown != null)
                    CostBreakdownCard(
                      firstHourRate: provider.firstHourRate,
                      additionalHoursRate: provider.costBreakdown!['additionalHoursTotal'] ?? 0.0,
                      additionalHours: provider.costBreakdown!['additionalHours'] ?? 0,
                      totalCost: provider.estimatedCost,
                    ),
                  
                  if (provider.bookingDuration != null && provider.costBreakdown != null)
                    SizedBox(height: spacing),
                  
                  // Booking Summary Card
                  if (_canShowSummary(provider))
                    BookingSummaryCard(
                      mallName: widget.mall['name'] ?? widget.mall['nama_mall'] ?? '',
                      mallAddress: widget.mall['address'] ?? widget.mall['alamat'] ?? '',
                      vehiclePlat: provider.selectedVehicle!['plat_nomor'] ?? '',
                      vehicleType: provider.selectedVehicle!['jenis_kendaraan'] ?? '',
                      vehicleBrand: '${provider.selectedVehicle!['merk']} ${provider.selectedVehicle!['tipe']}',
                      startTime: provider.startTime!,
                      duration: provider.bookingDuration!,
                      endTime: provider.calculatedEndTime!,
                      totalCost: provider.estimatedCost,
                      reservedSlotCode: provider.reservedSlot?.slotCode,
                      reservedFloorName: provider.reservedSlot?.floorName,
                      reservedSlotType: provider.reservedSlot?.typeLabel,
                    ),
                ],
              ),
            ),
            
            // Fixed bottom button
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildConfirmButton(provider),
            ),
            
            // Loading overlay
            if (provider.isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF573ED1)),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Check if we can show the booking summary card
  bool _canShowSummary(BookingProvider provider) {
    return provider.selectedVehicle != null &&
        provider.startTime != null &&
        provider.bookingDuration != null &&
        provider.calculatedEndTime != null;
  }

  /// Handle reservation errors with alternative floor suggestions
  ///
  /// Provides clear guidance when no slots are available and suggests
  /// alternative floors with available slots. Shows helpful dialog with
  /// one-tap floor switching.
  ///
  /// Requirements: 15.1-15.10
  void _handleReservationError(BookingProvider provider) {
    final errorMessage = provider.errorMessage ?? 'Gagal mereservasi slot';
    
    // Check if error is due to no slots available (using error code)
    if (errorMessage.startsWith('NO_SLOTS_AVAILABLE:')) {
      final floorName = errorMessage.split(':').length > 1 
          ? errorMessage.split(':')[1] 
          : 'lantai ini';
      
      // Get alternative floors with available slots
      final alternativeFloors = provider.getAlternativeFloors();
      
      if (alternativeFloors.isNotEmpty) {
        // Show dialog with alternative floor suggestions
        _showAlternativeFloorsDialog(
          floorName: floorName,
          alternativeFloors: alternativeFloors,
          provider: provider,
        );
      } else {
        // No alternative floors available - show helpful message
        _showNoAlternativesDialog(floorName: floorName);
      }
    } else if (errorMessage.contains('Tidak ada slot tersedia') || 
               errorMessage.contains('no slots')) {
      // Legacy error message format - still handle it
      final alternativeFloors = provider.getAlternativeFloors();
      
      if (alternativeFloors.isNotEmpty) {
        _showAlternativeFloorsDialog(
          floorName: provider.selectedFloor?.floorName ?? 'lantai ini',
          alternativeFloors: alternativeFloors,
          provider: provider,
        );
      } else {
        _showNoAlternativesDialog(
          floorName: provider.selectedFloor?.floorName ?? 'lantai ini',
        );
      }
    } else {
      // Other errors - just show snackbar
      _showErrorSnackbar(errorMessage);
    }
  }
  
  /// Show dialog with alternative floor suggestions
  ///
  /// Requirements: 15.1-15.10
  void _showAlternativeFloorsDialog({
    required String floorName,
    required List<dynamic> alternativeFloors,
    required BookingProvider provider,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.orange[700],
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Slot Tidak Tersedia',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Semua slot di $floorName sudah terisi.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Coba lantai lain yang masih tersedia:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Show up to 3 alternative floors
              ...alternativeFloors.take(3).map((floor) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.pop(context);
                    
                    // Select the alternative floor
                    provider.selectFloor(floor, token: _authToken);
                    
                    // Start auto-refresh timer for slot visualization
                    if (_authToken != null) {
                      provider.startSlotRefreshTimer(token: _authToken!);
                    }
                    
                    // Show success message
                    _showSuccessSnackbar('Beralih ke ${floor.floorName}');
                    
                    // Scroll to floor selector (optional - would need ScrollController)
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.local_parking,
                            color: Color(0xFF4CAF50),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                floor.floorName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${floor.availableSlots} slot tersedia dari ${floor.totalSlots}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ),
              )),
              if (alternativeFloors.length > 3) ...[
                const SizedBox(height: 8),
                Text(
                  '+${alternativeFloors.length - 3} lantai lainnya tersedia',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tutup',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Show dialog when no alternative floors are available
  ///
  /// Requirements: 15.1-15.10
  void _showNoAlternativesDialog({required String floorName}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange[700],
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Parkir Penuh',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Semua slot di $floorName sudah terisi.',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Saat ini tidak ada lantai lain yang tersedia.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Saran:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSuggestionItem('Coba lagi dalam beberapa menit'),
                  _buildSuggestionItem('Pilih waktu booking yang berbeda'),
                  _buildSuggestionItem('Pilih mall lain yang tersedia'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate back to home to select different mall
              Navigator.pop(context);
            },
            child: const Text(
              'Pilih Mall Lain',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF573ED1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Coba Lagi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build suggestion item widget
  Widget _buildSuggestionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.orange[700],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build slot reservation section with floor selector, visualization, and reservation button
  ///
  /// Requirements: 3.1-3.12
  Widget _buildSlotReservationSection(BookingProvider provider, double spacing) {
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(context, 18);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Semantics(
          header: true,
          child: Text(
            'Pilih Lokasi Parkir',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(height: spacing * 0.75),
        
        // Floor Selector Widget
        FloorSelectorWidget(
          floors: provider.floors,
          selectedFloor: provider.selectedFloor,
          isLoading: provider.isLoadingFloors,
          onFloorSelected: (floor) {
            provider.selectFloor(floor, token: _authToken);
            
            // Start auto-refresh timer for slot visualization
            if (_authToken != null) {
              provider.startSlotRefreshTimer(token: _authToken!);
            }
          },
          onRetry: () {
            if (_authToken != null) {
              provider.fetchFloors(token: _authToken!);
            }
          },
        ),
        
        // Show slot visualization when floor is selected
        if (provider.selectedFloor != null) ...[
          SizedBox(height: spacing),
          
          SlotVisualizationWidget(
            slots: provider.slotsVisualization,
            isLoading: provider.isLoadingSlots,
            errorMessage: provider.errorMessage,
            lastUpdated: provider.lastAvailabilityCheck,
            availableCount: provider.selectedFloor?.availableSlots ?? 0,
            totalCount: provider.selectedFloor?.totalSlots ?? 0,
            onRefresh: () {
              if (_authToken != null && provider.selectedFloor != null) {
                provider.refreshSlotVisualization(token: _authToken!);
              }
            },
          ),
          
          SizedBox(height: spacing),
          
          // Slot Reservation Button
          SlotReservationButton(
            floorName: provider.selectedFloor!.floorName,
            isLoading: provider.isReservingSlot,
            isEnabled: provider.selectedFloor!.hasAvailableSlots && !provider.hasReservedSlot,
            onPressed: () async {
              if (_authToken != null && provider.selectedFloor != null) {
                final success = await provider.reserveRandomSlot(
                  token: _authToken!,
                  userId: 'user_id', // TODO: Get from auth provider
                );
                
                if (success) {
                  _showSuccessSnackbar('Slot berhasil direservasi!');
                  
                  // Announce to screen reader
                  SemanticsService.announce(
                    'Slot ${provider.reservedSlot?.slotCode} berhasil direservasi',
                    TextDirection.ltr,
                  );
                } else if (provider.errorMessage != null) {
                  // Show error with alternative floor suggestions
                  _handleReservationError(provider);
                }
              }
            },
          ),
        ],
        
        // Show reserved slot info card when slot is reserved
        if (provider.hasReservedSlot) ...[
          SizedBox(height: spacing),
          
          ReservedSlotInfoCard(
            reservation: provider.reservedSlot!,
            onClear: () {
              provider.clearReservation();
              _showSuccessSnackbar('Reservasi slot dibatalkan');
            },
          ),
        ],
      ],
    );
  }

  /// Check if error is a network error
  bool _isNetworkError(String message) {
    return message.contains('internet') || 
           message.contains('koneksi') ||
           message.contains('timeout') ||
           message.contains('network');
  }

  /// Check if error is an offline error
  bool _isOfflineError(String message) {
    return message.contains('internet') || 
           message.contains('koneksi');
  }

  /// Check if error can be retried
  bool _canRetryError(String message) {
    return _isNetworkError(message) ||
           message.contains('timeout') ||
           message.contains('server') ||
           message.contains('coba lagi');
  }

  /// Build confirm booking button with gradient and validation
  ///
  /// Requirements: 8.1-8.7, 14.1-14.8, 13.7
  Widget _buildConfirmButton(BookingProvider provider) {
    final isEnabled = provider.canConfirmBooking;
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final fontSize = ResponsiveHelper.getResponsiveFontSize(context, 16);
    final borderRadius = ResponsiveHelper.getBorderRadius(context);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.all(padding),
      child: SafeArea(
        child: Semantics(
          label: isEnabled 
              ? 'Tombol konfirmasi booking' 
              : 'Tombol konfirmasi booking tidak aktif. Lengkapi semua data terlebih dahulu',
          hint: isEnabled 
              ? 'Ketuk untuk mengkonfirmasi dan membuat booking parkir' 
              : 'Lengkapi kendaraan, waktu, dan durasi untuk mengaktifkan tombol',
          button: true,
          enabled: isEnabled,
          child: SizedBox(
            height: 56,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isEnabled ? () => _handleConfirmBooking(provider) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isEnabled
                    ? const Color(0xFF573ED1)
                    : Colors.grey.shade300,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                elevation: isEnabled ? 8 : 0,
                shadowColor: const Color(0xFF573ED1).withOpacity(0.4),
                minimumSize: const Size(double.infinity, 56),
                padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
              ),
              child: provider.isLoading
                  ? Semantics(
                      label: 'Memproses booking',
                      child: const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : Text(
                      'Konfirmasi Booking',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  /// Handle confirm booking button press
  ///
  /// Requirements: 9.1-9.9, 11.1-11.7, 11.6
  Future<void> _handleConfirmBooking(BookingProvider provider) async {
    // Validate all inputs
    if (!provider.canConfirmBooking) {
      _showErrorSnackbar('Mohon lengkapi semua data dengan benar');
      return;
    }

    if (_authToken == null) {
      _showErrorSnackbar('Sesi Anda telah berakhir. Silakan login kembali.');
      return;
    }

    // Clear any previous errors
    provider.clearError();
    
    // Announce to screen reader
    SemanticsService.announce(
      'Memproses booking parkir',
      TextDirection.ltr,
    );

    // Check for existing active booking before proceeding
    final hasActive = await provider.hasActiveBooking(token: _authToken!);
    if (hasActive) {
      // Show booking conflict dialog
      _showBookingConflictDialog();
      
      // Announce conflict to screen reader
      SemanticsService.announce(
        'Anda sudah memiliki booking aktif',
        TextDirection.ltr,
      );
      return;
    }

    // Attempt to create booking
    final success = await provider.confirmBooking(
      token: _authToken!,
      skipActiveCheck: true, // Skip check since we already checked above
      onSuccess: (booking) {
        // Stop periodic availability check
        provider.stopPeriodicAvailabilityCheck();
        
        // Announce success to screen reader
        SemanticsService.announce(
          'Booking berhasil dibuat',
          TextDirection.ltr,
        );
        
        // Show confirmation dialog with booking details
        _showConfirmationDialog(booking);
      },
    );

    // Show error if booking failed
    if (!success && provider.errorMessage != null) {
      // Check if it's a booking conflict error (backend validation)
      if (_isBookingConflict(provider.errorMessage!)) {
        _showBookingConflictDialog();
      } else {
        _showErrorSnackbar(provider.errorMessage!);
      }
      
      // Announce error to screen reader
      SemanticsService.announce(
        'Booking gagal. ${provider.errorMessage}',
        TextDirection.ltr,
      );
    }
  }

  /// Check if error is a booking conflict
  bool _isBookingConflict(String message) {
    return message.contains('booking aktif') ||
           message.contains('active booking') ||
           message.contains('sudah memiliki') ||
           message.contains('conflict');
  }

  /// Show booking conflict dialog
  void _showBookingConflictDialog() {
    BookingConflictDialog.show(
      context: context,
      onViewExisting: () {
        // Navigate to Activity Page to view existing booking
        Navigator.pushReplacementNamed(
          context,
          '/activity',
          arguments: {'initialTab': 0},
        );
      },
      onCancel: () {
        // Just close the dialog and stay on booking page
        // User can modify their booking or go back
      },
    );
  }

  /// Show error snackbar with retry option
  ///
  /// Requirements: 11.1-11.7
  void _showErrorSnackbar(String message) {
    final isNetworkError = message.contains('internet') || 
                          message.contains('koneksi') ||
                          message.contains('timeout') ||
                          message.contains('network');
    
    final isOffline = message.contains('internet') || 
                     message.contains('koneksi');
    
    // Show offline indicator if network is unavailable
    if (isOffline) {
      ErrorSnackbarHelper.showOffline(context);
      return;
    }
    
    // Show error with retry button for recoverable errors
    ErrorSnackbarHelper.showError(
      context: context,
      message: message,
      isNetworkError: isNetworkError,
      onRetry: isNetworkError ? () {
        final provider = Provider.of<BookingProvider>(context, listen: false);
        _handleConfirmBooking(provider);
      } : null,
    );
  }

  /// Show success snackbar
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show booking confirmation dialog
  ///
  /// Requirements: 10.1-10.6, 10.8
  void _showConfirmationDialog(booking) {
    // Pop the booking page first
    Navigator.pop(context);
    
    // Show confirmation dialog as full-screen route
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => BookingConfirmationDialog(
          booking: booking,
          onViewActivity: () async {
            // Close dialog
            Navigator.pop(context);
            
            // Trigger ActiveParkingProvider to fetch new booking data
            final activeParkingProvider = Provider.of<ActiveParkingProvider>(
              context,
              listen: false,
            );
            
            // Fetch active parking data to display the new booking
            await activeParkingProvider.fetchActiveParking(token: _authToken);
            
            // Navigate to Activity Page with initialTab: 0 (Aktivitas tab)
            Navigator.pushReplacementNamed(
              context,
              '/activity',
              arguments: {'initialTab': 0},
            );
          },
          onBackToHome: () {
            // Close dialog
            Navigator.pop(context);
            
            // Navigate to Home Page
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Stop periodic availability check when leaving page
    _bookingProvider?.stopPeriodicAvailabilityCheck();
    
    // Dispose vehicle service if it has a dispose method
    // Note: VehicleService doesn't have dispose in current implementation
    // but we document this for future reference
    
    // Clear references to large objects
    _bookingProvider = null;
    
    super.dispose();
  }
}

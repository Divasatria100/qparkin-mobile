import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../../config/design_constants.dart';
import '../../data/models/vehicle_model.dart';
import '../../data/services/vehicle_api_service.dart';
import 'base_parking_card.dart';
import 'booking_shimmer_loading.dart';
import 'validation_error_text.dart';

/// Widget for selecting a vehicle from the user's registered vehicles
/// Displays a dropdown with vehicle cards showing icons, plat, jenis, and merk
///
/// Requirements: 3.1-3.7, 11.3, 12.1-12.9, 13.2
class VehicleSelector extends StatefulWidget {
  final VehicleModel? selectedVehicle;
  final Function(VehicleModel?) onVehicleSelected;
  final VehicleApiService vehicleService;
  final String? validationError;

  const VehicleSelector({
    Key? key,
    required this.selectedVehicle,
    required this.onVehicleSelected,
    required this.vehicleService,
    this.validationError,
  }) : super(key: key);

  @override
  State<VehicleSelector> createState() => _VehicleSelectorState();
}

class _VehicleSelectorState extends State<VehicleSelector> {
  List<VehicleModel> _vehicles = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  Future<void> _fetchVehicles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('[VehicleSelector] Fetching vehicles from API...');
      final vehicles = await widget.vehicleService.getVehicles();
      debugPrint(
          '[VehicleSelector] Vehicles fetched successfully: ${vehicles.length} vehicles');

      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[VehicleSelector] Error fetching vehicles: $e');

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  IconData _getVehicleIcon(String jenisKendaraan) {
    switch (jenisKendaraan.toLowerCase()) {
      case 'roda dua':
        return Icons.two_wheeler;
      case 'roda tiga':
        return Icons.electric_rickshaw;
      case 'roda empat':
        return Icons.directions_car;
      case 'lebih dari enam':
        return Icons.local_shipping;
      default:
        return Icons.directions_car;
    }
  }

  void _navigateToAddVehicle() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Navigasi ke halaman tambah kendaraan'),
        backgroundColor: DesignConstants.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasValidationError =
        widget.validationError != null && widget.validationError!.isNotEmpty;

    return BaseParkingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Kendaraan',
            style: DesignConstants.getHeadingStyle(
              fontSize: DesignConstants.fontSizeH4,
            ),
          ),
          const SizedBox(height: DesignConstants.spaceMd),

          if (_isLoading)
            _buildLoadingState()
          else if (_errorMessage != null)
            _buildErrorState()
          else if (_vehicles.isEmpty)
            _buildEmptyState()
          else
            _buildVehicleDropdown(),

          // Validation error display
          if (hasValidationError)
            ValidationErrorText(errorText: widget.validationError),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Semantics(
      label: 'Memuat daftar kendaraan',
      hint: 'Mohon tunggu, sedang memuat data kendaraan Anda',
      child: const VehicleSelectorShimmer(),
    );
  }

  Widget _buildErrorState() {
    return Semantics(
      label: 'Gagal memuat kendaraan',
      hint:
          'Terjadi kesalahan saat memuat data kendaraan. Ketuk tombol coba lagi untuk memuat ulang',
      child: Container(
        padding: DesignConstants.cardPadding,
        decoration: BoxDecoration(
          color: DesignConstants.errorSurface,
          borderRadius:
              BorderRadius.circular(DesignConstants.cardBorderRadius),
        ),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: DesignConstants.errorColor,
              size: DesignConstants.iconSizeXLarge,
            ),
            const SizedBox(height: DesignConstants.spaceSm),
            Text(
              'Gagal memuat kendaraan',
              style: DesignConstants.getBodyStyle(
                fontWeight: DesignConstants.fontWeightSemiBold,
                color: DesignConstants.errorColor,
              ),
            ),
            const SizedBox(height: DesignConstants.spaceSm),
            Semantics(
              label: 'Tombol coba lagi',
              hint: 'Ketuk untuk memuat ulang data kendaraan',
              button: true,
              child: TextButton(
                onPressed: _fetchVehicles,
                style: TextButton.styleFrom(
                  minimumSize: const Size(
                    DesignConstants.minTouchTarget,
                    DesignConstants.minTouchTarget,
                  ),
                ),
                child: const Text('Coba Lagi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Semantics(
      label:
          'Belum ada kendaraan terdaftar. Tambahkan kendaraan terlebih dahulu untuk melanjutkan booking',
      child: Container(
        padding: DesignConstants.cardPadding,
        decoration: BoxDecoration(
          border: Border.all(
            color: DesignConstants.borderPrimary,
            width: DesignConstants.cardBorderWidthFocused,
          ),
          borderRadius:
              BorderRadius.circular(DesignConstants.cardBorderRadius),
        ),
        child: Column(
          children: [
            Semantics(
              label: 'Ikon tambah kendaraan',
              child: Icon(
                Icons.add_circle,
                color: DesignConstants.primaryColor,
                size: DesignConstants.iconSizeXLarge,
              ),
            ),
            const SizedBox(height: DesignConstants.spaceSm),
            Text(
              'Belum ada kendaraan',
              style: DesignConstants.getHeadingStyle(
                fontSize: DesignConstants.fontSizeH4,
              ),
            ),
            const SizedBox(height: DesignConstants.spaceXs),
            Text(
              'Tambahkan kendaraan terlebih dahulu',
              style: DesignConstants.getBodyStyle(
                color: DesignConstants.textTertiary,
              ),
            ),
            const SizedBox(height: DesignConstants.spaceMd),
            Semantics(
              label: 'Tombol tambah kendaraan',
              hint: 'Ketuk untuk menambahkan kendaraan baru',
              button: true,
              child: TextButton(
                onPressed: _navigateToAddVehicle,
                style: TextButton.styleFrom(
                  foregroundColor: DesignConstants.primaryColor,
                  minimumSize: const Size(
                    DesignConstants.minTouchTarget,
                    DesignConstants.minTouchTarget,
                  ),
                ),
                child: Text(
                  'Tambah Kendaraan',
                  style: DesignConstants.getBodyStyle(
                    fontWeight: DesignConstants.fontWeightSemiBold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleDropdown() {
    debugPrint(
        '[VehicleSelector] Building dropdown with ${_vehicles.length} vehicles');
    if (widget.selectedVehicle != null) {
      debugPrint(
          '[VehicleSelector] Selected vehicle ID: ${widget.selectedVehicle!.idKendaraan}');
      debugPrint(
          '[VehicleSelector] Selected vehicle plat: ${widget.selectedVehicle!.platNomor}');
    }

    VehicleModel? matchingVehicle;
    if (widget.selectedVehicle != null) {
      try {
        matchingVehicle = _vehicles.firstWhere(
          (v) => v.idKendaraan == widget.selectedVehicle!.idKendaraan,
        );
        debugPrint(
            '[VehicleSelector] Found matching vehicle: ${matchingVehicle.platNomor}');
      } catch (e) {
        debugPrint('[VehicleSelector] No matching vehicle found in list');
        matchingVehicle = null;
      }
    }

    return Semantics(
      label:
          'Pilih kendaraan untuk booking. ${matchingVehicle != null ? "Kendaraan terpilih: ${matchingVehicle.platNomor}, ${matchingVehicle.jenisKendaraan}, ${matchingVehicle.merk} ${matchingVehicle.tipe}" : "Belum ada kendaraan dipilih"}',
      hint: 'Ketuk untuk memilih kendaraan dari daftar kendaraan terdaftar',
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _isFocused = hasFocus;
          });
        },
        child: DropdownButtonFormField<VehicleModel>(
          value: matchingVehicle,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: DesignConstants.spaceMd,
              vertical: DesignConstants.spaceSm,
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(DesignConstants.cardBorderRadius),
              borderSide: BorderSide(color: DesignConstants.borderPrimary),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(DesignConstants.cardBorderRadius),
              borderSide: BorderSide(color: DesignConstants.borderPrimary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(DesignConstants.cardBorderRadius),
              borderSide: BorderSide(
                color: DesignConstants.primaryColor,
                width: DesignConstants.cardBorderWidthFocused,
              ),
            ),
          ),
          hint: const Text('Pilih kendaraan Anda'),
          isExpanded: true,
          items: _vehicles.map((vehicle) {
            return DropdownMenuItem<VehicleModel>(
              value: vehicle,
              child: Semantics(
                label:
                    'Kendaraan ${vehicle.platNomor}, ${vehicle.jenisKendaraan}, ${vehicle.merk} ${vehicle.tipe}',
                child: _buildVehicleItem(vehicle),
              ),
            );
          }).toList(),
          onChanged: (VehicleModel? newValue) {
            debugPrint(
                '[VehicleSelector] Vehicle selected: ${newValue?.platNomor}');
            widget.onVehicleSelected(newValue);
            if (newValue != null) {
              SemanticsService.announce(
                'Kendaraan ${newValue.platNomor} dipilih',
                TextDirection.ltr,
              );
            }
          },
          selectedItemBuilder: (BuildContext context) {
            return _vehicles.map((vehicle) {
              return _buildVehicleItem(vehicle);
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _buildVehicleItem(VehicleModel vehicle) {
    return Row(
      children: [
        Icon(
          _getVehicleIcon(vehicle.jenisKendaraan),
          color: DesignConstants.primaryColor,
          size: DesignConstants.iconSizeMedium,
        ),
        const SizedBox(width: DesignConstants.spaceMd),
        Expanded(
          child: Text(
            '${vehicle.platNomor} - ${vehicle.merk} ${vehicle.tipe}',
            style: DesignConstants.getBodyStyle(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

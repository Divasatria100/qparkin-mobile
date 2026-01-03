// 📄 lib/presentation/screens/tambah_kendaraan.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/profile_provider.dart';
import '../../data/models/vehicle_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Add/Edit Vehicle Page
/// Allows users to register a new vehicle or edit existing vehicle information
/// Supports dual-mode operation: add mode and edit mode
/// Integrates with ProfileProvider for data persistence
class VehicleSelectionPage extends StatefulWidget {
  final bool isEditMode;
  final VehicleModel? vehicle;
  
  const VehicleSelectionPage({
    super.key,
    this.isEditMode = false,
    this.vehicle,
  });

  @override
  State<VehicleSelectionPage> createState() => _VehicleSelectionPageState();
}

class _VehicleSelectionPageState extends State<VehicleSelectionPage> {
  // Form controllers
  final TextEditingController brandController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController plateController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  
  // Form state
  String? selectedVehicleType;
  String? selectedVehicleStatus;
  File? selectedImage;
  bool isLoading = false;
  
  // Mode tracking
  late bool _isEditMode;
  late VehicleModel? _editingVehicle;
  
  // Track original photo URL for edit mode
  String? _originalPhotoUrl;
  
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Vehicle types matching VehicleModel
  final List<Map<String, dynamic>> vehicleTypes = [
    {
      "name": "Roda Dua",
      "icon": Icons.two_wheeler,
    },
    {
      "name": "Roda Tiga",
      "icon": Icons.electric_rickshaw,
    },
    {
      "name": "Roda Empat",
      "icon": Icons.directions_car,
    },
    {
      "name": "Lebih dari Enam",
      "icon": Icons.local_shipping,
    },
  ];

  // Vehicle status options
  final List<String> vehicleStatuses = [
    "Kendaraan Utama",
    "Kendaraan Tamu",
  ];

  @override
  void initState() {
    super.initState();
    
    // Detect mode
    _isEditMode = widget.isEditMode;
    _editingVehicle = widget.vehicle;
    
    // Prefill data if in edit mode
    if (_isEditMode && _editingVehicle != null) {
      _prefillFormData();
    }
    
    // Set default status if add mode
    if (!_isEditMode) {
      selectedVehicleStatus = vehicleStatuses[0];
    }
  }

  /// Prefill form data when in edit mode
  void _prefillFormData() {
    final vehicle = _editingVehicle!;
    
    // Prefill text controllers
    brandController.text = vehicle.merk;
    typeController.text = vehicle.tipe;
    plateController.text = vehicle.platNomor;
    colorController.text = vehicle.warna ?? '';
    
    // Set selected vehicle type (read-only in edit mode)
    selectedVehicleType = vehicle.jenisKendaraan;
    
    // Set vehicle status based on isActive flag
    selectedVehicleStatus = vehicle.isActive 
        ? "Kendaraan Utama" 
        : "Kendaraan Tamu";
    
    // Store original photo URL for later use
    _originalPhotoUrl = vehicle.fotoUrl;
  }

  @override
  void dispose() {
    brandController.dispose();
    typeController.dispose();
    plateController.dispose();
    colorController.dispose();
    super.dispose();
  }

  /// Pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: Colors.red[400],
          ),
        );
      }
    }
  }

  /// Show image source selection dialog
  void _showImageSourceDialog() {
    // Determine if there's a photo to remove (either new selection or existing photo)
    final hasPhoto = selectedImage != null || 
                     (_isEditMode && _originalPhotoUrl != null && _originalPhotoUrl!.isNotEmpty);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Pilih Sumber Foto',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Color(0xFF573ED1)),
                  title: const Text(
                    'Kamera',
                    style: TextStyle(fontFamily: 'Nunito'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Color(0xFF573ED1)),
                  title: const Text(
                    'Galeri',
                    style: TextStyle(fontFamily: 'Nunito'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (hasPhoto)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      'Hapus Foto',
                      style: TextStyle(fontFamily: 'Nunito'),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        selectedImage = null;
                        // In edit mode, also clear the original photo URL to indicate removal
                        if (_isEditMode) {
                          _originalPhotoUrl = null;
                        }
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Validate and submit form
  Future<void> _submitForm() async {
    // Validate required fields
    // In edit mode, vehicle type is already set and read-only
    if (!_isEditMode && selectedVehicleType == null) {
      _showSnackbar('Pilih jenis kendaraan terlebih dahulu', isError: true);
      return;
    }

    if (brandController.text.trim().isEmpty) {
      _showSnackbar('Masukkan merek kendaraan', isError: true);
      return;
    }

    if (typeController.text.trim().isEmpty) {
      _showSnackbar('Masukkan tipe kendaraan', isError: true);
      return;
    }

    // In add mode, validate plate number
    if (!_isEditMode) {
      if (plateController.text.trim().isEmpty) {
        _showSnackbar('Masukkan plat nomor kendaraan', isError: true);
        return;
      }

      // Validate plate number format (basic validation)
      final plateRegex = RegExp(r'^[A-Z]{1,2}\s?\d{1,4}\s?[A-Z]{1,3}$', caseSensitive: false);
      if (!plateRegex.hasMatch(plateController.text.trim())) {
        _showSnackbar('Format plat nomor tidak valid (contoh: B 1234 XYZ)', isError: true);
        return;
      }
    }

    // Validate color field (now required)
    if (colorController.text.trim().isEmpty) {
      _showSnackbar('Warna kendaraan wajib diisi', isError: true);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final provider = context.read<ProfileProvider>();
      
      if (_isEditMode) {
        // Edit mode: use updateVehicle
        await provider.updateVehicle(
          id: _editingVehicle!.idKendaraan,
          merk: brandController.text.trim(),
          tipe: typeController.text.trim(),
          warna: colorController.text.trim(),
          isActive: selectedVehicleStatus == "Kendaraan Utama",
          foto: selectedImage, // null if not changed
        );
        
        if (mounted) {
          _showSnackbar('Kendaraan berhasil diperbarui!', isError: false);
          Navigator.of(context).pop(true);
        }
      } else {
        // Add mode: use addVehicle (existing logic)
        await provider.addVehicle(
          platNomor: plateController.text.trim().toUpperCase(),
          jenisKendaraan: selectedVehicleType!,
          merk: brandController.text.trim(),
          tipe: typeController.text.trim(),
          warna: colorController.text.trim(),
          isActive: selectedVehicleStatus == "Kendaraan Utama",
          foto: selectedImage,
        );
        
        if (mounted) {
          _showSnackbar('Kendaraan berhasil ditambahkan!', isError: false);
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      // Handle API errors gracefully with user-friendly messages
      if (mounted) {
        final errorMessage = _getUserFriendlyErrorMessage(e.toString());
        _showSnackbar(errorMessage, isError: true);
        // Don't navigate away on error - allow user to retry
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// Convert technical error messages to user-friendly messages
  /// Provides specific guidance based on error type
  String _getUserFriendlyErrorMessage(String error) {
    final errorLower = error.toLowerCase();
    final operationText = _isEditMode ? 'memperbarui' : 'menambahkan';

    // Network/Connection errors
    if (errorLower.contains('timeout') || errorLower.contains('connection')) {
      return 'Koneksi internet bermasalah. Silakan periksa koneksi Anda dan coba lagi.';
    }
    
    // Authentication errors
    if (errorLower.contains('unauthorized') || errorLower.contains('401')) {
      return 'Sesi Anda telah berakhir. Silakan login kembali.';
    }
    
    // Not found errors
    if (errorLower.contains('404') || errorLower.contains('not found')) {
      return _isEditMode 
          ? 'Kendaraan tidak ditemukan. Data mungkin sudah dihapus.'
          : 'Gagal $operationText kendaraan. Silakan coba lagi.';
    }
    
    // Validation errors (422)
    if (errorLower.contains('422') || errorLower.contains('validation')) {
      return 'Data yang dimasukkan tidak valid. Periksa kembali informasi kendaraan.';
    }
    
    // Duplicate errors
    if (errorLower.contains('duplicate') || errorLower.contains('already exists')) {
      return 'Plat nomor sudah terdaftar. Gunakan plat nomor yang berbeda.';
    }
    
    // Server errors
    if (errorLower.contains('500') || errorLower.contains('server')) {
      return 'Server sedang bermasalah. Silakan coba beberapa saat lagi.';
    }
    
    // Network errors
    if (errorLower.contains('network')) {
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    }
    
    // Photo upload errors
    if (errorLower.contains('file') || errorLower.contains('upload')) {
      return 'Gagal mengunggah foto. Pastikan ukuran foto tidak lebih dari 5MB.';
    }
    
    // Generic error with operation context
    return 'Gagal $operationText kendaraan. Silakan coba lagi.';
  }

  void _showSnackbar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Nunito'),
        ),
        backgroundColor: isError ? Colors.red[400] : const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // Header - consistent with list_kendaraan.dart and vehicle_detail_page.dart
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF7C5ED1),
                      Color(0xFF573ED1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: 'Kembali',
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isEditMode ? 'Edit Kendaraan' : 'Tambah Kendaraan',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Form content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Photo section (optional)
                        _buildPhotoSection(),
                        const SizedBox(height: 32),

                        // Vehicle type selection
                        _buildVehicleTypeSection(),
                        const SizedBox(height: 32),

                        // Vehicle information
                        _buildVehicleInfoSection(),
                        const SizedBox(height: 32),

                        // Vehicle status
                        _buildVehicleStatusSection(),
                        const SizedBox(height: 40),

                        // Submit button
                        _buildSubmitButton(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto Kendaraan (Opsional)',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2E3A8C),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: GestureDetector(
            onTap: _showImageSourceDialog,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: _buildPhotoContent(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // Disclaimer for photo upload
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Foto kendaraan bersifat opsional dan digunakan untuk membantu identifikasi visual. Pastikan foto yang diunggah adalah kendaraan yang sesuai.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              height: 1.4,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  /// Build photo content based on current state
  /// Handles: new photo selected, existing photo (edit mode), or placeholder
  Widget _buildPhotoContent() {
    // Priority 1: Show newly selected image (both add and edit mode)
    if (selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.file(
          selectedImage!,
          fit: BoxFit.cover,
        ),
      );
    }
    
    // Priority 2: Show existing photo from URL (edit mode only)
    if (_isEditMode && _originalPhotoUrl != null && _originalPhotoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: CachedNetworkImage(
          imageUrl: _originalPhotoUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.grey.shade400,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image,
                size: 40,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                'Gagal memuat foto',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // Priority 3: Show placeholder (no photo)
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo,
          size: 40,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 8),
        Text(
          'Tambah Foto',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// Get icon for vehicle type
  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType) {
      case "Roda Dua":
        return Icons.two_wheeler;
      case "Roda Tiga":
        return Icons.electric_rickshaw;
      case "Roda Empat":
        return Icons.directions_car;
      case "Lebih dari Enam":
        return Icons.local_shipping;
      default:
        return Icons.directions_car;
    }
  }

  /// Build read-only vehicle type display for edit mode
  Widget _buildReadOnlyVehicleType() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Grey background for read-only
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            _getVehicleIcon(selectedVehicleType!),
            size: 32,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jenis Kendaraan',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedVehicleType!,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.lock,
            color: Colors.grey.shade400,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleTypeSection() {
    // If in edit mode, show read-only display
    if (_isEditMode) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jenis Kendaraan *',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E3A8C),
            ),
          ),
          const SizedBox(height: 16),
          _buildReadOnlyVehicleType(),
        ],
      );
    }
    
    // Otherwise, show interactive grid for add mode
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Kendaraan *',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2E3A8C),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: vehicleTypes.length,
          itemBuilder: (context, index) {
            final vehicle = vehicleTypes[index];
            final isSelected = selectedVehicleType == vehicle["name"];

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedVehicleType = vehicle["name"];
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected 
                        ? const Color(0xFF573ED1)
                        : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? const Color(0xFF573ED1).withOpacity(0.2)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: isSelected ? 16 : 8,
                      offset: Offset(0, isSelected ? 4 : 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      vehicle["icon"],
                      size: 32,
                      color: isSelected 
                          ? const Color(0xFF573ED1)
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vehicle["name"]!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected 
                            ? const Color(0xFF573ED1)
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVehicleInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informasi Kendaraan',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2E3A8C),
          ),
        ),
        const SizedBox(height: 16),
        
        // Brand
        TextField(
          controller: brandController,
          decoration: InputDecoration(
            labelText: 'Merek Kendaraan *',
            labelStyle: const TextStyle(fontFamily: 'Nunito'),
            hintText: 'Contoh: Toyota, Honda, Yamaha',
            hintStyle: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF573ED1), width: 2),
            ),
          ),
          style: const TextStyle(fontFamily: 'Nunito'),
        ),
        const SizedBox(height: 20),

        // Type
        TextField(
          controller: typeController,
          decoration: InputDecoration(
            labelText: 'Tipe/Model Kendaraan *',
            labelStyle: const TextStyle(fontFamily: 'Nunito'),
            hintText: 'Contoh: Avanza, Beat, Vario',
            hintStyle: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF573ED1), width: 2),
            ),
          ),
          style: const TextStyle(fontFamily: 'Nunito'),
        ),
        const SizedBox(height: 20),

        // Plate number
        TextField(
          controller: plateController,
          enabled: !_isEditMode, // Disabled in edit mode
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText: 'Plat Nomor *',
            labelStyle: const TextStyle(fontFamily: 'Nunito'),
            hintText: 'Contoh: B 1234 XYZ',
            hintStyle: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
            filled: _isEditMode, // Add grey background when disabled
            fillColor: _isEditMode ? Colors.grey.shade100 : null,
            suffixIcon: _isEditMode 
                ? Icon(Icons.lock, color: Colors.grey.shade400, size: 20)
                : null,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF573ED1), width: 2),
            ),
            disabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          style: const TextStyle(fontFamily: 'Nunito'),
        ),
        const SizedBox(height: 12),
        
        // Warning disclaimer for plate number
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0), // Light orange background
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFFF9800).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 20,
                color: Colors.orange[700],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pastikan plat nomor kendaraan diinput sesuai dengan kendaraan yang digunakan. Data yang tidak sesuai dapat menyebabkan kendala saat proses parkir.',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.orange[900],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Color (required)
        TextField(
          controller: colorController,
          decoration: InputDecoration(
            labelText: 'Warna Kendaraan *',
            labelStyle: const TextStyle(fontFamily: 'Nunito'),
            hintText: 'Contoh: Hitam, Putih, Merah',
            hintStyle: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF573ED1), width: 2),
            ),
          ),
          style: const TextStyle(fontFamily: 'Nunito'),
        ),
        const SizedBox(height: 8),
        
        // Helper text for color field
        Padding(
          padding: const EdgeInsets.only(left: 0),
          child: Text(
            'Sesuai dengan warna kendaraan pada STNK.',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status Kendaraan',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2E3A8C),
          ),
        ),
        const SizedBox(height: 12),
        ...vehicleStatuses.map((status) {
          final isSelected = selectedVehicleStatus == status;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedVehicleStatus = status;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? const Color(0xFF573ED1)
                        : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? const Color(0xFF573ED1).withOpacity(0.1)
                          : Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected 
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected 
                          ? const Color(0xFF573ED1)
                          : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected 
                                  ? const Color(0xFF573ED1)
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            status == "Kendaraan Utama"
                                ? 'Kendaraan yang sering digunakan untuk parkir'
                                : 'Kendaraan tamu atau kendaraan cadangan',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF573ED1),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _isEditMode ? 'Simpan Perubahan' : 'Tambahkan Kendaraan',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

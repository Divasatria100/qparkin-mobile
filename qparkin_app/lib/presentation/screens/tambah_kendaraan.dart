// 📄 lib/presentation/screens/tambah_kendaraan.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/profile_provider.dart';
import '../../data/models/vehicle_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// Add Vehicle Page
/// Allows users to register a new vehicle with complete information
/// Integrates with ProfileProvider for data persistence
class VehicleSelectionPage extends StatefulWidget {
  const VehicleSelectionPage({super.key});

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
    // Set default status
    selectedVehicleStatus = vehicleStatuses[0];
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
                if (selectedImage != null)
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
    if (selectedVehicleType == null) {
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

    setState(() {
      isLoading = true;
    });

    try {
      final provider = context.read<ProfileProvider>();
      
      // Add vehicle through provider with new API
      await provider.addVehicle(
        platNomor: plateController.text.trim().toUpperCase(),
        jenisKendaraan: selectedVehicleType!,
        merk: brandController.text.trim(),
        tipe: typeController.text.trim(),
        warna: colorController.text.trim().isNotEmpty 
            ? colorController.text.trim() 
            : null,
        isActive: selectedVehicleStatus == "Kendaraan Utama",
        foto: selectedImage,
      );

      if (mounted) {
        _showSnackbar('Kendaraan berhasil ditambahkan!', isError: false);
        
        // Return to previous page with success
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Gagal menambahkan kendaraan: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
                        const Text(
                          'Tambah Kendaraan',
                          style: TextStyle(
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
              child: selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
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
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleTypeSection() {
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

        // Color (optional)
        TextField(
          controller: colorController,
          decoration: InputDecoration(
            labelText: 'Warna Kendaraan (Opsional)',
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
            : const Text(
                'Tambahkan Kendaraan',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/profile_provider.dart';
import '../../data/models/user_model.dart';
import '../../utils/validators.dart';
import '../widgets/common/cached_profile_image.dart';

/// Page for editing user profile information
/// Allows users to update name, email, phone number, and profile photo
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isLoading = false;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    // Pre-fill form with current user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProfileProvider>();
      final user = provider.user;
      
      if (user != null) {
        _nameController.text = user.name;
        _emailController.text = user.email ?? ''; // Null-safe: use empty string if email is null
        _phoneController.text = user.phoneNumber ?? '';
        setState(() {
          _photoUrl = user.photoUrl;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Validate email format (optional)
  String? _validateEmail(String? value) {
    // Email is optional - allow empty
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    
    // If email is provided, validate format
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    
    return null;
  }

  /// Validate phone number format
  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      // Phone is optional
      return null;
    }
    
    // Remove all non-digit characters
    final digits = value.replaceAll(RegExp(r'\D'), '');
    
    // Check if it starts with 0 (Indonesian format)
    if (digits.startsWith('0')) {
      if (digits.length < 10 || digits.length > 13) {
        return 'Nomor telepon harus 10-13 digit';
      }
    } else {
      // Assume international format without leading 0
      if (digits.length < 9 || digits.length > 12) {
        return 'Nomor telepon harus 9-12 digit';
      }
    }
    
    return null;
  }

  /// Handle save button press
  Future<void> _handleSave() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if user is removing email (had email before, now empty)
    final provider = context.read<ProfileProvider>();
    final currentUser = provider.user;
    
    if (currentUser == null) {
      throw Exception('User data not found');
    }

    final hadEmail = currentUser.email != null && currentUser.email!.isNotEmpty; // Null-safe: use ! after null check
    final removingEmail = hadEmail && _emailController.text.trim().isEmpty;

    // Show warning if removing email
    if (removingEmail) {
      final confirmed = await _showRemoveEmailWarning();
      if (confirmed != true) {
        return; // User cancelled
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Log current state before update
      debugPrint('[EditProfilePage] ========================================');
      debugPrint('[EditProfilePage] BEFORE UPDATE:');
      debugPrint('[EditProfilePage] - Current email: ${currentUser.email}');
      debugPrint('[EditProfilePage] - Input email: "${_emailController.text}"');
      debugPrint('[EditProfilePage] - Had email: $hadEmail');
      debugPrint('[EditProfilePage] - Removing email: $removingEmail');
      debugPrint('[EditProfilePage] ========================================');
      
      // Create updated user model
      final updatedUser = currentUser.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim().isEmpty 
            ? null 
            : _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty 
            ? null 
            : _phoneController.text.trim(),
        photoUrl: _photoUrl,
        updatedAt: DateTime.now(),
      );
      
      debugPrint('[EditProfilePage] UPDATED USER MODEL:');
      debugPrint('[EditProfilePage] - name: ${updatedUser.name}');
      debugPrint('[EditProfilePage] - email: ${updatedUser.email} (${updatedUser.email == null ? "NULL" : "has value"})');
      debugPrint('[EditProfilePage] - phoneNumber: ${updatedUser.phoneNumber}');
      debugPrint('[EditProfilePage] ========================================');

      // Update user data through provider
      await provider.updateUser(updatedUser);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Profil berhasil diperbarui',
              style: TextStyle(fontFamily: 'Nunito'),
            ),
            backgroundColor: Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back to profile page with result
        Navigator.of(context).pop(true); // Return true to trigger refresh
      }
    } catch (e) {
      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memperbarui profil: ${e.toString()}',
              style: const TextStyle(fontFamily: 'Nunito'),
            ),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Handle photo selection (placeholder for image picker)
  Future<void> _handlePhotoSelection() async {
    // TODO: Implement image picker when package is added
    // For now, show a placeholder dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Pilih Foto',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Fitur pemilihan foto akan segera tersedia',
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Color(0xFF573ED1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show warning dialog when user removes email
  Future<bool?> _showRemoveEmailWarning() async {
    return showDialog<bool>(
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
            const Text(
              'Hapus Email?',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'Jika Anda menghapus email, Anda tidak akan menerima notifikasi booking parkiran via email. Anda masih bisa menambahkan email kembali nanti.',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Color(0xFF8E8E93),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              backgroundColor: Colors.orange[50],
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Hapus Email',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.orange[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF573ED1),
        elevation: 0,
        leading: Semantics(
          button: true,
          label: 'Tombol kembali',
          hint: 'Ketuk untuk kembali ke halaman profil',
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Photo Section
                Center(
                  child: Stack(
                    children: [
                      CachedProfileImage(
                        imageUrl: _photoUrl,
                        size: 100,
                        semanticLabel: 'Foto profil',
                        fallbackIcon: Icons.person,
                        fallbackIconSize: 50,
                        fallbackIconColor: const Color(0xFF8E8E93),
                        backgroundColor: Colors.white,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Semantics(
                          button: true,
                          label: 'Tombol ubah foto profil',
                          hint: 'Ketuk untuk memilih foto baru',
                          child: GestureDetector(
                            onTap: _handlePhotoSelection,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF573ED1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Name Field
                Semantics(
                  label: 'Label nama lengkap',
                  child: const Text(
                    'Nama Lengkap',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Semantics(
                  label: 'Kolom input nama lengkap',
                  hint: 'Masukkan nama lengkap Anda',
                  textField: true,
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama lengkap',
                      hintStyle: const TextStyle(
                        fontFamily: 'Nunito',
                        color: Color(0xFF8E8E93),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                    ),
                    validator: (value) => Validators.required(value, label: 'Nama'),
                  ),
                ),
                const SizedBox(height: 20),

                // Email Field
                Semantics(
                  label: 'Label email',
                  child: Row(
                    children: [
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(opsional)',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Semantics(
                  label: 'Kolom input email',
                  hint: 'Masukkan alamat email Anda, opsional',
                  textField: true,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Masukkan email (opsional)',
                      hintStyle: const TextStyle(
                        fontFamily: 'Nunito',
                        color: Color(0xFF8E8E93),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                    ),
                    validator: _validateEmail,
                  ),
                ),
                const SizedBox(height: 8),
                // Email info text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Email digunakan untuk notifikasi booking parkiran',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Phone Field
                Semantics(
                  label: 'Label nomor telepon',
                  child: const Text(
                    'Nomor Telepon',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Semantics(
                  label: 'Kolom input nomor telepon',
                  hint: 'Masukkan nomor telepon Anda, opsional',
                  textField: true,
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Masukkan nomor telepon (opsional)',
                      hintStyle: const TextStyle(
                        fontFamily: 'Nunito',
                        color: Color(0xFF8E8E93),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                    ),
                    validator: _validatePhone,
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                Semantics(
                  button: true,
                  label: _isLoading ? 'Menyimpan perubahan' : 'Tombol simpan perubahan',
                  hint: _isLoading ? 'Sedang menyimpan' : 'Ketuk untuk menyimpan perubahan profil',
                  enabled: !_isLoading,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF573ED1),
                        disabledBackgroundColor: const Color(0xFF573ED1).withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? Semantics(
                              label: 'Indikator loading',
                              child: const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            )
                          : const Text(
                              'Simpan Perubahan',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/config/app_theme.dart';
import '/utils/validators.dart';
import '/presentation/widgets/phone_field.dart';
import '/presentation/widgets/buttons.dart';
import '/data/services/auth_service.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signup';
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();

  // default tidak auto-centang
  bool _remember = false;
  bool _obscure = true;

  // FLAG: memicu autovalidasi setelah tombol ditekan
  bool _submitted = false;

  final _auth = AuthService();

  final BorderRadius _radius = BorderRadius.circular(12);

  // Warna konsisten dengan Home
  static const primaryPurple = Color(0xFF573ED1);
  static const labelBlue = Color(0xFF1E3A8A);
  static const borderGrey = Color(0xFFD0D5DD);
  static const hintGrey = Color(0xFF949191);
  static const focusBlue = Color.fromARGB(255, 69, 17, 173);

  // Layout constants
  static const double headerHeight = 360;
  static const double overlap = 80;
  double get _topPaddingForScroll => headerHeight - overlap;

  InputDecoration _pinDecoration() {
    return const InputDecoration(
      labelText: 'PIN',
      hintText: 'Masukkan 6 digit PIN',
      counterText: '',
      floatingLabelBehavior: FloatingLabelBehavior.always,
    ).copyWith(
      // ⬇️ rapetin jarak error
      isDense: true,
      labelStyle: const TextStyle(color: labelBlue),
      hintStyle: const TextStyle(color: hintGrey),
      border: OutlineInputBorder(borderRadius: _radius),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFD0D5DD), width: 2.0),
      ),
      disabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFD0D5DD), width: 2.0,),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFF1E3A8A), width: 2.0),
      ),
      // samakan ketebalan error
      errorBorder: OutlineInputBorder(
        borderRadius: _radius,
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: _radius,
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
      // ⬇️ teks error kecil & rapat (tinggi baris 0.9)
      errorStyle: const TextStyle(
        color: Colors.red,
        fontSize: 12,
        height: 0.9,
      ),
      // sedikit kurangi padding vertikal agar proporsional saat ada error
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      errorMaxLines: 2,
    );
  }

  InputDecoration _nameDecoration() {
    return const InputDecoration(
      labelText: 'Nama',
      hintText: 'Masukkan nama anda',
      floatingLabelBehavior: FloatingLabelBehavior.always,
    ).copyWith(
      // ⬇️ rapetin jarak error
      isDense: true,
      labelStyle: const TextStyle(color: labelBlue),
      hintStyle: const TextStyle(color: hintGrey),
      border: OutlineInputBorder(borderRadius: _radius),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: borderGrey, width: 2.0),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFF1E3A8A), width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: _radius,
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: _radius,
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
      // ⬇️ teks error kecil & rapat (tinggi baris 0.9)
      errorStyle: const TextStyle(
        color: Colors.red,
        fontSize: 12,
        height: 0.9,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      errorMaxLines: 2,
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ===== HEADER WITH GRADIENT =====
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              height: headerHeight,
              decoration: const BoxDecoration(
                color: primaryPurple,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Image.asset(
                        'assets/images/qparkin.png',
                        height: 78,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Buat akun baru',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Senang bertemu dengan anda!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ===== SCROLLABLE CONTENT =====
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, _topPaddingForScroll, 20, 20),
              child: Column(
                children: [
                  // === FORM CARD ===
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: primaryPurple.withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _submitted
                          ? AutovalidateMode.always
                          : AutovalidateMode.disabled,
                      child: Column(
                        children: [
                          // === Nama ===
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: _nameDecoration(),
                            validator: (v) =>
                                Validators.required(v, label: 'Nama'),
                          ),

                          // ⬇️ Jarak konsisten antar field (16)
                          const SizedBox(height: 16),

                          // === Nomor HP (pakai Theme lokal seperti login) ===
                          Material(
                            color: Colors.transparent,
                            child: Theme(
                              data: theme.copyWith(
                                inputDecorationTheme:
                                    theme.inputDecorationTheme.copyWith(
                                  // ⬇️ rapetin jarak error untuk PhoneField juga
                                  isDense: true,
                                  labelStyle:
                                      const TextStyle(color: labelBlue),
                                  hintStyle: const TextStyle(color: hintGrey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: borderGrey, width: 1.4),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: borderGrey, width: 1.4),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: borderGrey, width: 1.8),
                                  ),
                                  // Samakan error border & TAMPILKAN teks error
                                  errorBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide(
                                        color: Colors.red, width: 2.0),
                                  ),
                                  focusedErrorBorder:
                                      const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide(
                                        color: Colors.red, width: 2.0),
                                  ),
                                  errorStyle: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    height: 0.9, // ⬅️ rapet
                                  ),
                                  errorMaxLines: 2,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                              child: PhoneField(
                                phoneCtrl: _phoneCtrl,
                                validator: Validators.phone,
                              ),
                            ),
                          ),

                          // ⬇️ Jarak konsisten antar field (16)
                          const SizedBox(height: 16),

                          // === PIN ===
                          TextFormField(
                            controller: _pinCtrl,
                            keyboardType: TextInputType.number,
                            obscureText: _obscure,
                            maxLength: 6,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            contextMenuBuilder: (context, editableTextState) => const SizedBox.shrink(),
                            enableInteractiveSelection: false,

                            decoration: _pinDecoration().copyWith(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(Radius.circular(12)),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 1.8,
                                ),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                            validator: Validators.pin6,
                          ),

                          const SizedBox(height: 10),

                          const SizedBox(height: 12),

                          // === Ingat saya ===
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () => setState(() => _remember = !_remember),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: _remember ? primaryPurple : Colors.transparent,
                                      border: Border.all(
                                        color: _remember ? primaryPurple : borderGrey,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: _remember
                                        ? const Icon(
                                            Icons.check,
                                            size: 14,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Ingat saya',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // === Tombol Sign Up ===
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() => _submitted = true);
                                if (_formKey.currentState!.validate()) {
                                  _auth.signup(context, _nameCtrl.text, _phoneCtrl.text, _pinCtrl.text);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 69, 17, 173),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // === Punya akun? Login ===
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Sudah punya akun?'),
                              TextButton(
                                onPressed: () => Navigator.pushReplacementNamed(
                                    context, LoginScreen.routeName),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(color: labelBlue),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // === Spacer agar posisi “Lanjutkan dengan” sama seperti login ===
                  const SizedBox(height: 24),

                  // ===== Atau lanjutkan dengan =====
                  const Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Color(0x80BDBDBD),
                          thickness: 0.6,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Atau lanjutkan dengan',
                          style: TextStyle(color: hintGrey),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Color(0x80BDBDBD),
                          thickness: 0.6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ==== Google button ====
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: panggil signup via Google di sini
                        // _auth.signInWithGoogle(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: borderGrey, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/g-logo.png',
                            height: 20,
                            width: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Google',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
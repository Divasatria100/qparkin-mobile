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

  // Warna konsisten
  static const labelBlue = Color(0xFF1E3A8A);
  static const borderGrey = Color(0xFFC6C6C6);
  static const hintGrey = Color(0xFF949191);

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
      // ⬇️ PERBAIKAN: fokus jadi biru (sama seperti PhoneField)
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFF39BCF4), width: 2.0),
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

    // Konstanta layout agar overlap 100px seperti login
    const double headerHeight = 400;
    const double overlap = 116; // ⬅️ dinaikkan agar card naik ±16px
    final double topPaddingForScroll = headerHeight - overlap; // 284

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ===== HEADER GRADIENT (background) =====
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              height: headerHeight,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                gradient: AppTheme.heroGradient,
              ),
              child: SafeArea(
                bottom: false,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(40, 79, 40, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/qparkin.png',
                          height: 68,
                        ),
                        const SizedBox(height: 38),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Buat akun baru!',
                            style: theme.textTheme.headlineMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ===== KONTEN SCROLL (di atas header, tidak ketutupan) =====
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, topPaddingForScroll, 20, 20),
              child: Column(
                children: [
                  // === CARD FORM (posisi mirror login: overlap) ===
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: const Color(0xFFE8E8E8)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x26000000),
                          blurRadius: 20,
                          offset: Offset(0, 10),
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

                          // === Ingat saya ===
                          Row(
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _remember = !_remember),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Checkbox(
                                          value: _remember,
                                          onChanged: (v) => setState(
                                              () => _remember = (v ?? false)),
                                          visualDensity: const VisualDensity(
                                              horizontal: -4, vertical: -4),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        const SizedBox(width: 4),
                                        const Text('Ingat saya'),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // === Tombol Sign Up ===
                          PrimaryButton(
                            text: 'Sign Up',
                            color: const Color(0xFF1E3A8A),
                            onPressed: () {
                              setState(() => _submitted = true);
                              if (_formKey.currentState!.validate()) {
                                _auth.signup(context);
                              }
                            },
                          ),

                          const SizedBox(height: 8),

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

                  // ===== Lanjutkan dengan + Google (tanpa translate, tidak numpuk di card) =====
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
                          'Lanjutkan dengan',
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

                  // ==== Google button custom ====
                  Container(
                    // ⬇️ Tambah jarak atas & bawah (vertikal), kiri/kanan tetap
                    margin: const EdgeInsets.fromLTRB(15, 16, 15, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.15),
                          offset: Offset(0, 4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () {
                        // TODO: panggil signup via Google di sini
                        // _auth.signInWithGoogle(context);
                      },
                      child: const SizedBox(
                        height: 48,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image(
                              image: AssetImage('assets/images/g-logo.png'),
                              height: 20,
                              width: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Google',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
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
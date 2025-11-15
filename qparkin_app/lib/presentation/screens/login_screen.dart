import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/config/app_theme.dart';
import '/utils/validators.dart';
import '/presentation/widgets/phone_field.dart';
import '/presentation/widgets/buttons.dart';
import '/data/services/auth_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();

  bool _remember = false;
  bool _obscure = true;
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
    return InputDecoration(
      labelText: 'PIN',
      hintText: 'Masukkan 6 digit PIN',
      counterText: '',
      floatingLabelBehavior: FloatingLabelBehavior.always,
      isDense: true,
      labelStyle: const TextStyle(
        color: labelBlue,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: const TextStyle(color: hintGrey, fontSize: 14),
      border: OutlineInputBorder(borderRadius: _radius),
      disabledBorder: OutlineInputBorder(
        borderRadius: _radius,
        borderSide: const BorderSide(color: borderGrey, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: _radius,
        borderSide: const BorderSide(color: borderGrey, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: _radius,
        borderSide: const BorderSide(color: focusBlue, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: _radius,
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: _radius,
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
      errorStyle: const TextStyle(
        color: Colors.red,
        fontSize: 12,
        height: 0.9,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      errorMaxLines: 2,
    );
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  void _openForgotPinSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => const ForgotPinSheet(),
    );
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
                        'Hai!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Senang bertemu kembali!',
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
                          // === Nomor HP ===
                          Material(
                            color: Colors.transparent,
                            child: Theme(
                              data: theme.copyWith(
                                inputDecorationTheme:
                                    theme.inputDecorationTheme.copyWith(
                                  isDense: true,
                                  labelStyle: const TextStyle(
                                    color: labelBlue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  hintStyle: const TextStyle(
                                    color: hintGrey,
                                    fontSize: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: borderGrey,
                                      width: 1.5,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: borderGrey,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: focusBlue,
                                      width: 2.0,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 2.0,
                                    ),
                                  ),
                                  errorStyle: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    height: 0.9,
                                  ),
                                  errorMaxLines: 2,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                              child: PhoneField(
                                phoneCtrl: _phoneCtrl,
                                validator: Validators.phone,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // === PIN ===
                          TextFormField(
                            controller: _pinCtrl,
                            keyboardType: TextInputType.number,
                            obscureText: _obscure,
                            maxLength: 6,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: _pinDecoration().copyWith(
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                            validator: Validators.pin6,
                          ),

                          const SizedBox(height: 12),

                          // === Ingat saya + Lupa PIN ===
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
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
                              TextButton(
                                onPressed: () => _openForgotPinSheet(context),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Lupa PIN',
                                  style: TextStyle(
                                    color: Color(0xFFE32935),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // === Tombol Login ===
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() => _submitted = true);
                                if (_formKey.currentState!.validate()) {
                                  _auth.login(context, _phoneCtrl.text, _pinCtrl.text);
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
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // === Tidak punya akun? Sign Up ===
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Tidak punya akun? ',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushReplacementNamed(
                                  context,
                                  SignUpScreen.routeName,
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: primaryPurple,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ===== Divider dengan "Atau lanjutkan dengan" =====
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Atau lanjutkan dengan',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ==== Google Button - Modern Design ====
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Google sign in
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/g-logo.png',
                            height: 24,
                            width: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Google',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== Modal Bottom Sheet: Forgot PIN =====
class ForgotPinSheet extends StatefulWidget {
  const ForgotPinSheet({super.key});

  @override
  State<ForgotPinSheet> createState() => _ForgotPinSheetState();
}

class _ForgotPinSheetState extends State<ForgotPinSheet> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: FractionallySizedBox(
        heightFactor: 0.77,
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 24,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Kembali',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Lupa PIN',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Silahkan masukkan nomor HP anda untuk mengatur ulang PIN.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        inputDecorationTheme:
                            Theme.of(context).inputDecorationTheme.copyWith(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(color: Color(0xFFD0D5DD), width: 2),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(color: Color.fromARGB(255, 69, 17, 173), width: 2),
                          ),
                          errorBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          errorStyle: const TextStyle(fontSize: 12, height: 0.9),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          PhoneField(
                            phoneCtrl: _phoneCtrl,
                            validator: Validators.phone,
                          ),
                          const SizedBox(height: 30),
                          PrimaryButton(
                            text: 'Kirim Kode',
                            color: const Color(0xFF1E3A8A),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final nav = Navigator.of(context, rootNavigator: true);
                                final rootCtx = nav.context;
                                nav.pop();
                                Future.microtask(() {
                                  if (!context.mounted) return;
                                  showModalBottomSheet(
                                    context: rootCtx,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    barrierColor: Colors.black.withValues(alpha: 0.35),
                                    builder: (_) => const OtpVerifySheet(),
                                  );
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===== Modal Bottom Sheet: OTP Verify (frontend only) =====
class OtpVerifySheet extends StatefulWidget {
  const OtpVerifySheet({super.key});

  @override
  State<OtpVerifySheet> createState() => _OtpVerifySheetState();
}

class _OtpVerifySheetState extends State<OtpVerifySheet> {
  final _len = 5;
  late final List<TextEditingController> _ctrs;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _ctrs = List.generate(_len, (_) => TextEditingController());
    _nodes = List.generate(_len, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _ctrs) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _onChanged(int i, String v) {
    if (v.length == 1 && i < _len - 1) {
      _nodes[i + 1].requestFocus();
    } else if (v.isEmpty && i > 0) {
      _nodes[i - 1].requestFocus();
    }
    setState(() {});
  }

  String get _code => _ctrs.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: FractionallySizedBox(
        heightFactor: 0.77,
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 24,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 15),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),

                  // === Tombol Back ===
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          final nav = Navigator.of(context, rootNavigator: true);
                          final rootCtx = nav.context;
                          nav.pop();
                          Future.microtask(() {
                            if (!context.mounted) return;
                            showModalBottomSheet(
                              context: rootCtx,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              barrierColor: Colors.black.withValues(alpha: 0.35),
                              builder: (_) => const ForgotPinSheet(),
                            );
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Kembali',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Cek SMS Anda',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Kami telah mengirimkan kode 5 digit ke nomor HP Anda. '
                    'Silakan masukkan kode tersebut untuk mengatur ulang PIN.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 18),

                  // ===== OTP Boxes =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_len, (i) {
                      return SizedBox(
                        width: 54,
                        height: 54,
                        child: TextField(
                          controller: _ctrs[i],
                          focusNode: _nodes[i],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          maxLength: 1,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFD0D5DD), width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFD0D5DD), width: 2),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(color: Color.fromARGB(255, 69, 17, 173), width: 2),
                            ),
                          ),
                          onChanged: (v) => _onChanged(i, v),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 20),

                  PrimaryButton(
                    text: 'Verifikasi Kode',
                    color: const Color(0xFF1E3A8A),
                    onPressed: () {
                      if (_code.length == _len) {
                        final nav = Navigator.of(context, rootNavigator: true);
                        final rootCtx = nav.context;
                        nav.pop();
                        Future.microtask(() {
                          if (!context.mounted) return;
                          showModalBottomSheet(
                            context: rootCtx,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            barrierColor: Colors.black.withValues(alpha: 0.35),
                            builder: (_) => const ConfirmPinUpdateSheet(),
                          );
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lengkapi 5 digit kodenya dulu ya.')),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('Tidak mendapatkan kode? '),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Kirim ulang (dummy).')),
                            );
                          },
                          child: const Text(
                            'Kirim ulang',
                            style: TextStyle(
                              color: Color(0xFF1E3A8A),
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===== Modal Bottom Sheet: Konfirmasi Perbarui PIN (frontend only) =====
class ConfirmPinUpdateSheet extends StatelessWidget {
  const ConfirmPinUpdateSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: FractionallySizedBox(
        heightFactor: 0.77,
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 24,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 15),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),

                  // === Tombol Back ===
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          final nav = Navigator.of(context, rootNavigator: true);
                          final rootCtx = nav.context;
                          nav.pop();
                          Future.microtask(() {
                            if (!rootCtx.mounted) return;
                            showModalBottomSheet(
                              context: rootCtx,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              barrierColor: Colors.black.withValues(alpha: 0.35),
                              builder: (_) => const OtpVerifySheet(),
                            );
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Kembali',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Perbarui PIN',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'PIN anda berhasil diperbarui. Silahkan klik konfirmasi untuk memperbarui PIN anda.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    text: 'Konfirmasi',
                    color: const Color(0xFF1E3A8A),
                    onPressed: () {
                      final nav = Navigator.of(context, rootNavigator: true);
                      final rootCtx = nav.context;
                      nav.pop();
                      Future.microtask(() {
                        if (!rootCtx.mounted) return;
                        showModalBottomSheet(
                          context: rootCtx,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          barrierColor: Colors.black.withValues(alpha: 0.35),
                          builder: (_) => const NewPinSheet(),
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===== Modal Bottom Sheet: Buat PIN Baru (frontend only) =====
class NewPinSheet extends StatefulWidget {
  const NewPinSheet({super.key});

  @override
  State<NewPinSheet> createState() => _NewPinSheetState();
}

class _NewPinSheetState extends State<NewPinSheet> {
  final _formKey = GlobalKey<FormState>();
  final _pin1 = TextEditingController();
  final _pin2 = TextEditingController();
  bool _ob1 = true;
  bool _ob2 = true;

  static const labelBlue = Color(0xFF1E3A8A);
  static const hintGrey = Color(0xFF949191);
  final BorderRadius _radius = BorderRadius.circular(12);

  @override
  void dispose() {
    _pin1.dispose();
    _pin2.dispose();
    super.dispose();
  }

  InputDecoration _pinDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      counterText: '',
      floatingLabelBehavior: FloatingLabelBehavior.always,
      isDense: true,
      labelStyle: const TextStyle(color: labelBlue),
      hintStyle: const TextStyle(color: hintGrey),
      border: OutlineInputBorder(borderRadius: _radius),
      disabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFD0D5DD), width: 2.0),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFD0D5DD), width: 2.0),
      ),
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
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: FractionallySizedBox(
        heightFactor: 0.77,
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 24,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 15),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),

                  // === Tombol Back ===
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          final nav = Navigator.of(context, rootNavigator: true);
                          final rootCtx = nav.context;
                          nav.pop();
                          Future.microtask(() {
                            if (!context.mounted) return;
                            showModalBottomSheet(
                              context: rootCtx,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              barrierColor: Colors.black.withValues(alpha: 0.35),
                              builder: (_) => const ConfirmPinUpdateSheet(),
                            );
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Kembali',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Buat PIN Baru',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Buat PIN yang kuat dan berbeda dari sebelumnya untuk menjaga keamanan akun anda.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 18),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _pin1,
                          keyboardType: TextInputType.number,
                          obscureText: _ob1,
                          maxLength: 6,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: _pinDecoration(
                            'PIN',
                            'Masukkan 6 digit PIN',
                          ).copyWith(
                            counterText: '',
                            focusedBorder: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 1.8,
                              ),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _ob1 = !_ob1),
                              icon: Icon(_ob1 ? Icons.visibility : Icons.visibility_off),
                            ),
                          ),
                          validator: Validators.pin6,
                        ),
                        const SizedBox(height: 16),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _pin2,
                          keyboardType: TextInputType.number,
                          obscureText: _ob2,
                          maxLength: 6,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: _pinDecoration(
                            'Konfirmasi PIN',
                            'Masukkan kembali PIN anda',
                          ).copyWith(
                            counterText: '',
                            focusedBorder: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 1.8,
                              ),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _ob2 = !_ob2),
                              icon: Icon(_ob2 ? Icons.visibility : Icons.visibility_off),
                            ),
                          ),
                          validator: (v) {
                            final e = Validators.pin6(v);
                            if (e != null) return e;
                            if (v != _pin1.text) return 'PIN tidak sama';
                            return null;
                          },
                        ),
                        const SizedBox(height: 25),
                        PrimaryButton(
                          text: 'Ganti PIN',
                          color: const Color(0xFF1E3A8A),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('PIN baru disimpan.')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

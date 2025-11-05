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
  bool _submitted = false; // samakan perilaku validasi seperti SignUp

  final _auth = AuthService();

  final BorderRadius _radius = BorderRadius.circular(12);

  // Warna konsisten (match SignUp)
  static const labelBlue = Color(0xFF1E3A8A);
  static const borderGrey = Color(0xFFC6C6C6);
  static const hintGrey = Color(0xFF949191);

  // Konstanta layout (match SignUp)
  static const double headerHeight = 400;
  static const double overlap = 116; // card "menggantung" ±16px lebih tinggi
  double get _topPaddingForScroll => headerHeight - overlap; // 284

  InputDecoration _pinDecoration() {
    return const InputDecoration(
      labelText: 'PIN',
      hintText: 'Masukkan 6 digit PIN',
      counterText: '',
      floatingLabelBehavior: FloatingLabelBehavior.always,
    ).copyWith(
      // rapetin jarak error & samakan border
      isDense: true,
      labelStyle: const TextStyle(color: labelBlue),
      hintStyle: const TextStyle(color: hintGrey),
      border: OutlineInputBorder(borderRadius: _radius),
      disabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFD0D5DD), width: 2.0,),
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
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Hai!', style: theme.textTheme.headlineMedium),
                              const SizedBox(height: 6),
                              const Text(
                                'Senang bertemu kembali!',
                                style: TextStyle(color: Colors.white70),
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
          ),

          // ===== KONTEN SCROLL (di atas header, tidak ketutupan) =====
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, _topPaddingForScroll, 20, 20),
              child: Column(
                children: [
                  // === CARD FORM (mirror SignUp) ===
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
                      autovalidateMode:
                          _submitted ? AutovalidateMode.always : AutovalidateMode.disabled,
                      child: Column(
                        children: [
                          // === Nomor HP (pakai Theme lokal seperti SignUp) ===
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Material(
                              color: Colors.transparent,
                              child: Theme(
                                data: theme.copyWith(
                                  inputDecorationTheme:
                                      theme.inputDecorationTheme.copyWith(
                                    isDense: true,
                                    labelStyle: const TextStyle(color: labelBlue),
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
                                    errorBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(12)),
                                      borderSide: BorderSide(color: Colors.red, width: 1.4),
                                    ),
                                    focusedErrorBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(12)),
                                      borderSide: BorderSide(color: Colors.red, width: 1.4),
                                    ),
                                    errorStyle: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      height: 0.9,
                                    ),
                                    errorMaxLines: 2,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                  ),
                                ),
                                child: PhoneField(
                                  phoneCtrl: _phoneCtrl,
                                  validator: Validators.phone,
                                ),
                              ),
                            ),
                          ),

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
                                  _obscure ? Icons.visibility : Icons.visibility_off,
                                ),
                              ),
                            ),
                            validator: Validators.pin6,
                          ),

                          const SizedBox(height: 4),

                          // === Ingat saya + Lupa PIN ===
                          Row(
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _remember = !_remember),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Checkbox(
                                          value: _remember,
                                          onChanged: (v) =>
                                              setState(() => _remember = (v ?? false)),
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
                              TextButton(
                                // ⬇️ ganti pushNamed -> buka bottom sheet
                                onPressed: () => _openForgotPinSheet(context),
                                child: const Text(
                                  'Lupa PIN',
                                  style: TextStyle(color: Color(0xFFE32935)),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // === Tombol Login ===
                          PrimaryButton(
                            text: 'Login',
                            color: const Color(0xFF1E3A8A),
                            onPressed: () {
                              setState(() => _submitted = true);
                              if (_formKey.currentState!.validate()) {
                                _auth.login(context, _phoneCtrl.text, _pinCtrl.text);
                              }
                            },
                          ),

                          const SizedBox(height: 16),

                          // === Tidak punya akun? Sign Up ===
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Tidak punya akun?'),
                              TextButton(
                                onPressed: () => Navigator.pushReplacementNamed(
                                  context, SignUpScreen.routeName),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(color: labelBlue),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ===== Lanjutkan dengan + Google (mirror SignUp) =====
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
                          thickness: 0.6),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ==== Google button custom ====
                  Container(
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
                        // TODO: panggil login Google di sini
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
                              width: 20),
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
        heightFactor: 0.77,                 // ⬅️ bikin bg putih lebih panjang
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
              // handle tetap menempel atas; spasi diatur via margin handle
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,  // isi mengikuti tinggi sheet
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12), // << setara 12px
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  // === Tombol Back (ditambahkan, setelan sama) ===
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4), // tanpa bottom padding
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
                            borderSide: BorderSide(color:  Color(0xFF39BCF4), width: 2),
                          ),
                          errorBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(color: Colors.red),),
                          focusedErrorBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(color: Colors.red),),
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
                                // FIX: ambil navigator + pakai rootCtx setelah pop
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
                      margin: const EdgeInsets.only(bottom: 12), // << setara 12px
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
                      // tanpa bottom padding agar handle→back = 12px
                      padding: const EdgeInsets.only(left: 4),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          // FIX: pop → buka ForgotPinSheet pakai root navigator context
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
                              borderSide: BorderSide(color: Color(0xFF39BCF4), width: 2),
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
                      // FRONTEND ONLY: kalau 5 digit terisi, buka sheet konfirmasi
                      if (_code.length == _len) {
                        // FIX: pop → buka ConfirmPinUpdateSheet pakai root navigator context
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
                            // FRONTEND ONLY: snackbar dummy
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
                      margin: const EdgeInsets.only(bottom: 12), // << setara 12px
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
                      // tanpa bottom padding agar handle→back = 12px
                      padding: const EdgeInsets.only(left: 4),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          // FIX: pop → buka OtpVerifySheet pakai root navigator context
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
                      // FIX: pop → buka NewPinSheet pakai root navigator context
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

  // Samakan warna & radius seperti di LoginScreen
  static const labelBlue = Color(0xFF1E3A8A);
  static const hintGrey = Color(0xFF949191);
  final BorderRadius _radius = BorderRadius.circular(12);

  @override
  void dispose() {
    _pin1.dispose();
    _pin2.dispose();
    super.dispose();
  }

  // === Dekorasi PIN yang identik dengan _pinDecoration() di LoginScreen ===
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

  String? _vPin(String? v) {
    if ((v ?? '').isEmpty) return 'Wajib diisi';
    if (v!.length < 6) return 'Minimal 6 digit';
    return null;
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
                      margin: const EdgeInsets.only(bottom: 12), // << setara 12px
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
                      // tanpa bottom padding agar handle→back = 12px
                      padding: const EdgeInsets.only(left: 4),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          // FIX: pop → buka ConfirmPinUpdateSheet pakai root navigator context
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
                            // Samakan override fokus seperti di LoginScreen
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
                          validator: _vPin,
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
                            final e = _vPin(v);
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
                              // FRONTEND ONLY
                              Navigator.of(context).pop(); // tutup sheet ini
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
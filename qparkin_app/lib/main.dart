// lib/main.dart
import 'package:flutter/material.dart';

// ✅ ubah path sesuai struktur project kamu
import 'data/services/auth_service.dart';

// ✅ folder UI sekarang di presentation/screens/
import 'presentation/screens/about_page.dart';
import 'presentation/screens/login_page.dart';
// import 'presentation/screens/signup_page.dart';
// import 'presentation/screens/forgot_password_page.dart';
// import 'presentation/screens/verify_code_page.dart';
// import 'presentation/screens/confirm_pin_page.dart';
// import 'presentation/screens/change_pin_page.dart';
import 'presentation/screens/home_page.dart';
import 'presentation/screens/profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QParkin Mobile',
      debugShowCheckedModeBanner: false, // biar gak ada label debug merah
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: AuthService().getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // ✅ JIKA SUDAH LOGIN (ada token) -> langsung ke HomePage
          if (snapshot.hasData && snapshot.data != null) {
            return const ProfilePage();
          }

          // ✅ JIKA BELUM LOGIN -> tampilkan AboutPage pertama kali
          return const AboutPage();
        },
      ),
      routes: {
        '/about': (context) => const AboutPage(),
        '/login': (context) => const LoginPage(),
        // '/signup': (context) => const SignupPage(),
        // '/forgot-password': (context) => const ForgotPasswordPage(),
        // '/verify-code': (context) => const VerifyCodePage(),
        // '/confirm-pin': (context) => const ConfirmPinPage(),
        // '/change-pin': (context) => const ChangePinPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}

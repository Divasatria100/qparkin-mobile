import 'package:flutter/material.dart';
import 'config/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

void main() {
  runApp(const QParkinApp());
}

class QParkinApp extends StatelessWidget {
  const QParkinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qparkin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: WelcomeScreen.routeName,
      routes: {
        WelcomeScreen.routeName: (_) => const WelcomeScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        SignUpScreen.routeName: (_) => const SignUpScreen(),

      },
    );
  }
}

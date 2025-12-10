import 'package:flutter/material.dart';

class AppTheme {
  static const Color brandBlue = Color(0xFF2E3A8C);
  static const Color brandIndigo = Color(0xFF5C3BFF);
  static const Color brandNavy = Color(0xFF1F2A5A);
  static const Color brandRed = Color(0xFFE53935);

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: false);
    return base.copyWith(
      scaffoldBackgroundColor: Colors.white,
      primaryColor: brandNavy,
      textTheme: base.textTheme.copyWith(
        headlineMedium: const TextStyle(
            fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
        headlineSmall: const TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black),
        titleMedium: const TextStyle(fontSize: 14, color: Colors.black54),
        bodyMedium: const TextStyle(fontSize: 14, color: Colors.black87),
        labelLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: Colors.black38),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: brandNavy, width: 1.2),
        ),
        labelStyle: const TextStyle(color: brandNavy),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          backgroundColor: brandNavy,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  /// 🌈 Gradient sesuai Figma (18% cyan → 51% purple → 81% deep purple)
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      Color(0xFF42CBF8), // 18% - cyan
      Color(0xFF573ED1), // 51% - purple
      Color(0xFF39108A), // 81% - deep purple
    ],
    stops: <double>[0.18, 0.51, 0.81],
  );
}
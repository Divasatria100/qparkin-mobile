import 'package:flutter/material.dart';
import '/config/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color; // tambahan opsional untuk ubah warna tombol

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? scheme.primary, // default pakai warna tema
        minimumSize: const Size.fromHeight(52),   // tinggi seragam
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14), // radius lembut
        ),
        elevation: 2, // sedikit bayangan biar timbul
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }
}

class DangerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  const DangerButton({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.brandRed),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

class GoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const GoogleButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.g_mobiledata, size: 28),
          SizedBox(width: 6),
          Text('Google', style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
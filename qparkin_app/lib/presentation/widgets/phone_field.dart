import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// PhoneField 1 kolom dengan prefix +62 permanen.
/// - User hanya mengetik LANJUTAN nomor (tanpa +62).
/// - Hanya angka (digitsOnly).
/// - Otomatis hapus '0' di awal (0852 -> 852).
/// - Opsi format visual: 3-4-4 (852 8525 6338).
class PhoneField extends StatefulWidget {
  final TextEditingController phoneCtrl; // hanya lanjutan tanpa +62
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final bool withGrouping; // true = tampil 3-4-4

  const PhoneField({
    super.key,
    required this.phoneCtrl,
    this.label = 'Nomor HP',
    this.hint = 'Masukkan nomor HP anda',
    this.validator,
    this.withGrouping = true,
  });

  /// Ambil nomor penuh format E.164 (+62XXXXXXXXXX) dari controller.
  static String fullE164(TextEditingController ctrl) {
    final local = ctrl.text.replaceAll(RegExp(r'\D'), '');
    return '+62$local';
  }

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> {
  final BorderRadius _radius = BorderRadius.circular(12);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final fmts = <TextInputFormatter>[
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(13),
      _IndoPhoneFormatter(grouping: widget.withGrouping),
    ];

    return TextFormField(
      controller: widget.phoneCtrl,
      keyboardType: TextInputType.phone,
      inputFormatters: fmts,
      contextMenuBuilder: (context, editableTextState) => const SizedBox.shrink(),
      decoration: InputDecoration(
        // LABEL selalu di atas (selaras dengan PIN)
        labelText: widget.label,
        floatingLabelBehavior: FloatingLabelBehavior.always,

        // PREFIX stabil (bukan prefixText/prefixIcon)
        prefix: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Text('+62', style: theme.textTheme.titleMedium),
        ),

        hintText: widget.hint,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),


        // >>> Anti “hairline” & kompatibel SDK lama
        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius: _radius,
          borderSide: const BorderSide(
            color: Color(0xFFD0D5DD),
            width: 2.0,
          ),
        ),

        // Pastikan semua state pakai border yang sama (anti override)
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFFD0D5DD), width: 2.0,),
        ),
        disabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFFD0D5DD), width: 2.0,),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _radius,
          borderSide: BorderSide(color: Color.fromARGB(255, 69, 17, 173), width: 2.0,),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: _radius,
          borderSide: BorderSide(
            color:  Colors.red,
            width: 2.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: _radius,
          borderSide: BorderSide(
            color:  Colors.red,
            width: 2.0,
          ),
        ),
      ),
      validator: widget.validator ?? _defaultValidator,
    );
  }

  static String? _defaultValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Nomor HP wajib diisi';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) {
      return 'Jangan awali dengan 0 (cukup lanjutannya setelah +62)';
    }
    if (digits.length < 9 || digits.length > 12) {
      return 'Panjang nomor 9–12 digit';
    }
    return null;
  }
}

/// Formatter: hapus '0' di awal dan opsional format spasi 3-4-4.
class _IndoPhoneFormatter extends TextInputFormatter {
  final bool grouping;
  const _IndoPhoneFormatter({this.grouping = true});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Hapus 0 di awal (0852 -> 852)
    if (digits.startsWith('0')) digits = digits.substring(1);

    String out = digits;
    if (grouping) {
      final sb = StringBuffer();
      for (int i = 0; i < digits.length; i++) {
        sb.write(digits[i]);
        if (i == 2 || i == 6 || i == 10) sb.write(' ');
      }
      out = sb.toString().trimRight();
    }

    return TextEditingValue(
      text: out,
      selection: TextSelection.collapsed(offset: out.length),
    );
  }
}
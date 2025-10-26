class Validators {
  static String? required(String? v, {String label = 'Field'}) {
    if (v == null || v.trim().isEmpty) return '$label wajib diisi';
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Nomor HP wajib diisi';
    final onlyDigits = v.replaceAll(RegExp(r'[^0-9]'), '');
    if (onlyDigits.length < 8) return 'Nomor HP minimal 8 digit';
    return null;
  }

  static String? pin6(String? v) {
    if (v == null || v.isEmpty) return 'PIN wajib diisi';
    if (!RegExp(r'^\d{6}$').hasMatch(v)) return 'PIN harus 6 digit angka';
    return null;
  }
}

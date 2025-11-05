class Validators {
  static String? required(String? value, {String label = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$label wajib diisi';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor HP wajib diisi';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) {
      return 'Jangan awali dengan 0 (cukup lanjutannya setelah +62)';
    }
    if (digits.length < 9 || digits.length > 12) {
      return 'Panjang nomor 9–12 digit';
    }
    return null;
  }

  static String? pin6(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN wajib diisi';
    }
    if (value.length != 6) {
      return 'PIN harus 6 digit';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'PIN hanya boleh angka';
    }
    return null;
  }
}

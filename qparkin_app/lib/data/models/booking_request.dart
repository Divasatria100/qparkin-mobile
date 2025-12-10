class BookingRequest {
  final String idMall;
  final String idKendaraan;
  final DateTime waktuMulai;
  final int durasiJam;
  final String? notes;

  BookingRequest({
    required this.idMall,
    required this.idKendaraan,
    required this.waktuMulai,
    required this.durasiJam,
    this.notes,
  });

  /// Validate booking request data
  bool validate() {
    if (idMall.isEmpty) return false;
    if (idKendaraan.isEmpty) return false;
    if (durasiJam <= 0) return false;
    if (durasiJam > 12) return false; // Max 12 hours
    if (waktuMulai.isBefore(DateTime.now())) return false;
    return true;
  }

  /// Get validation error message
  String? getValidationError() {
    if (idMall.isEmpty) {
      return 'Mall harus dipilih';
    }
    if (idKendaraan.isEmpty) {
      return 'Kendaraan harus dipilih';
    }
    if (durasiJam <= 0) {
      return 'Durasi minimal 1 jam';
    }
    if (durasiJam > 12) {
      return 'Durasi maksimal 12 jam';
    }
    if (waktuMulai.isBefore(DateTime.now())) {
      return 'Waktu mulai tidak boleh di masa lalu';
    }
    return null;
  }

  /// Calculate end time based on start time and duration
  DateTime get waktuSelesai {
    return waktuMulai.add(Duration(hours: durasiJam));
  }

  /// Convert BookingRequest to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id_mall': idMall,
      'id_kendaraan': idKendaraan,
      'waktu_mulai': waktuMulai.toIso8601String(),
      'durasi_jam': durasiJam,
      'waktu_selesai': waktuSelesai.toIso8601String(),
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }

  /// Create BookingRequest from JSON
  factory BookingRequest.fromJson(Map<String, dynamic> json) {
    return BookingRequest(
      idMall: json['id_mall']?.toString() ?? '',
      idKendaraan: json['id_kendaraan']?.toString() ?? '',
      waktuMulai: json['waktu_mulai'] != null
          ? DateTime.parse(json['waktu_mulai'].toString())
          : DateTime.now(),
      durasiJam: _parseInt(json['durasi_jam']),
      notes: json['notes']?.toString(),
    );
  }

  /// Helper method to safely parse int values from JSON
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Create a copy of this request with updated fields
  BookingRequest copyWith({
    String? idMall,
    String? idKendaraan,
    DateTime? waktuMulai,
    int? durasiJam,
    String? notes,
  }) {
    return BookingRequest(
      idMall: idMall ?? this.idMall,
      idKendaraan: idKendaraan ?? this.idKendaraan,
      waktuMulai: waktuMulai ?? this.waktuMulai,
      durasiJam: durasiJam ?? this.durasiJam,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'BookingRequest(idMall: $idMall, idKendaraan: $idKendaraan, '
        'waktuMulai: $waktuMulai, durasiJam: $durasiJam, notes: $notes)';
  }
}

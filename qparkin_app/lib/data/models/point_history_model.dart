class PointHistory {
  final int idPoin;
  final int idUser;
  final int? idTransaksi;
  final int poin;
  final String perubahan; // 'tambah' or 'kurang'
  final String keterangan;
  final DateTime waktu;

  PointHistory({
    required this.idPoin,
    required this.idUser,
    this.idTransaksi,
    required this.poin,
    required this.perubahan,
    required this.keterangan,
    required this.waktu,
  });

  /// Check if this is a point addition
  bool get isAddition => perubahan == 'tambah';

  /// Check if this is a point deduction
  bool get isDeduction => perubahan == 'kurang';

  /// Check if this history entry is linked to a transaction
  bool get hasTransaction => idTransaksi != null;

  /// Get formatted point amount with sign (e.g., "+100" or "-50")
  String get formattedAmount {
    final sign = isAddition ? '+' : '-';
    return '$sign$poin';
  }

  /// Get formatted date string (e.g., "2 Des 2024, 14:30")
  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final day = waktu.day;
    final month = months[waktu.month - 1];
    final year = waktu.year;
    final hour = waktu.hour.toString().padLeft(2, '0');
    final minute = waktu.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }

  /// Validate point history data
  bool validate() {
    if (idPoin <= 0) return false;
    if (idUser <= 0) return false;
    if (poin <= 0) return false;
    if (perubahan != 'tambah' && perubahan != 'kurang') return false;
    if (keterangan.isEmpty) return false;
    return true;
  }

  /// Create PointHistory from JSON
  factory PointHistory.fromJson(Map<String, dynamic> json) {
    return PointHistory(
      idPoin: _parseInt(json['id_poin']),
      idUser: _parseInt(json['id_user']),
      idTransaksi: json['id_transaksi'] != null 
          ? _parseInt(json['id_transaksi']) 
          : null,
      poin: _parseInt(json['poin']),
      perubahan: json['perubahan']?.toString() ?? 'tambah',
      keterangan: json['keterangan']?.toString() ?? '',
      waktu: json['waktu'] != null
          ? DateTime.parse(json['waktu'].toString())
          : DateTime.now(),
    );
  }

  /// Convert PointHistory to JSON
  Map<String, dynamic> toJson() {
    return {
      'id_poin': idPoin,
      'id_user': idUser,
      'id_transaksi': idTransaksi,
      'poin': poin,
      'perubahan': perubahan,
      'keterangan': keterangan,
      'waktu': waktu.toIso8601String(),
    };
  }

  /// Helper method to safely parse int values from JSON
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Create a copy of this model with updated fields
  PointHistory copyWith({
    int? idPoin,
    int? idUser,
    int? idTransaksi,
    int? poin,
    String? perubahan,
    String? keterangan,
    DateTime? waktu,
  }) {
    return PointHistory(
      idPoin: idPoin ?? this.idPoin,
      idUser: idUser ?? this.idUser,
      idTransaksi: idTransaksi ?? this.idTransaksi,
      poin: poin ?? this.poin,
      perubahan: perubahan ?? this.perubahan,
      keterangan: keterangan ?? this.keterangan,
      waktu: waktu ?? this.waktu,
    );
  }
}

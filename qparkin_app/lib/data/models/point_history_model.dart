import 'package:intl/intl.dart';

/// Model representing a point transaction history entry
///
/// This model represents a single point transaction, either earning or using points.
/// It includes all necessary information for displaying transaction history to users.
///
/// Requirements: 1.1, 2.1
class PointHistory {
  final int idPoin;
  final int idUser;
  final int poin;
  final String perubahan; // 'tambah' or 'kurang'
  final String keterangan;
  final DateTime waktu;

  PointHistory({
    required this.idPoin,
    required this.idUser,
    required this.poin,
    required this.perubahan,
    required this.keterangan,
    required this.waktu,
  });

  /// Check if this is a point addition transaction
  bool get isAddition => perubahan.toLowerCase() == 'tambah';

  /// Check if this is a point deduction transaction
  bool get isDeduction => perubahan.toLowerCase() == 'kurang';

  /// Get formatted date string (e.g., "15 Jan 2024, 10:30")
  String get formattedDate {
    final formatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    return formatter.format(waktu);
  }

  /// Get formatted date string for display (e.g., "15 Januari 2024")
  String get formattedDateLong {
    final formatter = DateFormat('dd MMMM yyyy', 'id_ID');
    return formatter.format(waktu);
  }

  /// Get formatted time string (e.g., "10:30")
  String get formattedTime {
    final formatter = DateFormat('HH:mm', 'id_ID');
    return formatter.format(waktu);
  }

  /// Get formatted amount with sign (e.g., "+100" or "-50")
  String get formattedAmount {
    final sign = isAddition ? '+' : '-';
    return '$sign$poin';
  }

  /// Get formatted amount with sign and label (e.g., "+100 Poin")
  String get formattedAmountWithLabel {
    final sign = isAddition ? '+' : '-';
    return '$sign$poin Poin';
  }

  /// Get relative time string (e.g., "2 jam yang lalu", "Kemarin")
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(waktu);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks minggu yang lalu';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months bulan yang lalu';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years tahun yang lalu';
    }
  }

  /// Create PointHistory from JSON
  factory PointHistory.fromJson(Map<String, dynamic> json) {
    return PointHistory(
      idPoin: json['id_poin'] ?? json['idPoin'] ?? 0,
      idUser: json['id_user'] ?? json['idUser'] ?? 0,
      poin: json['poin'] ?? 0,
      perubahan: json['perubahan'] ?? '',
      keterangan: json['keterangan'] ?? '',
      waktu: json['waktu'] != null
          ? DateTime.parse(json['waktu'])
          : DateTime.now(),
    );
  }

  /// Convert PointHistory to JSON
  Map<String, dynamic> toJson() {
    return {
      'id_poin': idPoin,
      'id_user': idUser,
      'poin': poin,
      'perubahan': perubahan,
      'keterangan': keterangan,
      'waktu': waktu.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  PointHistory copyWith({
    int? idPoin,
    int? idUser,
    int? poin,
    String? perubahan,
    String? keterangan,
    DateTime? waktu,
  }) {
    return PointHistory(
      idPoin: idPoin ?? this.idPoin,
      idUser: idUser ?? this.idUser,
      poin: poin ?? this.poin,
      perubahan: perubahan ?? this.perubahan,
      keterangan: keterangan ?? this.keterangan,
      waktu: waktu ?? this.waktu,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PointHistory &&
        other.idPoin == idPoin &&
        other.idUser == idUser &&
        other.poin == poin &&
        other.perubahan == perubahan &&
        other.keterangan == keterangan &&
        other.waktu == waktu;
  }

  @override
  int get hashCode {
    return idPoin.hashCode ^
        idUser.hashCode ^
        poin.hashCode ^
        perubahan.hashCode ^
        keterangan.hashCode ^
        waktu.hashCode;
  }

  @override
  String toString() {
    return 'PointHistory(idPoin: $idPoin, idUser: $idUser, poin: $poin, perubahan: $perubahan, keterangan: $keterangan, waktu: $waktu)';
  }
}

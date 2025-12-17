import 'package:intl/intl.dart';

/// Model representing a point transaction history entry
///
/// This model represents a single point transaction, either earning or using points.
/// It includes all necessary information for displaying transaction history to users.
///
/// Business Logic:
/// - 1 poin = Rp100 discount value
/// - Points can be earned (perubahan: 'earned') or used (perubahan: 'used')
///
/// Requirements: 1.1, 1.4, 1.5
class PointHistoryModel {
  final String idPoin;
  final String idUser;
  final int poin;
  final String perubahan; // 'earned' or 'used'
  final String keterangan;
  final DateTime waktu;

  PointHistoryModel({
    required this.idPoin,
    required this.idUser,
    required this.poin,
    required this.perubahan,
    required this.keterangan,
    required this.waktu,
  });

  /// Check if this is a point earning transaction
  bool get isEarned => perubahan.toLowerCase() == 'earned';

  /// Check if this is a point usage transaction
  bool get isUsed => perubahan.toLowerCase() == 'used';
  
  /// Get absolute value of points (always positive)
  int get absolutePoints => poin.abs();
  
  /// Get formatted Rupiah value (1 poin = Rp100)
  /// Example: 100 poin = "Rp10.000"
  String get formattedValue {
    final rupiah = absolutePoints * 100;
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(rupiah);
  }

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
    final sign = isEarned ? '+' : '-';
    return '$sign$absolutePoints';
  }

  /// Get formatted amount with sign and label (e.g., "+100 Poin")
  String get formattedAmountWithLabel {
    final sign = isEarned ? '+' : '-';
    return '$sign$absolutePoints Poin';
  }
  
  /// Get formatted amount with value (e.g., "+100 poin (Rp10.000)")
  String get formattedAmountWithValue {
    final sign = isEarned ? '+' : '-';
    return '$sign$absolutePoints poin ($formattedValue)';
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

  /// Create PointHistoryModel from JSON
  /// Handles both snake_case and camelCase field names
  /// Throws FormatException if required fields are missing or invalid
  factory PointHistoryModel.fromJson(Map<String, dynamic> json) {
    try {
      return PointHistoryModel(
        idPoin: (json['id_poin'] ?? json['idPoin'] ?? '').toString(),
        idUser: (json['id_user'] ?? json['idUser'] ?? '').toString(),
        poin: json['poin'] is int ? json['poin'] : int.parse(json['poin'].toString()),
        perubahan: json['perubahan'] ?? '',
        keterangan: json['keterangan'] ?? '',
        waktu: json['waktu'] != null
            ? DateTime.parse(json['waktu'])
            : DateTime.now(),
      );
    } catch (e) {
      throw FormatException('Invalid PointHistoryModel JSON: $e');
    }
  }

  /// Convert PointHistoryModel to JSON
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
  PointHistoryModel copyWith({
    String? idPoin,
    String? idUser,
    int? poin,
    String? perubahan,
    String? keterangan,
    DateTime? waktu,
  }) {
    return PointHistoryModel(
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

    return other is PointHistoryModel &&
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
    return 'PointHistoryModel(idPoin: $idPoin, idUser: $idUser, poin: $poin, perubahan: $perubahan, keterangan: $keterangan, waktu: $waktu)';
  }
}

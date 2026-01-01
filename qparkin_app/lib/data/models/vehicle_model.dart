import 'vehicle_statistics.dart';

/// Model representing a vehicle registered by the user
class VehicleModel {
  final String idKendaraan;
  final String platNomor;
  final String jenisKendaraan; // Roda Dua, Roda Tiga, Roda Empat, Lebih dari Enam
  final String merk;
  final String tipe;
  final String? warna;
  final String? fotoUrl; // URL foto kendaraan dari backend
  final bool isActive;
  final VehicleStatistics? statistics;

  VehicleModel({
    required this.idKendaraan,
    required this.platNomor,
    required this.jenisKendaraan,
    required this.merk,
    required this.tipe,
    this.warna,
    this.fotoUrl,
    this.isActive = false,
    this.statistics,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      idKendaraan: json['id_kendaraan']?.toString() ?? '',
      platNomor: json['plat']?.toString() ?? json['plat_nomor']?.toString() ?? '',
      // Backend sends 'jenis', Flutter expects 'jenis_kendaraan'
      jenisKendaraan: json['jenis']?.toString() ?? json['jenis_kendaraan']?.toString() ?? '',
      merk: json['merk']?.toString() ?? '',
      tipe: json['tipe']?.toString() ?? '',
      warna: json['warna']?.toString(),
      fotoUrl: json['foto_url']?.toString(), // Backend sends computed foto_url
      isActive: json['is_active'] == true || json['is_active'] == 1,
      statistics: json['statistics'] != null
          ? VehicleStatistics.fromJson(json['statistics'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_kendaraan': idKendaraan,
      'plat_nomor': platNomor,
      'jenis_kendaraan': jenisKendaraan,
      'merk': merk,
      'tipe': tipe,
      'warna': warna,
      'foto_url': fotoUrl,
      'is_active': isActive,
      'statistics': statistics?.toJson(),
    };
  }

  VehicleModel copyWith({
    String? idKendaraan,
    String? platNomor,
    String? jenisKendaraan,
    String? merk,
    String? tipe,
    String? warna,
    String? fotoUrl,
    bool? isActive,
    VehicleStatistics? statistics,
  }) {
    return VehicleModel(
      idKendaraan: idKendaraan ?? this.idKendaraan,
      platNomor: platNomor ?? this.platNomor,
      jenisKendaraan: jenisKendaraan ?? this.jenisKendaraan,
      merk: merk ?? this.merk,
      tipe: tipe ?? this.tipe,
      warna: warna ?? this.warna,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      isActive: isActive ?? this.isActive,
      statistics: statistics ?? this.statistics,
    );
  }

  String get displayName => '$platNomor - $merk $tipe';
}

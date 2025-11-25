/// Model representing a vehicle registered by the user
class VehicleModel {
  final String idKendaraan;
  final String platNomor;
  final String jenisKendaraan; // Roda Dua, Roda Tiga, Roda Empat, Lebih dari Enam
  final String merk;
  final String tipe;
  final String? warna;

  VehicleModel({
    required this.idKendaraan,
    required this.platNomor,
    required this.jenisKendaraan,
    required this.merk,
    required this.tipe,
    this.warna,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      idKendaraan: json['id_kendaraan']?.toString() ?? '',
      platNomor: json['plat_nomor']?.toString() ?? '',
      jenisKendaraan: json['jenis_kendaraan']?.toString() ?? '',
      merk: json['merk']?.toString() ?? '',
      tipe: json['tipe']?.toString() ?? '',
      warna: json['warna']?.toString(),
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
    };
  }

  String get displayName => '$platNomor - $merk $tipe';
}

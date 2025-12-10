class ActiveParkingModel {
  final String idTransaksi;
  final String? idBooking;
  final String qrCode;

  // Mall & Location
  final String namaMall;
  final String lokasiMall;
  final String idParkiran;
  final String kodeSlot;

  // Vehicle
  final String platNomor;
  final String jenisKendaraan;
  final String merkKendaraan;
  final String tipeKendaraan;

  // Time
  final DateTime waktuMasuk;
  final DateTime? waktuSelesaiEstimas;
  final bool isBooking;

  // Cost
  final double biayaPerJam;
  final double biayaJamPertama;
  final double? penalty;

  // Status
  final String statusParkir; // 'aktif', 'booking_aktif'

  ActiveParkingModel({
    required this.idTransaksi,
    this.idBooking,
    required this.qrCode,
    required this.namaMall,
    required this.lokasiMall,
    required this.idParkiran,
    required this.kodeSlot,
    required this.platNomor,
    required this.jenisKendaraan,
    required this.merkKendaraan,
    required this.tipeKendaraan,
    required this.waktuMasuk,
    this.waktuSelesaiEstimas,
    required this.isBooking,
    required this.biayaPerJam,
    required this.biayaJamPertama,
    this.penalty,
    required this.statusParkir,
  });

  /// Calculate elapsed duration from waktu_masuk to current time
  Duration getElapsedDuration() {
    final now = DateTime.now();
    return now.difference(waktuMasuk);
  }

  /// Calculate remaining duration from current time to waktuSelesaiEstimas
  /// Returns null if no booking end time exists
  Duration? getRemainingDuration() {
    if (waktuSelesaiEstimas == null) {
      return null;
    }
    final now = DateTime.now();
    final remaining = waktuSelesaiEstimas!.difference(now);
    // Return zero if already exceeded
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Calculate current parking cost based on elapsed time and tariff
  /// Formula: First hour uses biayaJamPertama, subsequent hours use biayaPerJam
  double calculateCurrentCost() {
    final elapsed = getElapsedDuration();
    final hours = elapsed.inMinutes / 60.0;

    if (hours <= 1.0) {
      // First hour or less
      return biayaJamPertama;
    } else {
      // First hour + additional hours
      final additionalHours = (hours - 1.0).ceil();
      return biayaJamPertama + (additionalHours * biayaPerJam);
    }
  }

  /// Check if penalty is applicable (current time exceeds waktuSelesaiEstimas)
  bool isPenaltyApplicable() {
    if (waktuSelesaiEstimas == null) {
      return false;
    }
    final now = DateTime.now();
    return now.isAfter(waktuSelesaiEstimas!);
  }

  /// Create ActiveParkingModel from JSON
  factory ActiveParkingModel.fromJson(Map<String, dynamic> json) {
    return ActiveParkingModel(
      idTransaksi: json['id_transaksi']?.toString() ?? '',
      idBooking: json['id_booking']?.toString(),
      qrCode: json['qr_code']?.toString() ?? '',
      namaMall: json['nama_mall']?.toString() ?? '',
      lokasiMall: json['lokasi_mall']?.toString() ?? '',
      idParkiran: json['id_parkiran']?.toString() ?? '',
      kodeSlot: json['kode_slot']?.toString() ?? '',
      platNomor: json['plat_nomor']?.toString() ?? '',
      jenisKendaraan: json['jenis_kendaraan']?.toString() ?? '',
      merkKendaraan: json['merk_kendaraan']?.toString() ?? '',
      tipeKendaraan: json['tipe_kendaraan']?.toString() ?? '',
      waktuMasuk: json['waktu_masuk'] != null
          ? DateTime.parse(json['waktu_masuk'].toString())
          : DateTime.now(),
      waktuSelesaiEstimas: json['waktu_selesai_estimas'] != null
          ? DateTime.parse(json['waktu_selesai_estimas'].toString())
          : null,
      isBooking: json['is_booking'] == true || json['is_booking'] == 1,
      biayaPerJam: _parseDouble(json['biaya_per_jam']),
      biayaJamPertama: _parseDouble(json['biaya_jam_pertama']),
      penalty: json['penalty'] != null ? _parseDouble(json['penalty']) : null,
      statusParkir: json['status_parkir']?.toString() ?? 'aktif',
    );
  }

  /// Convert ActiveParkingModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id_transaksi': idTransaksi,
      'id_booking': idBooking,
      'qr_code': qrCode,
      'nama_mall': namaMall,
      'lokasi_mall': lokasiMall,
      'id_parkiran': idParkiran,
      'kode_slot': kodeSlot,
      'plat_nomor': platNomor,
      'jenis_kendaraan': jenisKendaraan,
      'merk_kendaraan': merkKendaraan,
      'tipe_kendaraan': tipeKendaraan,
      'waktu_masuk': waktuMasuk.toIso8601String(),
      'waktu_selesai_estimas': waktuSelesaiEstimas?.toIso8601String(),
      'is_booking': isBooking,
      'biaya_per_jam': biayaPerJam,
      'biaya_jam_pertama': biayaJamPertama,
      'penalty': penalty,
      'status_parkir': statusParkir,
    };
  }

  /// Helper method to safely parse double values from JSON
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Create a copy of this model with updated fields
  ActiveParkingModel copyWith({
    String? idTransaksi,
    String? idBooking,
    String? qrCode,
    String? namaMall,
    String? lokasiMall,
    String? idParkiran,
    String? kodeSlot,
    String? platNomor,
    String? jenisKendaraan,
    String? merkKendaraan,
    String? tipeKendaraan,
    DateTime? waktuMasuk,
    DateTime? waktuSelesaiEstimas,
    bool? isBooking,
    double? biayaPerJam,
    double? biayaJamPertama,
    double? penalty,
    String? statusParkir,
  }) {
    return ActiveParkingModel(
      idTransaksi: idTransaksi ?? this.idTransaksi,
      idBooking: idBooking ?? this.idBooking,
      qrCode: qrCode ?? this.qrCode,
      namaMall: namaMall ?? this.namaMall,
      lokasiMall: lokasiMall ?? this.lokasiMall,
      idParkiran: idParkiran ?? this.idParkiran,
      kodeSlot: kodeSlot ?? this.kodeSlot,
      platNomor: platNomor ?? this.platNomor,
      jenisKendaraan: jenisKendaraan ?? this.jenisKendaraan,
      merkKendaraan: merkKendaraan ?? this.merkKendaraan,
      tipeKendaraan: tipeKendaraan ?? this.tipeKendaraan,
      waktuMasuk: waktuMasuk ?? this.waktuMasuk,
      waktuSelesaiEstimas: waktuSelesaiEstimas ?? this.waktuSelesaiEstimas,
      isBooking: isBooking ?? this.isBooking,
      biayaPerJam: biayaPerJam ?? this.biayaPerJam,
      biayaJamPertama: biayaJamPertama ?? this.biayaJamPertama,
      penalty: penalty ?? this.penalty,
      statusParkir: statusParkir ?? this.statusParkir,
    );
  }
}

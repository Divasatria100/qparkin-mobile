class BookingModel {
  final String idTransaksi;
  final String idBooking;
  final String idMall;
  final String idParkiran;
  final String idKendaraan;
  final String qrCode;
  final DateTime waktuMulai;
  final DateTime waktuSelesai;
  final int durasiBooking; // in hours
  final String status; // 'aktif', 'selesai', 'expired'
  final double biayaEstimasi;
  final DateTime dibookingPada;

  // Additional display fields
  final String? namaMall;
  final String? lokasiMall;
  final String? platNomor;
  final String? jenisKendaraan;
  final String? kodeSlot;
  
  // Slot reservation fields
  final String? idSlot;
  final String? reservationId;
  final String? floorName;
  final String? floorNumber;
  final String? slotType; // 'regular' or 'disable_friendly'

  BookingModel({
    required this.idTransaksi,
    required this.idBooking,
    required this.idMall,
    required this.idParkiran,
    required this.idKendaraan,
    required this.qrCode,
    required this.waktuMulai,
    required this.waktuSelesai,
    required this.durasiBooking,
    required this.status,
    required this.biayaEstimasi,
    required this.dibookingPada,
    this.namaMall,
    this.lokasiMall,
    this.platNomor,
    this.jenisKendaraan,
    this.kodeSlot,
    this.idSlot,
    this.reservationId,
    this.floorName,
    this.floorNumber,
    this.slotType,
  });

  /// Get formatted duration string (e.g., "2 jam 30 menit")
  String get formattedDuration {
    final hours = durasiBooking;
    if (hours == 1) {
      return '1 jam';
    }
    return '$hours jam';
  }

  /// Get formatted cost string with thousand separators (e.g., "Rp 15.000")
  String get formattedCost {
    final formatter = _formatCurrency(biayaEstimasi);
    return 'Rp $formatter';
  }

  /// Check if booking is currently active
  bool get isActive {
    return status == 'aktif';
  }

  /// Check if booking has expired
  bool get isExpired {
    return status == 'expired' || DateTime.now().isAfter(waktuSelesai);
  }

  /// Check if booking is completed
  bool get isCompleted {
    return status == 'selesai';
  }

  /// Check if booking has reserved slot information
  bool get hasReservedSlot {
    return idSlot != null && kodeSlot != null;
  }

  /// Get formatted slot location (e.g., "Lantai 1 - Slot A15")
  String? get formattedSlotLocation {
    if (floorName != null && kodeSlot != null) {
      return '$floorName - Slot $kodeSlot';
    } else if (kodeSlot != null) {
      return 'Slot $kodeSlot';
    }
    return null;
  }

  /// Get formatted slot type label
  String? get formattedSlotType {
    if (slotType == null) return null;
    return slotType == 'disable_friendly' ? 'Disable-Friendly' : 'Regular Parking';
  }

  /// Get remaining time until booking starts
  Duration? get timeUntilStart {
    final now = DateTime.now();
    if (now.isBefore(waktuMulai)) {
      return waktuMulai.difference(now);
    }
    return null;
  }

  /// Get remaining time until booking ends
  Duration? get timeUntilEnd {
    final now = DateTime.now();
    if (now.isBefore(waktuSelesai)) {
      return waktuSelesai.difference(now);
    }
    return null;
  }

  /// Validate booking data
  bool validate() {
    if (idTransaksi.isEmpty) return false;
    if (idBooking.isEmpty) return false;
    if (idMall.isEmpty) return false;
    if (idParkiran.isEmpty) return false;
    if (idKendaraan.isEmpty) return false;
    if (qrCode.isEmpty) return false;
    if (durasiBooking <= 0) return false;
    if (biayaEstimasi < 0) return false;
    if (waktuSelesai.isBefore(waktuMulai)) return false;
    return true;
  }

  /// Create BookingModel from JSON
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Handle id_booking with fallback to id_transaksi
    final idBookingValue = json['id_booking'] ?? json['id_transaksi'];
    final idTransaksiValue = json['id_transaksi'];
    
    return BookingModel(
      idTransaksi: idTransaksiValue?.toString() ?? '',
      idBooking: idBookingValue?.toString() ?? idTransaksiValue?.toString() ?? '',
      idMall: json['id_mall']?.toString() ?? '',
      idParkiran: json['id_parkiran']?.toString() ?? '',
      idKendaraan: json['id_kendaraan']?.toString() ?? '',
      qrCode: json['qr_code']?.toString() ?? '',
      waktuMulai: json['waktu_mulai'] != null
          ? DateTime.parse(json['waktu_mulai'].toString())
          : DateTime.now(),
      waktuSelesai: json['waktu_selesai'] != null
          ? DateTime.parse(json['waktu_selesai'].toString())
          : DateTime.now(),
      durasiBooking: _parseInt(json['durasi_booking']),
      status: json['status']?.toString() ?? 'aktif',
      biayaEstimasi: _parseDouble(json['biaya_estimasi']),
      dibookingPada: json['diboking_pada'] != null
          ? DateTime.parse(json['diboking_pada'].toString())
          : DateTime.now(),
      namaMall: json['nama_mall']?.toString(),
      lokasiMall: json['lokasi_mall']?.toString(),
      platNomor: json['plat_nomor']?.toString(),
      jenisKendaraan: json['jenis_kendaraan']?.toString(),
      kodeSlot: json['kode_slot']?.toString(),
      idSlot: json['id_slot']?.toString(),
      reservationId: json['reservation_id']?.toString(),
      floorName: json['floor_name']?.toString(),
      floorNumber: json['floor_number']?.toString(),
      slotType: json['slot_type']?.toString(),
    );
  }

  /// Convert BookingModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id_transaksi': idTransaksi,
      'id_booking': idBooking,
      'id_mall': idMall,
      'id_parkiran': idParkiran,
      'id_kendaraan': idKendaraan,
      'qr_code': qrCode,
      'waktu_mulai': waktuMulai.toIso8601String(),
      'waktu_selesai': waktuSelesai.toIso8601String(),
      'durasi_booking': durasiBooking,
      'status': status,
      'biaya_estimasi': biayaEstimasi,
      'diboking_pada': dibookingPada.toIso8601String(),
      'nama_mall': namaMall,
      'lokasi_mall': lokasiMall,
      'plat_nomor': platNomor,
      'jenis_kendaraan': jenisKendaraan,
      'kode_slot': kodeSlot,
      'id_slot': idSlot,
      'reservation_id': reservationId,
      'floor_name': floorName,
      'floor_number': floorNumber,
      'slot_type': slotType,
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

  /// Helper method to safely parse int values from JSON
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Helper method to format currency with thousand separators
  static String _formatCurrency(double amount) {
    final intAmount = amount.toInt();
    final str = intAmount.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }

    return buffer.toString();
  }

  /// Create a copy of this model with updated fields
  BookingModel copyWith({
    String? idTransaksi,
    String? idBooking,
    String? idMall,
    String? idParkiran,
    String? idKendaraan,
    String? qrCode,
    DateTime? waktuMulai,
    DateTime? waktuSelesai,
    int? durasiBooking,
    String? status,
    double? biayaEstimasi,
    DateTime? dibookingPada,
    String? namaMall,
    String? lokasiMall,
    String? platNomor,
    String? jenisKendaraan,
    String? kodeSlot,
    String? idSlot,
    String? reservationId,
    String? floorName,
    String? floorNumber,
    String? slotType,
  }) {
    return BookingModel(
      idTransaksi: idTransaksi ?? this.idTransaksi,
      idBooking: idBooking ?? this.idBooking,
      idMall: idMall ?? this.idMall,
      idParkiran: idParkiran ?? this.idParkiran,
      idKendaraan: idKendaraan ?? this.idKendaraan,
      qrCode: qrCode ?? this.qrCode,
      waktuMulai: waktuMulai ?? this.waktuMulai,
      waktuSelesai: waktuSelesai ?? this.waktuSelesai,
      durasiBooking: durasiBooking ?? this.durasiBooking,
      status: status ?? this.status,
      biayaEstimasi: biayaEstimasi ?? this.biayaEstimasi,
      dibookingPada: dibookingPada ?? this.dibookingPada,
      namaMall: namaMall ?? this.namaMall,
      lokasiMall: lokasiMall ?? this.lokasiMall,
      platNomor: platNomor ?? this.platNomor,
      jenisKendaraan: jenisKendaraan ?? this.jenisKendaraan,
      kodeSlot: kodeSlot ?? this.kodeSlot,
      idSlot: idSlot ?? this.idSlot,
      reservationId: reservationId ?? this.reservationId,
      floorName: floorName ?? this.floorName,
      floorNumber: floorNumber ?? this.floorNumber,
      slotType: slotType ?? this.slotType,
    );
  }
}

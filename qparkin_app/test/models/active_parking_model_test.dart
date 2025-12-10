import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/data/models/active_parking_model.dart';

void main() {
  group('ActiveParkingModel Duration Calculations', () {
    test('getElapsedDuration returns correct duration from waktu_masuk', () {
      final waktuMasuk = DateTime.now().subtract(const Duration(hours: 2, minutes: 30));
      final model = _createTestModel(waktuMasuk: waktuMasuk);

      final elapsed = model.getElapsedDuration();

      expect(elapsed.inHours, equals(2));
      expect(elapsed.inMinutes, greaterThanOrEqualTo(150));
    });

    test('getRemainingDuration returns null when no booking end time', () {
      final model = _createTestModel(waktuSelesaiEstimas: null);

      final remaining = model.getRemainingDuration();

      expect(remaining, isNull);
    });

    test('getRemainingDuration returns correct duration before expiry', () {
      final waktuSelesaiEstimas = DateTime.now().add(const Duration(hours: 1, minutes: 30));
      final model = _createTestModel(waktuSelesaiEstimas: waktuSelesaiEstimas);

      final remaining = model.getRemainingDuration();

      expect(remaining, isNotNull);
      expect(remaining!.inMinutes, greaterThanOrEqualTo(89));
      expect(remaining.inMinutes, lessThanOrEqualTo(91));
    });

    test('getRemainingDuration returns zero when booking expired', () {
      final waktuSelesaiEstimas = DateTime.now().subtract(const Duration(hours: 1));
      final model = _createTestModel(waktuSelesaiEstimas: waktuSelesaiEstimas);

      final remaining = model.getRemainingDuration();

      expect(remaining, equals(Duration.zero));
    });
  });

  group('ActiveParkingModel Cost Calculations', () {
    test('calculateCurrentCost returns first hour rate for duration under 1 hour', () {
      final waktuMasuk = DateTime.now().subtract(const Duration(minutes: 45));
      final model = _createTestModel(
        waktuMasuk: waktuMasuk,
        biayaJamPertama: 5000,
        biayaPerJam: 3000,
      );

      final cost = model.calculateCurrentCost();

      expect(cost, equals(5000));
    });

    test('calculateCurrentCost returns first hour rate for exactly 1 hour', () {
      final waktuMasuk = DateTime.now().subtract(const Duration(hours: 1));
      final model = _createTestModel(
        waktuMasuk: waktuMasuk,
        biayaJamPertama: 5000,
        biayaPerJam: 3000,
      );

      final cost = model.calculateCurrentCost();

      expect(cost, equals(5000));
    });

    test('calculateCurrentCost adds additional hours correctly', () {
      final waktuMasuk = DateTime.now().subtract(const Duration(hours: 3, minutes: 30));
      final model = _createTestModel(
        waktuMasuk: waktuMasuk,
        biayaJamPertama: 5000,
        biayaPerJam: 3000,
      );

      final cost = model.calculateCurrentCost();

      // First hour: 5000, additional 3 hours: 3 * 3000 = 9000
      expect(cost, equals(14000));
    });

    test('calculateCurrentCost with different tariff rates', () {
      final waktuMasuk = DateTime.now().subtract(const Duration(hours: 2, minutes: 15));
      final model = _createTestModel(
        waktuMasuk: waktuMasuk,
        biayaJamPertama: 10000,
        biayaPerJam: 5000,
      );

      final cost = model.calculateCurrentCost();

      // First hour: 10000, additional 2 hours: 2 * 5000 = 10000
      expect(cost, equals(20000));
    });

    test('calculateCurrentCost handles zero rates', () {
      final waktuMasuk = DateTime.now().subtract(const Duration(hours: 2));
      final model = _createTestModel(
        waktuMasuk: waktuMasuk,
        biayaJamPertama: 0,
        biayaPerJam: 0,
      );

      final cost = model.calculateCurrentCost();

      expect(cost, equals(0));
    });
  });

  group('ActiveParkingModel Penalty Logic', () {
    test('isPenaltyApplicable returns false when no booking end time', () {
      final model = _createTestModel(waktuSelesaiEstimas: null);

      expect(model.isPenaltyApplicable(), isFalse);
    });

    test('isPenaltyApplicable returns false before booking expires', () {
      final waktuSelesaiEstimas = DateTime.now().add(const Duration(hours: 1));
      final model = _createTestModel(waktuSelesaiEstimas: waktuSelesaiEstimas);

      expect(model.isPenaltyApplicable(), isFalse);
    });

    test('isPenaltyApplicable returns true after booking expires', () {
      final waktuSelesaiEstimas = DateTime.now().subtract(const Duration(minutes: 30));
      final model = _createTestModel(waktuSelesaiEstimas: waktuSelesaiEstimas);

      expect(model.isPenaltyApplicable(), isTrue);
    });

    test('isPenaltyApplicable returns true just after expiry time', () {
      final waktuSelesaiEstimas = DateTime.now().subtract(const Duration(milliseconds: 100));
      final model = _createTestModel(waktuSelesaiEstimas: waktuSelesaiEstimas);

      expect(model.isPenaltyApplicable(), isTrue);
    });
  });

  group('ActiveParkingModel JSON Serialization', () {
    test('fromJson creates model with all fields', () {
      final json = {
        'id_transaksi': 'TRX001',
        'id_booking': 'BKG001',
        'qr_code': 'QR123456',
        'nama_mall': 'Mall ABC',
        'lokasi_mall': 'Jakarta',
        'id_parkiran': 'P001',
        'kode_slot': 'A-12',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Mobil',
        'merk_kendaraan': 'Toyota',
        'tipe_kendaraan': 'Avanza',
        'waktu_masuk': '2024-01-15T10:00:00.000Z',
        'waktu_selesai_estimas': '2024-01-15T12:00:00.000Z',
        'is_booking': true,
        'biaya_per_jam': 3000.0,
        'biaya_jam_pertama': 5000.0,
        'penalty': 2000.0,
        'status_parkir': 'aktif',
      };

      final model = ActiveParkingModel.fromJson(json);

      expect(model.idTransaksi, equals('TRX001'));
      expect(model.idBooking, equals('BKG001'));
      expect(model.qrCode, equals('QR123456'));
      expect(model.namaMall, equals('Mall ABC'));
      expect(model.platNomor, equals('B1234XYZ'));
      expect(model.isBooking, isTrue);
      expect(model.biayaPerJam, equals(3000.0));
      expect(model.penalty, equals(2000.0));
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id_transaksi': 'TRX001',
        'qr_code': 'QR123456',
        'nama_mall': 'Mall ABC',
        'lokasi_mall': 'Jakarta',
        'id_parkiran': 'P001',
        'kode_slot': 'A-12',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Mobil',
        'merk_kendaraan': 'Toyota',
        'tipe_kendaraan': 'Avanza',
        'waktu_masuk': '2024-01-15T10:00:00.000Z',
        'is_booking': false,
        'biaya_per_jam': 3000.0,
        'biaya_jam_pertama': 5000.0,
        'status_parkir': 'aktif',
      };

      final model = ActiveParkingModel.fromJson(json);

      expect(model.idBooking, isNull);
      expect(model.waktuSelesaiEstimas, isNull);
      expect(model.penalty, isNull);
    });

    test('fromJson parses double from string', () {
      final json = {
        'id_transaksi': 'TRX001',
        'qr_code': 'QR123456',
        'nama_mall': 'Mall ABC',
        'lokasi_mall': 'Jakarta',
        'id_parkiran': 'P001',
        'kode_slot': 'A-12',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Mobil',
        'merk_kendaraan': 'Toyota',
        'tipe_kendaraan': 'Avanza',
        'waktu_masuk': '2024-01-15T10:00:00.000Z',
        'is_booking': false,
        'biaya_per_jam': '3000',
        'biaya_jam_pertama': '5000',
        'status_parkir': 'aktif',
      };

      final model = ActiveParkingModel.fromJson(json);

      expect(model.biayaPerJam, equals(3000.0));
      expect(model.biayaJamPertama, equals(5000.0));
    });

    test('fromJson parses double from int', () {
      final json = {
        'id_transaksi': 'TRX001',
        'qr_code': 'QR123456',
        'nama_mall': 'Mall ABC',
        'lokasi_mall': 'Jakarta',
        'id_parkiran': 'P001',
        'kode_slot': 'A-12',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Mobil',
        'merk_kendaraan': 'Toyota',
        'tipe_kendaraan': 'Avanza',
        'waktu_masuk': '2024-01-15T10:00:00.000Z',
        'is_booking': false,
        'biaya_per_jam': 3000,
        'biaya_jam_pertama': 5000,
        'status_parkir': 'aktif',
      };

      final model = ActiveParkingModel.fromJson(json);

      expect(model.biayaPerJam, equals(3000.0));
      expect(model.biayaJamPertama, equals(5000.0));
    });

    test('toJson creates correct JSON structure', () {
      final model = _createTestModel(
        idTransaksi: 'TRX001',
        qrCode: 'QR123456',
        penalty: 2000.0,
      );

      final json = model.toJson();

      expect(json['id_transaksi'], equals('TRX001'));
      expect(json['qr_code'], equals('QR123456'));
      expect(json['penalty'], equals(2000.0));
      expect(json['waktu_masuk'], isA<String>());
      expect(json['is_booking'], isA<bool>());
    });

    test('toJson and fromJson round trip preserves data', () {
      final original = _createTestModel(
        idTransaksi: 'TRX001',
        biayaPerJam: 3000.0,
        biayaJamPertama: 5000.0,
      );

      final json = original.toJson();
      final restored = ActiveParkingModel.fromJson(json);

      expect(restored.idTransaksi, equals(original.idTransaksi));
      expect(restored.biayaPerJam, equals(original.biayaPerJam));
      expect(restored.biayaJamPertama, equals(original.biayaJamPertama));
    });
  });

  group('ActiveParkingModel copyWith', () {
    test('copyWith creates new instance with updated fields', () {
      final original = _createTestModel(idTransaksi: 'TRX001', penalty: null);

      final updated = original.copyWith(penalty: 2000.0);

      expect(updated.idTransaksi, equals('TRX001'));
      expect(updated.penalty, equals(2000.0));
      expect(original.penalty, isNull);
    });

    test('copyWith preserves unchanged fields', () {
      final original = _createTestModel(
        idTransaksi: 'TRX001',
        namaMall: 'Mall ABC',
        biayaPerJam: 3000.0,
      );

      final updated = original.copyWith(penalty: 2000.0);

      expect(updated.namaMall, equals('Mall ABC'));
      expect(updated.biayaPerJam, equals(3000.0));
    });
  });
}

/// Helper function to create test model with default values
ActiveParkingModel _createTestModel({
  String idTransaksi = 'TRX001',
  String? idBooking = 'BKG001',
  String qrCode = 'QR123456',
  String namaMall = 'Test Mall',
  String lokasiMall = 'Test Location',
  String idParkiran = 'P001',
  String kodeSlot = 'A-12',
  String platNomor = 'B1234XYZ',
  String jenisKendaraan = 'Mobil',
  String merkKendaraan = 'Toyota',
  String tipeKendaraan = 'Avanza',
  DateTime? waktuMasuk,
  DateTime? waktuSelesaiEstimas,
  bool isBooking = true,
  double biayaPerJam = 3000.0,
  double biayaJamPertama = 5000.0,
  double? penalty,
  String statusParkir = 'aktif',
}) {
  return ActiveParkingModel(
    idTransaksi: idTransaksi,
    idBooking: idBooking,
    qrCode: qrCode,
    namaMall: namaMall,
    lokasiMall: lokasiMall,
    idParkiran: idParkiran,
    kodeSlot: kodeSlot,
    platNomor: platNomor,
    jenisKendaraan: jenisKendaraan,
    merkKendaraan: merkKendaraan,
    tipeKendaraan: tipeKendaraan,
    waktuMasuk: waktuMasuk ?? DateTime.now(),
    waktuSelesaiEstimas: waktuSelesaiEstimas,
    isBooking: isBooking,
    biayaPerJam: biayaPerJam,
    biayaJamPertama: biayaJamPertama,
    penalty: penalty,
    statusParkir: statusParkir,
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/data/models/vehicle_model.dart';

void main() {
  group('VehicleModel', () {
    test('should create VehicleModel from JSON with isActive', () {
      final json = {
        'id_kendaraan': '456',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Roda Empat',
        'merk': 'Toyota',
        'tipe': 'Avanza',
        'warna': 'Hitam',
        'is_active': true,
      };

      final vehicle = VehicleModel.fromJson(json);

      expect(vehicle.idKendaraan, '456');
      expect(vehicle.platNomor, 'B1234XYZ');
      expect(vehicle.jenisKendaraan, 'Roda Empat');
      expect(vehicle.merk, 'Toyota');
      expect(vehicle.tipe, 'Avanza');
      expect(vehicle.warna, 'Hitam');
      expect(vehicle.isActive, true);
    });

    test('should handle isActive as integer (1 for true)', () {
      final json = {
        'id_kendaraan': '456',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Roda Empat',
        'merk': 'Toyota',
        'tipe': 'Avanza',
        'is_active': 1,
      };

      final vehicle = VehicleModel.fromJson(json);

      expect(vehicle.isActive, true);
    });

    test('should handle isActive as integer (0 for false)', () {
      final json = {
        'id_kendaraan': '456',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Roda Empat',
        'merk': 'Toyota',
        'tipe': 'Avanza',
        'is_active': 0,
      };

      final vehicle = VehicleModel.fromJson(json);

      expect(vehicle.isActive, false);
    });

    test('should default isActive to false when not provided', () {
      final json = {
        'id_kendaraan': '456',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Roda Empat',
        'merk': 'Toyota',
        'tipe': 'Avanza',
      };

      final vehicle = VehicleModel.fromJson(json);

      expect(vehicle.isActive, false);
    });

    test('should handle missing optional fields in JSON', () {
      final json = {
        'id_kendaraan': '456',
        'plat_nomor': 'B1234XYZ',
        'jenis_kendaraan': 'Roda Empat',
        'merk': 'Toyota',
        'tipe': 'Avanza',
      };

      final vehicle = VehicleModel.fromJson(json);

      expect(vehicle.idKendaraan, '456');
      expect(vehicle.platNomor, 'B1234XYZ');
      expect(vehicle.jenisKendaraan, 'Roda Empat');
      expect(vehicle.merk, 'Toyota');
      expect(vehicle.tipe, 'Avanza');
      expect(vehicle.warna, isNull);
      expect(vehicle.isActive, false); // Default value
    });

    test('should convert VehicleModel to JSON', () {
      final vehicle = VehicleModel(
        idKendaraan: '456',
        platNomor: 'B1234XYZ',
        jenisKendaraan: 'Roda Empat',
        merk: 'Toyota',
        tipe: 'Avanza',
        warna: 'Hitam',
        isActive: true,
      );

      final json = vehicle.toJson();

      expect(json['id_kendaraan'], '456');
      expect(json['plat_nomor'], 'B1234XYZ');
      expect(json['jenis_kendaraan'], 'Roda Empat');
      expect(json['merk'], 'Toyota');
      expect(json['tipe'], 'Avanza');
      expect(json['warna'], 'Hitam');
      expect(json['is_active'], true);
    });

    test('copyWith should create new instance with updated fields', () {
      final vehicle = VehicleModel(
        idKendaraan: '456',
        platNomor: 'B1234XYZ',
        jenisKendaraan: 'Roda Empat',
        merk: 'Toyota',
        tipe: 'Avanza',
        isActive: false,
      );

      final updatedVehicle = vehicle.copyWith(
        platNomor: 'B5678ABC',
        isActive: true,
      );

      expect(updatedVehicle.idKendaraan, '456'); // Unchanged
      expect(updatedVehicle.platNomor, 'B5678ABC'); // Changed
      expect(updatedVehicle.jenisKendaraan, 'Roda Empat'); // Unchanged
      expect(updatedVehicle.merk, 'Toyota'); // Unchanged
      expect(updatedVehicle.tipe, 'Avanza'); // Unchanged
      expect(updatedVehicle.isActive, true); // Changed
    });

    test('copyWith should preserve original values when no parameters provided', () {
      final vehicle = VehicleModel(
        idKendaraan: '456',
        platNomor: 'B1234XYZ',
        jenisKendaraan: 'Roda Empat',
        merk: 'Toyota',
        tipe: 'Avanza',
        isActive: true,
      );

      final copiedVehicle = vehicle.copyWith();

      expect(copiedVehicle.idKendaraan, vehicle.idKendaraan);
      expect(copiedVehicle.platNomor, vehicle.platNomor);
      expect(copiedVehicle.jenisKendaraan, vehicle.jenisKendaraan);
      expect(copiedVehicle.merk, vehicle.merk);
      expect(copiedVehicle.tipe, vehicle.tipe);
      expect(copiedVehicle.isActive, vehicle.isActive);
    });

    test('should handle round-trip JSON serialization', () {
      final originalVehicle = VehicleModel(
        idKendaraan: '456',
        platNomor: 'B1234XYZ',
        jenisKendaraan: 'Roda Empat',
        merk: 'Toyota',
        tipe: 'Avanza',
        warna: 'Hitam',
        isActive: true,
      );

      final json = originalVehicle.toJson();
      final deserializedVehicle = VehicleModel.fromJson(json);

      expect(deserializedVehicle.idKendaraan, originalVehicle.idKendaraan);
      expect(deserializedVehicle.platNomor, originalVehicle.platNomor);
      expect(deserializedVehicle.jenisKendaraan, originalVehicle.jenisKendaraan);
      expect(deserializedVehicle.merk, originalVehicle.merk);
      expect(deserializedVehicle.tipe, originalVehicle.tipe);
      expect(deserializedVehicle.warna, originalVehicle.warna);
      expect(deserializedVehicle.isActive, originalVehicle.isActive);
    });

    test('displayName should return formatted string', () {
      final vehicle = VehicleModel(
        idKendaraan: '456',
        platNomor: 'B1234XYZ',
        jenisKendaraan: 'Roda Empat',
        merk: 'Toyota',
        tipe: 'Avanza',
      );

      expect(vehicle.displayName, 'B1234XYZ - Toyota Avanza');
    });
  });
}

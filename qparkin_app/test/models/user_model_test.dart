import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('should create UserModel from JSON with saldoPoin', () {
      final json = {
        'id': '123',
        'name': 'Test User',
        'email': 'test@example.com',
        'phone_number': '081234567890',
        'photo_url': 'https://example.com/photo.jpg',
        'saldo_poin': 150,
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-02T00:00:00.000Z',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, '123');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.phoneNumber, '081234567890');
      expect(user.photoUrl, 'https://example.com/photo.jpg');
      expect(user.saldoPoin, 150);
      expect(user.createdAt, DateTime.parse('2024-01-01T00:00:00.000Z'));
      expect(user.updatedAt, DateTime.parse('2024-01-02T00:00:00.000Z'));
    });

    test('should handle missing optional fields in JSON', () {
      final json = {
        'id': '123',
        'name': 'Test User',
        'email': 'test@example.com',
        'created_at': '2024-01-01T00:00:00.000Z',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, '123');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.phoneNumber, isNull);
      expect(user.photoUrl, isNull);
      expect(user.saldoPoin, 0); // Default value
      expect(user.updatedAt, isNull);
    });

    test('should convert UserModel to JSON', () {
      final user = UserModel(
        id: '123',
        name: 'Test User',
        email: 'test@example.com',
        phoneNumber: '081234567890',
        photoUrl: 'https://example.com/photo.jpg',
        saldoPoin: 150,
        createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
      );

      final json = user.toJson();

      expect(json['id'], '123');
      expect(json['name'], 'Test User');
      expect(json['email'], 'test@example.com');
      expect(json['phone_number'], '081234567890');
      expect(json['photo_url'], 'https://example.com/photo.jpg');
      expect(json['saldo_poin'], 150);
      expect(json['created_at'], '2024-01-01T00:00:00.000Z');
      expect(json['updated_at'], '2024-01-02T00:00:00.000Z');
    });

    test('copyWith should create new instance with updated fields', () {
      final user = UserModel(
        id: '123',
        name: 'Test User',
        email: 'test@example.com',
        saldoPoin: 100,
        createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
      );

      final updatedUser = user.copyWith(
        name: 'Updated User',
        saldoPoin: 200,
      );

      expect(updatedUser.id, '123'); // Unchanged
      expect(updatedUser.name, 'Updated User'); // Changed
      expect(updatedUser.email, 'test@example.com'); // Unchanged
      expect(updatedUser.saldoPoin, 200); // Changed
    });

    test('copyWith should preserve original values when no parameters provided', () {
      final user = UserModel(
        id: '123',
        name: 'Test User',
        email: 'test@example.com',
        saldoPoin: 100,
        createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
      );

      final copiedUser = user.copyWith();

      expect(copiedUser.id, user.id);
      expect(copiedUser.name, user.name);
      expect(copiedUser.email, user.email);
      expect(copiedUser.saldoPoin, user.saldoPoin);
    });

    test('should handle round-trip JSON serialization', () {
      final originalUser = UserModel(
        id: '123',
        name: 'Test User',
        email: 'test@example.com',
        phoneNumber: '081234567890',
        photoUrl: 'https://example.com/photo.jpg',
        saldoPoin: 150,
        createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
      );

      final json = originalUser.toJson();
      final deserializedUser = UserModel.fromJson(json);

      expect(deserializedUser.id, originalUser.id);
      expect(deserializedUser.name, originalUser.name);
      expect(deserializedUser.email, originalUser.email);
      expect(deserializedUser.phoneNumber, originalUser.phoneNumber);
      expect(deserializedUser.photoUrl, originalUser.photoUrl);
      expect(deserializedUser.saldoPoin, originalUser.saldoPoin);
      expect(deserializedUser.createdAt, originalUser.createdAt);
      expect(deserializedUser.updatedAt, originalUser.updatedAt);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:qparkin_app/data/services/auth_service.dart';

/// **Feature: profile-page-enhancement, Property 16: Logout Data Clearing**
/// **Validates: Requirements 11.2**
/// 
/// Property: For any logout action, all user data should be cleared from local storage
/// 
/// This property test verifies that:
/// 1. All user data is cleared from FlutterSecureStorage on logout
/// 2. Auth tokens are removed
/// 3. User data is removed
/// 4. Saved phone (remember me) is removed
void main() {
  group('Property 16: Logout Data Clearing', () {
    late AuthService authService;
    late FlutterSecureStorage secureStorage;

    setUp(() {
      // Configure FlutterSecureStorage for testing
      FlutterSecureStorage.setMockInitialValues({});
      secureStorage = const FlutterSecureStorage();
      authService = AuthService();
    });

    test('Property: All user data should be cleared on logout', () async {
      // Test with 100 iterations to ensure property holds across different scenarios
      for (int i = 0; i < 100; i++) {
        // Setup: Store various user data
        await secureStorage.write(
          key: 'auth_token',
          value: 'test_token_$i',
        );
        await secureStorage.write(
          key: 'user_data',
          value: '{"id": "$i", "name": "User $i", "email": "user$i@test.com"}',
        );
        await secureStorage.write(
          key: 'saved_phone',
          value: '08123456789$i',
        );

        // Verify data is stored before logout
        final tokenBefore = await secureStorage.read(key: 'auth_token');
        final userDataBefore = await secureStorage.read(key: 'user_data');
        final savedPhoneBefore = await secureStorage.read(key: 'saved_phone');

        expect(tokenBefore, isNotNull, reason: 'Token should exist before logout');
        expect(userDataBefore, isNotNull, reason: 'User data should exist before logout');
        expect(savedPhoneBefore, isNotNull, reason: 'Saved phone should exist before logout');

        // Action: Perform logout
        await authService.logout();

        // Verification: All data should be cleared
        final tokenAfter = await secureStorage.read(key: 'auth_token');
        final userDataAfter = await secureStorage.read(key: 'user_data');
        final savedPhoneAfter = await secureStorage.read(key: 'saved_phone');

        expect(
          tokenAfter,
          isNull,
          reason: 'Auth token should be cleared after logout (iteration $i)',
        );
        expect(
          userDataAfter,
          isNull,
          reason: 'User data should be cleared after logout (iteration $i)',
        );
        expect(
          savedPhoneAfter,
          isNull,
          reason: 'Saved phone should be cleared after logout (iteration $i)',
        );

        // Verify isLoggedIn returns false after logout
        final isLoggedIn = await authService.isLoggedIn();
        expect(
          isLoggedIn,
          isFalse,
          reason: 'User should not be logged in after logout (iteration $i)',
        );
      }
    });

    test('Property: Logout should handle empty storage gracefully', () async {
      // Test logout when no data exists (edge case)
      for (int i = 0; i < 10; i++) {
        // Ensure storage is empty
        await secureStorage.deleteAll();

        // Action: Perform logout on empty storage
        // Should not throw exception
        expect(
          () async => await authService.logout(),
          returnsNormally,
          reason: 'Logout should handle empty storage without errors (iteration $i)',
        );

        // Verify storage is still empty
        final token = await secureStorage.read(key: 'auth_token');
        final userData = await secureStorage.read(key: 'user_data');
        final savedPhone = await secureStorage.read(key: 'saved_phone');

        expect(token, isNull);
        expect(userData, isNull);
        expect(savedPhone, isNull);
      }
    });

    test('Property: Multiple consecutive logouts should be idempotent', () async {
      // Test that calling logout multiple times has the same effect as calling it once
      for (int i = 0; i < 20; i++) {
        // Setup: Store user data
        await secureStorage.write(key: 'auth_token', value: 'token_$i');
        await secureStorage.write(key: 'user_data', value: '{"id": "$i"}');
        await secureStorage.write(key: 'saved_phone', value: '081234567$i');

        // Action: Perform logout multiple times
        await authService.logout();
        await authService.logout();
        await authService.logout();

        // Verification: Data should still be cleared (idempotent)
        final token = await secureStorage.read(key: 'auth_token');
        final userData = await secureStorage.read(key: 'user_data');
        final savedPhone = await secureStorage.read(key: 'saved_phone');

        expect(
          token,
          isNull,
          reason: 'Token should remain cleared after multiple logouts (iteration $i)',
        );
        expect(
          userData,
          isNull,
          reason: 'User data should remain cleared after multiple logouts (iteration $i)',
        );
        expect(
          savedPhone,
          isNull,
          reason: 'Saved phone should remain cleared after multiple logouts (iteration $i)',
        );
      }
    });

    test('Property: Logout should clear data regardless of data size', () async {
      // Test with various data sizes to ensure property holds
      final dataSizes = [
        10, // Small
        100, // Medium
        1000, // Large
        10000, // Very large
      ];

      for (final size in dataSizes) {
        // Create data of varying sizes
        final largeUserData = '{"id": "1", "data": "${'x' * size}"}';
        final largeToken = 'token_${'y' * size}';

        await secureStorage.write(key: 'auth_token', value: largeToken);
        await secureStorage.write(key: 'user_data', value: largeUserData);
        await secureStorage.write(key: 'saved_phone', value: '08123456789');

        // Verify data exists
        final tokenBefore = await secureStorage.read(key: 'auth_token');
        expect(tokenBefore, isNotNull);
        expect(tokenBefore!.length, greaterThan(size));

        // Action: Logout
        await authService.logout();

        // Verification: All data cleared regardless of size
        final token = await secureStorage.read(key: 'auth_token');
        final userData = await secureStorage.read(key: 'user_data');
        final savedPhone = await secureStorage.read(key: 'saved_phone');

        expect(
          token,
          isNull,
          reason: 'Large token (size $size) should be cleared',
        );
        expect(
          userData,
          isNull,
          reason: 'Large user data (size $size) should be cleared',
        );
        expect(
          savedPhone,
          isNull,
          reason: 'Saved phone should be cleared',
        );
      }
    });
  });
}

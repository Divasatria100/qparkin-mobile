import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/utils/point_error_handler.dart';

void main() {
  group('PointErrorHandler', () {
    group('classifyError', () {
      test('should classify network errors correctly', () {
        expect(
          PointErrorHandler.classifyError('Network error occurred'),
          PointErrorHandler.errorCodeNetwork,
        );
        
        expect(
          PointErrorHandler.classifyError('Connection failed'),
          PointErrorHandler.errorCodeNetwork,
        );
        
        expect(
          PointErrorHandler.classifyError('Socket exception'),
          PointErrorHandler.errorCodeNetwork,
        );
      });

      test('should classify timeout errors correctly', () {
        expect(
          PointErrorHandler.classifyError('Timeout exception'),
          PointErrorHandler.errorCodeTimeout,
        );
        
        expect(
          PointErrorHandler.classifyError('Request timed out'),
          PointErrorHandler.errorCodeTimeout,
        );
      });

      test('should classify auth errors correctly', () {
        expect(
          PointErrorHandler.classifyError('Unauthorized access'),
          PointErrorHandler.errorCodeAuth,
        );
        
        expect(
          PointErrorHandler.classifyError('401 error'),
          PointErrorHandler.errorCodeAuth,
        );
      });

      test('should classify server errors correctly', () {
        expect(
          PointErrorHandler.classifyError('500 Internal Server Error'),
          PointErrorHandler.errorCodeServer,
        );
        
        expect(
          PointErrorHandler.classifyError('Server error occurred'),
          PointErrorHandler.errorCodeServer,
        );
      });

      test('should classify insufficient points errors correctly', () {
        expect(
          PointErrorHandler.classifyError('Insufficient points'),
          PointErrorHandler.errorCodeInsufficientPoints,
        );
        
        expect(
          PointErrorHandler.classifyError('Poin tidak cukup'),
          PointErrorHandler.errorCodeInsufficientPoints,
        );
      });
    });

    group('getUserFriendlyMessage', () {
      test('should return user-friendly message for network errors', () {
        final message = PointErrorHandler.getUserFriendlyMessage('Network error');
        expect(message, contains('koneksi'));
        expect(message, contains('server'));
      });

      test('should return user-friendly message for timeout errors', () {
        final message = PointErrorHandler.getUserFriendlyMessage('Timeout');
        expect(message, contains('lambat'));
      });

      test('should return user-friendly message for auth errors', () {
        final message = PointErrorHandler.getUserFriendlyMessage('Unauthorized');
        expect(message, contains('Sesi'));
        expect(message, contains('login'));
      });

      test('should return user-friendly message for server errors', () {
        final message = PointErrorHandler.getUserFriendlyMessage('500 error');
        expect(message, contains('Server'));
      });
    });

    group('requiresInternetMessage', () {
      test('should return true for network errors', () {
        expect(
          PointErrorHandler.requiresInternetMessage('Network error'),
          isTrue,
        );
      });

      test('should return true for timeout errors', () {
        expect(
          PointErrorHandler.requiresInternetMessage('Timeout'),
          isTrue,
        );
      });

      test('should return false for other errors', () {
        expect(
          PointErrorHandler.requiresInternetMessage('Validation error'),
          isFalse,
        );
      });
    });

    group('isRetryable', () {
      test('should return true for network errors', () {
        expect(
          PointErrorHandler.isRetryable('Network error'),
          isTrue,
        );
      });

      test('should return false for auth errors', () {
        expect(
          PointErrorHandler.isRetryable('Unauthorized'),
          isFalse,
        );
      });

      test('should return false for validation errors', () {
        expect(
          PointErrorHandler.isRetryable('Validation failed'),
          isFalse,
        );
      });

      test('should return false for insufficient points errors', () {
        expect(
          PointErrorHandler.isRetryable('Insufficient points'),
          isFalse,
        );
      });
    });

    group('getDetailedMessage', () {
      test('should include error code and timestamp', () {
        final message = PointErrorHandler.getDetailedMessage(
          'Network error',
          context: 'fetchBalance',
        );
        
        expect(message, contains('POINT_ERR'));
        expect(message, contains('Context: fetchBalance'));
        expect(message, contains('Network error'));
      });
    });
  });
}

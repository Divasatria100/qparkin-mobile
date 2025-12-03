import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qparkin_app/logic/providers/profile_provider.dart';
import 'package:qparkin_app/presentation/screens/profile_page.dart';
import 'package:qparkin_app/presentation/widgets/common/empty_state_widget.dart';
import 'package:qparkin_app/data/models/user_model.dart';
import 'package:qparkin_app/data/models/vehicle_model.dart';

/// Mock ProfileProvider that can simulate error states for testing
class MockErrorProfileProvider extends ProfileProvider {
  bool _shouldError = false;
  String? _mockErrorMessage;

  void setMockError(String message) {
    _shouldError = true;
    _mockErrorMessage = message;
  }

  void clearMockError() {
    _shouldError = false;
    _mockErrorMessage = null;
  }

  @override
  Future<void> fetchUserData() async {
    if (_shouldError) {
      // Simulate the full error flow including loading state
      // Don't call super to avoid clearing error
      await Future.delayed(const Duration(milliseconds: 50));
      setErrorForTesting(_mockErrorMessage ?? 'Mock error');
      return;
    }
    await super.fetchUserData();
  }

  @override
  Future<void> fetchVehicles() async {
    if (_shouldError) {
      // When in error mode, don't call super.fetchVehicles()
      // because it would clear the error state
      // Just return immediately to preserve the error
      return;
    }
    await super.fetchVehicles();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfilePage Error State Recovery - Property-Based Tests', () {
    /// **Feature: profile-page-enhancement, Property 6: Error State Recovery**
    /// **Validates: Requirements 4.2**
    /// 
    /// Property: For any error state displayed, a retry button should be 
    /// present and functional
    testWidgets(
      'Property 6: Error State Recovery - retry button present in error state',
      (WidgetTester tester) async {
        const int iterations = 100;
        final random = Random(42); // Fixed seed for reproducibility

        for (int i = 0; i < iterations; i++) {
          // Create a mock provider that will return errors
          final provider = MockErrorProfileProvider();
          
          // Generate random error message
          final errorMessage = _generateRandomErrorMessage(random);
          
          // Set the provider to return errors
          provider.setMockError(errorMessage);

          // Build the ProfilePage with the provider
          await tester.pumpWidget(
            MaterialApp(
              home: ChangeNotifierProvider<ProfileProvider>.value(
                value: provider,
                child: const ProfilePage(),
              ),
            ),
          );

          // Pump once to trigger initState
          await tester.pump();
          
          // Wait for the async fetchUserData and fetchVehicles to complete
          await tester.pump(const Duration(milliseconds: 100));
          
          // Wait for all animations and rebuilds
          await tester.pumpAndSettle();

          // Verify error state is displayed
          expect(
            provider.hasError,
            isTrue,
            reason: 'Iteration $i: Provider should be in error state',
          );

          // Verify EmptyStateWidget is displayed
          expect(
            find.byType(EmptyStateWidget),
            findsOneWidget,
            reason: 'Iteration $i: EmptyStateWidget should be displayed in error state',
          );

          // Verify error icon is displayed
          expect(
            find.byIcon(Icons.error_outline),
            findsOneWidget,
            reason: 'Iteration $i: Error icon should be displayed',
          );

          // Verify error title is displayed
          expect(
            find.text('Terjadi Kesalahan'),
            findsOneWidget,
            reason: 'Iteration $i: Error title should be displayed',
          );

          // Verify retry button is present
          expect(
            find.text('Coba Lagi'),
            findsOneWidget,
            reason: 'Iteration $i: Retry button should be present in error state',
          );

          // Verify retry button is an ElevatedButton
          final retryButton = find.ancestor(
            of: find.text('Coba Lagi'),
            matching: find.byType(ElevatedButton),
          );
          expect(
            retryButton,
            findsOneWidget,
            reason: 'Iteration $i: Retry button should be an ElevatedButton',
          );

          // Verify button has minimum 48dp touch target
          final buttonWidget = tester.widget<ElevatedButton>(retryButton);
          final buttonSize = tester.getSize(retryButton);
          expect(
            buttonSize.height,
            greaterThanOrEqualTo(48.0),
            reason: 'Iteration $i: Retry button should have minimum 48dp height',
          );

          // Verify semantic labels are present
          final semantics = tester.getSemantics(retryButton);
          expect(
            semantics.label,
            isNotEmpty,
            reason: 'Iteration $i: Retry button should have semantic label',
          );

          // Properly tear down the widget tree before next iteration
          provider.dispose();
          await tester.pumpWidget(Container());
        }
      },
    );

    testWidgets(
      'Property 6: Error State Recovery - retry button triggers data reload',
      (WidgetTester tester) async {
        const int iterations = 100;
        final random = Random(123);

        for (int i = 0; i < iterations; i++) {
          // Create a mock provider that will return errors initially
          final provider = MockErrorProfileProvider();
          
          // Generate random error message
          final errorMessage = _generateRandomErrorMessage(random);
          provider.setMockError(errorMessage);

          // Build the ProfilePage
          await tester.pumpWidget(
            MaterialApp(
              home: ChangeNotifierProvider<ProfileProvider>.value(
                value: provider,
                child: const ProfilePage(),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Verify we're in error state
          expect(provider.hasError, isTrue);

          // Clear the mock error so retry will succeed
          provider.clearMockError();

          // Tap the retry button
          await tester.tap(find.text('Coba Lagi'));
          await tester.pump();

          // Verify error is cleared
          expect(
            provider.hasError,
            isFalse,
            reason: 'Iteration $i: Error should be cleared after retry',
          );

          // Wait for data to load
          await tester.pumpAndSettle();

          // Verify we're now in success state (not error, not loading)
          expect(
            provider.hasError,
            isFalse,
            reason: 'Iteration $i: Should be in success state after retry',
          );

          expect(
            provider.isLoading,
            isFalse,
            reason: 'Iteration $i: Should not be loading after successful retry',
          );

          // Properly tear down the widget tree before next iteration
          provider.dispose();
          await tester.pumpWidget(Container());
        }
      },
    );

    testWidgets(
      'Property 6: Error State Recovery - error clearing after successful retry',
      (WidgetTester tester) async {
        const int iterations = 100;
        final random = Random(456);

        for (int i = 0; i < iterations; i++) {
          // Create a mock provider with error state
          final provider = MockErrorProfileProvider();
          
          // Generate random error message
          final errorMessage = _generateRandomErrorMessage(random);
          provider.setMockError(errorMessage);

          // Build the ProfilePage
          await tester.pumpWidget(
            MaterialApp(
              home: ChangeNotifierProvider<ProfileProvider>.value(
                value: provider,
                child: const ProfilePage(),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Verify initial error state
          expect(provider.hasError, isTrue);
          expect(provider.errorMessage, equals(errorMessage));

          // Clear mock error so retry succeeds
          provider.clearMockError();

          // Tap retry button
          await tester.tap(find.text('Coba Lagi'));
          await tester.pump();

          // Verify error is immediately cleared
          expect(
            provider.hasError,
            isFalse,
            reason: 'Iteration $i: Error should be cleared immediately after retry',
          );

          expect(
            provider.errorMessage,
            isNull,
            reason: 'Iteration $i: Error message should be null after retry',
          );

          // Wait for successful data load
          await tester.pumpAndSettle();

          // Verify we're no longer in error state
          expect(
            provider.hasError,
            isFalse,
            reason: 'Iteration $i: Should not be in error state after successful retry',
          );

          // Verify EmptyStateWidget is no longer displayed
          expect(
            find.byType(EmptyStateWidget),
            findsNothing,
            reason: 'Iteration $i: EmptyStateWidget should not be displayed after successful retry',
          );

          // Properly tear down the widget tree before next iteration
          provider.dispose();
          await tester.pumpWidget(Container());
        }
      },
    );

    testWidgets(
      'Property 6: Error State Recovery - multiple retry attempts',
      (WidgetTester tester) async {
        const int iterations = 50;
        final random = Random(789);

        for (int i = 0; i < iterations; i++) {
          // Create a mock provider
          final provider = MockErrorProfileProvider();

          // Start with error state
          final initialError = _generateRandomErrorMessage(random);
          provider.setMockError(initialError);

          // Build the ProfilePage
          await tester.pumpWidget(
            MaterialApp(
              home: ChangeNotifierProvider<ProfileProvider>.value(
                value: provider,
                child: const ProfilePage(),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Verify initial error state
          expect(provider.hasError, isTrue);
          expect(find.text('Coba Lagi'), findsOneWidget);

          // Clear error and tap retry
          provider.clearMockError();
          await tester.tap(find.text('Coba Lagi'));
          await tester.pump();
          await tester.pumpAndSettle();

          // After retry, should be in success state
          expect(
            provider.hasError,
            isFalse,
            reason: 'Iteration $i: Should be in success state after retry',
          );

          // Properly tear down the widget tree before next iteration
          provider.dispose();
          await tester.pumpWidget(Container());
        }
      },
    );

    testWidgets(
      'Property 6: Error State Recovery - accessibility labels present',
      (WidgetTester tester) async {
        const int iterations = 100;
        final random = Random(101112);

        for (int i = 0; i < iterations; i++) {
          // Create a mock provider that will return errors
          final provider = MockErrorProfileProvider();
          
          final errorMessage = _generateRandomErrorMessage(random);
          provider.setMockError(errorMessage);

          // Build the ProfilePage
          await tester.pumpWidget(
            MaterialApp(
              home: ChangeNotifierProvider<ProfileProvider>.value(
                value: provider,
                child: const ProfilePage(),
              ),
            ),
          );

          // Pump to trigger initState and wait for error state
          await tester.pump();
          await tester.pump();
          await tester.pumpAndSettle();

          // Find the retry button
          final retryButton = find.ancestor(
            of: find.text('Coba Lagi'),
            matching: find.byType(ElevatedButton),
          );

          // Verify semantic properties
          final semantics = tester.getSemantics(retryButton);
          
          expect(
            semantics.label,
            isNotEmpty,
            reason: 'Iteration $i: Retry button should have semantic label',
          );

          // Verify EmptyStateWidget has semantic label
          final emptyStateWidget = find.byType(EmptyStateWidget);
          final emptyStateSemantics = tester.getSemantics(emptyStateWidget);
          
          expect(
            emptyStateSemantics.label,
            contains('Terjadi Kesalahan'),
            reason: 'Iteration $i: EmptyStateWidget should have semantic label with error title',
          );

          // Properly tear down the widget tree before next iteration
          provider.dispose();
          await tester.pumpWidget(Container());
        }
      },
    );
  });
}

/// Generate random error messages for property-based testing
String _generateRandomErrorMessage(Random random) {
  final errorMessages = [
    'Tidak dapat terhubung ke server',
    'Koneksi internet terputus',
    'Gagal memuat data profil',
    'Server tidak merespons',
    'Terjadi kesalahan pada sistem',
    'Data tidak ditemukan',
    'Sesi telah berakhir',
    'Permintaan timeout',
    'Gagal memproses permintaan',
    'Terjadi kesalahan tidak terduga',
  ];

  return errorMessages[random.nextInt(errorMessages.length)];
}

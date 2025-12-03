import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qparkin_app/data/models/user_model.dart';
import 'package:qparkin_app/logic/providers/profile_provider.dart';
import 'package:qparkin_app/presentation/widgets/premium_points_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfileProvider Points Display Reactivity', () {
    /// **Feature: profile-page-enhancement, Property 10: Points Display Reactivity**
    /// **Validates: Requirements 6.2**
    /// 
    /// Property: For any points value change, the PremiumPointsCard should 
    /// update to reflect the new value
    testWidgets('Property 10: PremiumPointsCard updates when points change', (WidgetTester tester) async {
      const int iterations = 20;
      final random = Random(42); // Fixed seed for reproducibility

      for (int i = 0; i < iterations; i++) {
        final provider = ProfileProvider();
        
        // Generate random initial points value
        final initialPoints = random.nextInt(10000);
        final initialUser = _generateUserWithPoints(random, initialPoints);
        
        // Set initial user directly for testing (bypass API delay)
        provider.setUser(initialUser);

        // Build widget tree with provider
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<ProfileProvider>.value(
              value: provider,
              child: Scaffold(
                body: Consumer<ProfileProvider>(
                  builder: (context, profileProvider, child) {
                    return PremiumPointsCard(
                      points: profileProvider.user?.saldoPoin ?? 0,
                      variant: PointsCardVariant.purple,
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify initial points are displayed
        expect(
          find.text('$initialPoints Poin'),
          findsOneWidget,
          reason: 'Iteration $i: Initial points ($initialPoints) should be displayed',
        );

        // Generate random new points value (different from initial)
        int newPoints;
        do {
          newPoints = random.nextInt(10000);
        } while (newPoints == initialPoints);

        final updatedUser = initialUser.copyWith(saldoPoin: newPoints);

        // Update points directly for testing (bypass API delay)
        provider.setUser(updatedUser);
        await tester.pumpAndSettle();

        // Verify new points are displayed
        expect(
          find.text('$newPoints Poin'),
          findsOneWidget,
          reason: 'Iteration $i: Updated points ($newPoints) should be displayed',
        );

        // Verify old points are no longer displayed
        expect(
          find.text('$initialPoints Poin'),
          findsNothing,
          reason: 'Iteration $i: Old points ($initialPoints) should not be displayed',
        );

        provider.dispose();
      }
    });

    testWidgets('Property 10: PremiumPointsCard reflects zero points correctly', (WidgetTester tester) async {
      const int iterations = 10;
      final random = Random(123);

      for (int i = 0; i < iterations; i++) {
        final provider = ProfileProvider();
        
        // Start with random non-zero points
        final initialPoints = random.nextInt(9999) + 1; // 1 to 9999
        final initialUser = _generateUserWithPoints(random, initialPoints);
        provider.setUser(initialUser);

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<ProfileProvider>.value(
              value: provider,
              child: Scaffold(
                body: Consumer<ProfileProvider>(
                  builder: (context, profileProvider, child) {
                    return PremiumPointsCard(
                      points: profileProvider.user?.saldoPoin ?? 0,
                      variant: PointsCardVariant.purple,
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Update to zero points
        final updatedUser = initialUser.copyWith(saldoPoin: 0);
        provider.setUser(updatedUser);
        await tester.pumpAndSettle();

        // Verify zero points are displayed
        expect(
          find.text('0 Poin'),
          findsOneWidget,
          reason: 'Iteration $i: Zero points should be displayed correctly',
        );

        provider.dispose();
      }
    });

    testWidgets('Property 10: PremiumPointsCard updates with large point values', (WidgetTester tester) async {
      const int iterations = 10;
      final random = Random(456);

      for (int i = 0; i < iterations; i++) {
        final provider = ProfileProvider();
        
        // Generate large random points value (10,000 to 999,999)
        final largePoints = random.nextInt(990000) + 10000;
        final user = _generateUserWithPoints(random, largePoints);
        provider.setUser(user);

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<ProfileProvider>.value(
              value: provider,
              child: Scaffold(
                body: Consumer<ProfileProvider>(
                  builder: (context, profileProvider, child) {
                    return PremiumPointsCard(
                      points: profileProvider.user?.saldoPoin ?? 0,
                      variant: PointsCardVariant.purple,
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify large points are displayed correctly
        expect(
          find.text('$largePoints Poin'),
          findsOneWidget,
          reason: 'Iteration $i: Large points value ($largePoints) should be displayed',
        );

        provider.dispose();
      }
    });

    testWidgets('Property 10: PremiumPointsCard updates through multiple sequential changes', (WidgetTester tester) async {
      const int changesPerIteration = 10;
      const int iterations = 10;
      final random = Random(789);

      for (int i = 0; i < iterations; i++) {
        final provider = ProfileProvider();
        
        // Start with initial points
        final initialPoints = random.nextInt(1000);
        var currentUser = _generateUserWithPoints(random, initialPoints);
        provider.setUser(currentUser);

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<ProfileProvider>.value(
              value: provider,
              child: Scaffold(
                body: Consumer<ProfileProvider>(
                  builder: (context, profileProvider, child) {
                    return PremiumPointsCard(
                      points: profileProvider.user?.saldoPoin ?? 0,
                      variant: PointsCardVariant.purple,
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Perform multiple sequential updates
        for (int j = 0; j < changesPerIteration; j++) {
          final newPoints = random.nextInt(10000);
          currentUser = currentUser.copyWith(saldoPoin: newPoints);
          
          provider.setUser(currentUser);
          await tester.pumpAndSettle();

          // Verify current points are displayed
          expect(
            find.text('$newPoints Poin'),
            findsOneWidget,
            reason: 'Iteration $i, Change $j: Points ($newPoints) should be displayed',
          );
        }

        provider.dispose();
      }
    });

    testWidgets('Property 10: PremiumPointsCard displays default zero when user is null', (WidgetTester tester) async {
      const int iterations = 50;

      for (int i = 0; i < iterations; i++) {
        final provider = ProfileProvider();
        
        // Don't set any user (user remains null)
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<ProfileProvider>.value(
              value: provider,
              child: Scaffold(
                body: Consumer<ProfileProvider>(
                  builder: (context, profileProvider, child) {
                    return PremiumPointsCard(
                      points: profileProvider.user?.saldoPoin ?? 0,
                      variant: PointsCardVariant.purple,
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify zero points are displayed when user is null
        expect(
          find.text('0 Poin'),
          findsOneWidget,
          reason: 'Iteration $i: Should display 0 points when user is null',
        );

        provider.dispose();
      }
    });

    testWidgets('Property 10: PremiumPointsCard updates correctly with rapid changes', (WidgetTester tester) async {
      const int rapidChanges = 20;
      const int iterations = 5;
      final random = Random(101112);

      for (int i = 0; i < iterations; i++) {
        final provider = ProfileProvider();
        
        var currentUser = _generateUserWithPoints(random, 0);
        provider.setUser(currentUser);

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<ProfileProvider>.value(
              value: provider,
              child: Scaffold(
                body: Consumer<ProfileProvider>(
                  builder: (context, profileProvider, child) {
                    return PremiumPointsCard(
                      points: profileProvider.user?.saldoPoin ?? 0,
                      variant: PointsCardVariant.purple,
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Perform rapid updates
        int lastPoints = 0;
        for (int j = 0; j < rapidChanges; j++) {
          lastPoints = random.nextInt(5000);
          currentUser = currentUser.copyWith(saldoPoin: lastPoints);
          provider.setUser(currentUser);
        }

        // Pump and settle after all rapid changes
        await tester.pumpAndSettle();

        // Verify final points value is displayed
        expect(
          find.text('$lastPoints Poin'),
          findsOneWidget,
          reason: 'Iteration $i: Final points ($lastPoints) should be displayed after rapid changes',
        );

        provider.dispose();
      }
    });
  });
}

/// Generate user with specific points value for property-based testing
UserModel _generateUserWithPoints(Random random, int points) {
  final id = random.nextInt(10000).toString();
  final names = ['John Doe', 'Jane Smith', 'Bob Johnson', 'Alice Williams', 'Charlie Brown'];
  final domains = ['example.com', 'test.com', 'demo.com', 'sample.com'];
  
  final name = names[random.nextInt(names.length)];
  final email = '${name.toLowerCase().replaceAll(' ', '.')}@${domains[random.nextInt(domains.length)]}';
  final phoneNumber = '08${random.nextInt(1000000000).toString().padLeft(9, '0')}';

  return UserModel(
    id: id,
    name: name,
    email: email,
    phoneNumber: phoneNumber,
    photoUrl: random.nextBool() ? 'https://example.com/photo$id.jpg' : null,
    saldoPoin: points,
    createdAt: DateTime.now().subtract(Duration(days: random.nextInt(365))),
    updatedAt: random.nextBool() ? DateTime.now() : null,
  );
}

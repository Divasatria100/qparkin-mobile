import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/widgets/qr_exit_button.dart';

void main() {
  group('QRExitButton', () {
    testWidgets('displays button with correct text and icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QRExitButton(
              qrCode: 'QR123456',
              isEnabled: true,
            ),
          ),
        ),
      );

      expect(find.text('Tampilkan QR Keluar'), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_2), findsOneWidget);
    });

    testWidgets('is enabled when isEnabled is true', (WidgetTester tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QRExitButton(
              qrCode: 'QR123456',
              isEnabled: true,
              onPressed: () {
                buttonPressed = true;
              },
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      expect(button.onPressed, isNotNull);

      // Tap the button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(buttonPressed, true);
    });

    testWidgets('is disabled when isEnabled is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QRExitButton(
              qrCode: 'QR123456',
              isEnabled: false,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      expect(button.onPressed, isNull);
    });

    testWidgets('shows loading indicator when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QRExitButton(
              qrCode: 'QR123456',
              isEnabled: true,
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Tampilkan QR Keluar'), findsNothing);
    });

    testWidgets('is disabled when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QRExitButton(
              qrCode: 'QR123456',
              isEnabled: true,
              isLoading: true,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      expect(button.onPressed, isNull);
    });

    testWidgets('has purple background when enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QRExitButton(
              qrCode: 'QR123456',
              isEnabled: true,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      final backgroundColor = button.style?.backgroundColor?.resolve({WidgetState.pressed});
      expect(backgroundColor, const Color(0xFF573ED1));
    });

    testWidgets('has gray background when disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QRExitButton(
              qrCode: 'QR123456',
              isEnabled: false,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      final disabledBackgroundColor = button.style?.backgroundColor?.resolve({WidgetState.disabled});
      expect(disabledBackgroundColor, isNotNull);
    });

    testWidgets('has correct height (56px)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QRExitButton(
              qrCode: 'QR123456',
              isEnabled: true,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ElevatedButton),
          matching: find.byType(SizedBox),
        ).first,
      );

      expect(sizedBox.height, 56);
    });

    testWidgets('is full width', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QRExitButton(
              qrCode: 'QR123456',
              isEnabled: true,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ElevatedButton),
          matching: find.byType(SizedBox),
        ).first,
      );

      expect(sizedBox.width, double.infinity);
    });

    testWidgets('has proper semantic label for accessibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QRExitButton(
              qrCode: 'QR123456',
              isEnabled: true,
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(QRExitButton));
      expect(semantics.label, contains('Tombol tampilkan QR keluar'));
    });

    testWidgets('has proper semantic label when disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QRExitButton(
              qrCode: 'QR123456',
              isEnabled: false,
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(QRExitButton));
      expect(semantics.label, contains('tidak tersedia'));
    });

    testWidgets('has proper semantic label when loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QRExitButton(
              qrCode: 'QR123456',
              isEnabled: true,
              isLoading: true,
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(QRExitButton));
      expect(semantics.label, contains('Memuat'));
    });

    testWidgets('calls onPressed callback when tapped', (WidgetTester tester) async {
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QRExitButton(
              qrCode: 'QR123456',
              isEnabled: true,
              onPressed: () {
                callbackCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(callbackCalled, true);
    });

    testWidgets('does not call onPressed when disabled', (WidgetTester tester) async {
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QRExitButton(
              qrCode: 'QR123456',
              isEnabled: false,
              onPressed: () {
                callbackCalled = true;
              },
            ),
          ),
        ),
      );

      // Try to tap the button
      await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
      await tester.pump();

      expect(callbackCalled, false);
    });

    testWidgets('has rounded corners (12px radius)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QRExitButton(
              qrCode: 'QR123456',
              isEnabled: true,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      final shape = button.style?.shape?.resolve({});
      expect(shape, isA<RoundedRectangleBorder>());
      
      final roundedShape = shape as RoundedRectangleBorder;
      expect(roundedShape.borderRadius, BorderRadius.circular(12));
    });

    testWidgets('has elevation when enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QRExitButton(
              qrCode: 'QR123456',
              isEnabled: true,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      final elevation = button.style?.elevation?.resolve({});
      expect(elevation, 4);
    });

    testWidgets('has no elevation when disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QRExitButton(
              qrCode: 'QR123456',
              isEnabled: false,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      final elevation = button.style?.elevation?.resolve({WidgetState.disabled});
      expect(elevation, 0);
    });
  });
}

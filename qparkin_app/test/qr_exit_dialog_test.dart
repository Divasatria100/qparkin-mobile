import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/dialogs/qr_exit_dialog.dart';

void main() {
  group('QRExitDialog', () {
    testWidgets('displays QR code with all information', (WidgetTester tester) async {
      // Build the dialog
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  QRExitDialog.show(
                    context,
                    qrCode: 'TEST_QR_CODE_12345',
                    mallName: 'Test Mall',
                    slotCode: 'A-123',
                  );
                },
                child: const Text('Show QR'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to show dialog
      await tester.tap(find.text('Show QR'));
      await tester.pumpAndSettle();

      // Verify dialog is displayed with all elements
      expect(find.text('QR Keluar'), findsOneWidget);
      expect(find.text('Tunjukkan QR code ini di gerbang keluar'), findsOneWidget);
      expect(find.text('Test Mall'), findsOneWidget);
      expect(find.text('Slot: A-123'), findsOneWidget);
      expect(find.text('Tutup'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.byIcon(Icons.local_parking), findsOneWidget);
    });

    testWidgets('displays without optional parameters', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  QRExitDialog.show(
                    context,
                    qrCode: 'TEST_QR_CODE',
                  );
                },
                child: const Text('Show QR'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show QR'));
      await tester.pumpAndSettle();

      expect(find.text('QR Keluar'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsNothing);
      expect(find.byIcon(Icons.local_parking), findsNothing);
    });

    testWidgets('QR code widget is rendered', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  QRExitDialog.show(
                    context,
                    qrCode: 'TEST_QR_CODE',
                  );
                },
                child: const Text('Show QR'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show QR'));
      await tester.pumpAndSettle();

      // Verify QR code widget is present
      expect(find.text('QR Keluar'), findsOneWidget);
      expect(find.byType(QRExitDialog), findsOneWidget);
    });
  });
}

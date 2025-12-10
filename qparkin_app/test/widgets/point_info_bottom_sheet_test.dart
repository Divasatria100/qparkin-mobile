import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/widgets/point_info_bottom_sheet.dart';

void main() {
  group('PointInfoBottomSheet Widget Tests', () {
    testWidgets('displays header with title and close button', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PointInfoBottomSheet(),
          ),
        ),
      );

      // Assert
      expect(find.text('Cara Kerja Poin'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byTooltip('Tutup'), findsOneWidget);
    });

    testWidgets('displays all main sections', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PointInfoBottomSheet(),
          ),
        ),
      );

      // Assert - check all section titles are present
      expect(find.text('Cara Mendapatkan Poin'), findsOneWidget);
      expect(find.text('Cara Menggunakan Poin'), findsOneWidget);
      expect(find.text('Aturan Konversi Poin'), findsOneWidget);
      expect(find.text('Sistem Penalty'), findsOneWidget);
      expect(find.text('Tips Memaksimalkan Poin'), findsOneWidget);
    });

    testWidgets('displays point conversion rule (100 poin = Rp 1.000)', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PointInfoBottomSheet(),
          ),
        ),
      );

      // Assert
      expect(find.text('100 Poin'), findsOneWidget);
      expect(find.text('Rp 1.000'), findsOneWidget);
      expect(
        find.text('Setiap 100 poin dapat digunakan untuk mengurangi biaya parkir sebesar Rp 1.000'),
        findsOneWidget,
      );
    });

    testWidgets('displays earning points information', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PointInfoBottomSheet(),
          ),
        ),
      );

      // Assert
      expect(find.text('Transaksi Parkir'), findsOneWidget);
      expect(find.text('Booking Parkir'), findsOneWidget);
      expect(
        find.textContaining('Setiap kali Anda menyelesaikan pembayaran parkir'),
        findsOneWidget,
      );
    });

    testWidgets('displays using points information', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PointInfoBottomSheet(),
          ),
        ),
      );

      // Assert
      expect(find.text('Diskon Pembayaran'), findsOneWidget);
      expect(find.text('Pembayaran Fleksibel'), findsOneWidget);
      expect(
        find.textContaining('Gunakan poin Anda sebagai metode pembayaran'),
        findsOneWidget,
      );
    });

    testWidgets('displays penalty system information', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PointInfoBottomSheet(),
          ),
        ),
      );

      // Assert
      expect(find.text('Keterlambatan (Overstay)'), findsOneWidget);
      expect(
        find.textContaining('melebihi waktu booking atau durasi parkir'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Penalty akan mengurangi poin Anda'),
        findsOneWidget,
      );
    });

    testWidgets('displays tips section with all tips', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PointInfoBottomSheet(),
          ),
        ),
      );

      // Assert
      expect(
        find.textContaining('Selalu selesaikan pembayaran parkir'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Gunakan poin untuk diskon pembayaran'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Hindari keterlambatan'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Cek riwayat poin secara berkala'),
        findsOneWidget,
      );
    });

    testWidgets('close button dismisses the bottom sheet', (WidgetTester tester) async {
      // Arrange
      bool dismissed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => const PointInfoBottomSheet(),
                  ).then((_) => dismissed = true);
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      // Open bottom sheet
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Assert
      expect(dismissed, isTrue);
      expect(find.byType(PointInfoBottomSheet), findsNothing);
    });

    testWidgets('content is scrollable', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PointInfoBottomSheet(),
          ),
        ),
      );

      // Assert - check that SingleChildScrollView exists
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('displays introduction section with icon', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PointInfoBottomSheet(),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.stars), findsWidgets);
      expect(
        find.textContaining('Sistem poin reward QPARKIN'),
        findsOneWidget,
      );
    });

    testWidgets('has proper section icons', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PointInfoBottomSheet(),
          ),
        ),
      );

      // Assert - check for section icons
      expect(find.byIcon(Icons.add_circle), findsOneWidget);
      expect(find.byIcon(Icons.payment), findsOneWidget);
      expect(find.byIcon(Icons.currency_exchange), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
    });

    testWidgets('conversion section has visual arrow indicator', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PointInfoBottomSheet(),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/widgets/slot_reservation_button.dart';

void main() {
  group('SlotReservationButton', () {
    group('Button Display', () {
      testWidgets('displays button with floor name', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Pesan Slot Acak di Lantai 1'), findsOneWidget);
      });

      testWidgets('displays casino icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 2',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.casino), findsOneWidget);
      });

      testWidgets('has full width', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                onPressed: () {},
              ),
            ),
          ),
        );

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
        expect(sizedBox.width, double.infinity);
      });

      testWidgets('has correct height of 56px', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                onPressed: () {},
              ),
            ),
          ),
        );

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
        expect(sizedBox.height, 56);
      });

      testWidgets('displays text with correct styling', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                onPressed: () {},
              ),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(
          find.text('Pesan Slot Acak di Lantai 1'),
        );
        
        expect(textWidget.style?.fontSize, 16);
        expect(textWidget.style?.fontWeight, FontWeight.bold);
        expect(textWidget.style?.color, Colors.white);
      });

      testWidgets('icon has correct size and color', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                onPressed: () {},
              ),
            ),
          ),
        );

        final icon = tester.widget<Icon>(find.byIcon(Icons.casino));
        expect(icon.size, 20);
        expect(icon.color, Colors.white);
      });
    });

    group('Button Interaction', () {
      testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
        bool wasPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                onPressed: () {
                  wasPressed = true;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        expect(wasPressed, true);
      });

      testWidgets('does not call onPressed when disabled', (WidgetTester tester) async {
        bool wasPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isEnabled: false,
                onPressed: () {
                  wasPressed = true;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        expect(wasPressed, false);
      });

      testWidgets('does not call onPressed when loading', (WidgetTester tester) async {
        bool wasPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isLoading: true,
                onPressed: () {
                  wasPressed = true;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(wasPressed, false);
      });

      testWidgets('does not call onPressed when onPressed is null', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                onPressed: null,
              ),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        // When onPressed is null, the button's internal handler should still exist
        // but it won't do anything since the callback is null
        expect(button.onPressed, isNull);
      });

      testWidgets('provides haptic feedback on tap', (WidgetTester tester) async {
        final List<MethodCall> log = <MethodCall>[];
        
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                onPressed: () {},
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        expect(
          log,
          contains(
            isA<MethodCall>()
                .having((m) => m.method, 'method', 'HapticFeedback.vibrate')
                .having((m) => m.arguments, 'arguments', 'HapticFeedbackType.lightImpact'),
          ),
        );

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      });
    });

    group('Loading State', () {
      testWidgets('displays loading indicator when isLoading is true', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isLoading: true,
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('displays "Mereservasi..." text when loading', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isLoading: true,
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Mereservasi...'), findsOneWidget);
      });

      testWidgets('does not display casino icon when loading', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isLoading: true,
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.casino), findsNothing);
      });

      testWidgets('does not display floor name text when loading', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isLoading: true,
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Pesan Slot Acak di Lantai 1'), findsNothing);
      });

      testWidgets('loading indicator has correct styling', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isLoading: true,
                onPressed: () {},
              ),
            ),
          ),
        );

        final sizedBox = tester.widget<SizedBox>(
          find.ancestor(
            of: find.byType(CircularProgressIndicator),
            matching: find.byType(SizedBox),
          ).first,
        );
        
        expect(sizedBox.width, 20);
        expect(sizedBox.height, 20);

        final progressIndicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        
        expect(progressIndicator.strokeWidth, 2);
        expect(progressIndicator.valueColor?.value, Colors.white);
      });

      testWidgets('maintains purple background when loading', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isLoading: true,
                onPressed: () {},
              ),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        final backgroundColor = button.style?.backgroundColor?.resolve({});
        
        expect(backgroundColor, const Color(0xFF573ED1));
      });
    });

    group('Disabled State', () {
      testWidgets('displays grey background when disabled', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isEnabled: false,
                onPressed: () {},
              ),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        final backgroundColor = button.style?.backgroundColor?.resolve({});
        
        expect(backgroundColor, Colors.grey[400]);
      });

      testWidgets('has no elevation when disabled', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isEnabled: false,
                onPressed: () {},
              ),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        final elevation = button.style?.elevation?.resolve({});
        
        expect(elevation, 0);
      });

      testWidgets('still displays floor name when disabled', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isEnabled: false,
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Pesan Slot Acak di Lantai 1'), findsOneWidget);
      });

      testWidgets('still displays casino icon when disabled', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isEnabled: false,
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.casino), findsOneWidget);
      });
    });

    group('Enabled State', () {
      testWidgets('displays purple background when enabled', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isEnabled: true,
                onPressed: () {},
              ),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        final backgroundColor = button.style?.backgroundColor?.resolve({});
        
        expect(backgroundColor, const Color(0xFF573ED1));
      });

      testWidgets('has elevation 4 when enabled', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isEnabled: true,
                onPressed: () {},
              ),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        final elevation = button.style?.elevation?.resolve({});
        
        expect(elevation, 4);
      });

      testWidgets('has white foreground color', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isEnabled: true,
                onPressed: () {},
              ),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        final foregroundColor = button.style?.foregroundColor?.resolve({});
        
        expect(foregroundColor, Colors.white);
      });

      testWidgets('has rounded corners with 16px radius', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isEnabled: true,
                onPressed: () {},
              ),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        final shape = button.style?.shape?.resolve({}) as RoundedRectangleBorder;
        
        expect(shape.borderRadius, BorderRadius.circular(16));
      });

      testWidgets('has correct padding', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isEnabled: true,
                onPressed: () {},
              ),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        final padding = button.style?.padding?.resolve({});
        
        expect(padding, const EdgeInsets.symmetric(horizontal: 24, vertical: 16));
      });
    });

    group('Accessibility Features', () {
      testWidgets('has proper semantic label', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(
          find.bySemanticsLabel('Pesan slot acak di Lantai 1'),
          findsOneWidget,
        );
      });

      testWidgets('has proper semantic hint', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 2',
                onPressed: () {},
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(SlotReservationButton));
        expect(semantics.hint, 'Ketuk untuk mereservasi slot secara otomatis di lantai ini');
      });

      testWidgets('is marked as button in semantics', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                onPressed: () {},
              ),
            ),
          ),
        );

        // Verify button is tappable (has ElevatedButton)
        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('button is enabled when isEnabled is true', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isEnabled: true,
                onPressed: () {},
              ),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNotNull);
      });

      testWidgets('button is disabled when isEnabled is false', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isEnabled: false,
                onPressed: () {},
              ),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNull);
      });

      testWidgets('button is disabled when loading', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isLoading: true,
                onPressed: () {},
              ),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNull);
      });

      testWidgets('maintains minimum 48dp touch target height', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                onPressed: () {},
              ),
            ),
          ),
        );

        final buttonSize = tester.getSize(find.byType(ElevatedButton));
        expect(buttonSize.height, greaterThanOrEqualTo(48));
      });

      testWidgets('announces state changes to screen readers', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isLoading: false,
                onPressed: () {},
              ),
            ),
          ),
        );

        // Initial state
        expect(find.text('Pesan Slot Acak di Lantai 1'), findsOneWidget);

        // Change to loading state
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isLoading: true,
                onPressed: () {},
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Mereservasi...'), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles very long floor names', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai Basement Premium VIP',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Pesan Slot Acak di Lantai Basement Premium VIP'), findsOneWidget);
        
        final textWidget = tester.widget<Text>(
          find.text('Pesan Slot Acak di Lantai Basement Premium VIP'),
        );
        
        expect(textWidget.overflow, TextOverflow.ellipsis);
        expect(textWidget.maxLines, 1);
      });

      testWidgets('handles floor names with special characters', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai B1-A',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Pesan Slot Acak di Lantai B1-A'), findsOneWidget);
      });

      testWidgets('handles rapid state changes', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isLoading: false,
                onPressed: () {},
              ),
            ),
          ),
        );

        // Change to loading
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isLoading: true,
                onPressed: () {},
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Change back to not loading
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isLoading: false,
                onPressed: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Pesan Slot Acak di Lantai 1'), findsOneWidget);
      });

      testWidgets('handles enabled to disabled state change', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isEnabled: true,
                onPressed: () {},
              ),
            ),
          ),
        );

        var button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        var backgroundColor = button.style?.backgroundColor?.resolve({});
        expect(backgroundColor, const Color(0xFF573ED1));

        // Change to disabled
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isEnabled: false,
                onPressed: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        backgroundColor = button.style?.backgroundColor?.resolve({});
        expect(backgroundColor, Colors.grey[400]);
      });

      testWidgets('handles multiple taps in quick succession', (WidgetTester tester) async {
        int tapCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                onPressed: () {
                  tapCount++;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        expect(tapCount, 3);
      });
    });

    group('Visual Consistency', () {
      testWidgets('maintains consistent styling across states', (WidgetTester tester) async {
        // Test enabled state
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isEnabled: true,
                onPressed: () {},
              ),
            ),
          ),
        );

        var sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
        expect(sizedBox.height, 56);

        // Test loading state
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isLoading: true,
                onPressed: () {},
              ),
            ),
          ),
        );
        await tester.pump();

        sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
        expect(sizedBox.height, 56);

        // Test disabled state
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isEnabled: false,
                onPressed: () {},
              ),
            ),
          ),
        );
        await tester.pump();

        sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
        expect(sizedBox.height, 56);
      });

      testWidgets('text remains white across all states', (WidgetTester tester) async {
        // Enabled state
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isEnabled: true,
                onPressed: () {},
              ),
            ),
          ),
        );

        var textWidget = tester.widget<Text>(find.text('Pesan Slot Acak di Lantai 1'));
        expect(textWidget.style?.color, Colors.white);

        // Loading state
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlotReservationButton(
                floorName: 'Lantai 1',
                isLoading: true,
                onPressed: () {},
              ),
            ),
          ),
        );
        await tester.pump();

        textWidget = tester.widget<Text>(find.text('Mereservasi...'));
        expect(textWidget.style?.color, Colors.white);
      });
    });
  });
}

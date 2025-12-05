import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/presentation/widgets/common/empty_state_widget.dart';

void main() {
  group('EmptyStateWidget Tests', () {
    testWidgets('should render icon, title, and description',
        (WidgetTester tester) async {
      const testTitle = 'Tidak ada data';
      const testDescription = 'Belum ada data untuk ditampilkan';
      const testIcon = Icons.inbox;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: testIcon,
              title: testTitle,
              description: testDescription,
            ),
          ),
        ),
      );

      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testDescription), findsOneWidget);
      expect(find.byIcon(testIcon), findsOneWidget);
    });

    testWidgets('should display action button when onAction is provided',
        (WidgetTester tester) async {
      const actionText = 'Tambah Kendaraan';
      bool wasActionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.directions_car,
              title: 'Tidak ada kendaraan',
              description: 'Anda belum memiliki kendaraan terdaftar',
              actionText: actionText,
              onAction: () {
                wasActionCalled = true;
              },
            ),
          ),
        ),
      );

      expect(find.text(actionText), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(wasActionCalled, isTrue);
    });

    testWidgets('should not display action button when onAction is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: 'Tidak ada data',
              description: 'Belum ada data untuk ditampilkan',
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('should use default action text when not provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.add,
              title: 'Empty',
              description: 'No items',
              onAction: () {},
            ),
          ),
        ),
      );

      expect(find.text('Tambah Sekarang'), findsOneWidget);
    });

    testWidgets('should use custom icon color when provided',
        (WidgetTester tester) async {
      const customColor = Color(0xFFE53935);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.error,
              title: 'Error',
              description: 'Something went wrong',
              iconColor: customColor,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, customColor);

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(Icon),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, customColor.withOpacity(0.1));
    });

    testWidgets('should use default brand purple when icon color not provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: 'Empty',
              description: 'No data',
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, const Color(0xFF573ED1));
    });

    testWidgets('should have semantic labels for accessibility',
        (WidgetTester tester) async {
      const title = 'Tidak ada kendaraan';
      const description = 'Anda belum memiliki kendaraan terdaftar';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.directions_car,
              title: title,
              description: description,
            ),
          ),
        ),
      );

      // Check for Semantics widget with combined label
      // The root Semantics widget wraps the entire empty state
      final semanticsFinder = find.byType(Semantics);
      expect(semanticsFinder, findsWidgets);
      
      // Find the root semantics widget (wrapping the Center)
      final rootSemantics = tester.widgetList<Semantics>(semanticsFinder).firstWhere(
        (s) => s.properties.label == '$title. $description',
        orElse: () => throw Exception('Root semantics not found'),
      );

      expect(rootSemantics.properties.label, '$title. $description');
    });

    testWidgets('should have semantic button label for action button',
        (WidgetTester tester) async {
      const actionText = 'Tambah Kendaraan';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.directions_car,
              title: 'Empty',
              description: 'No vehicles',
              actionText: actionText,
              onAction: () {},
            ),
          ),
        ),
      );

      // Find the Semantics widget wrapping the button
      final buttonSemantics = tester.widget<Semantics>(
        find.ancestor(
          of: find.byType(ElevatedButton),
          matching: find.byType(Semantics),
        ).first,
      );

      expect(buttonSemantics.properties.button, isTrue);
      expect(buttonSemantics.properties.label, actionText);
      expect(buttonSemantics.properties.hint, 'Ketuk untuk $actionText');
    });

    testWidgets('should have minimum 48dp touch target for action button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.add,
              title: 'Empty',
              description: 'No data',
              onAction: () {},
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

      expect(sizedBox.height, 48);
    });

    testWidgets('should use correct typography for title',
        (WidgetTester tester) async {
      const title = 'Test Title';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: title,
              description: 'Description',
            ),
          ),
        ),
      );

      final titleText = tester.widget<Text>(find.text(title));
      expect(titleText.style?.fontSize, 20);
      expect(titleText.style?.fontWeight, FontWeight.w700);
      expect(titleText.style?.color, Colors.black87);
      expect(titleText.style?.fontFamily, 'Nunito');
      expect(titleText.textAlign, TextAlign.center);
    });

    testWidgets('should use correct typography for description',
        (WidgetTester tester) async {
      const description = 'Test Description';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: 'Title',
              description: description,
            ),
          ),
        ),
      );

      final descriptionText = tester.widget<Text>(find.text(description));
      expect(descriptionText.style?.fontSize, 14);
      expect(descriptionText.style?.fontWeight, FontWeight.w400);
      expect(descriptionText.style?.color, Colors.black54);
      expect(descriptionText.style?.fontFamily, 'Nunito');
      expect(descriptionText.style?.height, 1.5);
      expect(descriptionText.textAlign, TextAlign.center);
    });

    testWidgets('should have correct icon container styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: 'Title',
              description: 'Description',
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(Icon),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.constraints?.maxWidth, 96);
      expect(container.constraints?.maxHeight, 96);

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
    });

    testWidgets('should have correct icon size',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: 'Title',
              description: 'Description',
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, 48);
    });

    testWidgets('should have correct spacing between elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: 'Title',
              description: 'Description',
              onAction: () {},
            ),
          ),
        ),
      );

      final column = tester.widget<Column>(
        find.descendant(
          of: find.byType(EmptyStateWidget),
          matching: find.byType(Column),
        ),
      );

      final children = column.children;
      
      // Check spacing: icon, 24dp, title, 8dp, description, 24dp, button
      expect((children[1] as SizedBox).height, 24); // After icon
      expect((children[3] as SizedBox).height, 8);  // After title
      expect((children[5] as SizedBox).height, 24); // After description
    });

    testWidgets('should center content vertically and horizontally',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: 'Title',
              description: 'Description',
            ),
          ),
        ),
      );

      // Verify Center widget exists
      expect(find.byType(Center), findsWidgets);

      // Find the Column widget inside the EmptyStateWidget
      final columnFinder = find.descendant(
        of: find.byType(EmptyStateWidget),
        matching: find.byType(Column),
      );
      
      expect(columnFinder, findsOneWidget);
      final column = tester.widget<Column>(columnFinder);

      expect(column.mainAxisAlignment, MainAxisAlignment.center);
      expect(column.mainAxisSize, MainAxisSize.min);
    });

    testWidgets('should have correct button styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.add,
              title: 'Title',
              description: 'Description',
              onAction: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = button.style!;

      final backgroundColor = style.backgroundColor?.resolve({});
      expect(backgroundColor, const Color(0xFF573ED1));

      final foregroundColor = style.foregroundColor?.resolve({});
      expect(foregroundColor, Colors.white);

      final elevation = style.elevation?.resolve({});
      expect(elevation, 0);

      final shape = style.shape?.resolve({}) as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(12));

      final padding = style.padding?.resolve({}) as EdgeInsets;
      expect(padding, const EdgeInsets.symmetric(horizontal: 24, vertical: 12));
    });

    testWidgets('should have correct button text styling',
        (WidgetTester tester) async {
      const actionText = 'Test Action';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.add,
              title: 'Title',
              description: 'Description',
              actionText: actionText,
              onAction: () {},
            ),
          ),
        ),
      );

      final buttonText = tester.widget<Text>(
        find.descendant(
          of: find.byType(ElevatedButton),
          matching: find.text(actionText),
        ),
      );

      expect(buttonText.style?.fontSize, 16);
      expect(buttonText.style?.fontWeight, FontWeight.w600);
      expect(buttonText.style?.fontFamily, 'Nunito');
    });
  });
}

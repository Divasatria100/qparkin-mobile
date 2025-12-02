import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qparkin_app/presentation/screens/edit_profile_page.dart';
import 'package:qparkin_app/logic/providers/profile_provider.dart';
import 'package:qparkin_app/data/models/user_model.dart';
import 'dart:math';

/// **Feature: profile-page-enhancement, Property 11: Form Validation**
/// **Validates: Requirements 7.4**
/// 
/// Property-based test for EditProfilePage form validation
/// Tests that all fields are validated before submission
/// Generates random valid and invalid inputs
/// Verifies validation errors are displayed correctly
void main() {
  group('Property 11: Form Validation', () {
    late ProfileProvider provider;

    setUp(() {
      provider = ProfileProvider();
      // Set initial user data
      provider.setUser(UserModel(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        phoneNumber: '081234567890',
        saldoPoin: 100,
        createdAt: DateTime.now(),
      ));
    });

    /// Helper function to create test widget
    Widget createTestWidget() {
      return ChangeNotifierProvider<ProfileProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: EditProfilePage(),
        ),
      );
    }

    /// Generate random valid name
    String generateValidName() {
      final random = Random();
      final names = [
        'John Doe',
        'Jane Smith',
        'Ahmad Rizki',
        'Siti Nurhaliza',
        'Budi Santoso',
        'Maria Garcia',
        'Chen Wei',
        'Yuki Tanaka',
      ];
      return names[random.nextInt(names.length)];
    }

    /// Generate random invalid name (empty or whitespace)
    String generateInvalidName() {
      final random = Random();
      final invalidNames = ['', '   ', '\t', '\n', '  \t  '];
      return invalidNames[random.nextInt(invalidNames.length)];
    }

    /// Generate random valid email
    String generateValidEmail() {
      final random = Random();
      final domains = ['gmail.com', 'yahoo.com', 'outlook.com', 'example.com'];
      final usernames = ['user', 'test', 'john', 'jane', 'admin'];
      
      final username = usernames[random.nextInt(usernames.length)];
      final domain = domains[random.nextInt(domains.length)];
      final number = random.nextInt(1000);
      
      return '$username$number@$domain';
    }

    /// Generate random invalid email
    String generateInvalidEmail() {
      final random = Random();
      final invalidEmails = [
        '',
        '   ',
        'notanemail',
        'missing@domain',
        '@nodomain.com',
        'no@domain',
        'spaces in@email.com',
        'double@@domain.com',
        'nodot@domaincom',
      ];
      return invalidEmails[random.nextInt(invalidEmails.length)];
    }

    /// Generate random valid phone number
    String generateValidPhone() {
      final random = Random();
      // Generate Indonesian phone numbers
      final prefixes = ['081', '082', '083', '085', '087', '088', '089'];
      final prefix = prefixes[random.nextInt(prefixes.length)];
      final suffix = random.nextInt(100000000).toString().padLeft(8, '0');
      return '$prefix$suffix';
    }

    /// Generate random invalid phone number
    String generateInvalidPhone() {
      final random = Random();
      final invalidPhones = [
        '123', // Too short
        '12345678901234567890', // Too long
        'abcdefghij', // Non-numeric
        '081-234-567', // With dashes (less than minimum)
      ];
      return invalidPhones[random.nextInt(invalidPhones.length)];
    }

    testWidgets(
      'Property: Valid inputs should pass validation',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Test with 100 different valid input combinations
        for (int i = 0; i < 100; i++) {
          // Generate random valid inputs
          final validName = generateValidName();
          final validEmail = generateValidEmail();
          final validPhone = generateValidPhone();

          // Find form fields by key or type
          final textFields = find.byType(TextFormField);
          expect(textFields, findsNWidgets(3), 
            reason: 'Should find 3 text fields (iteration $i)');

          // Enter valid data
          await tester.enterText(textFields.at(0), validName);
          await tester.pump();
          await tester.enterText(textFields.at(1), validEmail);
          await tester.pump();
          await tester.enterText(textFields.at(2), validPhone);
          await tester.pump();

          // Get the form state and validate
          final formFinder = find.byType(Form);
          expect(formFinder, findsOneWidget);
          final formState = tester.state<FormState>(formFinder);
          
          // Validate the form
          final isValid = formState.validate();
          
          // Verify validation passes for valid inputs
          expect(isValid, isTrue,
            reason: 'Form should be valid for inputs: name="$validName", email="$validEmail", phone="$validPhone" (iteration $i)');

          // Verify no validation error messages are shown
          await tester.pump();
          expect(find.text('Nama wajib diisi'), findsNothing,
            reason: 'Should not show name error for valid input (iteration $i)');
          expect(find.text('Email wajib diisi'), findsNothing,
            reason: 'Should not show email required error (iteration $i)');
          expect(find.text('Format email tidak valid'), findsNothing,
            reason: 'Should not show email format error for valid input (iteration $i)');
        }
      },
    );

    testWidgets(
      'Property: Invalid name should show validation error',
      (WidgetTester tester) async {
        // Run 50 iterations with random invalid names
        for (int i = 0; i < 50; i++) {
          final invalidName = generateInvalidName();
          final validEmail = generateValidEmail();

          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          // Find form fields
          final nameFinder = find.byType(TextFormField).at(0);
          final emailFinder = find.byType(TextFormField).at(1);

          // Enter invalid name and valid email
          await tester.enterText(nameFinder, invalidName);
          await tester.enterText(emailFinder, validEmail);
          await tester.pumpAndSettle();

          // Tap save button to trigger validation
          final saveButton = find.widgetWithText(ElevatedButton, 'Simpan Perubahan');
          await tester.tap(saveButton);
          await tester.pumpAndSettle();

          // Verify validation error is shown
          expect(find.text('Nama wajib diisi'), findsOneWidget,
            reason: 'Should show name validation error for invalid input (iteration $i)');
        }
      },
    );

    testWidgets(
      'Property: Invalid email should show validation error',
      (WidgetTester tester) async {
        // Run 50 iterations with random invalid emails
        for (int i = 0; i < 50; i++) {
          final validName = generateValidName();
          final invalidEmail = generateInvalidEmail();

          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          // Find form fields
          final nameFinder = find.byType(TextFormField).at(0);
          final emailFinder = find.byType(TextFormField).at(1);

          // Enter valid name and invalid email
          await tester.enterText(nameFinder, validName);
          await tester.enterText(emailFinder, invalidEmail);
          await tester.pumpAndSettle();

          // Tap save button to trigger validation
          final saveButton = find.widgetWithText(ElevatedButton, 'Simpan Perubahan');
          await tester.tap(saveButton);
          await tester.pumpAndSettle();

          // Verify validation error is shown (either required or format error)
          final hasRequiredError = find.text('Email wajib diisi').evaluate().isNotEmpty;
          final hasFormatError = find.text('Format email tidak valid').evaluate().isNotEmpty;
          
          expect(hasRequiredError || hasFormatError, isTrue,
            reason: 'Should show email validation error for invalid input "$invalidEmail" (iteration $i)');
        }
      },
    );

    testWidgets(
      'Property: Invalid phone should show validation error',
      (WidgetTester tester) async {
        // Run 50 iterations with random invalid phone numbers
        for (int i = 0; i < 50; i++) {
          final validName = generateValidName();
          final validEmail = generateValidEmail();
          final invalidPhone = generateInvalidPhone();

          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          // Find form fields
          final nameFinder = find.byType(TextFormField).at(0);
          final emailFinder = find.byType(TextFormField).at(1);
          final phoneFinder = find.byType(TextFormField).at(2);

          // Enter valid name, email and invalid phone
          await tester.enterText(nameFinder, validName);
          await tester.enterText(emailFinder, validEmail);
          await tester.enterText(phoneFinder, invalidPhone);
          await tester.pumpAndSettle();

          // Tap save button to trigger validation
          final saveButton = find.widgetWithText(ElevatedButton, 'Simpan Perubahan');
          await tester.tap(saveButton);
          await tester.pumpAndSettle();

          // Verify validation error is shown
          final hasPhoneError = find.text('Nomor telepon harus 10-13 digit').evaluate().isNotEmpty ||
                                find.text('Nomor telepon harus 9-12 digit').evaluate().isNotEmpty;
          
          expect(hasPhoneError, isTrue,
            reason: 'Should show phone validation error for invalid input "$invalidPhone" (iteration $i)');
        }
      },
    );

    testWidgets(
      'Property: Empty phone should be valid (optional field)',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Test with 20 iterations with empty phone
        for (int i = 0; i < 20; i++) {
          final validName = generateValidName();
          final validEmail = generateValidEmail();

          // Find form fields
          final textFields = find.byType(TextFormField);
          expect(textFields, findsNWidgets(3));

          // Enter valid name, email and empty phone
          await tester.enterText(textFields.at(0), validName);
          await tester.pump();
          await tester.enterText(textFields.at(1), validEmail);
          await tester.pump();
          await tester.enterText(textFields.at(2), '');
          await tester.pump();

          // Get the form state and validate
          final formFinder = find.byType(Form);
          final formState = tester.state<FormState>(formFinder);
          
          // Validate the form
          final isValid = formState.validate();
          
          // Verify validation passes for empty phone (optional field)
          expect(isValid, isTrue,
            reason: 'Form should be valid with empty phone (iteration $i)');

          // Verify no phone validation error is shown (phone is optional)
          await tester.pump();
          expect(find.text('Nomor telepon harus 10-13 digit'), findsNothing,
            reason: 'Should not show phone error for empty input (iteration $i)');
          expect(find.text('Nomor telepon harus 9-12 digit'), findsNothing,
            reason: 'Should not show phone error for empty input (iteration $i)');
        }
      },
    );

    testWidgets(
      'Property: All invalid inputs should show multiple validation errors',
      (WidgetTester tester) async {
        // Run 30 iterations with all invalid inputs
        for (int i = 0; i < 30; i++) {
          final invalidName = generateInvalidName();
          final invalidEmail = generateInvalidEmail();
          final invalidPhone = generateInvalidPhone();

          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          // Find form fields
          final nameFinder = find.byType(TextFormField).at(0);
          final emailFinder = find.byType(TextFormField).at(1);
          final phoneFinder = find.byType(TextFormField).at(2);

          // Enter all invalid data
          await tester.enterText(nameFinder, invalidName);
          await tester.enterText(emailFinder, invalidEmail);
          await tester.enterText(phoneFinder, invalidPhone);
          await tester.pumpAndSettle();

          // Tap save button to trigger validation
          final saveButton = find.widgetWithText(ElevatedButton, 'Simpan Perubahan');
          await tester.tap(saveButton);
          await tester.pumpAndSettle();

          // Verify at least one validation error is shown
          final hasNameError = find.text('Nama wajib diisi').evaluate().isNotEmpty;
          final hasEmailError = find.text('Email wajib diisi').evaluate().isNotEmpty ||
                                find.text('Format email tidak valid').evaluate().isNotEmpty;
          final hasPhoneError = find.text('Nomor telepon harus 10-13 digit').evaluate().isNotEmpty ||
                                find.text('Nomor telepon harus 9-12 digit').evaluate().isNotEmpty;
          
          // At least name and email errors should be shown
          expect(hasNameError, isTrue,
            reason: 'Should show name error when all inputs invalid (iteration $i)');
          expect(hasEmailError, isTrue,
            reason: 'Should show email error when all inputs invalid (iteration $i)');
        }
      },
    );
  });
}

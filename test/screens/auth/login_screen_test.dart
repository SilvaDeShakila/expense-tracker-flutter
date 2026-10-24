import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/screens/auth/login_screen.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';

void main() {
  group('LoginScreen widget tests', () {
    Future<void> buildLoginScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: LoginScreen(
              onRegisterTap: () {},
            ),
          ),
        ),
      );
    }

    testWidgets('shows login form fields and button',
        (tester) async {
      await buildLoginScreen(tester);

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Email address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);
    });

    testWidgets('shows validation errors when fields are empty',
        (tester) async {
      await buildLoginScreen(tester);

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Email is required.'), findsOneWidget);
      expect(find.text('Password is required.'), findsOneWidget);
    });

    testWidgets('rejects an invalid email address',
        (tester) async {
      await buildLoginScreen(tester);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'invalid-email',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'password123',
      );

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(
        find.text('Enter a valid email address.'),
        findsOneWidget,
      );
    });

    testWidgets('rejects a password shorter than six characters',
        (tester) async {
      await buildLoginScreen(tester);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        '123',
      );

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(
        find.text('Password must be at least 6 characters.'),
        findsOneWidget,
      );
    });

    testWidgets('toggles password visibility',
        (tester) async {
      await buildLoginScreen(tester);

      final passwordField = tester.widget<EditableText>(
        find.descendant(
          of: find.byType(TextFormField).at(1),
          matching: find.byType(EditableText),
        ),
      );

      expect(passwordField.obscureText, isTrue);

      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();

      final updatedPasswordField = tester.widget<EditableText>(
        find.descendant(
          of: find.byType(TextFormField).at(1),
          matching: find.byType(EditableText),
        ),
      );

      expect(updatedPasswordField.obscureText, isFalse);
      expect(find.byTooltip('Hide password'), findsOneWidget);
    });

    testWidgets('opens registration screen callback',
        (tester) async {
      var registerTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: LoginScreen(
              onRegisterTap: () {
                registerTapped = true;
              },
            ),
          ),
        ),
      );

      await tester.ensureVisible(find.text('Create account'));
      await tester.tap(find.text('Create account'));
      await tester.pump();

      expect(registerTapped, isTrue);
    });
  });
}



import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:app_prueba/providers/auth_provider.dart';
import 'package:app_prueba/screens/auth/login_screen.dart';
import '../mocks.dart';

Widget createLoginScreen({MockAuthProvider? provider}) {
  return MaterialApp(
    home: ChangeNotifierProvider<AuthProvider>(
      create: (_) => provider ?? MockAuthProvider(),
      child: const LoginScreen(),
    ),
  );
}

void main() {
  group('LoginScreen', () {
    testWidgets('renders title and login button', (tester) async {
      await tester.pumpWidget(createLoginScreen());

      expect(find.text('Sistema de Asistencia'), findsOneWidget);
      expect(find.text('Iniciar sesi\u00f3n'), findsOneWidget);
    });

    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(createLoginScreen());

      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('renders forgot password button', (tester) async {
      await tester.pumpWidget(createLoginScreen());

      expect(find.text('\u00bfOlvidaste tu contrase\u00f1a?'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when loading', (tester) async {
      await tester.pumpWidget(createLoginScreen(
        provider: MockAuthProvider(mockLoading: true),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('forgot password dialog appears on tap', (tester) async {
      await tester.pumpWidget(createLoginScreen());

      await tester.tap(find.text('\u00bfOlvidaste tu contrase\u00f1a?'));
      await tester.pump();

      expect(find.text('Restablecer contrase\u00f1a'), findsOneWidget);
      expect(find.text('Enviar'), findsOneWidget);
    });
  });
}

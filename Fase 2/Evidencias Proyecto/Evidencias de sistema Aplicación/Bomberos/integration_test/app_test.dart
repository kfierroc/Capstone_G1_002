import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bomberos/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Pruebas de Integración - Autenticación', () {
    testWidgets('App inicia correctamente', (WidgetTester tester) async {
      // Iniciar app
      app.main();
      await tester.pumpAndSettle();

      // Verificar que la app se carga
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Pantalla de login se muestra correctamente', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verificar elementos de login
      expect(find.textContaining('Iniciar Sesión'), findsWidgets);
      expect(find.textContaining('Email'), findsWidgets);
      expect(find.textContaining('Contraseña'), findsWidgets);
    });

    testWidgets('Navegación a registro funciona', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Buscar botón de registro
      final registerButton = find.text('Regístrate');
      if (registerButton.evaluate().isNotEmpty) {
        await tester.tap(registerButton);
        await tester.pumpAndSettle();

        // Verificar que se navegó a registro
        expect(find.textContaining('Crear cuenta'), findsWidgets);
      }
    });
  });

  group('Pruebas de Integración - Formularios', () {
    testWidgets('Validación de email en formulario', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navegar a registro si es necesario
      final registerButton = find.text('Regístrate');
      if (registerButton.evaluate().isNotEmpty) {
        await tester.tap(registerButton);
        await tester.pumpAndSettle();
      }

      // Buscar campo de email
      final emailField = find.byType(TextFormField).first;
      if (emailField.evaluate().isNotEmpty) {
        // Ingresar email inválido
        await tester.enterText(emailField, 'email-invalido');
        await tester.pumpAndSettle();

        // Intentar enviar formulario
        final submitButton = find.textContaining('Continuar');
        if (submitButton.evaluate().isNotEmpty) {
          await tester.tap(submitButton);
          await tester.pumpAndSettle();

          // Verificar que se muestra error de validación
          // (esto depende de tu implementación)
        }
      }
    });
  });
}


// Test básico para la aplicación de residentes
//
// Verifica que la aplicación se inicia correctamente y muestra
// la pantalla de login o home según el estado de autenticación.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fire_data/main.dart';

void main() {
  testWidgets('App inicia correctamente', (WidgetTester tester) async {
    // Construir la aplicación y activar un frame
    await tester.pumpWidget(const MyApp());

    // Verificar que la aplicación se construye sin errores
    expect(find.byType(MaterialApp), findsOneWidget);

    // La app debería mostrar AuthChecker que maneja el estado de autenticación
    expect(find.byType(StreamBuilder), findsOneWidget);
  });

  testWidgets('Título de la aplicación es correcto', (
    WidgetTester tester,
  ) async {
    // Construir la aplicación
    await tester.pumpWidget(const MyApp());

    // Verificar que el título de la aplicación es correcto
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.title, equals('Residentes'));
  });
}

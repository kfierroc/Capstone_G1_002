import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_emergencias_residente/main.dart';

void main() {
  testWidgets('App inicia correctamente', (WidgetTester tester) async {
    // Construir la aplicación y activar un frame
    await tester.pumpWidget(const MyApp());

    // Verificar que la aplicación se construye sin errores
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Título de la aplicación es correcto', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verificar que el título de la aplicación es correcto
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.title, 'FireData - Residente');
  });
}
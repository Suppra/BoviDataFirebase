import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bovinos/main.dart';

void main() {
  testWidgets('Login screen displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(BoviDataApp());

    // Verificar que el título de la pantalla de login se muestra correctamente.
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('BoviData'), findsOneWidget);

    // Verificar que los campos de texto y el botón se muestran correctamente.
    expect(find.byType(TextField), findsNWidgets(2)); // Email y Contraseña
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('¿No tienes una cuenta? Regístrate aquí'), findsOneWidget);
  });
}


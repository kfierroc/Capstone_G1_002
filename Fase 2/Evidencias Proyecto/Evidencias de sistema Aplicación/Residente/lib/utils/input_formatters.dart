import 'package:flutter/services.dart';

/// Formateador de RUT chileno
/// Convierte: 123456789 → 12.345.678-9
class RutInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(RegExp(r'[^\dKk]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    text = text.toUpperCase();

    if (text.length < 2) {
      return newValue.copyWith(text: text);
    }

    // Separar número y dígito verificador
    String numero = text.substring(0, text.length - 1);
    String dv = text.substring(text.length - 1);

    // Formatear el número con puntos
    String formatted = '';
    int count = 0;
    for (int i = numero.length - 1; i >= 0; i--) {
      if (count == 3) {
        formatted = '.$formatted';
        count = 0;
      }
      formatted = numero[i] + formatted;
      count++;
    }

    final result = '$formatted-$dv';
    
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

/// Formateador de teléfono chileno
/// Convierte: 912345678 → 9 1234 5678
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Limitar a 9 dígitos
    if (text.length > 9) {
      text = text.substring(0, 9);
    }

    String formatted = '';

    if (text.isNotEmpty) {
      // Primer dígito
      formatted = text[0];

      if (text.length > 1) {
        // Siguiente grupo de 4 dígitos
        formatted += ' ${text.substring(1, text.length > 5 ? 5 : text.length)}';
      }

      if (text.length > 5) {
        // Último grupo de 4 dígitos
        formatted += ' ${text.substring(5)}';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Limita a solo números
class NumericInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}


import 'package:flutter/services.dart';

/// Utilidades para formateo de RUT y teléfono
class FormatUtils {
  
  /// Formatear RUT chileno (ej: 12345678-9)
  static String formatRut(String rut) {
    // Remover todos los caracteres no numéricos excepto la última letra
    String cleanRut = rut.replaceAll(RegExp(r'[^0-9kK]'), '');
    
    if (cleanRut.isEmpty) return '';
    
    // Separar número y dígito verificador
    String number = cleanRut.substring(0, cleanRut.length - 1);
    String dv = cleanRut.substring(cleanRut.length - 1).toUpperCase();
    
    if (number.isEmpty) return dv;
    
    // Agregar puntos cada 3 dígitos desde la derecha
    String formattedNumber = _addThousandsSeparator(number);
    
    return '$formattedNumber-$dv';
  }
  
  /// Formatear teléfono chileno (ej: +56 9 1234 5678)
  static String formatPhone(String phone) {
    // Remover todos los caracteres no numéricos
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanPhone.isEmpty) return '';
    
    // Si empieza con 56, es un número internacional
    if (cleanPhone.startsWith('56')) {
      if (cleanPhone.length >= 11) {
        // +56 9 1234 5678
        return '+${cleanPhone.substring(0, 2)} ${cleanPhone.substring(2, 3)} ${cleanPhone.substring(3, 7)} ${cleanPhone.substring(7, 11)}';
      } else if (cleanPhone.length >= 9) {
        // +56 9 1234 5678 (sin el 9 inicial)
        return '+${cleanPhone.substring(0, 2)} 9 ${cleanPhone.substring(2, 6)} ${cleanPhone.substring(6, 10)}';
      }
    }
    
    // Si empieza con 9, es un número móvil nacional
    if (cleanPhone.startsWith('9') && cleanPhone.length == 9) {
      return '+56 9 ${cleanPhone.substring(1, 5)} ${cleanPhone.substring(5, 9)}';
    }
    
    // Si tiene 8 dígitos, es un número fijo
    if (cleanPhone.length == 8) {
      return '+56 2 ${cleanPhone.substring(0, 4)} ${cleanPhone.substring(4, 8)}';
    }
    
    // Si tiene 9 dígitos y no empieza con 9, agregar +56
    if (cleanPhone.length == 9 && !cleanPhone.startsWith('9')) {
      return '+56 ${cleanPhone.substring(0, 1)} ${cleanPhone.substring(1, 5)} ${cleanPhone.substring(5, 9)}';
    }
    
    // Formato por defecto
    return '+56 $cleanPhone';
  }
  
  /// Agregar separadores de miles a un número
  static String _addThousandsSeparator(String number) {
    if (number.length <= 3) return number;
    
    String result = '';
    int count = 0;
    
    for (int i = number.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = '.$result';
        count = 0;
      }
      result = number[i] + result;
      count++;
    }
    
    return result;
  }
  
  /// Limpiar RUT para almacenamiento (solo números y dígito verificador)
  static String cleanRut(String rut) {
    return rut.replaceAll(RegExp(r'[^0-9kK]'), '').toUpperCase();
  }
  
  /// Limpiar teléfono para almacenamiento (solo números)
  static String cleanPhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }
  
  /// Validar formato de RUT chileno
  static bool isValidRut(String rut) {
    String cleanRutValue = FormatUtils.cleanRut(rut);
    if (cleanRutValue.length < 8 || cleanRutValue.length > 9) return false;
    
    String number = cleanRutValue.substring(0, cleanRutValue.length - 1);
    String dv = cleanRutValue.substring(cleanRutValue.length - 1);
    
    // Calcular dígito verificador
    int sum = 0;
    int multiplier = 2;
    
    for (int i = number.length - 1; i >= 0; i--) {
      sum += int.parse(number[i]) * multiplier;
      multiplier = multiplier == 7 ? 2 : multiplier + 1;
    }
    
    int remainder = sum % 11;
    String calculatedDv = (11 - remainder).toString();
    
    if (calculatedDv == '11') calculatedDv = '0';
    if (calculatedDv == '10') calculatedDv = 'K';
    
    return dv == calculatedDv;
  }
  
  /// Validar formato de teléfono chileno
  static bool isValidPhone(String phone) {
    String cleanPhoneValue = FormatUtils.cleanPhone(phone);
    
    // Número móvil: 9 dígitos empezando con 9
    if (cleanPhoneValue.length == 9 && cleanPhoneValue.startsWith('9')) {
      return true;
    }
    
    // Número fijo: 8 dígitos
    if (cleanPhoneValue.length == 8) {
      return true;
    }
    
    // Número internacional: 11 dígitos empezando con 56
    if (cleanPhoneValue.length == 11 && cleanPhoneValue.startsWith('56')) {
      return true;
    }
    
    return false;
  }
}

/// Input formatter para RUT chileno
class RutInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String formatted = FormatUtils.formatRut(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Input formatter para teléfono chileno
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String formatted = FormatUtils.formatPhone(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

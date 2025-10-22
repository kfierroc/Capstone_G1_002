import 'dart:async';
import 'dart:math';
import 'dart:math' as math;
import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // Comentado temporalmente

/// Utilidades comunes para la aplicación
class CommonUtilities {
  CommonUtilities._();

  // Formateadores de fecha y hora (temporalmente deshabilitados)
  // static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  // static final DateFormat _timeFormat = DateFormat('HH:mm');
  // static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  /// Formatea una fecha
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Formatea una hora
  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Formatea fecha y hora
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  /// Formatea una fecha relativa (hace X tiempo)
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora${difference.inHours == 1 ? '' : 's'}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes == 1 ? '' : 's'}';
    } else {
      return 'ahora';
    }
  }

  /// Formatea un número con separadores de miles
  static String formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Formatea un número decimal
  static String formatDecimal(double number, {int decimals = 2}) {
    return number.toStringAsFixed(decimals).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Formatea un porcentaje
  static String formatPercentage(double number) {
    return '${(number / 100).toStringAsFixed(1)}%';
  }

  /// Formatea una moneda
  static String formatCurrency(double amount) {
    return '\$${formatDecimal(amount)}';
  }

  /// Capitaliza la primera letra de una cadena
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Capitaliza cada palabra de una cadena
  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  /// Trunca un texto a una longitud específica
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Genera un color aleatorio
  static Color generateRandomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[DateTime.now().millisecond % colors.length];
  }

  /// Convierte un color hexadecimal a Color
  static Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Agregar alpha si no está presente
    }
    return Color(int.parse(hex, radix: 16));
  }

  /// Convierte un Color a hexadecimal
  static String colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  /// Calcula la distancia entre dos puntos geográficos
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Radio de la Tierra en kilómetros
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = 
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  /// Convierte grados a radianes
  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Valida si un email es válido
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  /// Valida si un teléfono es válido
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phone);
  }

  /// Valida si un RUT chileno es válido
  static bool isValidRut(String rut) {
    rut = rut.replaceAll('.', '').replaceAll('-', '');
    if (rut.length < 2) return false;
    
    final String body = rut.substring(0, rut.length - 1);
    final String checkDigit = rut.substring(rut.length - 1).toUpperCase();
    
    if (!RegExp(r'^[0-9]+$').hasMatch(body)) return false;
    
    int sum = 0;
    int multiplier = 2;
    
    for (int i = body.length - 1; i >= 0; i--) {
      sum += int.parse(body[i]) * multiplier;
      multiplier = multiplier == 7 ? 2 : multiplier + 1;
    }
    
    final int remainder = sum % 11;
    final String calculatedCheckDigit = remainder == 0 ? '0' : 
                                       remainder == 1 ? 'K' : 
                                       (11 - remainder).toString();
    
    return checkDigit == calculatedCheckDigit;
  }

  /// Genera un ID único
  static String generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Genera un código aleatorio
  static String generateRandomCode(int length) {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }

  /// Convierte bytes a formato legible
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Obtiene el nombre del mes
  static String getMonthName(int month) {
    const List<String> months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }

  /// Obtiene el nombre del día de la semana
  static String getDayName(int weekday) {
    const List<String> days = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
    ];
    return days[weekday - 1];
  }

  /// Verifica si una cadena es nula o vacía
  static bool isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// Verifica si una lista es nula o vacía
  static bool isListNullOrEmpty<T>(List<T>? list) {
    return list == null || list.isEmpty;
  }

  /// Obtiene el primer elemento no nulo de una lista
  static T? firstNonNull<T>(List<T?> list) {
    for (final item in list) {
      if (item != null) return item;
    }
    return null;
  }

  /// Agrupa elementos de una lista por una clave
  static Map<K, List<V>> groupBy<K, V>(List<V> list, K Function(V) keyFunction) {
    final Map<K, List<V>> groups = {};
    for (final item in list) {
      final key = keyFunction(item);
      groups.putIfAbsent(key, () => []).add(item);
    }
    return groups;
  }

  /// Debounce para evitar llamadas excesivas
  static Timer debounce(Duration delay, VoidCallback callback) {
    return Timer(delay, callback);
  }

  /// Throttle para limitar la frecuencia de llamadas
  static DateTime? _lastCall;
  static void throttle(Duration delay, VoidCallback callback) {
    final now = DateTime.now();
    
    if (_lastCall == null || now.difference(_lastCall!) >= delay) {
      _lastCall = now;
      callback();
    }
  }

  /// Formatea un RUT chileno
  static String formatRut(String rut) {
    if (isNullOrEmpty(rut)) return '';
    
    // Remover caracteres no numéricos excepto la K
    String cleanRut = rut.replaceAll(RegExp(r'[^0-9Kk]'), '');
    
    if (cleanRut.isEmpty) return '';
    
    // Separar número y dígito verificador
    String number = cleanRut.substring(0, cleanRut.length - 1);
    String dv = cleanRut.substring(cleanRut.length - 1).toUpperCase();
    
    // Formatear número con puntos
    String formattedNumber = '';
    for (int i = 0; i < number.length; i++) {
      if (i > 0 && (number.length - i) % 3 == 0) {
        formattedNumber += '.';
      }
      formattedNumber += number[i];
    }
    
    return '$formattedNumber-$dv';
  }
}
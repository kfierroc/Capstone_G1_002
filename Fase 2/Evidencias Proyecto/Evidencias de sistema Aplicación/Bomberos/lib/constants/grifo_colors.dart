import 'package:flutter/material.dart';

/// Colores específicos para el módulo de grifos
class GrifoColors {
  GrifoColors._();

  // Colores primarios
  static final Color primary = Colors.blue.shade800;
  static const Color primaryLight = Colors.blue;
  static final Color primaryDark = Colors.blue.shade900;

  // Colores secundarios
  static const Color secondary = Colors.green;
  static final Color secondaryLight = Colors.green.shade400;
  static final Color secondaryDark = Colors.green.shade700;

  // Colores de estado
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color warning = Colors.orange;
  static const Color info = Colors.blue;
  static const Color grey = Colors.grey;

  // Colores de estado de grifos
  static const Color operativo = Colors.green;
  static const Color danado = Colors.red;
  static const Color mantenimiento = Colors.orange;
  static const Color sinVerificar = Colors.grey;

  // Colores de fondo
  static final Color background = Colors.grey.shade100;
  static const Color surface = Colors.white;
  static final Color surfaceVariant = Colors.grey.shade50;

  // Colores de texto
  static const Color textPrimary = Colors.black87;
  static final Color textSecondary = Colors.grey.shade700;
  static final Color textTertiary = Colors.grey.shade600;
  static const Color textOnPrimary = Colors.white;
  static const Color textLight = Colors.white70;

  /// Obtiene el color según el estado del grifo
  static Color getEstadoColor(String estado) {
    switch (estado) {
      case 'Operativo':
        return operativo;
      case 'Dañado':
        return danado;
      case 'Mantenimiento':
        return mantenimiento;
      case 'Sin verificar':
        return sinVerificar;
      default:
        return grey;
    }
  }
}

import 'package:flutter/material.dart';

/// Colores del sistema de grifos
/// Centraliza todos los colores utilizados en la aplicación
class GrifoColors {
  // Colores primarios
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryVariant = Color(0xFF1976D2);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);

  // Colores de superficie
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F0F0);
  
  // Colores neutros
  static const Color grey = Color(0xFF9E9E9E);

  // Colores de texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Colores de estado
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Colores de grifo por estado
  static const Color grifoFuncionando = Color(0xFF4CAF50);
  static const Color grifoDaniado = Color(0xFFFF9800);
  static const Color grifoFueraServicio = Color(0xFFF44336);
  static const Color grifoSinVerificar = Color(0xFF9E9E9E);

  // Colores de tipo de grifo
  static const Color grifoAltoFlujo = Color(0xFF2196F3);
  static const Color grifoMedioFlujo = Color(0xFF00BCD4);
  static const Color grifoBajoFlujo = Color(0xFF4CAF50);

  // Getters para colores de estado
  static Color get operativo => grifoFuncionando;
  static Color get danado => grifoDaniado;
  static Color get mantenimiento => grifoFueraServicio;
  static Color get sinVerificar => grifoSinVerificar;

  /// Obtiene el color correspondiente al estado de un grifo
  static Color getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'operativo':
      case 'funcionando':
        return grifoFuncionando;
      case 'dañado':
      case 'danado':
        return grifoDaniado;
      case 'fuera de servicio':
      case 'mantenimiento':
        return grifoFueraServicio;
      case 'sin verificar':
      default:
        return grifoSinVerificar;
    }
  }
}
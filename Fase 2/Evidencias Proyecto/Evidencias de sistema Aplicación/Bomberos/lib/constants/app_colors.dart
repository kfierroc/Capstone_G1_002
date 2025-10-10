import 'package:flutter/material.dart';

/// Colores estandarizados de la aplicación
class AppColors {
  AppColors._();

  // Colores primarios
  static final primary = Colors.red.shade700;
  static final primaryDark = Colors.red.shade800;
  static final primaryLight = Colors.red.shade600;

  // Colores secundarios
  static final secondary = Colors.blue.shade700;
  static final secondaryLight = Colors.blue.shade50;

  // Colores de estado
  static final success = Colors.green.shade600;
  static final warning = Colors.orange;
  static final error = Colors.red;
  static final info = Colors.blue.shade700;

  // Colores de fondo
  static const background = Colors.white;
  static final backgroundLight = Colors.grey.shade50;
  static final border = Colors.grey.shade200;
  static final borderDark = Colors.grey.shade400;

  // Colores de texto
  static final textPrimary = Colors.grey.shade900;
  static final textSecondary = Colors.grey.shade700;
  static final textTertiary = Colors.grey.shade600;
  static const textWhite = Colors.white;
  static final textWhite70 = Colors.white70;

  // Colores específicos
  static final ownerBackground = Colors.blue.shade50;
  static final ownerBorder = Colors.blue.shade200;
  static final medicalBackground = Colors.red.shade100;
  static final medicalBorder = Colors.red.shade300;
  static final medicalText = Colors.red.shade900;

  // Colores de mascotas
  static final dogColor = Colors.brown;
  static final catColor = Colors.orange;
}

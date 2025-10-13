/// Constantes generales de la aplicación
class AppConstants {
  AppConstants._();

  // Estados de grifos
  static const List<String> estadosGrifo = [
    'Todos',
    'Operativo',
    'Dañado',
    'Mantenimiento',
    'Sin verificar',
  ];

  static const List<String> estadosGrifoSinTodos = [
    'Sin verificar',
    'Operativo',
    'Dañado',
    'Mantenimiento',
  ];

  // Tipos de grifos
  static const List<String> tiposGrifo = [
    'Estándar',
    'Alto flujo',
    'Seco',
  ];

  // Credenciales de prueba
  static const String testEmail = 'admin@grifos.cl';
  static const String testPassword = 'admin123';

  // Mensajes
  static const String msgLoginSuccess = '¡Bienvenido admin@grifos.cl!';
  static const String msgLoginError =
      'Credenciales incorrectas. Usa el botón "Usar Credenciales de Prueba"';
  static const String msgRegistroSuccess =
      '¡Registro exitoso! Verifica tu email para activar tu cuenta.';
  static const String msgRecuperacionSuccess =
      'Email de recuperación enviado. Revisa tu bandeja de entrada.';
  static const String msgCamposRequeridos =
      'Por favor completa todos los campos obligatorios';

  // Duraciones
  static const Duration snackbarDuration = Duration(seconds: 4);
  static const Duration loadingDuration = Duration(seconds: 1);
}


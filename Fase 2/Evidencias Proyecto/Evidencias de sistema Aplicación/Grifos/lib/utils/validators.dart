/// Validadores reutilizables para formularios
class Validators {
  Validators._();

  /// Valida que el campo no esté vacío
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa ${fieldName ?? 'este campo'}';
    }
    return null;
  }

  /// Valida formato de email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un email válido';
    }
    return null;
  }

  /// Valida contraseña (mínimo 6 caracteres)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  /// Valida que las contraseñas coincidan
  static String? confirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Por favor confirma tu contraseña';
    }
    if (value != originalPassword) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  /// Valida nombre completo (al menos 2 palabras)
  static String? fullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu nombre completo';
    }
    if (value.trim().split(' ').length < 2) {
      return 'Ingresa tu nombre y apellido';
    }
    return null;
  }

  /// Valida RUT chileno
  static String? rut(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu RUT';
    }

    String cleanRut =
        value.replaceAll('.', '').replaceAll('-', '').toUpperCase();

    if (cleanRut.length < 8) {
      return 'RUT inválido';
    }

    String rutNumber = cleanRut.substring(0, cleanRut.length - 1);
    String verifier = cleanRut.substring(cleanRut.length - 1);

    if (int.tryParse(rutNumber) == null) {
      return 'RUT inválido';
    }

    int sum = 0;
    int multiplier = 2;

    for (int i = rutNumber.length - 1; i >= 0; i--) {
      sum += int.parse(rutNumber[i]) * multiplier;
      multiplier = multiplier == 7 ? 2 : multiplier + 1;
    }

    int mod = 11 - (sum % 11);
    String calculatedVerifier =
        mod == 11 ? '0' : mod == 10 ? 'K' : mod.toString();

    if (verifier != calculatedVerifier) {
      return 'RUT inválido';
    }

    return null;
  }

  /// Valida longitud mínima
  static String? minLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa ${fieldName ?? 'este campo'}';
    }
    if (value.length < minLength) {
      return '${fieldName ?? 'Este campo'} debe tener al menos $minLength caracteres';
    }
    return null;
  }
}


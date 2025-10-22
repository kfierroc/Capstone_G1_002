/// Sistema de validación centralizado para formularios
class ValidationSystem {
  ValidationSystem._();

  // Patrones de validación
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  static final RegExp _phoneRegex = RegExp(
    r'^\+?[1-9]\d{1,14}$',
  );
  
  static final RegExp _rutRegex = RegExp(
    r'^[0-9]+-[0-9kK]$',
  );

  // Mensajes de error
  static const String requiredField = 'Este campo es obligatorio';
  static const String invalidEmail = 'Ingrese un email válido';
  static const String invalidPhone = 'Ingrese un teléfono válido';
  static const String invalidRut = 'Ingrese un RUT válido';
  static const String passwordTooShort = 'La contraseña debe tener al menos 6 caracteres';
  static const String passwordsDoNotMatch = 'Las contraseñas no coinciden';
  static const String invalidNumber = 'Ingrese un número válido';
  static const String invalidPositiveNumber = 'Ingrese un número positivo';
  static const String invalidUrl = 'Ingrese una URL válida';

  /// Valida que el campo no esté vacío
  static String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return requiredField;
    }
    return null;
  }

  /// Valida formato de email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return requiredField;
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return invalidEmail;
    }
    return null;
  }

  /// Valida formato de teléfono
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return requiredField;
    }
    if (!_phoneRegex.hasMatch(value.trim())) {
      return invalidPhone;
    }
    return null;
  }

  /// Valida formato de RUT chileno
  static String? validateRut(String? value) {
    if (value == null || value.trim().isEmpty) {
      return requiredField;
    }
    if (!_rutRegex.hasMatch(value.trim())) {
      return invalidRut;
    }
    return null;
  }

  /// Valida contraseña
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return requiredField;
    }
    if (value.length < 6) {
      return passwordTooShort;
    }
    return null;
  }

  /// Valida confirmación de contraseña
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return requiredField;
    }
    if (value != password) {
      return passwordsDoNotMatch;
    }
    return null;
  }

  /// Valida confirmación de contraseña (alias para validatePasswordConfirmation)
  static String? validateConfirmPassword(String? value, String? password) {
    return validatePasswordConfirmation(value, password);
  }

  /// Valida número
  static String? validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return requiredField;
    }
    final number = double.tryParse(value.trim());
    if (number == null) {
      return invalidNumber;
    }
    return null;
  }

  /// Valida número positivo
  static String? validatePositiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return requiredField;
    }
    final number = double.tryParse(value.trim());
    if (number == null) {
      return invalidNumber;
    }
    if (number <= 0) {
      return invalidPositiveNumber;
    }
    return null;
  }

  /// Valida URL
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return requiredField;
    }
    try {
      Uri.parse(value.trim());
      return null;
    } catch (e) {
      return invalidUrl;
    }
  }

  /// Valida longitud mínima
  static String? validateMinLength(String? value, int minLength) {
    if (value == null || value.trim().isEmpty) {
      return requiredField;
    }
    if (value.trim().length < minLength) {
      return 'Debe tener al menos $minLength caracteres';
    }
    return null;
  }

  /// Valida longitud máxima
  static String? validateMaxLength(String? value, int maxLength) {
    if (value == null || value.trim().isEmpty) {
      return null; // No es requerido, solo valida longitud si tiene contenido
    }
    if (value.trim().length > maxLength) {
      return 'No puede tener más de $maxLength caracteres';
    }
    return null;
  }

  /// Valida rango de números
  static String? validateRange(String? value, double min, double max) {
    if (value == null || value.trim().isEmpty) {
      return requiredField;
    }
    final number = double.tryParse(value.trim());
    if (number == null) {
      return invalidNumber;
    }
    if (number < min || number > max) {
      return 'Debe estar entre $min y $max';
    }
    return null;
  }

  /// Valida coordenadas de latitud
  static String? validateLatitude(String? value) {
    return validateRange(value, -90.0, 90.0);
  }

  /// Valida coordenadas de longitud
  static String? validateLongitude(String? value) {
    return validateRange(value, -180.0, 180.0);
  }

  /// Valida múltiples validadores
  static String? validateMultiple(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  /// Valida campo de texto personalizado
  static String? validateCustom(String? value, String? Function(String?) validator) {
    return validator(value);
  }

  /// Valida que el campo tenga un valor específico
  static String? validateEquals(String? value, String expectedValue, String errorMessage) {
    if (value == null || value.trim().isEmpty) {
      return requiredField;
    }
    if (value.trim() != expectedValue) {
      return errorMessage;
    }
    return null;
  }

  /// Valida que el campo contenga solo letras
  static String? validateLettersOnly(String? value) {
    if (value == null || value.trim().isEmpty) {
      return requiredField;
    }
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value.trim())) {
      return 'Solo se permiten letras';
    }
    return null;
  }

  /// Valida que el campo contenga solo números
  static String? validateNumbersOnly(String? value) {
    if (value == null || value.trim().isEmpty) {
      return requiredField;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
      return 'Solo se permiten números';
    }
    return null;
  }

  /// Valida que el campo contenga solo alfanumérico
  static String? validateAlphanumeric(String? value) {
    if (value == null || value.trim().isEmpty) {
      return requiredField;
    }
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value.trim())) {
      return 'Solo se permiten letras y números';
    }
    return null;
  }

  /// Valida un nombre (letras y espacios)
  static String? validateName(String? value) {
    return validateLettersOnly(value);
  }

  /// Valida una empresa/institución
  static String? validateCompany(String? value) {
    if (value == null || value.trim().isEmpty) {
      return requiredField;
    }
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null;
  }

  /// Valida una dirección
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return requiredField;
    }
    if (value.trim().length < 5) {
      return 'La dirección debe tener al menos 5 caracteres';
    }
    return null;
  }

  /// Valida una comuna
  static String? validateComuna(String? value) {
    if (value == null || value.trim().isEmpty) {
      return requiredField;
    }
    if (value.trim().length < 2) {
      return 'El nombre de la comuna debe tener al menos 2 caracteres';
    }
    return null;
  }

  /// Valida notas/observaciones
  static String? validateNotes(String? value) {
    // Las notas son opcionales, solo validar longitud si se proporcionan
    if (value != null && value.trim().length > 500) {
      return 'Las notas no pueden exceder 500 caracteres';
    }
    return null;
  }
}
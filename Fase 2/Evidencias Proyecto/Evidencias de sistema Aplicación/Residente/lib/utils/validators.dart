class Validators {
  /// Valida el formato y dígito verificador del RUT chileno
  static String? validateRut(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu RUT';
    }

    // Remover puntos y guión
    String rut = value.replaceAll('.', '').replaceAll('-', '').toUpperCase();

    // Verificar largo mínimo (7 dígitos + verificador)
    if (rut.length < 2) {
      return 'RUT inválido';
    }

    // Separar número del dígito verificador
    String numero = rut.substring(0, rut.length - 1);
    String dv = rut.substring(rut.length - 1);

    // Verificar que el número sea numérico
    if (int.tryParse(numero) == null) {
      return 'RUT debe contener solo números';
    }

    // Calcular dígito verificador
    String dvCalculado = _calcularDV(numero);

    if (dv != dvCalculado) {
      return 'RUT inválido - Dígito verificador incorrecto';
    }

    return null;
  }

  /// Calcula el dígito verificador del RUT
  static String _calcularDV(String rut) {
    int suma = 0;
    int multiplicador = 2;

    // Recorrer el RUT de derecha a izquierda
    for (int i = rut.length - 1; i >= 0; i--) {
      suma += int.parse(rut[i]) * multiplicador;
      multiplicador = multiplicador < 7 ? multiplicador + 1 : 2;
    }

    int resto = suma % 11;
    int dv = 11 - resto;

    if (dv == 11) {
      return '0';
    } else if (dv == 10) {
      return 'K';
    } else {
      return dv.toString();
    }
  }

  /// Formatea el RUT con puntos y guión
  static String formatRut(String rut) {
    // Remover caracteres no numéricos excepto K
    String cleanRut = rut.replaceAll(RegExp(r'[^\dKk]'), '').toUpperCase();

    if (cleanRut.length < 2) return cleanRut;

    // Separar número y dígito verificador
    String numero = cleanRut.substring(0, cleanRut.length - 1);
    String dv = cleanRut.substring(cleanRut.length - 1);

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

    return '$formatted-$dv';
  }

  /// Valida el formato de teléfono chileno
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa un teléfono';
    }

    // Remover espacios, paréntesis, guiones y signos +
    String phone = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');

    // Verificar que solo contenga números
    if (!RegExp(r'^\d+$').hasMatch(phone)) {
      return 'El teléfono debe contener solo números';
    }

    // Validar formatos comunes chilenos:
    // - 9 dígitos (celular): 912345678
    // - 11 dígitos con código país: 56912345678
    // - 8 dígitos (fijo): 221234567
    // - 10 dígitos fijo con código país: 56221234567

    if (phone.startsWith('56')) {
      // Con código de país
      phone = phone.substring(2); // Remover 56
    }

    // Celular: debe empezar con 9 y tener 9 dígitos
    if (phone.startsWith('9')) {
      if (phone.length != 9) {
        return 'Número de celular debe tener 9 dígitos';
      }
      return null;
    }

    // Teléfono fijo: 8 o 9 dígitos
    if (phone.length == 8 || phone.length == 9) {
      return null;
    }

    return 'Formato de teléfono inválido';
  }

  /// Valida teléfono opcional (puede estar vacío)
  static String? validatePhoneOptional(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Es opcional, no hay error
    }
    return validatePhone(value);
  }

  /// Formatea el teléfono chileno
  static String formatPhone(String phone) {
    // Remover caracteres no numéricos
    String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');

    // Si empieza con 56, es el código de país
    if (cleanPhone.startsWith('56')) {
      cleanPhone = cleanPhone.substring(2);
    }

    // Formato para celular (9 dígitos): +56 9 1234 5678
    if (cleanPhone.startsWith('9') && cleanPhone.length == 9) {
      return '+56 ${cleanPhone[0]} ${cleanPhone.substring(1, 5)} ${cleanPhone.substring(5)}';
    }

    // Formato para fijo (8 dígitos): +56 2 2123 4567
    if (cleanPhone.length == 8 || cleanPhone.length == 9) {
      if (cleanPhone.length == 8) {
        return '+56 ${cleanPhone.substring(0, 1)} ${cleanPhone.substring(1, 5)} ${cleanPhone.substring(5)}';
      } else {
        return '+56 ${cleanPhone.substring(0, 2)} ${cleanPhone.substring(2, 5)} ${cleanPhone.substring(5)}';
      }
    }

    // Si no cumple formato conocido, devolver el original
    return phone;
  }

  /// Valida email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un email válido';
    }
    return null;
  }

  /// Valida contraseña
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    if (value.length < minLength) {
      return 'La contraseña debe tener al menos $minLength caracteres';
    }
    return null;
  }

  /// Valida año de nacimiento
  static String? validateBirthYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu año de nacimiento';
    }
    final year = int.tryParse(value);
    final currentYear = DateTime.now().year;
    if (year == null || year < 1900 || year > currentYear) {
      return 'Año inválido';
    }
    return null;
  }

  /// Valida dirección
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa la dirección';
    }
    if (value.length < 5) {
      return 'La dirección es muy corta';
    }
    return null;
  }

  /// Valida nombre
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el nombre';
    }
    if (value.length < 2) {
      return 'El nombre es muy corto';
    }
    return null;
  }

  /// Valida coordenadas (latitud/longitud)
  static String? validateCoordinate(String? value, bool isLatitude) {
    if (value == null || value.isEmpty) {
      return null; // Es opcional
    }

    final coordinate = double.tryParse(value);
    if (coordinate == null) {
      return 'Debe ser un número válido';
    }

    if (isLatitude) {
      if (coordinate < -90 || coordinate > 90) {
        return 'Latitud debe estar entre -90 y 90';
      }
    } else {
      if (coordinate < -180 || coordinate > 180) {
        return 'Longitud debe estar entre -180 y 180';
      }
    }

    return null;
  }
}


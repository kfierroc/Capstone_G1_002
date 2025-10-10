/// Utilidades de formateo
class Formatters {
  Formatters._();

  /// Formatea una fecha en formato YYYY-MM-DD
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Formatea RUT chileno con puntos y guión
  static String formatRut(String value) {
    String cleanRut = value.replaceAll('.', '').replaceAll('-', '');

    if (cleanRut.isEmpty || cleanRut.length <= 1) {
      return value;
    }

    String rutNumber = cleanRut.substring(0, cleanRut.length - 1);
    String verifier = cleanRut.substring(cleanRut.length - 1);

    String formattedNumber = '';
    int counter = 0;
    
    for (int i = rutNumber.length - 1; i >= 0; i--) {
      if (counter == 3) {
        formattedNumber = '.$formattedNumber';
        counter = 0;
      }
      formattedNumber = rutNumber[i] + formattedNumber;
      counter++;
    }

    return '$formattedNumber-$verifier';
  }

  /// Aplica formato de RUT a un TextEditingController
  static void applyRutFormat(
    String value,
    void Function(String) onFormatted,
  ) {
    String cleanRut = value.replaceAll('.', '').replaceAll('-', '');

    if (cleanRut.isNotEmpty && cleanRut.length > 1) {
      String formattedRut = formatRut(cleanRut);
      if (formattedRut != value) {
        onFormatted(formattedRut);
      }
    }
  }
}


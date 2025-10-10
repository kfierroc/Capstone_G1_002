/// Constantes de datos para la aplicación

class MedicalConditions {
  MedicalConditions._();

  static const Map<String, List<String>> categories = {
    'Enfermedades Crónicas': [
      'Diabetes',
      'Hipertensión',
      'Problemas cardíacos',
      'Enfermedades respiratorias',
      'Epilepsia o convulsiones',
      'Cáncer en tratamiento',
      'Enfermedades mentales',
    ],
    'Movilidad y Sentidos': [
      'Persona postrada',
      'Problemas de audición',
      'Problemas de visión',
      'Vértigo o pérdida de equilibrio',
      'Dificultad para moverse o caminar',
      'Asma o problemas para respirar',
    ],
  };
}

class PetData {
  PetData._();

  static const List<String> species = [
    'Perro',
    'Gato',
    'Ave',
    'Conejo',
    'Hámster',
    'Pez',
    'Reptil',
    'Otro',
  ];

  static const List<String> sizes = [
    'Muy pequeño',
    'Pequeño',
    'Mediano',
    'Grande',
    'Muy grande',
  ];
}

class HousingData {
  HousingData._();

  static const List<String> types = [
    'Casa',
    'Departamento',
    'Empresa',
    'Local comercial',
    'Oficina',
    'Bodega',
    'Otro',
  ];

  static const List<String> materials = [
    'Hormigón/Concreto',
    'Ladrillo',
    'Madera',
    'Adobe',
    'Metal',
    'Material ligero',
    'Mixto',
    'Otro',
  ];

  static const List<String> conditions = [
    'Excelente',
    'Bueno',
    'Regular',
    'Malo',
    'Muy malo',
  ];
}


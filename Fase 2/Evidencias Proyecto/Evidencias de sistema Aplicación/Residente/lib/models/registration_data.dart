class RegistrationData {
  // Paso 1: Crear Cuenta
  String? email;
  String? password;

  // Paso 2: Datos del Titular
  String? fullName;
  String? rut;
  String? phoneNumber;
  int? birthYear;
  int? age;
  List<String> medicalConditions;

  // Paso 3: Información de la Residencia
  String? address;
  double? latitude;
  double? longitude;

  // Paso 4: Detalles de la Vivienda
  String? housingType;
  int? numberOfFloors;
  String? constructionMaterial;
  String? housingCondition;
  String? mainPhone; // Teléfono principal de la residencia

  RegistrationData({
    this.email,
    this.password,
    this.fullName,
    this.rut,
    this.phoneNumber,
    this.birthYear,
    this.age,
    List<String>? medicalConditions,
    this.address,
    this.latitude,
    this.longitude,
    this.housingType,
    this.numberOfFloors,
    this.constructionMaterial,
    this.housingCondition,
    this.mainPhone,
  }) : medicalConditions = medicalConditions ?? [];

  // Optimización: Método copyWith para actualizaciones inmutables
  RegistrationData copyWith({
    String? email,
    String? password,
    String? fullName,
    String? rut,
    String? phoneNumber,
    int? birthYear,
    int? age,
    List<String>? medicalConditions,
    String? address,
    double? latitude,
    double? longitude,
    String? housingType,
    int? numberOfFloors,
    String? constructionMaterial,
    String? housingCondition,
    String? mainPhone,
  }) {
    return RegistrationData(
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      rut: rut ?? this.rut,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      birthYear: birthYear ?? this.birthYear,
      age: age ?? this.age,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      housingType: housingType ?? this.housingType,
      numberOfFloors: numberOfFloors ?? this.numberOfFloors,
      constructionMaterial: constructionMaterial ?? this.constructionMaterial,
      housingCondition: housingCondition ?? this.housingCondition,
      mainPhone: mainPhone ?? this.mainPhone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'full_name': fullName,
      'rut': rut,
      'phone_number': phoneNumber,
      'birth_year': birthYear,
      'age': age,
      'medical_conditions': medicalConditions,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'main_phone': mainPhone,
      'housing_type': housingType,
      'number_of_floors': numberOfFloors,
      'construction_material': constructionMaterial,
      'housing_condition': housingCondition,
    };
  }

  // Optimización: Método fromJson para deserialización
  factory RegistrationData.fromJson(Map<String, dynamic> json) {
    return RegistrationData(
      email: json['email'] as String?,
      fullName: json['full_name'] as String?,
      rut: json['rut'] as String?,
      phoneNumber: json['phone_number'] as String?,
      birthYear: json['birth_year'] as int?,
      age: json['age'] as int?,
      medicalConditions: (json['medical_conditions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      address: json['address'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      housingType: json['housing_type'] as String?,
      numberOfFloors: json['number_of_floors'] as int?,
      constructionMaterial: json['construction_material'] as String?,
      housingCondition: json['housing_condition'] as String?,
      mainPhone: json['main_phone'] as String?,
    );
  }
}

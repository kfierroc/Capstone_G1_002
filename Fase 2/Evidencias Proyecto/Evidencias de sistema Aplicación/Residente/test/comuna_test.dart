import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_emergencias_residente/models/registration_data.dart';

void main() {
  group('Pruebas de Modelos', () {
    test('RegistrationData debería crear instancia correctamente', () {
      final registrationData = RegistrationData(
        email: 'test@example.com',
        rut: '12345678-9',
        address: 'Calle Test 123',
        latitude: -33.4489,
        longitude: -70.6483,
        phoneNumber: '+56912345678',
        housingType: 'Casa',
        numberOfFloors: 2,
        constructionMaterial: 'Hormigón',
        housingCondition: 'Bueno',
      );

      expect(registrationData.email, 'test@example.com');
      expect(registrationData.rut, '12345678-9');
      expect(registrationData.address, 'Calle Test 123');
      expect(registrationData.latitude, -33.4489);
      expect(registrationData.longitude, -70.6483);
      expect(registrationData.phoneNumber, '+56912345678');
      expect(registrationData.housingType, 'Casa');
      expect(registrationData.numberOfFloors, 2);
      expect(registrationData.constructionMaterial, 'Hormigón');
      expect(registrationData.housingCondition, 'Bueno');
    });

    test('RegistrationData debería convertir a JSON correctamente', () {
      final registrationData = RegistrationData(
        email: 'test@example.com',
        rut: '12345678-9',
        address: 'Calle Test 123',
        latitude: -33.4489,
        longitude: -70.6483,
        phoneNumber: '+56912345678',
        housingType: 'Casa',
        numberOfFloors: 2,
        constructionMaterial: 'Hormigón',
        housingCondition: 'Bueno',
      );

      final json = registrationData.toJson();
      
      expect(json['email'], 'test@example.com');
      expect(json['rut'], '12345678-9');
      expect(json['address'], 'Calle Test 123');
      expect(json['latitude'], -33.4489);
      expect(json['longitude'], -70.6483);
      expect(json['phone_number'], '+56912345678');
      expect(json['housing_type'], 'Casa');
      expect(json['number_of_floors'], 2);
      expect(json['construction_material'], 'Hormigón');
      expect(json['housing_condition'], 'Bueno');
    });

    test('RegistrationData debería crear desde JSON correctamente', () {
      final json = {
        'email': 'test@example.com',
        'rut': '12345678-9',
        'address': 'Calle Test 123',
        'latitude': -33.4489,
        'longitude': -70.6483,
        'phone_number': '+56912345678',
        'housing_type': 'Casa',
        'number_of_floors': 2,
        'construction_material': 'Hormigón',
        'housing_condition': 'Bueno',
      };

      final registrationData = RegistrationData.fromJson(json);
      
      expect(registrationData.email, 'test@example.com');
      expect(registrationData.rut, '12345678-9');
      expect(registrationData.address, 'Calle Test 123');
      expect(registrationData.latitude, -33.4489);
      expect(registrationData.longitude, -70.6483);
      expect(registrationData.phoneNumber, '+56912345678');
      expect(registrationData.housingType, 'Casa');
      expect(registrationData.numberOfFloors, 2);
      expect(registrationData.constructionMaterial, 'Hormigón');
      expect(registrationData.housingCondition, 'Bueno');
    });
  });
}
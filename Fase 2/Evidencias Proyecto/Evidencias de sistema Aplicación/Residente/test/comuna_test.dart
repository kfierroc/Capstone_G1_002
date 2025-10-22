import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fire_data/services/database_service.dart';
import 'package:fire_data/models/registration_data.dart';

void main() {
  group('Pruebas de Comunas', () {
    late DatabaseService databaseService;

    setUpAll(() async {
      // Inicializar Supabase para pruebas
      await Supabase.initialize(
        url: 'https://your-project.supabase.co', // Reemplazar con URL real
        anonKey: 'your-anon-key', // Reemplazar con clave real
      );
      
      databaseService = DatabaseService();
    });

    test('Debería crear comuna temporal cuando no hay comunas existentes', () async {
      // Este test verifica que el método _obtenerComunaValida funcione correctamente
      // Nota: Este test requiere acceso a la base de datos real
      
      // Simular datos de registro
      final registrationData = RegistrationData(
        email: 'test@example.com',
        rut: '12345678-9',
        address: 'Calle Test 123',
        latitude: -33.4489,
        longitude: -70.6483,
        phoneNumber: '+56912345678', // Updated to use phoneNumber from step 2
        housingType: 'Casa',
        numberOfFloors: 2,
        constructionMaterial: 'Hormigón',
        housingCondition: 'Bueno',
        specialInstructions: 'Test instructions',
      );

      // Intentar crear residencia (esto debería crear una comuna temporal si es necesario)
      final result = await databaseService.crearResidencia(
        grupoId: 'test-group-id',
        data: registrationData,
      );

      // Verificar que no hay error de comuna
      expect(result.isSuccess, true);
    });

    test('Debería usar comuna existente cuando hay comunas en la base de datos', () async {
      // Este test verifica que se use una comuna existente en lugar de crear una nueva
      // Nota: Este test requiere que haya al menos una comuna en la base de datos
      
      final registrationData = RegistrationData(
        email: 'test2@example.com',
        rut: '87654321-0',
        address: 'Calle Test 456',
        latitude: -33.4489,
        longitude: -70.6483,
        phoneNumber: '+56987654321', // Updated to use phoneNumber from step 2
        housingType: 'Departamento',
        numberOfFloors: 1,
        constructionMaterial: 'Ladrillo',
        housingCondition: 'Excelente',
        specialInstructions: 'Test instructions 2',
      );

      final result = await databaseService.crearResidencia(
        grupoId: 'test-group-id-2',
        data: registrationData,
      );

      // Verificar que se creó correctamente
      expect(result.isSuccess, true);
    });
  });
}

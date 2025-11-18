import 'package:flutter_test/flutter_test.dart';
import 'package:bomberos/models/bombero.dart';

void main() {
  group('Modelo Bombero', () {
    test('debería crear instancia correctamente', () {
      final bombero = Bombero(
        rutNum: 12345678,
        rutDv: '9',
        compania: 'Primera Compañía',
        nombBombero: 'Juan',
        apePBombero: 'Pérez',
        emailB: 'juan@test.com',
        cutCom: 13101,
      );

      expect(bombero.rutNum, 12345678);
      expect(bombero.rutDv, '9');
      expect(bombero.compania, 'Primera Compañía');
      expect(bombero.nombBombero, 'Juan');
      expect(bombero.apePBombero, 'Pérez');
      expect(bombero.emailB, 'juan@test.com');
      expect(bombero.cutCom, 13101);
    });

    test('debería convertir a JSON correctamente', () {
      final bombero = Bombero(
        rutNum: 12345678,
        rutDv: '9',
        compania: 'Primera Compañía',
        nombBombero: 'Juan',
        apePBombero: 'Pérez',
        emailB: 'juan@test.com',
        cutCom: 13101,
      );

      final json = bombero.toJson();

      expect(json['rut_num'], 12345678);
      expect(json['rut_dv'], '9');
      expect(json['compania'], 'Primera Compañía');
      expect(json['nomb_bombero'], 'Juan');
      expect(json['ape_p_bombero'], 'Pérez');
      expect(json['email_b'], 'juan@test.com');
      expect(json['cut_com'], 13101);
    });

    test('debería crear desde JSON correctamente', () {
      final json = {
        'rut_num': 12345678,
        'rut_dv': '9',
        'compania': 'Primera Compañía',
        'nomb_bombero': 'Juan',
        'ape_p_bombero': 'Pérez',
        'email_b': 'juan@test.com',
        'cut_com': 13101,
      };

      final bombero = Bombero.fromJson(json);

      expect(bombero.rutNum, 12345678);
      expect(bombero.rutDv, '9');
      expect(bombero.compania, 'Primera Compañía');
      expect(bombero.nombBombero, 'Juan');
      expect(bombero.apePBombero, 'Pérez');
      expect(bombero.emailB, 'juan@test.com');
      expect(bombero.cutCom, 13101);
    });

    test('debería crear copia con copyWith', () {
      final bombero = Bombero(
        rutNum: 12345678,
        rutDv: '9',
        compania: 'Primera Compañía',
        nombBombero: 'Juan',
        apePBombero: 'Pérez',
        emailB: 'juan@test.com',
        cutCom: 13101,
      );

      final copia = bombero.copyWith(nombBombero: 'Carlos');

      expect(copia.nombBombero, 'Carlos');
      expect(copia.rutNum, bombero.rutNum); // Otros campos iguales
      expect(copia.emailB, bombero.emailB);
      expect(copia.compania, bombero.compania);
    });

    test('debería formatear RUT correctamente', () {
      final bombero = Bombero(
        rutNum: 12345678,
        rutDv: '9',
        compania: 'Primera Compañía',
        nombBombero: 'Juan',
        apePBombero: 'Pérez',
        emailB: 'juan@test.com',
        cutCom: 13101,
      );

      final rutCompleto = bombero.rutCompleto;
      expect(rutCompleto, '12.345.678-9');
    });

    test('debería crear desde RUT completo', () {
      final bombero = Bombero.fromRutCompleto('12.345.678-9', 'Primera Compañía', email: 'test@test.com');

      expect(bombero.rutNum, 12345678);
      expect(bombero.rutDv, '9');
      expect(bombero.compania, 'Primera Compañía');
    });
  });
}


import 'package:flutter/foundation.dart';
import 'search_service.dart';
import 'supabase_auth_service.dart';

/// Servicio para manejar la lógica de negocio de la pantalla de detalles
/// Aplicando principio de responsabilidad única (SRP)
class AddressDetailService {
  final SearchService _searchService = SearchService();
  final SupabaseAuthService _authService = SupabaseAuthService();

  /// Carga los detalles completos de una residencia
  Future<Map<String, dynamic>?> loadDetailedData(int residenceId) async {
    try {
      final result = await _searchService.getResidenceDetails(residenceId);
      if (result.isSuccess) {
        return result.data;
      } else {
        debugPrint('Error cargando detalles de residencia: ${result.error}');
        return null;
      }
    } catch (e) {
      debugPrint('Error cargando detalles de residencia: $e');
      return null;
    }
  }

  /// Obtiene el nombre del usuario actual
  String? getCurrentUserName() {
    final currentUser = _authService.currentUser;
    if (currentUser?.email != null) {
      return _extractNameFromEmail(currentUser!.email!);
    }
    return null;
  }

  /// Extrae el nombre del email del usuario
  String _extractNameFromEmail(String email) {
    final emailPart = email.split('@')[0];
    final namePart = emailPart.replaceAll(RegExp(r'[._]'), ' ');
    final words = namePart.split(' ');
    return words.map((word) => word.isNotEmpty 
        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
        : '').join(' ');
  }

  /// Calcula el número de integrantes con condiciones médicas
  int calculateMembersWithConditions(List<Map<String, dynamic>> integrantes) {
    return integrantes.where((i) {
      final padecimiento = i['padecimiento'] as String?;
      return padecimiento != null && padecimiento.isNotEmpty;
    }).length;
  }

  /// Extrae las condiciones médicas de un integrante
  List<String> extractMedicalConditions(Map<String, dynamic> integrante) {
    final padecimiento = integrante['padecimiento'] as String?;
    if (padecimiento == null || padecimiento.isEmpty) {
      return [];
    }
    return padecimiento.split(',').map((e) => e.trim()).toList();
  }

  /// Valida si los datos de la residencia son válidos
  bool isValidResidenceData(Map<String, dynamic> data) {
    return data.containsKey('id_residencia') && 
           data['id_residencia'] != null;
  }
}

import 'package:flutter/foundation.dart';
import '../../../models/models.dart';
import '../../../services/database_service.dart';

/// Controlador para manejar la lógica de integrantes familiares
/// Sigue principios SOLID y patrón MVC
/// 
/// Responsabilidades:
/// - Manejar estado de integrantes familiares
/// - Coordinar operaciones CRUD
/// - Validar datos antes de operaciones
/// - Notificar cambios de estado
/// 
/// Principios aplicados:
/// - Single Responsibility: Solo maneja lógica de familia
/// - Open/Closed: Extensible sin modificar código existente
/// - Dependency Inversion: Depende de abstracciones
class FamilyController extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<FamilyMember> _familyMembers = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _userEmail;

  // Getters
  List<FamilyMember> get familyMembers => List.unmodifiable(_familyMembers);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get memberCount => _familyMembers.length;

  /// Inicializa el controlador
  Future<void> initialize(String userEmail) async {
    _userEmail = userEmail;
    await loadFamilyMembers();
  }

  /// Carga los integrantes familiares
  Future<void> loadFamilyMembers() async {
    if (_userEmail == null) {
      _setError('Email de usuario no disponible');
      return;
    }

    try {
      _setLoading(true);
      _clearError();

      // Obtener grupo familiar
      final grupoResult = await _databaseService.obtenerGrupoFamiliar(email: _userEmail!);
      if (!grupoResult.isSuccess) {
        _setError('Error al obtener grupo familiar: ${grupoResult.error}');
        return;
      }

      final grupo = grupoResult.data!;

      // Obtener integrantes
      final integrantesResult = await _databaseService.obtenerIntegrantes(
        grupoId: grupo.idGrupoF.toString(),
      );

      if (integrantesResult.isSuccess) {
        final integrantes = integrantesResult.data ?? [];
        _familyMembers = integrantes
            .map((i) => i.toFamilyMember())
            .where((member) => member != null)
            .cast<FamilyMember>()
            .toList();
        
        debugPrint('✅ Integrantes familiares cargados: ${_familyMembers.length}');
      } else {
        _setError('Error al cargar integrantes: ${integrantesResult.error}');
      }
    } catch (e) {
      _setError('Error inesperado: ${e.toString()}');
      debugPrint('❌ Error al cargar integrantes familiares: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Agrega un nuevo integrante familiar
  Future<bool> addFamilyMember(FamilyMember member) async {
    if (_userEmail == null) {
      _setError('Email de usuario no disponible');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      // Obtener grupo familiar
      final grupoResult = await _databaseService.obtenerGrupoFamiliar(email: _userEmail!);
      if (!grupoResult.isSuccess) {
        _setError('Error al obtener grupo familiar: ${grupoResult.error}');
        return false;
      }

      final grupo = grupoResult.data!;

      // Agregar integrante
      final result = await _databaseService.agregarIntegrante(
        grupoId: grupo.idGrupoF.toString(),
        rut: member.rut,
        edad: member.age,
        anioNac: member.birthYear,
        padecimiento: member.conditions.isNotEmpty ? member.conditions.join(', ') : null,
      );

      if (result.isSuccess) {
        // Recargar datos
        await loadFamilyMembers();
        debugPrint('✅ Integrante agregado exitosamente');
        return true;
      } else {
        _setError('Error al agregar integrante: ${result.error}');
        return false;
      }
    } catch (e) {
      _setError('Error inesperado: ${e.toString()}');
      debugPrint('❌ Error al agregar integrante: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Edita un integrante familiar existente
  Future<bool> editFamilyMember(int index, FamilyMember member) async {
    if (_userEmail == null) {
      _setError('Email de usuario no disponible');
      return false;
    }

    if (index < 0 || index >= _familyMembers.length) {
      _setError('Índice de integrante inválido');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      // Obtener grupo familiar
      final grupoResult = await _databaseService.obtenerGrupoFamiliar(email: _userEmail!);
      if (!grupoResult.isSuccess) {
        _setError('Error al obtener grupo familiar: ${grupoResult.error}');
        return false;
      }

      final grupo = grupoResult.data!;

      // Obtener integrantes para encontrar el ID
      final integrantesResult = await _databaseService.obtenerIntegrantes(
        grupoId: grupo.idGrupoF.toString(),
      );

      if (!integrantesResult.isSuccess || integrantesResult.data == null) {
        _setError('Error al obtener integrantes: ${integrantesResult.error}');
        return false;
      }

      final integrantes = integrantesResult.data!;
      if (index >= integrantes.length) {
        _setError('Índice de integrante fuera de rango');
        return false;
      }

      final integrante = integrantes[index];
      final updates = {
        'anio_nac': member.birthYear,
        'padecimiento': member.conditions.isNotEmpty ? member.conditions.join(', ') : null,
      };

      // Actualizar integrante
      final result = await _databaseService.actualizarIntegrante(
        integranteId: integrante.idIntegrante.toString(),
        updates: updates,
      );

      if (result.isSuccess) {
        // Recargar datos
        await loadFamilyMembers();
        debugPrint('✅ Integrante actualizado exitosamente');
        return true;
      } else {
        _setError('Error al actualizar integrante: ${result.error}');
        return false;
      }
    } catch (e) {
      _setError('Error inesperado: ${e.toString()}');
      debugPrint('❌ Error al actualizar integrante: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Elimina un integrante familiar
  Future<bool> deleteFamilyMember(int index) async {
    if (_userEmail == null) {
      _setError('Email de usuario no disponible');
      return false;
    }

    if (index < 0 || index >= _familyMembers.length) {
      _setError('Índice de integrante inválido');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      // Obtener grupo familiar
      final grupoResult = await _databaseService.obtenerGrupoFamiliar(email: _userEmail!);
      if (!grupoResult.isSuccess) {
        _setError('Error al obtener grupo familiar: ${grupoResult.error}');
        return false;
      }

      final grupo = grupoResult.data!;

      // Obtener integrantes para encontrar el ID
      final integrantesResult = await _databaseService.obtenerIntegrantes(
        grupoId: grupo.idGrupoF.toString(),
      );

      if (!integrantesResult.isSuccess || integrantesResult.data == null) {
        _setError('Error al obtener integrantes: ${integrantesResult.error}');
        return false;
      }

      final integrantes = integrantesResult.data!;
      if (index >= integrantes.length) {
        _setError('Índice de integrante fuera de rango');
        return false;
      }

      final integrante = integrantes[index];

      // Eliminar integrante
      final result = await _databaseService.eliminarIntegrante(
        integranteId: integrante.idIntegrante.toString(),
      );

      if (result.isSuccess) {
        // Recargar datos
        await loadFamilyMembers();
        debugPrint('✅ Integrante eliminado exitosamente');
        return true;
      } else {
        _setError('Error al eliminar integrante: ${result.error}');
        return false;
      }
    } catch (e) {
      _setError('Error inesperado: ${e.toString()}');
      debugPrint('❌ Error al eliminar integrante: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Valida un integrante familiar
  bool validateFamilyMember(FamilyMember member) {
    if (member.rut.isEmpty) {
      _setError('El RUT es obligatorio');
      return false;
    }

    if (member.age < 0 || member.age > 120) {
      _setError('La edad debe estar entre 0 y 120 años');
      return false;
    }

    if (member.birthYear < 1900 || member.birthYear > DateTime.now().year) {
      _setError('El año de nacimiento no es válido');
      return false;
    }

    _clearError();
    return true;
  }

  /// Limpia el error actual
  void clearError() {
    _clearError();
  }

  /// Recarga los datos
  Future<void> refresh() async {
    await loadFamilyMembers();
  }

  /// Cierra sesión
  Future<void> logout() async {
    _familyMembers.clear();
    _userEmail = null;
    _clearError();
    _setLoading(false);
  }

  // ============================================
  // MÉTODOS PRIVADOS
  // ============================================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

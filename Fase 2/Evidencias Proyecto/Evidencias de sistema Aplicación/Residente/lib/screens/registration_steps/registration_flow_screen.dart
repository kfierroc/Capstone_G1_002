import 'package:flutter/material.dart';
import '../../models/registration_data.dart';
import '../../utils/app_styles.dart';
import '../../services/unified_auth_service.dart';
import '../../services/database_service.dart' as db;
import '../home/resident_home.dart';
import 'step2_holder_data.dart';
import 'step3_residence_info.dart';
import 'step4_housing_details.dart';

/// Flujo principal de registro reorganizado con verificación de correo
class RegistrationFlowScreen extends StatefulWidget {
  final String email;
  final String password;

  const RegistrationFlowScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<RegistrationFlowScreen> createState() => _RegistrationFlowScreenState();
}

class _RegistrationFlowScreenState extends State<RegistrationFlowScreen> {
  final RegistrationData _registrationData = RegistrationData();
  final UnifiedAuthService _authService = UnifiedAuthService();
  final db.DatabaseService _databaseService = db.DatabaseService();
  
  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _stepTitles = [
    'Datos del Titular',
    'Información de la Residencia',
    'Detalles de la Vivienda',
  ];

  @override
  void initState() {
    super.initState();
    // Inicializar datos básicos
    _registrationData.email = widget.email;
    _registrationData.password = widget.password;
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _completeRegistration() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Verificar si el usuario está autenticado, si no, iniciar sesión
      if (!_authService.isAuthenticated) {
        debugPrint('🔐 Usuario no autenticado, iniciando sesión...');
        final signInResult = await _authService.signInWithPassword(
          email: widget.email,
          password: widget.password,
        );
        
        if (!signInResult.isSuccess) {
          debugPrint('❌ Error al iniciar sesión: ${signInResult.error}');
          setState(() {
            _errorMessage = 'Error al iniciar sesión: ${signInResult.error}';
            _isLoading = false;
          });
          return;
        }
        debugPrint('✅ Sesión iniciada exitosamente');
      }

      // 2. Crear el grupo familiar y residencia
      final userId = _authService.currentUser?.id ?? '';
      if (userId.isEmpty) {
        setState(() {
          _errorMessage = 'No se pudo obtener el ID del usuario';
          _isLoading = false;
        });
        return;
      }

      debugPrint('📝 Creando grupo familiar para usuario: $userId');
      final result = await _databaseService.crearGrupoFamiliar(
        userId: userId,
        data: _registrationData,
      );

      if (result.isSuccess) {
        debugPrint('✅ Grupo familiar creado exitosamente');
        // Verificar que la sesión sigue activa antes de navegar
        if (_authService.isAuthenticated) {
          debugPrint('✅ Usuario autenticado, navegando a home');
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => ResidentHomeScreen(
                  registrationData: _registrationData,
                ),
              ),
              (route) => false,
            );
          }
        } else {
          debugPrint('⚠️ Sesión perdida después de crear grupo familiar');
          setState(() {
            _errorMessage = 'La sesión se perdió. Por favor, inicia sesión manualmente.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = result.message ?? 'Error al completar el registro';
        });
      }
    } catch (e) {
      debugPrint('❌ Error en _completeRegistration: $e');
      setState(() {
        _errorMessage = 'Error inesperado: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return Step2HolderData(
          registrationData: _registrationData,
          onNext: _nextStep,
          onPrevious: () {},
        );
      case 1:
        return Step3ResidenceInfo(
          registrationData: _registrationData,
          onNext: _nextStep,
          onPrevious: _previousStep,
        );
      case 2:
        return Step4HousingDetails(
          registrationData: _registrationData,
          onPrevious: _previousStep,
          onComplete: _completeRegistration,
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
        title: Text(
          'Paso ${_currentStep + 1} de ${_stepTitles.length}',
          style: AppTextStyles.heading3,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Indicador de progreso
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
            child: Column(
              children: [
                // Barra de progreso
                LinearProgressIndicator(
                  value: (_currentStep + 1) / _stepTitles.length,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 8,
                ),
                const SizedBox(height: AppSpacing.md),
                // Título del paso actual
                Text(
                  _stepTitles[_currentStep],
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Contenido del paso actual
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: _buildCurrentStep(),
            ),
          ),

          // Error message
          if (_errorMessage != null)
            Container(
              margin: const EdgeInsets.all(AppSpacing.xl),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.error),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

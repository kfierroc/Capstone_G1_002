import 'package:flutter/material.dart';
import '../../models/registration_data.dart';
import '../../services/unified_auth_service.dart';
import '../../services/database_service.dart';
import '../registration_steps/step1_create_account.dart';
import '../registration_steps/step2_holder_data.dart';
import '../registration_steps/step3_residence_info.dart';
import '../registration_steps/step4_housing_details.dart';
import '../home/resident_home.dart';

class RegisterWizardScreen extends StatefulWidget {
  const RegisterWizardScreen({super.key});

  @override
  State<RegisterWizardScreen> createState() => _RegisterWizardScreenState();
}

class _RegisterWizardScreenState extends State<RegisterWizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final RegistrationData _registrationData = RegistrationData();

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeRegistration() async {
    try {
      // Mostrar loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Creando cuenta...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // 1. Registrar usuario en Supabase Auth y crear grupo familiar
      debugPrint('🔐 Iniciando registro de usuario...');
      debugPrint('📧 Email: ${_registrationData.email}');
      
      final authService = UnifiedAuthService();
      
      // Verificar si ya existe una sesión activa
      if (authService.isAuthenticated) {
        debugPrint('⚠️ Ya hay una sesión activa, cerrando sesión anterior...');
        await authService.signOut();
        // Esperar un momento para que se procese el cierre de sesión
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      final authResult = await authService.signUpGrupoFamiliar(
        email: _registrationData.email ?? '',
        password: _registrationData.password ?? '',
        rutTitular: _registrationData.rut ?? 'Sin RUT',
      );

      debugPrint('✅ Resultado de autenticación: ${authResult.isSuccess}');
      if (authResult.isSuccess) {
        debugPrint('👤 Usuario creado: ${authResult.data?.id}');
        debugPrint('👥 Grupo familiar creado: ${authResult.data?.grupoFamiliar?.idGrupof}');
      } else {
        debugPrint('❌ Error de autenticación: ${authResult.error}');
      }

      if (!authResult.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al crear cuenta: ${authResult.error}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      // 2. Crear residencia y registro_v
      debugPrint('📝 Creando residencia y registro_v...');
      final databaseService = DatabaseService();
      final residenciaResult = await databaseService.crearResidencia(
        grupoId: authResult.data!.grupoFamiliar!.idGrupof.toString(),
        data: _registrationData,
      );

      if (!residenciaResult.isSuccess) {
        debugPrint('❌ Error al crear residencia: ${residenciaResult.error}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al crear residencia: ${residenciaResult.error}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      debugPrint('✅ Residencia y registro_v creados exitosamente');

      // 3. Crear integrante titular (el usuario que se registra)
      debugPrint('👤 Creando integrante titular...');
      final integranteResult = await databaseService.agregarIntegrante(
        grupoId: authResult.data!.grupoFamiliar!.idGrupof.toString(),
        rut: _registrationData.rut ?? 'Sin RUT', // Usar RUT del titular
        edad: _registrationData.age ?? 25, // Edad por defecto si no se especifica
        anioNac: _registrationData.birthYear ?? DateTime.now().year - 25, // Año de nacimiento calculado
        padecimiento: null, // Sin padecimientos por defecto
      );

      if (integranteResult.isSuccess) {
        debugPrint('✅ Integrante titular creado exitosamente');
      } else {
        debugPrint('⚠️ Error al crear integrante titular: ${integranteResult.error}');
        // No es crítico, continuar con el registro
      }

      debugPrint('🎉 Registro completado exitosamente');

      // 3. Navegar al home después del registro exitoso
      if (!mounted) return;
      
      debugPrint('🏠 Navegando al home...');
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) =>
              ResidentHomeScreen(registrationData: _registrationData),
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint('💥 Error inesperado durante el registro: $e');
      debugPrint('📍 Stack trace: ${StackTrace.current}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Configuración inicial', style: TextStyle(fontSize: 16)),
            Text(
              'Configura la información de tu domicilio',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Indicador de pasos
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isActive = index == _currentStep;
                final isCompleted = index < _currentStep;

                return Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green.shade600
                            : isActive
                            ? Colors.green.shade700
                            : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    if (index < 3)
                      Container(
                        width: 40,
                        height: 2,
                        color: isCompleted
                            ? Colors.green.shade600
                            : Colors.grey.shade300,
                      ),
                  ],
                );
              }),
            ),
          ),

          // Contenido de los pasos
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Step1CreateAccount(
                  registrationData: _registrationData,
                  onNext: _nextStep,
                ),
                Step2HolderData(
                  registrationData: _registrationData,
                  onNext: _nextStep,
                  onPrevious: _previousStep,
                ),
                Step3ResidenceInfo(
                  registrationData: _registrationData,
                  onNext: _nextStep,
                  onPrevious: _previousStep,
                ),
                Step4HousingDetails(
                  registrationData: _registrationData,
                  onPrevious: _previousStep,
                  onComplete: _completeRegistration,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

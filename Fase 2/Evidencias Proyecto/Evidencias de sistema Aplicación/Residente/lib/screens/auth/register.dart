import 'package:flutter/material.dart';
import '../../models/registration_data.dart';
import '../../services/auth_service.dart';
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

      // 1. Registrar usuario en Supabase Auth
      print('🔐 Iniciando registro de usuario...');
      print('📧 Email: ${_registrationData.email}');
      
      final authService = AuthService();
      final authResult = await authService.signUp(
        email: _registrationData.email ?? '',
        password: _registrationData.password ?? '',
        metadata: {'name': _registrationData.fullName ?? 'Residente'},
      );

      print('✅ Resultado de autenticación: ${authResult.isSuccess}');
      if (authResult.isSuccess) {
        print('👤 Usuario creado: ${authResult.user?.id}');
      } else {
        print('❌ Error de autenticación: ${authResult.error}');
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

      // 2. Crear grupo familiar en la base de datos
      print('📝 Creando grupo familiar en base de datos...');
      print('👤 User ID: ${authResult.user!.id}');
      print('📍 Dirección: ${_registrationData.address}');
      
      final databaseService = DatabaseService();
      final grupoResult = await databaseService.crearGrupoFamiliar(
        userId: authResult.user!.id, // Aunque no se use en la BD, lo mantenemos para compatibilidad
        data: _registrationData,
      );

      print('✅ Resultado de creación de grupo: ${grupoResult.isSuccess}');
      if (!grupoResult.isSuccess) {
        print('❌ Error al crear grupo: ${grupoResult.error}');
      }

      if (!grupoResult.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al crear perfil: ${grupoResult.error}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      print('🎉 Registro completado exitosamente');

      // 3. Navegar al home después del registro exitoso
      if (!mounted) return;
      
      print('🏠 Navegando al home...');
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) =>
              ResidentHomeScreen(registrationData: _registrationData),
        ),
        (route) => false,
      );
    } catch (e) {
      print('💥 Error inesperado durante el registro: $e');
      print('📍 Stack trace: ${StackTrace.current}');
      
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

import 'package:flutter/material.dart';
import '../../models/registration_data.dart';
import '../../services/mock_auth_service.dart';
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
    // Registrar usuario con el servicio mock
    final mockAuth = MockAuthService();
    await mockAuth.signUp(
      email: _registrationData.email ?? '',
      password: _registrationData.password ?? '',
      name: 'Residente',
    );
    
    // Aquí iría la lógica para guardar en Supabase
    // Navegar al home después del registro exitoso
    if (!mounted) return;
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) =>
            ResidentHomeScreen(registrationData: _registrationData),
      ),
      (route) => false,
    );
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
